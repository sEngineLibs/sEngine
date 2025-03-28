package se;

class Log {
	public static function log(msg:String, color:LogColor) {
		#if js
		js.Lib.global.console.log('%c$msg', color);
		#else
		Sys.println('$color$msg${LogColor.Reset}');
		#end
	}

	public static function error(msg:String) {
		log(msg, LogColor.Red);
	}

	public static function debug(msg:String) {
		log(msg, LogColor.Green);
	}

	public static function warning(msg:String) {
		log(msg, LogColor.Yellow);
	}

	public static function info(msg:String) {
		log(msg, LogColor.Blue);
	}
}

enum abstract LogColor(String) from String to String {
	#if js
	var Red = "color: red;";
	var Green = "color: green;";
	var Yellow = "color: yellow;";
	var Blue = "color: blue;";
	#else
	var Red = "\x1b[31m";
	var Green = "\x1b[32m";
	var Yellow = "\x1b[33m";
	var Blue = "\x1b[34m";
	var Reset = "\x1b[0m";
	#end
}
