package s2d.core.utils.extensions;

using s2d.core.utils.extensions.StringExt;

class StringExt {
	public static inline function startsWith(str:String, value:String):Bool {
		return StringTools.startsWith(str, value);
	}

	public static inline function endsWith(str:String, value:String):Bool {
		return StringTools.endsWith(str, value);
	}

	public static inline function replace(str:String, sub:String, by:String):String {
		return StringTools.replace(str, sub, by);
	}

	public static inline function contains(str:String, value:String):Bool {
		return StringTools.contains(str, value);
	}

	public static inline function trim(str:String):String {
		return StringTools.trim(str);
	}

	public static inline function capitalize(word:String):String {
		return word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
	}

	public static inline function capitalizeWords(str:String, delimiter:String = ' '):String {
		return str.split(delimiter).map(capitalize).join(delimiter);
	}

	public static inline function cleanSpaces(str:String):String {
		return ~/\s+/.replace(str.trim(), " ");
	}

	public static inline function cleanLines(str:String):String {
		return str.split("\n").filter(line -> line != "").join("\n");
	}

	public static inline function strip(str:String):String {
		return str.replace('\n', ' ');
	}
}
