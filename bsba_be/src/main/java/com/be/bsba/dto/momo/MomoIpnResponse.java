package com.be.bsba.dto.momo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MomoIpnResponse {
    private int status;
    private String message;
}
