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
		cleanDir("shaders_compiled");
		preprocess("shaders");
	}

	public static function cleanDir(fp:String) {
		if (FileSystem.exists(fp)) {
			for (file in FileSystem.readDirectory(fp)) {
				var filePath = Path.join([fp, file]);
				if (FileSystem.isDirectory(filePath))
					if (FileSystem.readDirectory(filePath).length == 0)
						FileSystem.deleteDirectory(filePath);
					else
						cleanDir(filePath);
				else
					FileSystem.deleteFile(filePath);
			}
		} else {
			FileSystem.createDirectory(fp);
		}
	}

	public static function preprocess(fp:String) {
		for (file in FileSystem.readDirectory(fp)) {
			var filePath = Path.join([fp, file]);
			if (FileSystem.isDirectory(filePath))
				preprocess(filePath);
			else if (Path.extension(file) == "glsl")
				preprocessShader(filePath);
		}
	}

	public static function preprocessShader(fp:String) {
		var compiled = new StringBuf();

		for (line in FileUtils.readLines(fp)) {
			var noComments = if (line.indexOf("//") != -1) line.substr(0, line.indexOf("//")) else line;
			var clean = noComments.cleanSpaces();
			var tokens = clean.split(" ");

			if (tokens.length == 0)
				continue;

			var compiledLine = "";

			// process commands
			var command = tokens[0];
			switch (command) {
				case('import'):
					{
						var fpath = Path.join(["shaders"].concat(tokens[1].split("."))) + ".glsl";
						var path = Path.join(["shaders_compiled"].concat(tokens[1].split("."))) + ".glsl";
						try {
							if (!FileSystem.exists(path))
								preprocessShader(fpath);
							compiledLine = FileUtils.readAll(path);
						} catch (e) {
							trace('Failed to import ${Path.withoutDirectory(path)}: "${e}"');
						}
					}
				case('global'):
					{
						var defName = tokens[1];
						var defValue = Context.definedValue(defName);
						if (defValue != null)
							compiledLine = '#define ${defName} ${defValue}\n';
						else
							trace('Failed to define ${defName}: value not found');
					}
				default:
					compiledLine = tokens.join(" ");
			}

			if (compiledLine != "")
				if (compiledLine.startsWith("#"))
					compiled.add("\n" + compiledLine + "\n");
				else
					compiled.add(compiledLine + " ");
		}

		var pathNorm = Path.normalize(fp);
		var dirs = Path.directory(pathNorm).split("/").slice(1);
		var fileName = Path.withoutDirectory(pathNorm);

		var d = "shaders_compiled";
		for (dir in dirs) {
			d = Path.join([d, dir]);
			if (!FileSystem.exists(d))
				FileSystem.createDirectory(d);
		}

		var pathCompiled = Path.join([d, fileName]);
		FileUtils.writeAll(pathCompiled, compiled.toString().cleanLines());
	}
}
