package s2d.core.math.vectors;

import haxe.ds.Vector;

abstract VecN<T>(Vector<T>) from Vector<T> to Vector<T> {
	public var size(get, never):Int;

	public inline function new(size:Int, ?defaultValue:T) {
		this = new Vector(size, defaultValue);
	}

	public inline function copy():VecN<T> {
		var vec = new Vector(size);
		for (i in 0...size)
			vec.set(i, this[i]);
		return vec;
	}

	inline function get_size():Int {
		return this.length;
	}

	@:arrayAccess
	inline function get(i:Int) {
		if (i >= size)
			throw 'Vector index $i is out of range [0, ${size - 1}].';
		return this[i];
	}

	@:arrayAccess
	inline function set(i:Int, value:T) {
		if (i >= size)
			throw 'Vector index $i is out of range [0, ${size - 1}].';
		this[i] = value;
	}

	public inline function iterator():VecNIterator<T> {
		return new VecNIterator(this);
	}
}

class VecNIterator<T> {
	var vec:Vector<T>;
	var i:Int;

	public function new(vec:Vector<T>) {
		this.vec = vec;
		i = 0;
	}

	public inline function hasNext():Bool {
		return i < vec.length;
	}

	public inline function next():T {
		return vec[i++];
	}
}
