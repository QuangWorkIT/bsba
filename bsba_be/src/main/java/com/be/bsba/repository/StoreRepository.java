package com.be.bsba.repository;

import com.be.bsba.dto.projection.NearbyStoreProjection;
import com.be.bsba.dto.response.EditStoreResponse;
import com.be.bsba.entity.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.be.bsba.entity.Store;

@Repository
public interface StoreRepository extends JpaRepository<Store, UUID> {

    List<Store> findByIsActiveTrue();

    // Active stores matching a free-text query on name or description.
    @Query("SELECT s FROM Store s WHERE s.isActive = true AND (" +
            "LOWER(s.name) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
            "LOWER(s.description) LIKE LOWER(CONCAT('%', :q, '%')))")
    List<Store> searchActive(@Param("q") String q);
    
    Optional<Store> findByIdAndIsActiveTrue(UUID id);


        @Query(value = """
        SELECT
            s.id,
            s.name,
            s.address,
            s.description,
            s.latitude,
            s.open_time AS openTime,
            s.close_time AS closeTime,
            s.longitude,
            s.rating_avg AS ratingAvg,
            s.cover_image_url AS coverImageUrl,
            ST_Distance(
                s.location,
                ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography
            ) / 1000 AS distanceKm
        FROM stores s
        WHERE s.is_active = true
          AND s.location IS NOT NULL
          AND ST_DWithin(
                s.location,
                ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
                :radiusKm * 1000
              )
        ORDER BY distanceKm ASC
        """, nativeQuery = true)
        List<NearbyStoreProjection> findNearbyStores(
                @Param("lat") double lat,
                @Param("lng") double lng,
                @Param("radiusKm") double radiusKm
        );

        @Query(value = """
        SELECT
            s.id,
            s.name,
            s.address,
            s.description,
            s.latitude,
            s.open_time AS openTime,
            s.close_time AS closeTime,
            s.longitude,
            s.rating_avg AS ratingAvg,
            s.cover_image_url AS coverImageUrl,
            CAST(NULL AS double precision) AS distanceKm
        FROM stores s
        WHERE s.is_active = true
          AND (:name IS NULL OR LOWER(COALESCE(s.name, '')) LIKE LOWER(CONCAT('%', :name, '%')))
          AND (:description IS NULL OR LOWER(COALESCE(s.description, '')) LIKE LOWER(CONCAT('%', :description, '%')))
          AND (:address IS NULL OR LOWER(COALESCE(s.address, '')) LIKE LOWER(CONCAT('%', :address, '%')))
        ORDER BY s.name ASC
        """, nativeQuery = true)
        List<NearbyStoreProjection> searchStores(
                @Param("name") String name,
                @Param("description") String description,
                @Param("address") String address
        );

        @Query("""
        SELECT new com.be.bsba.dto.response.EditStoreResponse(
            CAST(s.id AS string),
            s.name,
            s.description,
            s.address,
            s.coverImageUrl,
            s.phone,
            s.email,
            s.openTime,
            s.closeTime,
            s.totalCapacity,
            s.chargeFee
        )
        FROM StoreStaff ss
        JOIN ss.store s
        WHERE ss.staff.id = :staffId
          AND s.isActive = true
        """)
        EditStoreResponse getStoreDetailByStaffId(@Param("staffId") UUID staffId);
}
