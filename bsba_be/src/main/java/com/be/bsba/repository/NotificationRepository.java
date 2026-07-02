package com.be.bsba.repository;

import com.be.bsba.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    List<Notification> getByUserIdOrderByCreatedAtDesc(UUID userId);

    Optional<Notification> findFirstByUserIdAndTypeAndBodyOrderByCreatedAtDesc(UUID userId, String type, String body);
}
