package com.ssinha.common.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class Runtime {
	private static final String CONFIG_PATH = "/config/";
	private static final String CONFIG_EXT = ".xml";
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
			InputStream stream = Runtime.class.getResourceAsStream(CONFIG_PATH + "application" + CONFIG_EXT);
			if (stream != null) {
				System.out.println("Loading base configuration file : application" + CONFIG_EXT);
				if (CONFIG_EXT.equalsIgnoreCase(".xml")) {
					configs.loadFromXML(stream);
				} else {
					configs.load(stream);
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
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public String getConfiguration(String key) {
		return this.properties.get(key);
	}
}
