package s2d.animation;

import kha.math.FastVector2;
// s2d
import s2d.math.Rect;
import s2d.math.IVec2;

@:autoBuild(s2d.core.macro.SMacro.build())
class SpriteSheet {
	@:isVar public var colsNum(default, set):Int = 1;
	@:isVar public var rowsNum(default, set):Int = 1;
	@readonly public var length:Int = 1;
	@readonly public var tileSize:FastVector2 = {x: 1.0, y: 1.0};

	@readonly public var curTile:Rect = Rect.Identity;
	@:isVar public var curTileID(default, set):Int = 0;
	@:isVar public var curTilePosition(default, set):IVec2 = {x: 0, y: 0};

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

	inline function set_curTilePosition(value:IVec2):IVec2 {
		curTilePosition = value;
		curTile = new Rect(value.x * tileSize.x, value.y * tileSize.y, (value.x + 1) * tileSize.x, (value.y + 1) * tileSize.y);
		return value;
	}
}
