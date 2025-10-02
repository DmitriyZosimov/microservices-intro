package com.ms.intro.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {

     @GetMapping("/health")
     public ResponseEntity<String> healthCheck() {
         return ResponseEntity.ok("Resources Service is up and running");
     }
}
