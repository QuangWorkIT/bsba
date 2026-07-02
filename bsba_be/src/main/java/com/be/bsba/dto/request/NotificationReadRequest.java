package com.be.bsba.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@AllArgsConstructor
public class NotificationReadRequest {
    private List<UUID> notificationIds;
}
