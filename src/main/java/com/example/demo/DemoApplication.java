package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.PropertySource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;


@SpringBootApplication
//@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
@RestController
//@PropertySource("classpath:*.properties")
@PropertySource(
        name = "props",
        value = { "classpath:application.properties", "classpath:application-qa.properties", "classpath:application-dev.properties" })
public class DemoApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(DemoApplication.class);
    }

    @GetMapping(value = {"/hello", "/hello/{name}"})
    public String hello(@PathVariable(required = false) String name) {
        name = name == null ? "Canon" : name;
        System.out.println("********* Hello, " + name + "!");
        System.out.println();
        return "Hello, " + name + "! \n";
    }

    @GetMapping(path = "/simpleHello")
    public String SimpleHello() {
        System.out.println("******** Hello Canon...");
        return "Hello Canon... \n";
    }
}


