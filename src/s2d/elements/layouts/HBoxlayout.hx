package s2d.elements.layouts;

import se.math.VectorMath;
import s2d.Anchors;
import s2d.Direction;
import s2d.Box.SingleElementBox;

class HBoxlayout extends Element {
	var cells:Array<SingleElementBox> = [];

	@:inject(rebuild) var fillWidthCells:Int = 0;
	@:inject(rebuild) var availableWidth:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 0.0;
	@:inject(rebuild) public var direction:Direction = LeftToRight;

	public function new(?parent:Element) {
		super(parent);
	}

	override function __childAdded__(child:Element) {
		super.__childAdded__(child);
		addCell(child);
	}

	override function __childRemoved__(child:Element) {
		super.__childRemoved__(child);
		if (child.visible)
			for (c in cells)
				if (c.element == child) {
					c.remove(child);
					return;
				}
	}

	function addCell(el:Element) {
		var left:AnchorLine;
		var right:AnchorLine;
		if (direction & RightToLeft != 0) {
			right = new AnchorLine(-1.0);
			if (cells.length > 0)
				right.bindTo(cells[cells.length - 1].left);
			left = new AnchorLine(1.0);
		} else {
			left = new AnchorLine(1.0);
			if (cells.length > 0)
				left.bindTo(cells[cells.length - 1].right);
			right = new AnchorLine(-1.0);
		}
		left.padding = spacing;
		var cell = new SingleElementBox(el, left, this.top, right, this.bottom);
		el.layout.onFillWidthChanged(fw -> {
			if (!fw && el.layout.fillWidth) {
				cell.fillWidth(el);
				++fillWidthCells;
			} else if (fw && !el.layout.fillWidth) {
				cell.unfillWidth(el);
				cell.fitWidth(el);
				--fillWidthCells;
			}
		});
		cell.onAvailableWidthChanged(aw -> availableWidth += cell.availableWidth - aw);
		cells.push(cell);
		availableWidth -= cell.getPreferredWidth() ?? spacing;
		return cell;
	}

	function rebuild() {
		if (cells.length > 0)
			if (fillWidthCells > 0)
				rebuildFill();
			else
				rebuildFit();
	}

	function rebuildFill() {
		var fillWidth = clamp(availableWidth, 0.0, width - left.padding - right.padding) / fillWidthCells;
		var _c = fillWidthCells;
		if (direction & RightToLeft != 0) {
			cells[0].right.position = right.position - right.padding;
			for (cell in cells) {
				var cellWidth = cell.getPreferredWidth(fillWidth);
				if (cell.element.layout.fillWidth)
					fillWidth += (fillWidth - cellWidth) / --_c;
				cell.left.position = cell.right.position - cellWidth;
			}
		} else {
			cells[0].left.position = left.padding;
			for (cell in cells) {
				var cellWidth = cell.getPreferredWidth(fillWidth);
				if (cell.element.layout.fillWidth)
					fillWidth += (fillWidth - cellWidth) / --_c;
				cell.right.position = cell.left.position + cellWidth;
			}
		}
	}

	function rebuildFit() {
		final fillWidth = clamp(availableWidth, 0.0, width - left.padding - right.padding) / cells.length;
		if (direction & RightToLeft != 0) {
			cells[0].right.position = right.position - fillWidth * 0.5;
			for (cell in cells) {
				var cellWidth = cell.getPreferredWidth(fillWidth);
				cell.left.position = cell.right.position - cellWidth;
			}
		} else {
			cells[0].left.position = fillWidth * 0.5;
			for (cell in cells) {
				var cellWidth = cell.getPreferredWidth(fillWidth);
				cell.right.position = cell.left.position + cellWidth;
			}
		}
	}

	@:slot(widthChanged)
	function syncWidth(previous:Float) {
		availableWidth += width - previous;
	}

	@:slot(left.paddingChanged)
	function syncLeftPadding(previous:Float) {
		availableWidth += previous - left.padding;
	}

	@:slot(right.paddingChanged)
	function syncRightPadding(previous:Float) {
		availableWidth += previous - right.padding;
	}

	function set_spacing(value:Float):Float {
		final d = value - spacing;
		spacing = value;
		for (c in cells.slice(1))
			c.left.padding = spacing;
		availableWidth += d * (cells.length - 1);
		return spacing;
	}
}
