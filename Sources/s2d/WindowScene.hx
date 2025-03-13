package s2d;

import s2d.InteractiveElement.FocusPolicy;
import kha.Window;
import kha.Assets;
import kha.Framebuffer;
import se.App;
import se.Color;
import se.Texture;
import se.graphics.Context2D;
import se.events.MouseEvents;
import se.input.Mouse;

@:structInit
@:allow(se.App)
@:allow(se.SEngine)
@:allow(s2d.Element)
class WindowScene {
	static var current:WindowScene;

	var backbuffer:Texture;
	var elements:Array<Element> = [];
	var interactives:Array<InteractiveElement> = [];
	@:isVar var focused(default, set):InteractiveElement = null;

	public var color:Color = White;

	public function new(window:Window) {
		WindowScene.current = this;

		backbuffer = new Texture(window.width, window.height);
		window.notifyOnResize((w, h) -> backbuffer = new Texture(w, h));

		var m = App.input.mouse;
		m.onMoved(mouseMoved);
		m.onScrolled(d -> {
			mouseScrolled(d);
			adjustWheelFocus(d);
		});
		m.onDown(mouseDown);
		m.onUp(mouseUp);
		m.onHold(mouseHold);
		m.onClicked(mouseClicked);
		m.onDoubleClicked(mouseDoubleClicked);

		var k = App.input.keyboard;
		k.onKeyDown(Tab, adjustTabFocus);

		k.onDown(key -> if (focused != null) focused.keyboardDown(key));
		k.onUp(key -> if (focused != null) focused.keyboardUp(key));
		k.onHold(key -> if (focused != null) focused.keyboardHold(key));
		k.onPressed(char -> if (focused != null) focused.keyboardPressed(char));
	}

	public function elementAt(x:Float, y:Float):Element {
		var i = elements.length;
		while (--i >= 0) {
			final c = elements[i];
			var cat = c.descendantAt(x, y);
			if (cat == null) {
				if (c.contains(x, y))
					return c;
			} else
				return cat;
		};
		return null;
	}

	function adjustTabFocus() {
		final i = focused == null ? -1 : interactives.indexOf(focused);
		for (j in 1...interactives.length) {
			var e = interactives[(i + j) % interactives.length];
			if (e.enabled && (e.focusPolicy & TabFocus != 0)) {
				focused = e;
				return;
			}
		}
	}

	function adjustWheelFocus(d:Int) {
		final i = interactives.length + (focused == null ? -1 : interactives.indexOf(focused));
		for (j in 1...interactives.length) {
			var e = interactives[(i + (d > 0 ? j : -j)) % interactives.length];
			if (e.enabled && (e.focusPolicy & WheelFocus != 0)) {
				focused = e;
				return;
			}
		}
	}

	function processMouseEvent<T:MouseEvent>(event:T, f:(InteractiveElement, T) -> Void) {
		event.accepted = true;
		for (e in interactives)
			if (e.visible && e.enabled && e.contains(App.input.mouse.x, App.input.mouse.y)) {
				f(e, event);
				if (event.accepted)
					break;
			}
	}

	function mouseMoved(x:Int, y:Int, dx:Int, dy:Int):Void {
		inline processMouseEvent({
			x: x,
			y: y,
			dx: dx,
			dy: dy
		}, (c, m) -> c.mouseMoved.emit(m));
	}

	function mouseScrolled(d:Int):Void {
		inline processMouseEvent({
			delta: d
		}, (c, m) -> c.mouseScrolled.emit(m));
	}

