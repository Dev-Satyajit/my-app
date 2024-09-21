package com.ssinha.common.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class Runtime {
	private static final String CONFIG_PATH = "/config/";
	private static final String CONFIG_EXT = ".xml";
	private static final Runtime RUNTIME = new Runtime();

	public static Runtime get() {
		return RUNTIME;
	}

	public String getConfiguration(String key) {
		String value = System.getenv(key);
		if (value != null) {
			return value;
		}
		try (InputStream stream = Runtime.class.getResourceAsStream(CONFIG_PATH + "application" + CONFIG_EXT)) {
			Properties config = new Properties();
			config.loadFromXML(stream);
			value = config.getProperty(key);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return value;
	}
}
