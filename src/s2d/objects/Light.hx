package s2d.objects;

import kha.Color;

class Light extends Object {
	public var color:Color = Color.White;
	public var power:Float = 1.0;
	public var radius:Float = 1.0;

	public inline function new() {
		super();
		S2D.stage.lights.push(this);
	}
}
