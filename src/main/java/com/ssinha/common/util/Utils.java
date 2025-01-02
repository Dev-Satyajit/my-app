package com.ssinha.common.util;

public class Utils {

	public static boolean isEmpty(CharSequence... strings) {
		for (CharSequence string : strings) {
			if (string == null || string == "") {
				return true;
			}
		}
		return false;
	}

	public static boolean anyNull(Object... objects) {
		for (Object o : objects) {
			if (o == null) {
				return true;
			}
		}
		return false;
	}
}
