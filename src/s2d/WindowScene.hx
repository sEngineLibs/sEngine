package s2d;

import kha.Window;
import se.App;
import se.Texture;
import se.input.Mouse;
import se.events.MouseEvents;
import s2d.FocusPolicy;

using se.extensions.StringExt;

@:structInit
@:allow(se.App)
@:allow(se.SEngine)
@:allow(s2d.Element)
final class WindowScene extends DrawableElement {
	var window:Window;
	var backbuffer:Texture;

	var pending:Array<Element> = [];
	var activeElements:Array<Element> = [];
	@:isVar var focusedElement(default, set):Element;

	@:signal function resized(width:Int, height:Int):Void;

	public function new(window:Window) {
		super("scene");

		width = window.width;
		height = window.height;

		window.notifyOnResize((w, h) -> {
			width = w;
			height = h;
			resized(w, h);
		});

		// handle mouse events
		var m = App.input.mouse;
		m.onMoved(processMouseMoved);
		m.onScrolled(d -> {
			processMouseScrolled(d, m.x, m.y);
			adjustWheelFocus(d);
		});
		m.onPressed(processMouseDown);
		m.onReleased(processMouseUp);
		m.onHold(processMouseHold);
		m.onClicked(processMouseClicked);
		m.onDoubleClicked(processMouseDoubleClicked);

		// handle keyboard events
		var k = App.input.keyboard;
		k.onKeyDown(Tab, adjustTabFocus);

		k.onDown(key -> if (focusedElement != null) focusedElement.keyboardDown(key));
		k.onUp(key -> if (focusedElement != null) focusedElement.keyboardUp(key));
		k.onHold(key -> if (focusedElement != null) focusedElement.keyboardHold(key));
		k.onPressed(char -> if (focusedElement != null) focusedElement.keyboardPressed(char));

		// init backbuffer
		this.window = window;
		onResized((w, h) -> backbuffer = new Texture(w, h));
		resized(Std.int(width), Std.int(height));
	}

	public inline function addElement(el:Element) {
		addChild(el);
	}

	public function elementAt(x:Float, y:Float):Null<Element> {
		var i = children.length;
		while (--i >= 0) {
			final c = children[i];
			var cat = c.descendantAt(x, y);
			if (cat == null) {
				if (c.contains(x, y))
					return c;
			} else
				return cat;
		};
		return null;
	}

	public inline function resize(width:Int, height:Int) {
		window.resize(width, height);
	}

	function draw(target:Texture) {
		target.context2D.render(true, color, ctx -> {
			for (e in children)
				e.render(backbuffer);
			#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
			var e = elementAt(App.input.mouse.x, App.input.mouse.y);
			if (e != null)
				drawBounds(e, ctx);
			#end
		});
	}

	function adjustTabFocus() {
		final i = focusedElement == null ? -1 : children.indexOf(focusedElement);
		for (j in 1...children.length) {
			var e = children[(i + j) % children.length];
			if (e.enabled && (e.focusPolicy & TabFocus != 0)) {
				focusedElement = e;
				return;
			}
		}
	}

	function adjustWheelFocus(d:Int) {
		final i = children.length + (focusedElement == null ? -1 : children.indexOf(focusedElement));
		for (j in 1...children.length) {
			var e = children[(i + (d > 0 ? j : -j)) % children.length];
			if (e.enabled && (e.focusPolicy & WheelFocus != 0)) {
				focusedElement = e;
				return;
			}
		}
	}

	function processMouseMoved(x:Int, y:Int, dx:Int, dy:Int):Void {
		final moved = {
			accepted: false,
			x: x,
			y: y,
			dx: dx,
			dy: dy
		}
		function f(el) {
			for (i in 1...(el.vChildren.length + 1))
				f(el.vChildren[el.vChildren.length - i]);
			if (el.enabled) {
				if (el.contains(App.input.mouse.x, App.input.mouse.y)) {
					if (!moved.accepted) {
						if (!activeElements.contains(el)) {
							activeElements.push(el);
							el.containsMouse = true;
							el.mouseEntered(x, y);
						}
						moved.accepted = true;
						el.mouseMoved(moved);
					} else if (activeElements.remove(el)) {
						el.containsMouse = false;
						el.mouseExited(x, y);
					}
				} else if (activeElements.remove(el)) {
					el.containsMouse = false;
					el.mouseExited(x, y);
				}
			}
		};
		for (i in 1...(children.length + 1)) {
			final el = children[children.length - i];
			if (el.visible)
				f(el);
		}
	}

	function processMouseEvent<T:MouseEvent>(event:T, f:(Element, T) -> Void) {
		for (el in activeElements) {
			f(el, event);
			if (event.accepted)
				break;
		}
	}

