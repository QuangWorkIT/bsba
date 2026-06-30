package com.be.bsba;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableAsync
@EnableScheduling
public class BsbaApplication {

	public static void main(String[] args) {
		SpringApplication.run(BsbaApplication.class, args);
	}

}
