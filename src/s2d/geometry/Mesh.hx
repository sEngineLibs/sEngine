package s2d.geometry;

import haxe.ds.Vector;
import kha.math.FastVector2;

@:forward()
abstract Mesh(Vector<FastVector2>) from Vector<FastVector2> to Vector<FastVector2> {
	function new(value:Vector<FastVector2>) {
		this = value;
	}

	@:from
	static function fromArray(value:Array<FastVector2>) {
		var v = new Vector(value.length);
		for (i in 0...value.length)
			v[i] = value[i];
		return new Mesh(v);
	}

	public function iterator() {
		return this.toData().iterator();
	}
}
