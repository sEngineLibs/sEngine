package se.ui;

import kha.Assets;
import kha.Canvas;
import se.system.Application;
import se.math.Mat3;
import se.ui.elements.UIElement;

using kha.StringExtensions;

@:structInit
@:allow(se.SEngine)
@:allow(se.ui.elements.UIElement)
class UIScene {
	public static var current:UIScene;

	var elements:Array<UIElement> = [];

	function new() {}

	function addBaseElement(element:UIElement) {
		elements.push(element);
	}

	function removeBaseElement(element:UIElement) {
		elements.remove(element);
	}

	public function elementAt(x:Float, y:Float):UIElement {
		var c:UIElement = null;
		for (i in 1...elements.length + 1) {
			final element = elements[elements.length - i];
			final e = element.childAt(x, y);

			if (e != null) {
				c = e;
				break;
			} else if (element.contains(x, y)) {
				c = element;
				break;
			}
		}
		return c;
	}

	function render(target:Canvas) {
		final g2 = target.g2;

		g2.begin(false);
		for (element in elements)
			element.render(target);
		g2.color = White;
		g2.opacity = 0.85;
		g2.transformation = Mat3.identity();
		#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
		final e = elementAt(Application.input.mouse.x, Application.input.mouse.y);
		if (e != null)
			drawBounds(e, target);
		#end
		g2.end();
	}

	#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
	function drawBounds(e:UIElement, target:Canvas) {
		final g2 = target.g2;
		g2.font = Assets.fonts.get("Roboto_Regular");
		g2.fontSize = 16;

		final lm = e.anchors.left == null ? 0.0 : e.anchors.leftMargin;
		final tm = e.anchors.top == null ? 0.0 : e.anchors.topMargin;
		final rm = e.anchors.right == null ? 0.0 : e.anchors.rightMargin;
		final bm = e.anchors.bottom == null ? 0.0 : e.anchors.bottomMargin;
		final lp = e.left.padding;
		final tp = e.top.padding;
		final rp = e.right.padding;
		final bp = e.bottom.padding;

		g2.color = Black;
		g2.fillRect(e.x - lm, e.y - tm, e.width + rm, e.height + bm);

		// margins
		g2.color = Color.fromFloats(0.75, 0.25, 0.75);
		g2.fillRect(e.x - lm, e.y, lm, e.height);
		g2.fillRect(e.x - lm, e.y - tm, lm + e.width + rm, tm);
		g2.fillRect(e.x + e.width, e.y, rm, e.height);
		g2.fillRect(e.x - lm, e.y + e.height, lm + e.width + rm, bm);

		// padding
		g2.color = Color.fromFloats(0.75, 0.75, 0.25);
		g2.fillRect(e.x, e.y, lp, e.height);
		g2.fillRect(e.x + lp, e.y, e.width - lp - rp, tp);
		g2.fillRect(e.x + e.width - rp, e.y, rp, e.height);
		g2.fillRect(e.x + lp, e.y + e.height - bp, e.width - lp - rp, bp);

		// content
		g2.color = Color.fromFloats(0.25, 0.75, 0.75);
		g2.fillRect(e.x + lp, e.y + tp, e.width - lp - rp, e.height - tp - bp);

		// labels
		g2.color = White;
		final fs = g2.fontSize + 5;

		// labels - titles
		if (tm >= fs)
			g2.drawString("margins", e.x - lm + 5, e.y - tm + 5);
		if (tp >= fs)
			g2.drawString("padding", e.x + 5, e.y + 5);
		if (e.height >= fs)
			g2.drawString("content", e.x + lp + 5, e.y + tp + 5);

		// labels - values
		g2.fontSize = 14;
		// margins
		var i = 0;
		for (m in [lm, tm, rm, bm]) {
			final str = '${Std.int(m)}px';
			final strWidth = g2.font.widthOfCharacters(g2.fontSize, str.toCharArray(), 0, str.length);
			final strheight = g2.font.height(g2.fontSize);
			if (m >= strWidth) {
				if (i == 0)
					g2.drawString(str, e.x - (m + strWidth) / 2, e.y + e.height / 2);
				else if (i == 2)
					g2.drawString(str, e.x + e.width + (m - strWidth) / 2, e.y + e.height / 2);
			}
			if (m >= strheight) {
				if (i == 1)
					g2.drawString(str, e.x + e.width / 2, e.y - (m + strheight) / 2);
				else if (i == 3)
					g2.drawString(str, e.x + e.width / 2, e.y + e.height + (m - strheight) / 2);
			}
			++i;
		}
		// padding
		var i = 0;
		for (p in [lp, tp, rp, bp]) {
			final str = '${Std.int(p)}px';
			final strWidth = g2.font.widthOfCharacters(g2.fontSize, str.toCharArray(), 0, str.length);
			final strheight = g2.font.height(g2.fontSize);
			if (p >= strWidth) {
				if (i == 0)
					g2.drawString(str, e.x + (p - strWidth) / 2, e.y + e.height / 2);
				else if (i == 2)
					g2.drawString(str, e.x + e.width - (p + strWidth) / 2, e.y + e.height / 2);
			}
			if (p >= strheight) {
				if (i == 1)
					g2.drawString(str, e.x + e.width / 2, e.y + (p - strheight) / 2);
				else if (i == 3)
					g2.drawString(str, e.x + e.width / 2, e.y + e.height - (p + strheight) / 2);
			}
			++i;
		}

		g2.fontSize = 22;
		final name = e.toString();
		g2.drawString(name, Application.input.mouse.x - g2.font.widthOfCharacters(g2.fontSize, name.toCharArray(), 0, name.length),
			Application.input.mouse.y - g2.font.height(g2.fontSize));

		g2.fontSize = 16;
		final rect = '${Std.int(e.width)} × ${Std.int(e.height)} at (${Std.int(e.x)}, ${Std.int(e.y)})';
		g2.drawString(rect, Application.input.mouse.x
			- g2.font.widthOfCharacters(g2.fontSize, rect.toCharArray(), 0, rect.length),
			Application.input.mouse.y
			- g2.font.height(g2.fontSize)
			+ g2.fontSize);
	}
	#end
}
