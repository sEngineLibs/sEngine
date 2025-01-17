package s2d.animation;

import s2d.math.SMath;

@:autoBuild(s2d.core.macro.SMacro.build())
class SpriteSheet {
	@:isVar public var colsNum(default, set):Int = 1;
	@:isVar public var rowsNum(default, set):Int = 1;
	@readonly public var length:Int = 1;
	@readonly public var tileSize = vec2(1.0);

	@readonly public var curTile = vec4(0.0, 0.0, 1.0, 1.0);
	@:isVar public var curTileID(default, set):Int = 0;
	@:isVar public var curTilePosition(default, set) = vec2(0.0);

	public inline function new(?colsNum:Int = 1, ?rowsNum:Int = 1) {
		this.colsNum = colsNum;
		this.rowsNum = rowsNum;
	}

	public inline function advance() {
		++curTileID;
	}

	inline function set_colsNum(value:Int):Int {
		colsNum = value;
		length = rowsNum * colsNum;
		tileSize.x = 1 / colsNum;
		update();
		return value;
	}

	inline function set_rowsNum(value:Int):Int {
		rowsNum = value;
		length = rowsNum * colsNum;
		tileSize.y = 1 / rowsNum;
		update();
		return value;
	}

	inline function update() {
		curTilePosition = {
			x: curTileID % colsNum,
			y: Std.int(curTileID / colsNum)
		}
	}

	inline function set_curTileID(value:Int):Int {
		curTileID = value % length;
		update();
		return value;
	}

	inline function set_curTilePosition(value) {
		curTilePosition = value;
		curTile = vec4(value * tileSize, (value + 1.0) * tileSize);
		return value;
	}
}
