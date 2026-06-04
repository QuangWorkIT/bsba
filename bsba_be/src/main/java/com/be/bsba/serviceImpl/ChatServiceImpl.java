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

import java.util.List;
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
    public ConversationResponse startConversation(UUID userId, StartConversationRequest request) {
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
    public Page<MessageResponse> getMessages(UUID conversationId, Pageable pageable) {
        if (!conversationRepository.existsById(conversationId)) {
            throw new ResourceNotFoundException(
                    "Conversation not found with id: " + conversationId);
        }

        return messageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageable)
                .map(this::mapToResponse);
    }

    @Override
    @Transactional
    public void markConversationRead(UUID conversationId, UUID userId, UserRole role) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Conversation not found with id: " + conversationId));

        // A staff member may only act on conversations of a store they're assigned to.
        if (role == UserRole.STAFF) {
            UUID storeId = conversation.getStore() != null ? conversation.getStore().getId() : null;
            if (storeId == null || !storeStaffRepository.existsByStoreIdAndStaffId(storeId, userId)) {
                throw new BadRequestException("Staff is not assigned to this conversation's store");
            }
        }

        // Mark the other party's messages as read: a customer reads staff messages, staff read customer messages.
        SenderType target = role == UserRole.CUSTOMER ? SenderType.STAFF : SenderType.CUSTOMER;
        int updated = messageRepository.markRead(conversationId, target);

        // Nothing was unread -> no inbox change to push.
        if (updated == 0) {
            return;
        }

        // The bulk update cleared the persistence context; re-load to map lazy fields safely.
        Conversation refreshed = conversationRepository.findById(conversationId).orElse(conversation);
        broadcastConversationRow(refreshed);
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

        // A staff member may only reply in conversations of a store they're assigned to.
        if (role == UserRole.STAFF) {
            UUID storeId = conversation.getStore() != null ? conversation.getStore().getId() : null;
            if (storeId == null || !storeStaffRepository.existsByStoreIdAndStaffId(storeId, userId)) {
                throw new BadRequestException("Staff is not assigned to this conversation's store");
            }
        }

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

        Message savedMessage = messageRepository.save(message);

        // Keep the denormalized inbox-preview fields in sync.
        conversation.setLastMessagePreview(savedMessage.getContent());
        conversation.setLastMessageAt(savedMessage.getCreatedAt());
        conversationRepository.save(conversation);

        broadcastNewMessage(conversation, savedMessage);

        return mapToResponse(savedMessage);
    }

    // Push the new message + inbox-row updates to everyone involved over STOMP.
    private void broadcastNewMessage(Conversation conversation, Message message) {
        // Anyone with this chat open receives the new message.
        messagingTemplate.convertAndSend(
                "/topic/conversations/" + conversation.getId() + "/messages",
                mapToResponse(message));

        broadcastConversationRow(conversation);
    }

    // Push the (perspective-correct) inbox row to the customer and every store staff,
    // so unread counts / previews update live on each side's inbox.
    private void broadcastConversationRow(Conversation conversation) {
        User customer = conversation.getUser();
        Store store = conversation.getStore();

        // The customer's inbox row (their unread perspective).
        if (customer != null) {
            messagingTemplate.convertAndSend(
                    "/topic/users/" + customer.getId() + "/conversations",
                    mapToConversationResponse(conversation, false));
        }

        // Every staff member of the store gets the row in their (staff) perspective.
        if (store != null) {
            ConversationResponse staffView = mapToConversationResponse(conversation, true);
            for (UUID staffId : storeStaffRepository.findStaffIdsByStoreId(store.getId())) {
                messagingTemplate.convertAndSend(
                        "/topic/users/" + staffId + "/conversations",
                        staffView);
            }
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
