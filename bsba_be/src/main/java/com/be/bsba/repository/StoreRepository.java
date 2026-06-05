package com.be.bsba.repository;

import com.be.bsba.dto.projection.NearbyStoreProjection;
import com.be.bsba.entity.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface StoreRepository extends JpaRepository<Store, UUID> {


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

}
