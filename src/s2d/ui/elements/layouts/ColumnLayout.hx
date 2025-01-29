package s2d.ui.elements.layouts;

// s2d.ui
import s2d.ui.elements.UIElement;
import s2d.ui.positioning.Alignment;
import s2d.ui.positioning.Direction;

using s2d.core.extensions.ArrayExt;

class ColumnLayout extends UIElement {
	@:isVar public var spacing(default, set):Float = 0.;
	@:isVar public var direction(default, set):Direction = Direction.TopToBottom;
	public var alignment:Alignment = Alignment.HCenter | Alignment.VCenter;

	function set_spacing(value:Float) {
		spacing = value;
		for (i in 1...children.length)
			children[i].anchors.top.margin = spacing;
		return value;
	}

	function set_direction(value:Direction) {
		if (direction == Direction.BottomToTop && value == Direction.TopToBottom)
			children.reverse();
		buildLayout();
		direction = value;
		return value;
	}

	function buildLayout() {
		if (direction == Direction.BottomToTop)
			children.reverse();

		var h = height / children.length;
		children[0].anchors.top = top;
		children[0].height = h;
		if ((alignment & Alignment.VCenter) != 0)
			children[0].anchors.verticalCenter = verticalCenter;

		for (i in 1...children.length) {
			children[i].anchors.top = children[i - 1].top;
			children[i].anchors.top.margin = spacing;
			children[i].height = h;
			if ((alignment & Alignment.VCenter) != 0)
				children[i].anchors.verticalCenter = verticalCenter;
		}
	}
}
