package se;

import haxe.iterators.ArrayIterator;

using StringTools;

extern abstract Chars(Array<Char>) from Array<Char> to Array<Char> {
	public var length(get, never):Int;

	@:from
	public static inline function fromString(value:String):Chars {
		return [
			for (i in 0...value.length)
				value.charCodeAt(i)
		];
	}

	public inline function new() {
		this = [];
	}

	@:to
	public inline function copy():Chars {
		return this.copy();
	}

	public inline function sub(start:Int, ?end:Int) {
		return this.slice(start, end);
	}

	public inline function split(delimeter:Chars):Array<Chars> {
		return toString().split(delimeter).map(s -> Chars.fromString(s));
	}

	public inline function startsWith(str:Chars):Bool {
		return toString().startsWith(str);
	}

	public inline function endsWith(str:Chars):Bool {
		return toString().endsWith(str);
	}

	public inline function indexOf(sub:Chars):Int {
		return toString().indexOf(sub);
	}

	public inline function clear():Void {
		while (length > 0)
			this.pop();
	}

	public inline function upper():Void {
		for (i in 0...length)
			this[i] = this[i].upper();
	}

	public inline function lower():Void {
		for (i in 0...length)
			this[i] = this[i].lower();
	}

	public inline function capitalize():Void {
		this[0] = this[0]?.upper();
	}

	@:op(a + b)
	public inline function concat(b:Chars):Chars {
		return this.concat(b);
	}

	@:op(a += b)
	public inline function addText(value:Chars) {
		for (c in value)
			this.push(c);
	}

	@:op(a -= b)
	public inline function remove(value:Char):Bool {
		return this.remove(value);
	}

	@:arrayAccess
	public inline function get(i:Int):Char {
		return this[i];
	}

	@:arrayAccess
	public inline function set(i:Int, value:Char):Void {
		this[i] = value;
	}

	@:to
	public inline function toString():String {
		final s:Array<String> = [
			for (c in this)
				c
		];
		return s.join("");
	}

	@:to
	inline function toIntArray():Array<Int> {
		return this;
	}

	inline function iterator():ArrayIterator<Char> {
		return this.iterator();
	}

	inline function get_length() {
		return this.length;
	}

	inline function get_string() {
		return toString();
	}
}

extern abstract Char(Int) from Int to Int {
	public var code(get, never):Int;

	@:from
	public static inline function fromString(value:String) {
		return new Char(value.charCodeAt(0));
	}

	public inline function new(value:Int):Char {
		this = value;
	}

	@:to
	public inline function toString():String {
		return String.fromCharCode(this);
	}

	public inline function upper():Char {
		return toString().toUpperCase();
	}

	public inline function lower():Char {
		return toString().toLowerCase();
	}

	inline function get_code():Int {
		return this;
	}
}
