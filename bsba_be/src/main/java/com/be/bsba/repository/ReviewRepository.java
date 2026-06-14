package com.be.bsba.repository;

import com.be.bsba.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

    List<Review> findByStoreIdOrderByCreatedAtDesc(UUID storeId);

    long countByStoreId(UUID storeId);
}
