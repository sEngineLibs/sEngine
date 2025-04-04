package se;

class Log {
	public static inline final INFO:Int = 1;
	public static inline final DEBUG:Int = 2;
	public static inline final ERROR:Int = 4;
	public static inline final WARNING:Int = 8;
	public static inline final ALL:Int = INFO | DEBUG | ERROR | WARNING;
	#if js
	public static inline final Red = "color: red;";
	public static inline final Green = "color: green;";
	public static inline final Yellow = "color: yellow;";
	public static inline final Blue = "color: blue;";
	#else
	public static inline final Red = "\x1b[31m";
	public static inline final Green = "\x1b[32m";
	public static inline final Yellow = "\x1b[33m";
	public static inline final Blue = "\x1b[34m";
	public static inline final Reset = "\x1b[0m";
	#end

	public static var mask:Int = ALL;

	public static function error(msg:String, stamp:Bool = true) {
		log(msg, Red, stamp, ERROR);
	}

	public static function debug(msg:String, stamp:Bool = true) {
		log(msg, Green, stamp, DEBUG);
	}

	public static function warning(msg:String, stamp:Bool = true) {
		log(msg, Yellow, stamp, WARNING);
	}

	public static function info(msg:String, stamp:Bool = true) {
		log(msg, Blue, stamp, INFO);
	}

	public static function fatal(msg:String, stamp:Bool = true) {
		log(msg, Red, stamp, Log.mask);
	}

	public static function log(data:String, color:String, stamp:Bool = true, mask:Int = 0) {
		if (Log.mask & mask != 0) {
			var msg = stamp ? '[${DateTools.format(Date.now(), "%H:%M:%S")}]' : "";
			#if js
			js.Lib.global.console.log('$msg %c$data', color);
			#else
			Sys.println('$msg $color$data${Reset}');
			#end
		}
	}
}
