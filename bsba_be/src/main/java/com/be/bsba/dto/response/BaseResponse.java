package com.be.bsba.dto.response;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class BaseResponse <T>{
    private String status;
    private String message;
    private T data;

    public BaseResponse(String status, String message) {
        this.status = status;
        this.message = message;
    }
}
