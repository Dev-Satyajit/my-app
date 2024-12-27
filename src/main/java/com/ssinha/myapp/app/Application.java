package com.ssinha.myapp.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.ssinha.myapp")
public class Application {
	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
}