	function mouseDown(b:MouseButton, x:Int, y:Int):Void {
		inline processMouseEvent({
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseDown.emit(m));
	}

	function mouseUp(b:MouseButton, x:Int, y:Int):Void {
		inline processMouseEvent({
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseUp.emit(m));
	}

	function mouseHold(b:MouseButton, x:Int, y:Int):Void {
		inline processMouseEvent({
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseHold.emit(m));
	}

	function mouseClicked(b:MouseButton, x:Int, y:Int):Void {
		inline processMouseEvent({
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseClicked.emit(m));
	}

	function mouseDoubleClicked(b:MouseButton, x:Int, y:Int):Void {
		inline processMouseEvent({
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseDoubleClicked.emit(m));
	}

	function render(target:Framebuffer) {
		backbuffer.ctx2D.render(true, color, ctx -> {
			for (e in elements)
				e.render(backbuffer);
			#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
			var e = elementAt(App.input.mouse.x, App.input.mouse.y);
			if (e != null)
				drawBounds(e, ctx);
			#end
		});

		final g2 = target.g2;
		g2.begin(true, color);
		g2.drawImage(backbuffer, 0, 0);
		g2.end();
	}

	#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
	private inline function drawBounds(e:Element, ctx:Context2D) {
		final style = ctx.style;

		style.font = Assets.fonts.get("Roboto_Regular");
		style.fontSize = 16;

		final lm = e.anchors.left == null ? 0.0 : e.anchors.left.margin;
		final tm = e.anchors.top == null ? 0.0 : e.anchors.top.margin;
		final rm = e.anchors.right == null ? 0.0 : e.anchors.right.margin;
		final bm = e.anchors.bottom == null ? 0.0 : e.anchors.bottom.margin;
		final lp = e.left.padding;
		final tp = e.top.padding;
		final rp = e.right.padding;
		final bp = e.bottom.padding;

		style.color = Black;
		ctx.fillRect(e.x - lm, e.y - tm, e.width + rm, e.height + bm);

		// margins
		style.color = se.Color.rgb(0.75, 0.25, 0.75);
		ctx.fillRect(e.x - lm, e.y, lm, e.height);
		ctx.fillRect(e.x - lm, e.y - tm, lm + e.width + rm, tm);
		ctx.fillRect(e.x + e.width, e.y, rm, e.height);
		ctx.fillRect(e.x - lm, e.y + e.height, lm + e.width + rm, bm);

		// padding
		style.color = se.Color.rgb(0.75, 0.75, 0.25);
		ctx.fillRect(e.x, e.y, lp, e.height);
		ctx.fillRect(e.x + lp, e.y, e.width - lp - rp, tp);
		ctx.fillRect(e.x + e.width - rp, e.y, rp, e.height);
		ctx.fillRect(e.x + lp, e.y + e.height - bp, e.width - lp - rp, bp);

		// content
		style.color = se.Color.rgb(0.25, 0.75, 0.75);
		ctx.fillRect(e.x + lp, e.y + tp, e.width - lp - rp, e.height - tp - bp);

		// labels
		style.color = se.Color.rgb(1.0, 1.0, 1.0);
		final fs = style.fontSize + 5;

		// labels - titles
		if (tm >= fs)
			ctx.drawString("margins", e.x - lm + 5, e.y - tm + 5);
		if (tp >= fs)
			ctx.drawString("padding", e.x + 5, e.y + 5);
		if (e.height >= fs)
			ctx.drawString("content", e.x + lp + 5, e.y + tp + 5);

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
					ctx.drawString(str, e.x - (m + strWidth) / 2, e.y + e.height / 2);
				else if (i == 2)
					ctx.drawString(str, e.x + e.width + (m - strWidth) / 2, e.y + e.height / 2);
			}
			if (m >= strheight) {
				if (i == 1)
					ctx.drawString(str, e.x + e.width / 2, e.y - (m + strheight) / 2);
				else if (i == 3)
					ctx.drawString(str, e.x + e.width / 2, e.y + e.height + (m - strheight) / 2);
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
					ctx.drawString(str, e.x + (p - strWidth) / 2, e.y + e.height / 2);
				else if (i == 2)
					ctx.drawString(str, e.x + e.width - (p + strWidth) / 2, e.y + e.height / 2);
			}
			if (p >= strheight) {
				if (i == 1)
					ctx.drawString(str, e.x + e.width / 2, e.y + (p - strheight) / 2);
				else if (i == 3)
					ctx.drawString(str, e.x + e.width / 2, e.y + e.height - (p + strheight) / 2);
			}
			++i;
		}

		style.fontSize = 22;
		final name = e.toString();
		ctx.drawString(name, App.input.mouse.x - style.font.widthOfCharacters(style.fontSize, name.toCharArray(), 0, name.length),
			App.input.mouse.y - style.font.height(style.fontSize));

		style.fontSize = 16;
		final rect = '${Std.int(e.width)} × ${Std.int(e.height)} at (${Std.int(e.x)}, ${Std.int(e.y)})';
		ctx.drawString(rect, App.input.mouse.x
			- style.font.widthOfCharacters(style.fontSize, rect.toCharArray(), 0, rect.length),
			App.input.mouse.y
			- style.font.height(style.fontSize)
			+ style.fontSize);
	}
	#end

	inline function set_focused(value:InteractiveElement):InteractiveElement {
		if (focused != value) {
			if (focused != null)
				focused.focused = false;
			value.focused = true;
			focused = value;
		}
		return focused;
	}
}
