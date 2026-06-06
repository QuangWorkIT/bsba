package com.be.bsba.repository;

import com.be.bsba.entity.StoreImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface StoreImageRepository extends JpaRepository<StoreImage, UUID> {

    List<StoreImage> findByStoreIdOrderByDisplayOrderAsc(UUID storeId);
}
