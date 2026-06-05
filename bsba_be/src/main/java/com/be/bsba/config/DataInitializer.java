package com.be.bsba.config;

import com.be.bsba.entity.Role;
import com.be.bsba.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final RoleRepository roleRepository;

    @Override
    public void run(String... args) {
        if (roleRepository.count() == 0) {
            Role userRole = Role.builder().name("USER").build();
            Role adminRole = Role.builder().name("ADMIN").build();
            roleRepository.save(userRole);
            roleRepository.save(adminRole);
        }
    }
}
