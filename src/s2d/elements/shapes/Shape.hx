package s2d.elements.shapes;

import se.Color;

abstract class Shape extends DrawableElement {
	public var border:ShapeBorder = {
		width: 0.0,
		color: Black
	};

	public function new(name:String = "shape") {
		super(name);
	}
}

typedef ShapeBorder = {
	width:Float,
	color:Color
}
