package com.ssinha.myapp.handler;

import java.util.Optional;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.microsoft.azure.functions.HttpRequestMessage;
import com.microsoft.azure.functions.HttpResponseMessage;
import com.ssinha.myapp.service.MyAppService;

@Component
public class MyAppHandler implements Function<HttpRequestMessage<Optional<String>>, HttpResponseMessage> {

	@Autowired
	private MyAppService myAppService;

	@Override
	public HttpResponseMessage apply(HttpRequestMessage<Optional<String>> request) {
		return myAppService.process(request);
	}
}
