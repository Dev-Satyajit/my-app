package com.ssinha.testapp.function;

import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.annotation.EventHubTrigger;
import com.microsoft.azure.functions.annotation.FunctionName;

public class EventHubTriggerFunction {
	@FunctionName("eventHubTrigger")
	public void eventHubProcessor(
			@EventHubTrigger(
					name = "event",
					eventHubName = "%EH_NAME%",
					consumerGroup = "%EH_CONSUMER_GROUP%",
					connection = "EH_CONNECTION_STRING") String message,
			final ExecutionContext context) {
		context.getLogger().info(message);
	}
}
