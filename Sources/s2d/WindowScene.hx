package s2d;

import se.Color;
import kha.Framebuffer;
import kha.Window;
import kha.Assets;
import se.App;
import se.Texture;
import se.graphics.Context2D;
import se.events.MouseEvents;
import se.system.input.Mouse;

using kha.StringExtensions;

@:structInit
@:allow(se.App)
@:allow(se.SEngine)
@:allow(s2d.Element)
class WindowScene {
	static var current:WindowScene;

	var backbuffer:Texture;
	var elements:Array<Element> = [];

	public var color:Color = White;

	public function new(window:Window) {
		WindowScene.current = this;

		backbuffer = new Texture(window.width, window.height);
		window.notifyOnResize((w, h) -> backbuffer = new Texture(w, h));

		var m = App.input.mouse;
		m.onMoved(_moved);
		m.onScrolled(_scrolled);
		m.onDown(_down);
		m.onUp(_up);
		m.onHold(_hold);
		m.onClicked(_clicked);
		m.onDoubleClicked(_doubleClicked);
	}

	function traverse(e:Array<Element>, f:Element->Bool) {
		var i = e.length;
		while (0 < i) {
			final c = e[--i];
			if (!traverse(c.children, f) && c.contains(App.input.mouse.x, App.input.mouse.x) && f(c))
				return true;
		}
		return false;
	}

	function process<T:MouseEvent>(event:T, f:(Element, T) -> Void) {
		traverse(this.elements, c -> {
			f(c, event);
			event.accepted;
		});
	}

	function _moved(x:Int, y:Int, dx:Int, dy:Int):Void {
		process({
			accepted: false,
			x: x,
			y: y,
			dx: dx,
			dy: dy
		}, (c, m) -> c.mouseMoved.emit(m));
	}

	function _scrolled(d:Int):Void {
		process({
			accepted: false,
			delta: d
		}, (c, m) -> c.mouseScrolled.emit(m));
	}

	function _down(b:MouseButton, x:Int, y:Int):Void {
		process({
			accepted: false,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseDown.emit(m));
	}

	function _up(b:MouseButton, x:Int, y:Int):Void {
		process({
			accepted: false,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseUp.emit(m));
	}

	function _hold(b:MouseButton, x:Int, y:Int):Void {
		process({
			accepted: false,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseHold.emit(m));
	}

	function _clicked(b:MouseButton, x:Int, y:Int):Void {
		process({
			accepted: false,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseClicked.emit(m));
	}

	function _doubleClicked(b:MouseButton, x:Int, y:Int):Void {
		process({
			accepted: false,
			button: b,
			x: x,
			y: y
		}, (c, m) -> c.mouseDoubleClicked.emit(m));
	}

	function render(target:Framebuffer) {
		backbuffer.ctx2D.render(true, color, ctx -> {
			for (e in elements)
				e.render(backbuffer);
			// #if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
			// var e = descendantAt(App.input.mouse.x, App.input.mouse.y);
			// if (e != null)
			// 	drawBounds(e, ctx);
			// #end
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
}
