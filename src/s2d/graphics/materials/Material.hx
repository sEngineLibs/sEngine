package s2d.graphics.materials;

import kha.Image;
import kha.FastFloat;
import kha.arrays.Float32Array;
// s2d
import s2d.animation.SpriteSheet;

class Material {
	public var albedoMap:Image;
	public var normalMap:Image;
	public var ormMap:Image;
	public var emissionMap:Image;

	public var params:Float32Array;
	public var depthScale(get, set):FastFloat;
	public var emissionStrength(get, set):FastFloat;
	public var sheet:SpriteSheet = new SpriteSheet(1, 1);

	public inline function new() {
		params = new Float32Array(2);
		depthScale = 1.0;
		emissionStrength = 1.0;
	}

	inline function get_depthScale():FastFloat {
		return params[0];
	}

	inline function set_depthScale(value:FastFloat):FastFloat {
		params[0] = value;
		return value;
	}

	inline function get_emissionStrength():FastFloat {
		return params[1];
	}

	inline function set_emissionStrength(value:FastFloat):FastFloat {
		params[1] = value;
		return value;
	}
}
