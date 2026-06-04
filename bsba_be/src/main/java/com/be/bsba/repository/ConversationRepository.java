package com.be.bsba.repository;

import com.be.bsba.entity.Conversation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, UUID> {

    // Get-or-create lookup: one thread per (customer, store).
    Optional<Conversation> findByUserIdAndStoreId(UUID userId, UUID storeId);

    // Customer inbox: only the threads this customer owns.
    Page<Conversation> findByUserIdOrderByLastMessageAtDesc(UUID userId, Pageable pageable);

    // Staff inbox: only threads of the stores this staff is assigned to.
    Page<Conversation> findByStoreIdInOrderByLastMessageAtDesc(Collection<UUID> storeIds, Pageable pageable);

    // Admin inbox: every thread, most recently active first.
    @Query("SELECT c FROM Conversation c ORDER BY c.lastMessageAt DESC")
    Page<Conversation> findAllOrderByLastMessageAtDesc(Pageable pageable);
}
