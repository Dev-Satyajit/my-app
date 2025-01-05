package com.ssinha.myapp.service;

import java.util.Optional;

import org.springframework.stereotype.Service;

import com.microsoft.azure.functions.HttpRequestMessage;
import com.microsoft.azure.functions.HttpResponseMessage;
import com.microsoft.azure.functions.HttpStatus;
import com.ssinha.common.config.Runtime;
import com.ssinha.models.MyAppHttpResponse;

@Service
public class MyAppService {

	public HttpResponseMessage process(HttpRequestMessage<Optional<String>> request) {

		final String query = request.getQueryParameters().get("name");
		final String name = request.getBody().orElse(query);

		String envValue = Runtime.get().getConfiguration("env.name");
		String testValue = Runtime.get().getConfiguration("test.key");
		String secretValue = Runtime.get().getConfiguration("test.secret@secure");

		MyAppHttpResponse response = new MyAppHttpResponse();
		response.setEnvValue(envValue);
		response.setTestValue(testValue);
		response.setSecretValue(secretValue);

		if (name == null) {
			return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
					.body("Please pass a name on the query string or in the request body")
					.build();
		} else {
			return request.createResponseBuilder(HttpStatus.OK)
					.body("Hello, " + name + "\n" + response.toString())
					.build();
		}
	}
}
