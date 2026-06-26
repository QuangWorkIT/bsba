package com.be.bsba.serviceImpl;

import com.be.bsba.constant.MessageType;
import com.be.bsba.constant.SenderType;
import com.be.bsba.constant.UserRole;
import com.be.bsba.dto.request.SendMessageRequest;
import com.be.bsba.dto.request.StartConversationRequest;
import com.be.bsba.dto.response.ConversationResponse;
import com.be.bsba.dto.response.MessageResponse;
import com.be.bsba.entity.Conversation;
import com.be.bsba.entity.Message;
import com.be.bsba.entity.Store;
import com.be.bsba.entity.User;
import com.be.bsba.exception.BadRequestException;
import com.be.bsba.exception.ResourceNotFoundException;
import com.be.bsba.repository.ConversationRepository;
import com.be.bsba.repository.MessageRepository;
import com.be.bsba.repository.StoreRepository;
import com.be.bsba.repository.StoreStaffRepository;
import com.be.bsba.repository.UserRepository;
import com.be.bsba.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final StoreRepository storeRepository;
    private final StoreStaffRepository storeStaffRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    @Transactional(readOnly = true)
    public Page<ConversationResponse> getConversations(UUID userId, UserRole role, Pageable pageable) {
        Page<Conversation> conversations;
        boolean staffView;

        switch (role) {
            case ADMIN -> {
                // Admin oversees every store's threads.
                conversations = conversationRepository.findAllOrderByLastMessageAtDesc(pageable);
                staffView = true;
            }
            case STAFF -> {
                // Staff only see threads of the stores they're assigned to.
                List<UUID> storeIds = storeStaffRepository.findStoreIdsByStaffId(userId);
                if (storeIds.isEmpty()) {
                    return Page.empty(pageable);
                }
                conversations = conversationRepository.findByStoreIdInOrderByLastMessageAtDesc(storeIds, pageable);
                staffView = true;
            }
            default -> {
                // Customer sees only their own threads.
                conversations = conversationRepository.findByUserIdOrderByLastMessageAtDesc(userId, pageable);
                staffView = false;
            }
        }

        return conversations.map(conversation -> mapToConversationResponse(conversation, staffView));
    }

    @Override
    @Transactional(readOnly = true)
    public long getUnreadCount(UUID userId, UserRole role) {
        if (role == UserRole.ADMIN) {
            return messageRepository.countUnreadConversationsAll(SenderType.CUSTOMER);
        }
        if (role == UserRole.STAFF) {
            List<UUID> storeIds = storeStaffRepository.findStoreIdsByStaffId(userId);
            if (storeIds.isEmpty()) {
                return 0;
            }
            return messageRepository.countUnreadConversationsForStores(storeIds, SenderType.CUSTOMER);
        }
        return messageRepository.countUnreadConversationsForCustomer(userId, SenderType.STAFF);
    }

    @Override
    @Transactional
    public ConversationResponse startConversation(UUID userId, UserRole role, StartConversationRequest request) {
        // Only customers initiate a thread with a store; staff/admin reply but never start one.
        // Guards against accidentally creating a conversation that treats a staff member as the customer.
        if (role != UserRole.CUSTOMER) {
            throw new BadRequestException("Only customers can start a conversation");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "User not found with id: " + userId));

        UUID storeId = request.getStoreId();
        Store store = storeRepository.findById(storeId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Store not found with id: " + storeId));

        // One thread per (customer, store): return the existing one or create it.
        Conversation conversation = conversationRepository
                .findByUserIdAndStoreId(userId, storeId)
                .orElseGet(() -> conversationRepository.save(
                        Conversation.builder()
                                .user(user)
                                .store(store)
                                .build()));

        return mapToConversationResponse(conversation, false);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<MessageResponse> getMessages(UUID conversationId, UUID userId, UserRole role, Pageable pageable) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Conversation not found with id: " + conversationId));

        // Only the thread's customer, an assigned staff, or an admin may read it.
        authorizeConversationAccess(conversation, userId, role);

        return messageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageable)
                .map(this::mapToResponse);
    }

    // Authorize a caller to view/act on a conversation:
    //   admin    → any conversation
    //   staff    → only conversations of a store they're assigned to
    //   customer → only their own thread
    private void authorizeConversationAccess(Conversation conversation, UUID userId, UserRole role) {
        if (role == UserRole.ADMIN) {
            return;
        }
        if (role == UserRole.STAFF) {
            UUID storeId = conversation.getStore() != null ? conversation.getStore().getId() : null;
            if (storeId == null || !storeStaffRepository.existsByStoreIdAndStaffId(storeId, userId)) {
                throw new BadRequestException("Staff is not assigned to this conversation's store");
            }
            return;
        }
        // CUSTOMER: must own the conversation.
        UUID ownerId = conversation.getUser() != null ? conversation.getUser().getId() : null;
        if (ownerId == null || !ownerId.equals(userId)) {
            throw new BadRequestException("You do not have access to this conversation");
        }
    }

    @Override
    @Transactional
    public void markConversationRead(UUID conversationId, UUID userId, UserRole role) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Conversation not found with id: " + conversationId));

        // The customer who owns the thread, an assigned staff, or an admin may act on it.
        authorizeConversationAccess(conversation, userId, role);

        // Mark the other party's messages as read: a customer reads staff messages, staff read customer messages.
        SenderType target = role == UserRole.CUSTOMER ? SenderType.STAFF : SenderType.CUSTOMER;
        int updated = messageRepository.markRead(conversationId, target);

        // Nothing was unread -> no inbox change to push.
        if (updated == 0) {
            return;
        }

        // The bulk update cleared the persistence context; re-load to map lazy fields safely.
        Conversation refreshed = conversationRepository.findById(conversationId).orElse(conversation);

        // Build the payloads now (while the session is open), then push only after the
        // transaction commits, so a rollback can't leave clients showing a "read" state
        // the database never saved.
        List<Broadcast> broadcasts = new ArrayList<>();
        // Live read receipt: tell anyone with this chat open that messages from
        // `target` were just read, so their "seen" indicator updates instantly.
        broadcasts.add(new Broadcast(
                "/topic/conversations/" + conversationId + "/read",
                Map.of("readSenderType", target.name())));
        broadcasts.addAll(collectConversationRowBroadcasts(refreshed));

        publishAfterCommit(broadcasts);
    }

    @Override
    @Transactional
    public MessageResponse sendMessage(UUID conversationId, UUID userId, UserRole role, SendMessageRequest request) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Conversation not found with id: " + conversationId));

        User sender = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "User not found with id: " + userId));

        // The customer who owns the thread, an assigned staff, or an admin may reply.
        authorizeConversationAccess(conversation, userId, role);

        // A customer speaks as CUSTOMER; staff/admin both reply as STAFF in the thread.
        SenderType senderType = role == UserRole.CUSTOMER ? SenderType.CUSTOMER : SenderType.STAFF;

        MessageType type = request.getType() != null ? request.getType() : MessageType.TEXT;

        Message message = Message.builder()
                .conversation(conversation)
                .sender(sender)
                .senderType(senderType)
                .content(request.getContent())
                .type(type)
                .isRead(false)
                .build();

        // Flush so Hibernate runs the INSERT now and populates the
        // @CreationTimestamp; otherwise createdAt stays null until commit and
        // the POST response / socket broadcast would ship a message with no time.
        Message savedMessage = messageRepository.saveAndFlush(message);

        // Keep the denormalized inbox-preview fields in sync.
        conversation.setLastMessagePreview(savedMessage.getContent());
        conversation.setLastMessageAt(savedMessage.getCreatedAt());
        conversationRepository.save(conversation);

        // Build the broadcast payloads now (DB/lazy access happens here), but defer the
        // actual STOMP push until the transaction commits — otherwise a rollback after
        // this point would leave clients showing a message the DB never stored.
        publishAfterCommit(collectNewMessageBroadcasts(conversation, savedMessage));

        return mapToResponse(savedMessage);
    }

    // A single STOMP message to send: where it goes and what payload.
    private record Broadcast(String destination, Object payload) {}

    // Collect the new-message broadcast + inbox-row updates for everyone involved.
    // Builds payloads eagerly (DB/lazy access happens here, inside the transaction).
    private List<Broadcast> collectNewMessageBroadcasts(Conversation conversation, Message message) {
        List<Broadcast> broadcasts = new ArrayList<>();
        // Anyone with this chat open receives the new message.
        broadcasts.add(new Broadcast(
                "/topic/conversations/" + conversation.getId() + "/messages",
                mapToResponse(message)));
        broadcasts.addAll(collectConversationRowBroadcasts(conversation));
        return broadcasts;
    }

    // Collect the (perspective-correct) inbox row for the customer and every store staff,
    // so unread counts / previews update live on each side's inbox.
    private List<Broadcast> collectConversationRowBroadcasts(Conversation conversation) {
        List<Broadcast> broadcasts = new ArrayList<>();
        User customer = conversation.getUser();
        Store store = conversation.getStore();

        // The customer's inbox row (their unread perspective).
        if (customer != null) {
            broadcasts.add(new Broadcast(
                    "/topic/users/" + customer.getId() + "/conversations",
                    mapToConversationResponse(conversation, false)));
        }

        // Every staff member of the store gets the row in their (staff) perspective.
        if (store != null) {
            ConversationResponse staffView = mapToConversationResponse(conversation, true);
            for (UUID staffId : storeStaffRepository.findStaffIdsByStoreId(store.getId())) {
                broadcasts.add(new Broadcast(
                        "/topic/users/" + staffId + "/conversations",
                        staffView));
            }
        }
        return broadcasts;
    }

    // Push the collected STOMP messages only after the current transaction commits, so
    // clients never receive an update that a later rollback would erase. If there is no
    // active transaction (shouldn't happen here), send immediately.
    private void publishAfterCommit(List<Broadcast> broadcasts) {
        Runnable send = () -> broadcasts.forEach(
                b -> messagingTemplate.convertAndSend(b.destination(), b.payload()));

        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    send.run();
                }
            });
        } else {
            send.run();
        }
    }

    private ConversationResponse mapToConversationResponse(Conversation conversation, boolean isStaff) {
        // Staff count unread customer messages; a customer counts unread staff/system messages.
        long unreadCount = isStaff
                ? messageRepository.countByConversationIdAndIsReadFalseAndSenderType(
                        conversation.getId(), SenderType.CUSTOMER)
                : messageRepository.countByConversationIdAndIsReadFalseAndSenderTypeNot(
                        conversation.getId(), SenderType.CUSTOMER);

        Store store = conversation.getStore();
        User customer = conversation.getUser();

        List<UUID> staffUserIds = store != null
                ? storeStaffRepository.findStaffIdsByStoreId(store.getId())
                : List.of();

        return ConversationResponse.builder()
                .id(conversation.getId())
                .storeId(store != null ? store.getId() : null)
                .storeName(store != null ? store.getName() : null)
                .storeCoverImageUrl(store != null ? store.getCoverImageUrl() : null)
                .customerId(customer != null ? customer.getId() : null)
                .customerName(customer != null ? customer.getFullName() : null)
                .customerAvatarUrl(customer != null ? customer.getAvatarUrl() : null)
                .lastMessagePreview(conversation.getLastMessagePreview())
                .lastMessageAt(conversation.getLastMessageAt())
                .unreadCount(unreadCount)
                .staffUserIds(staffUserIds)
                .createdAt(conversation.getCreatedAt())
                .updatedAt(conversation.getUpdatedAt())
                .build();
    }

    private MessageResponse mapToResponse(Message message) {
        return MessageResponse.builder()
                .id(message.getId())
                .conversationId(message.getConversation().getId())
                .senderId(message.getSender() != null ? message.getSender().getId() : null)
                .senderType(message.getSenderType())
                .content(message.getContent())
                .type(message.getType())
                .isRead(message.getIsRead())
                .createdAt(message.getCreatedAt())
                .build();
    }
}
