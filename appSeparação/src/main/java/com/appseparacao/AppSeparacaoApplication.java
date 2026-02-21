package com.appseparacao;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling; 

@SpringBootApplication
@EnableScheduling
public class AppSeparacaoApplication {

	public static void main(String[] args) {
		SpringApplication.run(AppSeparacaoApplication.class, args);
	}
}