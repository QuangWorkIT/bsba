package com.be.bsba.dto.momo;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class MomoPaymentRequest {

    @JsonProperty("partnerCode")
    private String partnerCode;

    @JsonProperty("requestId")
    private String requestId;

    @JsonProperty("amount")
    private Long amount;

    @JsonProperty("orderId")
    private String orderId;

    @JsonProperty("orderInfo")
    private String orderInfo;

    @JsonProperty("redirectUrl")
    private String redirectUrl;

    @JsonProperty("ipnUrl")
    private String ipnUrl;

    @JsonProperty("requestType")
    private String requestType;

    @JsonProperty("extraData")
    private String extraData;

    @JsonProperty("lang")
    private String lang;

    @JsonProperty("signature")
    private String signature;

    @JsonProperty("autoCapture")
    private Boolean autoCapture;

    @JsonProperty("items")
    private List<MomoItem> items;

    @JsonProperty("userInfo")
    private MomoUserInfo userInfo;

    @JsonProperty("deliveryInfo")
    private MomoDeliveryInfo deliveryInfo;

    @JsonProperty("referenceId")
    private String referenceId;

    @Data
    @Builder
    public static class MomoItem {
        private String id;
        private String name;
        private String description;
        private String category;
        private String imageUrl;
        private String manufacturer;
        private Long price;
        private String currency;
        private Integer quantity;
        private String unit;
        private Long totalPrice;
        private Long taxAmount;
    }

    @Data
    @Builder
    public static class MomoUserInfo {
        private String name;
        private String phoneNumber;
        private String email;
    }

    @Data
    @Builder
    public static class MomoDeliveryInfo {
        private String deliveryAddress;
        private String deliveryFee;
        private String quantity;
    }
}
