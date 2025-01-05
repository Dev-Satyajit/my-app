package com.ssinha.myapp.function;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.HttpMethod;
import com.microsoft.azure.functions.HttpRequestMessage;
import com.microsoft.azure.functions.HttpResponseMessage;
import com.microsoft.azure.functions.annotation.AuthorizationLevel;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.HttpTrigger;
import com.ssinha.myapp.handler.MyAppHandler;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class MyAppFunction {

	@Autowired
	private MyAppHandler myAppHandler;

    @FunctionName("myAppHttp")
    public HttpResponseMessage run(
            @HttpTrigger(
                name = "request",
                methods = {HttpMethod.GET, HttpMethod.POST},
                authLevel = AuthorizationLevel.ANONYMOUS)
                HttpRequestMessage<Optional<String>> request,
            final ExecutionContext context) {
		log.info("Java HTTP trigger processed a request.");
		log.info("Printing environment variables...");
		System.getenv().forEach((k, v) -> {
			log.info("{} = {}", k, v);
		});
		log.info("Printing system properties...");
		System.getProperties().forEach((k, v) -> {
			log.info("{} = {}", k, v);
		});

        return myAppHandler.apply(request);
    }
}
