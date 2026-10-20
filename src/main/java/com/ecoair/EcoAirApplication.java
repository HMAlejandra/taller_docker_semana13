package com.ecoair;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class EcoAirApplication {

    public static void main(String[] args) {
        System.out.println("EcoAir Backend - Sistema de Alertas Ambientales");
        System.out.println("Modo Seguro: Usuario sin privilegios");
        System.out.println("ID Operador: " + System.getenv("OPERATOR_ID"));
        
        SpringApplication.run(EcoAirApplication.class, args);
    }

    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "EcoAir Backend");
        response.put("status", "OPERATIONAL");
        response.put("operator_id", System.getenv("OPERATOR_ID"));
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("message", "Sistema de alertas ambientales críticas activo");
        return response;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("operator", System.getenv("OPERATOR_ID"));
        return response;
    }

    @GetMapping("/alerts")
    public Map<String, Object> alerts() {
        Map<String, Object> response = new HashMap<>();
        response.put("total_alerts", 42);
        response.put("critical", 3);
        response.put("warning", 15);
        response.put("info", 24);
        response.put("operator_id", System.getenv("OPERATOR_ID"));
        return response;
    }
}