	function processMouseScrolled(d:Int, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			delta: d,
			x: x,
			y: y
		}, (c, m) -> c.mouseScrolled(m));
	}

	function processMouseDown(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> {
			pending.push(c);
			c.mousePressed(m);
		});
	}

	function processMouseUp(b:MouseButton, x:Int, y:Int):Void {
		final m = {
			accepted: true,
			button: b,
			x: x,
			y: y
		}
		for (el in pending)
			el.mouseReleased(m);
	}

	function processMouseHold(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseHold(m));
	}

	function processMouseClicked(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> {
			c.mouseClicked(m);
			if (!c.focused && (c.focusPolicy & ClickFocus != 0))
				this.focusedElement = c;
		});
	}

	function processMouseDoubleClicked(b:MouseButton, x:Int, y:Int):Void {
		processMouseEvent({
			accepted: true,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseDoubleClicked(m));
	}

	#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
	function drawBounds(e:Element, ctx:Context2D) {
		final style = ctx.style;

		style.opacity = 0.5;
		style.font = "Roboto_Regular";
		style.fontSize = 16;

		final lm = e.left.margin;
		final tm = e.top.margin;
		final rm = e.right.margin;
		final bm = e.bottom.margin;
		final lp = e.left.padding;
		final tp = e.top.padding;
		final rp = e.right.padding;
		final bp = e.bottom.padding;

		style.color = Black;
		ctx.fillRect(e.absX - lm, e.absY - tm, e.width + lm + rm, e.height + tm + bm);

		// margins
		style.color = se.Color.rgb(0.75, 0.25, 0.75);
		ctx.fillRect(e.absX - lm, e.absY, lm, e.height);
		ctx.fillRect(e.absX - lm, e.absY - tm, lm + e.width + rm, tm);
		ctx.fillRect(e.absX + e.width, e.absY, rm, e.height);
		ctx.fillRect(e.absX - lm, e.absY + e.height, lm + e.width + rm, bm);

		// padding
		style.color = se.Color.rgb(0.75, 0.75, 0.25);
		ctx.fillRect(e.absX, e.absY, lp, e.height);
		ctx.fillRect(e.absX + lp, e.absY, e.width - lp - rp, tp);
		ctx.fillRect(e.absX + e.width - rp, e.absY, rp, e.height);
		ctx.fillRect(e.absX + lp, e.absY + e.height - bp, e.width - lp - rp, bp);

		// content
		style.color = se.Color.rgb(0.25, 0.75, 0.75);
		ctx.fillRect(e.absX + lp, e.absY + tp, e.width - lp - rp, e.height - tp - bp);

		// labels
		style.color = se.Color.rgb(1.0, 1.0, 1.0);
		final fs = style.fontSize + 5;

		// labels - titles
		if (tm >= fs)
			ctx.drawString("margins", e.absX - lm + 5, e.absY - tm + 5);
		if (tp >= fs)
			ctx.drawString("padding", e.absX + 5, e.absY + 5);
		if (e.height >= fs)
			ctx.drawString("content", e.absX + lp + 5, e.absY + tp + 5);

		// labels - values
		style.fontSize = 14;

		// margins
		var i = 0;
		for (m in [lm, tm, rm, bm]) {
			final str = '${Std.int(m)}px';
			final strWidth = style.font.widthOfCharacters(style.fontSize, str.toCharArray(), 0, str.length);
			final strheight = style.font.height(style.fontSize);
			if (m >= strWidth) {
				if (i == 0)
					ctx.drawString(str, e.absX - (m + strWidth) / 2, e.absY + e.height / 2);
				else if (i == 2)
					ctx.drawString(str, e.absX + e.width + (m - strWidth) / 2, e.absY + e.height / 2);
			}
			if (m >= strheight) {
				if (i == 1)
					ctx.drawString(str, e.absX + e.width / 2, e.absY - (m + strheight) / 2);
				else if (i == 3)
					ctx.drawString(str, e.absX + e.width / 2, e.absY + e.height + (m - strheight) / 2);
			}
			++i;
		}

		// padding
		var i = 0;
		for (p in [lp, tp, rp, bp]) {
			final str = '${Std.int(p)}px';
			final strWidth = style.font.widthOfCharacters(style.fontSize, str.toCharArray(), 0, str.length);
			final strheight = style.font.height(style.fontSize);
			if (p >= strWidth) {
				if (i == 0)
					ctx.drawString(str, e.absX + (p - strWidth) / 2, e.absY + e.height / 2);
				else if (i == 2)
					ctx.drawString(str, e.absX + e.width - (p + strWidth) / 2, e.absY + e.height / 2);
			}
			if (p >= strheight) {
				if (i == 1)
					ctx.drawString(str, e.absX + e.width / 2, e.absY + (p - strheight) / 2);
				else if (i == 3)
					ctx.drawString(str, e.absX + e.width / 2, e.absY + e.height - (p + strheight) / 2);
			}
			++i;
		}

		style.fontSize = 22;
		final name = e.toString();
		ctx.drawString(name, App.input.mouse.x - style.font.widthOfCharacters(style.fontSize, name.toCharArray(), 0, name.length),
			App.input.mouse.y - style.font.height(style.fontSize));

		style.fontSize = 16;
		final rect = '${Std.int(e.width)} × ${Std.int(e.height)} at (${Std.int(e.absX)}, ${Std.int(e.absY)})';
		ctx.drawString(rect, App.input.mouse.x
			- style.font.widthOfCharacters(style.fontSize, rect.toCharArray(), 0, rect.length),
			App.input.mouse.y
			- style.font.height(style.fontSize)
			+ style.fontSize);
		style.opacity = 1.0;
	}
	#end

	function set_focusedElement(value:Element):Element {
		if (focusedElement != value) {
			if (focusedElement != null)
				focusedElement.focused = false;
			value.focused = true;
			focusedElement = value;
		}
		return focusedElement;
	}
}
