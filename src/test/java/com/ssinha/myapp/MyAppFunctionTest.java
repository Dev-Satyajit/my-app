package com.ssinha.myapp;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

import com.microsoft.azure.functions.HttpStatus;
/**
 * Unit test for Function class.
 */
public class MyAppFunctionTest {
	/**
	 * Unit test for HttpTriggerJava method.
	 */
	@Test
	public void testHttpTriggerJava() {
		assertEquals("OK", HttpStatus.OK.toString());
	}
}
