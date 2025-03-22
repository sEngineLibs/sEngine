package s2d.elements.layouts;

import se.math.VectorMath;
import s2d.Direction;
import s2d.elements.layouts.Box;

class VBox extends Element {
	var cells:Array<SingleElementBoxCell> = [];

	var rowsnum:Int = 0;
	@:inject(rebuild) var availableHeight:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 0.0;
	@:inject(rebuild) public var direction:Direction = TopToBottom;

	public function new(?parent:Element) {
		super(parent);
	}

	override function __childAdded__(child:Element) {
		super.__childAdded__(child);

		var cell = addCell(child);
		var childSlot = v -> {
			if (!v && child.visible)
				cell.add(child);
			else if (v && !child.visible)
				cell.remove(child);
		}
		var dirtySlot = (v:Float) -> rebuild();
		var spanSlot = previous -> {
			rowsnum += child.layout.rowSpan - previous;
			rebuild();
		};
		child.onVisibleChanged(childSlot);
		child.layout.onRowSpanChanged(spanSlot);
		child.layout.onMinimumHeightChanged(dirtySlot);
		child.layout.onMaximumHeightChanged(dirtySlot);
		child.layout.onPreferredHeightChanged(dirtySlot);

		child.onParentChanged(_ -> {
			child.offVisibleChanged(childSlot);
			child.layout.offRowSpanChanged(spanSlot);
			child.layout.offMinimumHeightChanged(dirtySlot);
			child.layout.offMaximumHeightChanged(dirtySlot);
			child.layout.offPreferredHeightChanged(dirtySlot);
		});

		rowsnum += child.layout.rowSpan;
		availableHeight -= cells.length > 1 ? spacing : 0.0;
	}

	override function __childRemoved__(child:Element) {
		super.__childRemoved__(child);
		if (child.visible)
			for (c in cells)
				@:privateAccess if (c.element == child) {
					c.remove(child);
					return;
				}
	}

	function addCell(el:Element) {
		var cell = new SingleElementBoxCell(el);
		cells.push(cell);
		cell.left = left.padding;
		cell.right = height - right.padding;
		return cell;
	}

	function rebuild() {
		var aw = availableHeight;
		var cn = rowsnum;
		if (cn > 0) {
			if (direction & BottomToTop != 0) {
				var b = height - bottom.padding;
				for (cell in cells) {
					var el = @:privateAccess cell.element;
					var cellHeight = getCellHeight(el, aw / cn);
					cell.bottom = b;
					cell.top = cell.bottom - cellHeight;

					b -= cellHeight + spacing;
					aw -= cellHeight;
					cn -= el.layout.rowSpan;
				}
			} else {
				var b = top.padding;
				for (cell in cells) {
					var el = @:privateAccess cell.element;
					var cellHeight = getCellHeight(el, aw / cn);
					cell.top = b;
					cell.bottom = cell.top + cellHeight;

					b += cellHeight + spacing;
					aw -= cellHeight;
					cn -= el.layout.rowSpan;
				}
			}
		}
	}

	function getCellHeight(el:Element, h:Float) {
		var l = el.layout;
		var cellHeight;
		if (Math.isNaN(l.preferredHeight))
			cellHeight = l.fillHeight ? h * l.rowSpan : Math.max(h * l.rowSpan, el.height);
		else
			cellHeight = l.preferredHeight;
		return el.top.margin + clamp(cellHeight, l.minimumHeight, l.maximumHeight) + el.bottom.margin;
	}

	@:slot(heightChanged)
	function syncHeight(previous:Float) {
		availableHeight += height - previous;
	}

	@:slot(top.paddingChanged)
	function syncTopPadding(previous:Float) {
		availableHeight += previous - top.padding;
	}

	@:slot(bottom.paddingChanged)
	function syncBottomPadding(previous:Float) {
		availableHeight += previous - bottom.padding;
	}

	@:slot(widthChanged)
	function syncWidth(previous:Float) {
		final d = width - previous;
		for (cell in cells)
			cell.right += d;
	}

	@:slot(left.paddingChanged)
	function syncLeftPadding(previous:Float) {
		final d = left.padding - previous;
		for (c in cells)
			c.left += d;
	}

	@:slot(right.paddingChanged)
	function syncRightPadding(previous:Float) {
		final d = previous - right.padding;
		for (c in cells)
			c.right += d;
	}

	function set_spacing(value:Float):Float {
		final d = value - spacing;
		spacing = value;
		availableHeight += d * (cells.length - 1);
		return spacing;
	}
}
