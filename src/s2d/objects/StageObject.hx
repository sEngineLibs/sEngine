package s2d.objects;

import kha.FastFloat;
// s2d
import s2d.core.S2DObject;

using s2d.core.extensions.FastMatrix3Ext;

abstract class StageObject extends S2DObject<StageObject> {
	var layer:Layer;

	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;

	public function new(layer:Layer) {
		super();
		this.layer = layer;
	}

	function onParentChanged() {}

	function get_x():FastFloat {
		return translationX;
	}

	function set_x(value:FastFloat):FastFloat {
		translationX = value;
		return value;
	}

	function get_y():FastFloat {
		return translationY;
	}

	function set_y(value:FastFloat):FastFloat {
		translationY = value;
		return value;
	}
}
