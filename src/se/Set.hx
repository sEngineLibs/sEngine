package se;

import haxe.iterators.ArrayIterator;
import haxe.iterators.ArrayKeyValueIterator;

@:forward.new
extern abstract Set<T>(Array<T>) from Array<T> to Array<T> {
	/**
		The length of `this` Set.
	**/
	public var length(get, never):Int;

	@:from
	public static inline function fromArray<T>(a:Array<T>):Set<T> {
		return new Set().concat(a);
	}

	/**
		Creates a new Set.
	**/
	public inline function new():Void {
		this = [];
	}

	/**
		Returns a new Set by appending the elements of `a` to the elements of
		`this` Set. 

		The resulting Set will not contain duplicate elements.

		This operation does not modify `this` Set.

		If `a` is the empty Set `[]`, a copy of `this` Set is returned.

		If `a` is `null`, the result is unspecified.
	**/
	public inline function concat(a:Set<T>):Set<T> {
		var s = copy();
		for (e in a)
			s.push(e);
		return s;
	}

	/**
		Returns a string representation of `this` Set, with `sep` separating
		each element.

		The result of this operation is equal to `Std.string(this[0]) + sep +
		Std.string(this[1]) + sep + ... + sep + Std.string(this[this.length-1])`

		If `this` is the empty Set `[]`, the result is the empty String `""`.
		If `this` has exactly one element, the result is equal to a call to
		`Std.string(this[0])`.

		If `sep` is null, the result is unspecified.
	**/
	public inline function join(sep:String):String {
		return this.join(sep);
	}

	/**
		Removes the first element of `this` Set and returns it.

		This operation modifies `this` Set in place.

		If `this` has at least one element, `this`.length and the index of each
		remaining element is decreased by 1.

		If `this` is the empty Set `[]`, `null` is returned and the length
		remains 0.
	**/
	@:op(--a)
	public inline function shift():Null<T> {
		return this.shift();
	}

	/**
		Removes the last element of `this` Set and returns it.

		This operation modifies `this` Set in place.

		If `this` has at least one element, `this.length` will decrease by 1.

		If `this` is the empty Set `[]`, null is returned and the length
		remains 0.
	**/
	@:op(a--)
	public inline function pop():Null<T> {
		return this.pop();
	}

	/**
		Adds the element `x` at the start of `this` Set if `this` doesn't already contain it.

		If so, this operation modifies `this` Set in place and `this.length` and the index of each Set element increases by 1.
	**/
	public inline function unshift(x:T):Void {
		if (!contains(x))
			this.unshift(x);
	}

	/**
		Adds the element `x` at the end of `this` Set and returns the new
		length of `this` Set if `this` doesn't already contain it. -1 is returned otherwise.

		If so, this operation modifies `this` Set in place and `this.length` increases by 1.
	**/
	@:op(a += b)
	public inline function push(x:T):Int {
		if (!contains(x))
			return this.push(x);
		return -1;
	}

	/**
		Removes the first occurrence of `x` in `this` Set.

		This operation modifies `this` Set in place.

		If `x` is found by checking standard equality, it is removed from `this`
		Set and all following elements are reindexed accordingly. The function
		then returns true.

		If `x` is not found, `this` Set is not changed and the function
		returns false.
	**/
	@:op(a -= b)
	public inline function remove(x:T):Bool {
		return this.remove(x);
	}

	/**
		Reverse the order of elements of `this` Set.

		This operation modifies `this` Set in place.

		If `this.length < 2`, `this` remains unchanged.
	**/
	public inline function reverse():Void {
		this.reverse();
	}

	/**
		Reverse the order of elements of the copy of `this` Set.

		This operation does not modify `this`.

		If `this.length < 2`, the copy remains unchanged.
	**/
	public inline function reversed():Set<T> {
		var _copy = copy();
		_copy.reverse();
		return _copy;
	}

	/**
		Creates a shallow copy of the range of `this` Set, starting at and
		including `pos`, up to but not including `end`.

		This operation does not modify `this` Set.

		The elements are not copied and retain their identity.

		If `end` is omitted or exceeds `this.length`, it defaults to the end of
		`this` Set.

		If `pos` or `end` are negative, their offsets are calculated from the
		end of `this` Set by `this.length + pos` and `this.length + end`
		respectively. If this yields a negative value, 0 is used instead.

		If `pos` exceeds `this.length` or if `end` is less than or equals
		`pos`, the result is `[]`.
	**/
	public inline function slice(pos:Int, ?end:Int):Set<T> {
		return this.slice(pos, end);
	}

	/**
		Sorts `this` Set according to the comparison function `f`, where
			`f(x,y)` returns 0 if x == y, a positive Int if x > y and a
		negative Int if x < y.

		This operation modifies `this` Set in place.

		The sort operation is not guaranteed to be stable, which means that the
		order of equal elements may not be retained. For a stable Set sorting
		algorithm, `haxe.ds.ArraySort.sort()` can be used instead.

		If `f` is null, the result is unspecified.
	**/
	public inline function sort(f:T->T->Int):Void {
		this.sort(f);
	}

	/**
		Removes `len` elements from `this` Set, starting at and including
		`pos`, an returns them.

		This operation modifies `this` Set in place.

		If `len` is < 0 or `pos` exceeds `this`.length, an empty Set [] is
		returned and `this` Set is unchanged.

		If `pos` is negative, its value is calculated from the end	of `this`
		Set by `this.length + pos`. If this yields a negative value, 0 is
		used instead.

		If the sum of the resulting values for `len` and `pos` exceed
		`this.length`, this operation will affect the elements from `pos` to the
		end of `this` Set.

		The length of the returned Set is equal to the new length of `this`
		Set subtracted from the original length of `this` Set. In other
		words, each element of the original `this` Set either remains in
		`this` Set or becomes an element of the returned Set.
	**/
	public inline function splice(pos:Int, len:Int):Set<T> {
		return this.splice(pos, len);
	}

	public inline function traverse(f:T->Void):Void {
		for (e in this)
			f(e);
	}

	@:to
	public inline function toArray():Array<T> {
		return this;
	}

	/**
		Returns a string representation of `this` Set.

		The result will include the individual elements' String representations
		separated by comma. The enclosing [ ] may be missing on some platforms,
		use `Std.string()` to get a String representation that is consistent
		across platforms.
	**/
	@:to
	public inline function toString():String {
		return this.toString();
	}

	/**
		Inserts the element `x` at the position `pos` if `this` doesn't already contain it.

		This operation modifies `this` Set in place.

		The offset is calculated like so:

		- If `pos` exceeds `this.length`, the offset is `this.length`.
		- If `pos` is negative, the offset is calculated from the end of `this`
		  Set, i.e. `this.length + pos`. If this yields a negative value, the
		  offset is 0.
		- Otherwise, the offset is `pos`.

		If the resulting offset does not exceed `this.length`, all elements from
		and including that offset to the end of `this` Set are moved one index
		ahead.
	**/
	public inline function insert(pos:Int, x:T):Void {
		if (!contains(x))
			this.insert(pos, x);
	}

	/**
		Returns whether `this` Set contains `x`.

		If `x` is found by checking standard equality, the function returns `true`, otherwise
		the function returns `false`.
	**/
	public inline function contains(x:T):Bool {
		return this.contains(x);
	}

	/**
		Returns position of the first occurrence of `x` in `this` Set, searching front to back.

		If `x` is found by checking standard equality, the function returns its index.

		If `x` is not found, the function returns -1.

		If `fromIndex` is specified, it will be used as the starting index to search from,
		otherwise search starts with zero index. If it is negative, it will be taken as the
		offset from the end of `this` Set to compute the starting index. If given or computed
		starting index is less than 0, the whole array will be searched, if it is greater than
		or equal to the length of `this` Set, the function returns -1.
	**/
	public inline function indexOf(x:T, ?fromIndex:Int):Int {
		return this.indexOf(x, fromIndex);
	}

	/**
		Returns position of the last occurrence of `x` in `this` Set, searching back to front.

		If `x` is found by checking standard equality, the function returns its index.

		If `x` is not found, the function returns -1.

		If `fromIndex` is specified, it will be used as the starting index to search from,
		otherwise search starts with the last element index. If it is negative, it will be
		taken as the offset from the end of `this` Set to compute the starting index. If
		given or computed starting index is greater than or equal to the length of `this` Set,
		the whole array will be searched, if it is less than 0, the function returns -1.
	**/
	public inline function lastIndexOf(x:T, ?fromIndex:Int):Int {
		return this.lastIndexOf(x, fromIndex);
	}

	/**
		Returns a shallow copy of `this` Set.

		The elements are not copied and retain their identity.
	**/
	public inline function copy():Set<T> {
		return this.copy();
	}

	@:op(a == b)
	public inline function equals(b:Set<T>):Bool {
		if (this.length != b.length)
			return false;
		var f = true;
		for (e in this)
			if (!b.contains(e)) {
				f = false;
				break;
			}
		return f;
	}

	@:op(a != b)
	public inline function nequals(b:Set<T>):Bool {
		return !equals(b);
	}

	@:op(a < b)
	public inline function lt(b:Set<T>):Bool {
		return this.length < b.length;
	}

	@:op(a <= b)
	public inline function ltequals(b:Set<T>):Bool {
		return lt(b) || equals(b);
	}

	@:op(a > b)
	public inline function gt(b:Set<T>):Bool {
		return this.length > b.length;
	}

	@:op(a >= b)
	public inline function gtequals(b:Set<T>):Bool {
		return gt(b) || equals(b);
	}

	/**
		Creates a new Set by applying function `f` to all elements of `this`.

		The order of elements is preserved.

		If `f` is null, the result is unspecified.
	**/
	public inline function map<S>(f:T->S):Set<S> {
		return this.map(f);
	}

	/**
		Returns an Set containing those elements of `this` for which `f`
		returned true.

		The individual elements are not duplicated and retain their identity.

		If `f` is null, the result is unspecified.
	**/
	public inline function filter(f:T->Bool):Set<T> {
		return this.filter(f);
	}

	/**
		Returns an iterator of the Set values.
	**/
	public inline function iterator():ArrayIterator<T> {
		return this.iterator();
	}

	/**
		Returns an iterator of the Set indices and values.
	**/
	public inline function keyValueIterator():ArrayKeyValueIterator<T> {
		return this.keyValueIterator();
	}

	private inline function get_length():Int {
		return this.length;
	}
}
