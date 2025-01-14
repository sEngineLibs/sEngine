package s2d.objects;

// s2d
import s2d.math.Vec4;
import s2d.graphics.materials.Material;

class Sprite extends Object {
	public var cropRect:Vec4 = new Vec4(0.0, 0.0, 1.0, 1.0);
	public var material:Material = new Material();

	public inline function new() {
		super();
		S2D.stage.sprites.push(this);
	}
}
