package s2d.core.utils.extensions;

class StringExt {
	public static inline function capitalize(word:String):String {
		return word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
	}

	public static inline function capitalizeWords(str:String, delimiter:String = ' '):String {
		return str.split(delimiter).map(capitalize).join(delimiter);
	}

	public static inline function startsWith(str:String, value:String):Bool {
		return str.substring(0, value.length) == value;
	}

	public static inline function replace(str:String, value1:String, value2:String):String {
		if (value1 == "")
			return str;

		var result = new StringBuf();
		var i = 0;

		while (i <= str.length - value1.length) {
			if (str.substr(i, value1.length) == value1) {
				result.add(value2);
				i += value1.length;
			} else {
				result.add(str.charAt(i));
				i++;
			}
		}

		if (i < str.length) {
			result.add(str.substr(i));
		}

		return result.toString();
	}

	public static inline function contains(str:String, value:String):Bool {
		return str.indexOf(value) != -1;
	}
}
