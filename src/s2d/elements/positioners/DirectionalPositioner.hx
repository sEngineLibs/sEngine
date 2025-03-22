package s2d.elements.positioners;

import s2d.Direction;

abstract class DirectionalPositioner<T> extends Positioner<T> {
	@:isVar public var spacing(default, set):Float = 0.0;
	@:isVar public var direction(default, set):Direction = TopToBottom | LeftToRight;

	abstract function adjustSpacing(d:Float):Void;

	function set_spacing(value:Float):Float {
		adjustSpacing(value - spacing);
		spacing = value;
		return spacing;
	}

	function set_direction(value:Direction):Direction {
		direction = value;
		if (children.length > 0) {
			var prev = children[0];
			position(prev, null);
			for (c in children.slice(1)) {
				position(c, prev);
				prev = c;
			}
		}
		return direction;
	}
}
