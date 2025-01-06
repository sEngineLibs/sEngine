package s2d.core;

import sys.FileSystem;
import haxe.io.Path;
import haxe.macro.Context;
// s2d
import s2d.core.utils.FileUtils;

using s2d.core.utils.extensions.ArrayExt;
using s2d.core.utils.extensions.StringExt;

class Preprocessor {
	public static function main() {
		var dir = "shaders";

		// clean "compiled" directory
		var fp = Path.join([dir, "compiled"]);
		if (FileSystem.exists(fp)) {
			for (file in FileSystem.readDirectory(fp)) {
				var filePath = Path.join([fp, file]);
				if (FileSystem.isDirectory(filePath))
					FileSystem.deleteDirectory(filePath);
				else
					FileSystem.deleteFile(filePath);
			}
		} else {
			FileSystem.createDirectory(fp);
		}

		preprocess(dir);
	}

	public static function preprocess(fp:String) {
		for (file in FileSystem.readDirectory(fp)) {
			if (file != "compiled") {
				var filePath = Path.join([fp, file]);
				if (FileSystem.isDirectory(filePath))
					preprocess(filePath);
				else if (Path.extension(file) == "glsl")
					preprocessShader(filePath);
			}
		}
	}

	public static function preprocessShader(fp:String) {
		var compiled = new StringBuf();

		for (line in FileUtils.readLines(fp)) {
			var clean = line.cleanSpaces();
			var tokens = clean.split(" ").filter(token -> !token.startsWith("//") || token.startsWith("//:"));
			if (tokens.length == 0)
				continue;

			var compiledLine = "";

			// process commands
			if (tokens[0].startsWith("//:")) {
				var command = tokens[0].substring(3);
				switch (command) {
					case('import'):
						{
							var splitted = tokens[1].split('.');
							var fileName = '${splitted.last()}.glsl';
							try {
								if (splitted[0] != "compiled")
									preprocessShader(Path.join(["shaders", fileName]));

								var toImport = FileUtils.readAll(Path.join(["shaders", "compiled", fileName]));
								compiledLine = '${toImport}';
							} catch (e) {
								trace('Failed to import ${fileName}: "${e}"');
								compiledLine = "";
							}
						}
					case('global'):
						{
							var defName = tokens[1];
							var defValue = Context.definedValue(defName);
							if (defValue != null)
								compiledLine = '#define ${defName} ${defValue}';
							else {
								trace('Failed to define ${defName}: value not found');
								compiledLine = "";
							}
						}
					default:
						trace('Unknown command: ${command}');
				}
			} else {
				compiledLine = tokens.join(" ");
			}

			if (compiledLine != "")
				compiled.add(compiledLine + "\n");
		}

		var fileName = Path.withoutDirectory(fp);
		FileUtils.writeAll(Path.join(["shaders", "compiled", fileName]), compiled.toString());
	}
}
