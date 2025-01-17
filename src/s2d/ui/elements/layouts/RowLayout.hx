package sui.elements.layouts;

// sui
import sui.elements.Element;
import sui.positioning.Alignment;
import sui.positioning.Direction;

using score.utils.ArrayExt;

class RowLayout extends Element {
	@:isVar public var spacing(default, set):Float = 0.;
	@:isVar public var direction(default, set):Direction = Direction.LeftToRight;
	public var alignment:Alignment = Alignment.HCenter | Alignment.VCenter;

	inline function set_spacing(value:Float) {
		spacing = value;
		for (i in 1...children.length)
			children[i].anchors.leftMargin = spacing;
		return value;
	}

	inline function set_direction(value:Direction) {
		if (direction == Direction.LeftToRight && value == Direction.RightToLeft || direction == Direction.RightToLeft && value == Direction.LeftToRight)
			children.reverse();
		buildLayout();
		direction = value;
		return value;
	}

	inline function buildLayout() {
		if (direction == Direction.RightToLeft)
			children.reverse();

		var w = width / children.length;
		children[0].anchors.left = left;
		children[0].width = w;
		if ((alignment & Alignment.HCenter) != 0)
			children[0].anchors.horizontalCenter = horizontalCenter;

		for (i in 1...children.length) {
			children[i].anchors.left = children[i - 1].left;
			children[i].anchors.leftMargin = spacing;
			children[i].width = w;
			if ((alignment & Alignment.HCenter) != 0)
				children[i].anchors.horizontalCenter = horizontalCenter;
		}
	}
}
