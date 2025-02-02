package s2d.geometry;

import haxe.ds.Vector;
import s2d.math.Vec2;

@:forward()
abstract Mesh(Vector<Vec2>) from Vector<Vec2> to Vector<Vec2> {
	function new(value:Vector<Vec2>) {
		this = value;
	}

	@:from
	static function fromArray(value:Array<Vec2>) {
		var v = new Vector(value.length);
		for (i in 0...value.length)
			v[i] = value[i];
		return new Mesh(v);
	}

	public function iterator() {
		return this.toData().iterator();
	}
}
