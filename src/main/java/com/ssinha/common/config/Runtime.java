package com.ssinha.common.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.stream.Stream;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class Runtime {
	private static final String CONFIG_PATH = "/config/";
	private static final String CONFIG_EXT = ".xml";
	private KeyVaultSecretAccess secretAccess;
	private final Map<String, String> properties = new HashMap<>();
	private static final Runtime RUNTIME = new Runtime();

	private Runtime() {
		init();
	}

	public static Runtime get() {
		return RUNTIME;
	}

	private void init() {
		System.out.println("Initializing runtime configurations...");
		try {
			Properties configs = new Properties();
			InputStream stream0 = Runtime.class.getResourceAsStream(CONFIG_PATH + "application" + CONFIG_EXT);
			if (stream0 != null) {
				System.out.println("Loading base configuration file : application" + CONFIG_EXT);
				if (CONFIG_EXT.equalsIgnoreCase(".xml")) {
					configs.loadFromXML(stream0);
				} else {
					configs.load(stream0);
				}
			}
			configs.forEach((k, v) -> {
				properties.put(String.valueOf(k), String.valueOf(v));
			});
			System.getProperties().forEach((k, v) -> {
				properties.put(String.valueOf(k), String.valueOf(v));
			});
			System.getenv().forEach((k, v) -> {
				properties.put(String.valueOf(k), String.valueOf(v));
			});
			final boolean disabled = Boolean.parseBoolean(properties.get("security_disabled"));
			if (!disabled) {
				log.info("Fetching KeyVault secrets...");
				String endpoint = properties.get("keyVault_base_url");
				String tenant = properties.get("keyVault_tenant");
				String clientId = properties.get("keyVault_clientId");
				String clientSecret = properties.get("keyVault_clientKey");
				this.secretAccess = new KeyVaultSecretAccess(endpoint, tenant, clientId, clientSecret);
				final Stream<String> stream = properties.keySet().stream().filter(k -> k.endsWith("@secure"));
				stream.forEach(entry -> {
					try {
						final String key = properties.get(entry);
						String value = this.secretAccess.getSecretValue(key);
						log.info("Fecthed KeyVault secret > {}: {}", entry, value);
						properties.put(entry, value);
					} catch (Exception e) {
						log.error("Unable to resolve key: {}", entry);
					}
				});
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public String getConfiguration(String key) {
		return this.properties.get(key);
	}
}
