package s2d.ui.elements.layouts;

import s2d.ui.elements.UIElement;
import s2d.ui.positioning.Alignment;

using s2d.core.extensions.ArrayExt;

class Layout extends UIElement {
	public var alignment:Alignment;

	public function new(?alignment:Alignment = Alignment.Center) {
		super();
		this.alignment = alignment;
	}

	override function addChild(element:UIElement) {
		children.push(element);
		element.parent = this;

		if ((alignment & Alignment.Left) != 0)
			element.anchors.left = left;
		if ((alignment & Alignment.Right) != 0)
			element.anchors.right = right;
		if ((alignment & Alignment.Top) != 0)
			element.anchors.top = top;
		if ((alignment & Alignment.Bottom) != 0)
			element.anchors.bottom = bottom;
	}
}
