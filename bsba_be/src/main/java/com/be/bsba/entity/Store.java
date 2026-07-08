package com.be.bsba.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;


@Entity
@Table(name = "stores")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Store {

    @Id
    @GeneratedValue
    private UUID id;

    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String address;

    @Column(precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(precision = 10, scale = 7)
    private BigDecimal longitude;

    private String phone;

    private String email;

    private String coverImageUrl;

    private LocalTime openTime;

    private LocalTime closeTime;

    private Integer totalCapacity;

    @Column(name = "charge_fee")
    private Double chargeFee;

    @Column(precision = 3, scale = 2)
    private BigDecimal ratingAvg;

    private Boolean isActive = true;

    @CreationTimestamp
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    private OffsetDateTime updatedAt;

    @OneToMany(mappedBy = "store")
    private List<StoreImage> images;

    @OneToMany(mappedBy = "store")
    private List<StoreTimeSlot> timeSlots;

    @OneToMany(mappedBy = "store")
    private List<Review> reviews;
}
