package com.be.bsba.repository;

import com.be.bsba.constant.SenderType;
import com.be.bsba.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface MessageRepository extends JpaRepository<Message, UUID> {

    // Message history, newest first (the client reverses each page for display).
    Page<Message> findByConversationIdOrderByCreatedAtDesc(UUID conversationId, Pageable pageable);

    // Unread shown to a customer: messages from staff/system they haven't read.
    long countByConversationIdAndIsReadFalseAndSenderTypeNot(UUID conversationId, SenderType senderType);

    // Unread shown to staff: messages from the customer they haven't read.
    long countByConversationIdAndIsReadFalseAndSenderType(UUID conversationId, SenderType senderType);

    // Mark the other party's unread messages as read; returns how many rows changed.
    @Modifying(clearAutomatically = true)
    @Query("UPDATE Message m SET m.isRead = true " +
            "WHERE m.conversation.id = :conversationId " +
            "AND m.senderType = :senderType " +
            "AND m.isRead = false")
    int markRead(@Param("conversationId") UUID conversationId, @Param("senderType") SenderType senderType);
}
