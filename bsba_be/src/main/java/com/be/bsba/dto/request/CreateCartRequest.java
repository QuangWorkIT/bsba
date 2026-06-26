package com.be.bsba.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreateCartRequest {
    @NotBlank(message = "Booking ID cannot be blank")
    private String bookingId;

    private String note;
}
