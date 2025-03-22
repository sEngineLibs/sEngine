package s2d.elements.layouts;

import se.math.VectorMath;
import s2d.Direction;
import s2d.elements.layouts.Box;

class HBox extends Element {
	var cells:Array<SingleElementBoxCell> = [];

	var colsnum:Int = 0;
	@:inject(rebuild) var availableWidth:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 0.0;
	@:inject(rebuild) public var direction:Direction = LeftToRight;

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
			colsnum += child.layout.columnSpan - previous;
			rebuild();
		};
		child.onVisibleChanged(childSlot);
		child.layout.onColumnSpanChanged(spanSlot);
		child.layout.onMinimumWidthChanged(dirtySlot);
		child.layout.onMaximumWidthChanged(dirtySlot);
		child.layout.onPreferredWidthChanged(dirtySlot);

		child.onParentChanged(_ -> {
			child.offVisibleChanged(childSlot);
			child.layout.offColumnSpanChanged(spanSlot);
			child.layout.offMinimumWidthChanged(dirtySlot);
			child.layout.offMaximumWidthChanged(dirtySlot);
			child.layout.offPreferredWidthChanged(dirtySlot);
		});

		colsnum += child.layout.columnSpan;
		availableWidth -= cells.length > 1 ? spacing : 0.0;
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
		cell.top = top.padding;
		cell.bottom = height - bottom.padding;
		return cell;
	}

	function rebuild() {
		var aw = availableWidth;
		var cn = colsnum;
		if (cn > 0) {
			if (direction & RightToLeft != 0) {
				var b = width - right.padding;
				for (cell in cells) {
					var el = @:privateAccess cell.element;
					var cellWidth = getCellWidth(el, aw / cn);
					cell.right = b;
					cell.left = cell.right - cellWidth;

					b -= cellWidth + spacing;
					aw -= cellWidth;
					cn -= el.layout.columnSpan;
				}
			} else {
				var b = left.padding;
				for (cell in cells) {
					var el = @:privateAccess cell.element;
					var cellWidth = getCellWidth(el, aw / cn);
					cell.left = b;
					cell.right = cell.left + cellWidth;

					b += cellWidth + spacing;
					aw -= cellWidth;
					cn -= el.layout.columnSpan;
				}
			}
		}
	}

	function getCellWidth(el:Element, w:Float) {
		var l = el.layout;
		var cellWidth;
		if (Math.isNaN(l.preferredWidth))
			cellWidth = l.fillWidth ? w * l.columnSpan : Math.max(w * l.columnSpan, el.width);
		else
			cellWidth = l.preferredWidth;
		return el.left.margin + clamp(cellWidth, l.minimumWidth, l.maximumWidth) + el.right.margin;
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

	@:slot(heightChanged)
	function syncHeight(previous:Float) {
		final d = height - previous;
		for (cell in cells)
			cell.bottom += d;
	}

	@:slot(top.paddingChanged)
	function syncTopPadding(previous:Float) {
		final d = top.padding - previous;
		for (c in cells)
			c.top += d;
	}

	@:slot(bottom.paddingChanged)
	function syncBottomPadding(previous:Float) {
		final d = previous - bottom.padding;
		for (c in cells)
			c.bottom += d;
	}

	function set_spacing(value:Float):Float {
		final d = value - spacing;
		spacing = value;
		availableWidth += d * (cells.length - 1);
		return spacing;
	}
}
