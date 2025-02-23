package s2d.ui;

import kha.Assets;
import se.Texture;
import se.system.Application;
import se.math.Mat3;

using kha.StringExtensions;

@:structInit
@:allow(se.SEngine)
@:allow(s2d.ui.UIElement)
class UIScene extends UIElement {
	public static var current:UIScene;

	function new() {
		super();
		Application.window.notifyOnResize((w, h) -> setSize(w, h));
	}

	override function render(target:Texture) {
		final ctx = target.context2D;

		updateBounds();
		ctx.begin();
		for (child in children) {
			child.updateBounds();
			child.render(target);
		}
		ctx.color = se.Color.rgb(1.0, 1.0, 1.0);
		ctx.opacity = 0.85;
		ctx.transformation = Mat3.identity();
		#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
		final e = childAt(Application.input.mouse.x, Application.input.mouse.y);
		if (e != null)
			drawBounds(e, target);
		#end
		ctx.end();
	}

	#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
	function drawBounds(e:UIElement, target:Texture) {
		final ctx = target.context2D;
		ctx.font = Assets.fonts.get("Roboto_Regular");
		ctx.fontSize = 16;

		final lm = e.anchors.left == null ? 0.0 : e.anchors.leftMargin;
		final tm = e.anchors.top == null ? 0.0 : e.anchors.topMargin;
		final rm = e.anchors.right == null ? 0.0 : e.anchors.rightMargin;
		final bm = e.anchors.bottom == null ? 0.0 : e.anchors.bottomMargin;
		final lp = e.left.padding;
		final tp = e.top.padding;
		final rp = e.right.padding;
		final bp = e.bottom.padding;

		ctx.color = se.Color.rgb(0.0, 0.0, 0.0);
		ctx.fillRect(e.x - lm, e.y - tm, e.width + rm, e.height + bm);

		// margins
		ctx.color = se.Color.rgb(0.75, 0.25, 0.75);
		ctx.fillRect(e.x - lm, e.y, lm, e.height);
		ctx.fillRect(e.x - lm, e.y - tm, lm + e.width + rm, tm);
		ctx.fillRect(e.x + e.width, e.y, rm, e.height);
		ctx.fillRect(e.x - lm, e.y + e.height, lm + e.width + rm, bm);

		// padding
		ctx.color = se.Color.rgb(0.75, 0.75, 0.25);
		ctx.fillRect(e.x, e.y, lp, e.height);
		ctx.fillRect(e.x + lp, e.y, e.width - lp - rp, tp);
		ctx.fillRect(e.x + e.width - rp, e.y, rp, e.height);
		ctx.fillRect(e.x + lp, e.y + e.height - bp, e.width - lp - rp, bp);

		// content
		ctx.color = se.Color.rgb(0.25, 0.75, 0.75);
		ctx.fillRect(e.x + lp, e.y + tp, e.width - lp - rp, e.height - tp - bp);

		// labels
		ctx.color = se.Color.rgb(1.0, 1.0, 1.0);
		final fs = ctx.fontSize + 5;

		// labels - titles
		if (tm >= fs)
			ctx.drawString("margins", e.x - lm + 5, e.y - tm + 5);
		if (tp >= fs)
			ctx.drawString("padding", e.x + 5, e.y + 5);
		if (e.height >= fs)
			ctx.drawString("content", e.x + lp + 5, e.y + tp + 5);

		// labels - values
		ctx.fontSize = 14;
		// margins
		var i = 0;
		for (m in [lm, tm, rm, bm]) {
			final str = '${Std.int(m)}px';
			final strWidth = ctx.font.widthOfCharacters(ctx.fontSize, str.toCharArray(), 0, str.length);
			final strheight = ctx.font.height(ctx.fontSize);
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
			final strWidth = ctx.font.widthOfCharacters(ctx.fontSize, str.toCharArray(), 0, str.length);
			final strheight = ctx.font.height(ctx.fontSize);
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

		ctx.fontSize = 22;
		final name = e.toString();
		ctx.drawString(name, Application.input.mouse.x - ctx.font.widthOfCharacters(ctx.fontSize, name.toCharArray(), 0, name.length),
			Application.input.mouse.y - ctx.font.height(ctx.fontSize));

		ctx.fontSize = 16;
		final rect = '${Std.int(e.width)} × ${Std.int(e.height)} at (${Std.int(e.x)}, ${Std.int(e.y)})';
		ctx.drawString(rect, Application.input.mouse.x
			- ctx.font.widthOfCharacters(ctx.fontSize, rect.toCharArray(), 0, rect.length),
			Application.input.mouse.y
			- ctx.font.height(ctx.fontSize)
			+ ctx.fontSize);
	}
	#end
}
