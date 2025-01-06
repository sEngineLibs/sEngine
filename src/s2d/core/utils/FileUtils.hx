package s2d.core.utils;

import sys.io.File;

class FileUtils {
	public static inline function readAll(fp:String):String {
		var p = "";
		var fin = File.read(fp, false);
		try {
			while (true) {
				p += '\n${fin.readLine()}';
			}
		} catch (e:haxe.io.Eof) {
			fin.close();
		}
		return p;
	}

	public static inline function writeAll(fp:String, content:String):Void {
		var fout = File.write(fp);
		fout.writeString(content);
		fout.close();
	}

	public static inline function readLines(fp:String):Array<String> {
		return readAll(fp).split('\n');
	}
}
