package s2d.utils;

import sys.io.File;
import haxe.macro.Context;

using s2d.utils.StringExt;

class ShaderPrecompiler {
	static var defines = Context.getDefines();

	public static inline function precompile(fp:String) {
		fp = fp.replace("/", "\\");
		var compiled = new StringBuf();

		for (line in readLines(fp)) {
			var compiledLine = line;
			var tokens = line.split(" ");

			// process commands
			if (tokens[0].startsWith("//:")) {
				var command = tokens[0].substring(3);
				switch (command) {
					case('import'):
						{
							var ps = tokens[1].replace(".", "\\").split('\\');
							var fileName = '${ps[ps.length - 1]}.glsl';

							try {
								if (ps[0] != "compiled")
									precompile('shaders/${fileName}');

								var toImport = readAll('shaders/compiled/${fileName}');
								compiledLine = '${toImport}\n';
							} catch (e) {
								trace('Failed to import ${fileName}: "${e}"');
								compiledLine = "";
							}
						}
					case('global'):
						{
							var defName = tokens[1];
							var defValue = defines[defName];
							if (defValue != null)
								compiledLine = '#define ${defName} ${defValue}';
							else
								compiledLine = "";
						}
					default:
						null;
				}
			}
			// clear comments
			else if (tokens[0].startsWith("//"))
				compiledLine = "";

			if (compiledLine != "") {
				if (compiled.length > 0)
					compiled.add("\n");
				compiled.add(compiledLine);
			}
		}

		var ps = fp.split('\\');
		var fileName = ps[ps.length - 1];

		writeAll('shaders\\compiled\\${fileName}', compiled.toString());
	}

	static inline function readAll(fp:String):String {
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

	static inline function writeAll(fp:String, content:String):Void {
		var fout = File.write(fp, true);
		fout.writeString(content);
		fout.close();
	}

	static inline function readLines(fp:String):Array<String> {
		return readAll(fp).split('\n');
	}
}
