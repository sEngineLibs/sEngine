package se;

@:forward.new
@:forward()
extern abstract Stack<T>(StackData<T>) {
	public var length(get, never):Int;

	@:from
	static inline function fromArray<T>(value:Array<T>):Stack<T> {
		final s = new Stack();
		for (x in value)
			s.add(x);
		return s;
	}

	/**
		Creates a new empty Stack.
	**/
	public inline function new() {
		this = new StackData();
	}

	/**
		Returns a shallow copy of `this` Stack.

		The elements are not copied and retain their identity, 
		so `a[i] == a.copy()[i]` is `true` for any valid `i`. 
		However, `a == a.copy()` is always `false`.
	**/
	public inline function copy():Stack<T> {
		final s = new Stack();
		for (x in iterator())
			s.add(x);
		return s;
	}

	@:op(a + b)
	public inline function concat(b:Stack<T>):Stack<T> {
		final s = copy();
		for (x in b)
			s.add(x);
		return s;
	}

	/**
		Pushes element `item` onto the stack.
	**/
	@:op(a += b)
	public inline function add(x:T) {
		this.head = new StackCell<T>(x, this.head);
		++this.length;
	}

	/**
		Removes the first element which is equal to `v` according to the `==`
		operator.

		This method traverses the stack until it finds a matching element and
		unlinks it, returning true.

		If no matching element is found, false is returned.
	**/
	@:op(a -= b)
	public inline function remove(v:T):Bool {
		var prev:StackCell<T> = null;
		var l = this.head;
		while (l != null) {
			if (l.elt == v) {
				if (prev == null)
					this.head = l.next;
				else
					prev.next = l.next;
				break;
			}
			prev = l;
			l = l.next;
		}
		if (l != null) {
			--this.length;
			return true;
		}
		return false;
	}

	/**
		Returns the topmost stack element and removes it.

		If the stack is empty, null is returned.
	**/
	@:op(a--)
	public inline function pop():Null<T> {
		final k = this.head;

		if (k == null)
			return null;
		else {
			this.head = k.next;
			--this.length;
			return k.elt;
		}
	}

	@:arrayAccess
	public inline function get(i:Int):Null<T> {
		var k = this.head;
		while (--i >= 0 && k != null)
			k = k.next;
		return k?.elt;
	}

	@:arrayAccess
	public inline function set(i:Int, value:T):Void {
		if (value != null) {
			var k = this.head;
			while (--i >= 0 && k != null)
				k = k.next;
			if (k != null)
				k.elt = value;
		} else
			remove(get(i));
	}

	/**
		Returns the topmost stack element without removing it.

		If the stack is empty, null is returned.
	**/
	public inline function first():Null<T> {
		return this.head?.elt;
	}

	/**
		Tells if the stack is empty.
	**/
	public inline function isEmpty():Bool {
		return this.head == null;
	}

	#if cpp
	/**
		Returns an iterator over the elements of `this` Stack.
	**/
	public inline function iterator():Iterator<T> {
		return new StackIterator<T>(head);
	}
	#else

	/**
		Returns an iterator over the elements of `this` Stack.
	**/
	public inline function iterator():Iterator<T> {
		var l = this.head;
		return {
			hasNext: () -> l != null,
			next: () -> {
				var k = l;
				l = k.next;
				k.elt;
			}
		};
	}
	#end

	/**
		Returns a String representation of `this` Stack.
	**/
	public inline function toString():String {
		var a = new Array();
		var l = this.head;
		while (l != null) {
			a.push(l.elt);
			l = l.next;
		}
		return "{" + a.join(",") + "}";
	}

	inline function get_length():Int {
		return this.length;
	}
}

#if (flash || cpp)
@:generic
#end
@:allow(se.Stack)
class StackData<T> {
	var head:StackCell<T>;
	var length:Int = 0;

	function new() {}
}

#if (flash || cpp)
@:generic
#end
@:allow(se.Stack)
class StackCell<T> {
	var elt:T;
	var next:StackCell<T>;

	inline function new(elt, next) {
		this.elt = elt;
		this.next = next;
	}
}

#if cpp
@:generic
#if cppia
private class StackIterator<T> {
	public var current:StackCell<T>;

	public function new(head) {
		current = head;
	}

	public function hasNext():Bool {
		return current != null;
	}

	public function next():T {
		var result = current.elt;
		current = current.next;
		return result;
	}
}
#else
private class StackIterator<T> extends cpp.FastIterator<T> {
	public var current:StackCell<T>;

	public function new(head) {
		current = head;
	}

	public function hasNext():Bool {
		return current != null;
	}

	public function next():T {
		var result = current.elt;
		current = current.next;
		return result;
	}
}
#end
#end
