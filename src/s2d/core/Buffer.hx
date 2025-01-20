package s2d.core;

import haxe.ds.Vector;

@:forward
abstract Buffer<T>(Vector<T>) from Vector<T> to Vector<T> {
	public inline function new(?length:Int = 0) {
		this = new Vector(length);
	}

	public inline function push(value:T):Void {
		final tmp = this;
		this = new Vector(tmp.length + 1);
		for (i in 0...tmp.length)
			this[i] = tmp[i];
		this[tmp.length] = value;
	}

	public inline function concat(value:Buffer<T>):Buffer<T> {
		final b = new Buffer(this.length + value.length);
		for (i in 0...this.length)
			b[i] = this[i];
		for (i in 0...value.length)
			b[i + this.length] = value[i];
		return b;
	}

	@:op(A + B) @:commutative
	inline function plusBuffer(value:Buffer<T>) {
		return concat(value);
	}

	@:op(A + B) @:commutative
	inline function plusValue(value:T) {
		var c:Buffer<T> = this.copy();
		c.push(value);
		return c;
	}

	@:op(A += B) @:commutative
	inline function addBuffer(value:Buffer<T>) {
		this = concat(value);
		return this;
	}

	@:op(A += B) @:commutative
	inline function addValue(value:T) {
		push(value);
		return this;
	}

	@:op([])
	public inline function get(i:Int) {
		return this.get(i);
	}

	@:op([])
	inline function set(i:Int, value:T) {
		return this.set(i, value);
	}

	@:from
	static inline function fromArray<T>(value:Array<T>):Buffer<T> {
		final b = new Buffer<T>(value.length);
		for (i in 0...value.length)
			b[i] = value[i];
		return b;
	}

	public function iterator() {
		return new BufferIterator(this);
	}
}

private class BufferIterator<T> {
	var b:Buffer<T>;
	var i:Int;

	public inline function new(b:Buffer<T>) {
		this.b = b;
		this.i = 0;
	}

	public inline function hasNext():Bool {
		return i < b.length;
	}

	public inline function next():T {
		return b[i++];
	}
}
