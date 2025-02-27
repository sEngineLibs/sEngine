package s2d.stage.objects;

import kha.FastFloat;
import s2d.PhysicalObject;

abstract class StageObject extends PhysicalObject<StageObject> {
	var layer:Layer;

	@observable public var x(get, set):FastFloat;
	@observable public var y(get, set):FastFloat;

	public inline function new(layer:Layer) {
		super(null);
		this.layer = layer;
	}

	inline function get_x():FastFloat {
		return this.transform.global.translationX;
	}

	inline function set_x(value:FastFloat):FastFloat {
		this.transform.global.translationX = value;
		return value;
	}

	inline function get_y():FastFloat {
		return this.transform.global.translationY;
	}

	inline function set_y(value:FastFloat):FastFloat {
		this.transform.global.translationY = value;
		return value;
	}
}
