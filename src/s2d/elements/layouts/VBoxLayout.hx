package s2d.elements.layouts;

import se.math.VectorMath;
import s2d.Anchors;
import s2d.Direction;
import s2d.elements.layouts.BoxLayout;

class VBoxLayout extends Element {
	var cells:Array<SingleElementBox> = [];

	@:inject(rebuild) var fillHeightCells:Int = 0;
	@:inject(rebuild) var availableHeight:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 0.0;
	@:inject(rebuild) public var direction:Direction = TopToBottom;

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
		var top:AnchorLine;
		var bottom:AnchorLine;
		if (direction & BottomToTop != 0) {
			bottom = new AnchorLine(-1.0);
			if (cells.length > 0)
				bottom.bindTo(cells[cells.length - 1].top);
			top = new AnchorLine(1.0);
		} else {
			top = new AnchorLine(1.0);
			if (cells.length > 0)
				top.bindTo(cells[cells.length - 1].bottom);
			bottom = new AnchorLine(-1.0);
		}
		top.padding = spacing;
		var cell = new SingleElementBox(el, top, this.top, bottom, this.bottom);
		el.layout.onFillHeightChanged(fw -> {
			if (!fw && el.layout.fillHeight) {
				cell.fillHeight(el);
				++fillHeightCells;
			} else if (fw && !el.layout.fillHeight) {
				cell.unfillHeight(el);
				cell.fitHeight(el);
				--fillHeightCells;
			}
		});
		cell.onAvailableHeightChanged(aw -> availableHeight += cell.availableHeight - aw);
		cells.push(cell);
		availableHeight -= cell.getPreferredHeight() ?? spacing;
		return cell;
	}

	function rebuild() {
		if (cells.length > 0)
			if (fillHeightCells > 0)
				rebuildFill();
			else
				rebuildFit();
	}

	function rebuildFill() {
		var fillHeight = clamp(availableHeight, 0.0, height - top.padding - bottom.padding) / fillHeightCells;
		var _c = fillHeightCells;
		if (direction & BottomToTop != 0) {
			cells[0].bottom.position = bottom.position - bottom.padding;
			for (cell in cells) {
				var cellHeight = cell.getPreferredHeight(fillHeight);
				if (cell.element.layout.fillHeight)
					fillHeight += (fillHeight - cellHeight) / --_c;
				cell.top.position = cell.bottom.position - cellHeight;
			}
		} else {
			cells[0].top.position = top.padding;
			for (cell in cells) {
				var cellHeight = cell.getPreferredHeight(fillHeight);
				if (cell.element.layout.fillHeight)
					fillHeight += (fillHeight - cellHeight) / --_c;
				cell.bottom.position = cell.top.position + cellHeight;
			}
		}
	}

	function rebuildFit() {
		final fillHeight = clamp(availableHeight, 0.0, height - top.padding - bottom.padding) / cells.length;
		if (direction & BottomToTop != 0) {
			cells[0].bottom.position = bottom.position - fillHeight * 0.5;
			for (cell in cells) {
				var cellHeight = cell.getPreferredHeight(fillHeight);
				cell.top.position = cell.bottom.position - cellHeight;
			}
		} else {
			cells[0].top.position = fillHeight * 0.5;
			for (cell in cells) {
				var cellHeight = cell.getPreferredHeight(fillHeight);
				cell.bottom.position = cell.top.position + cellHeight;
			}
		}
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

	function set_spacing(value:Float):Float {
		final d = value - spacing;
		spacing = value;
		for (c in cells.slice(1))
			c.top.padding = spacing;
		availableHeight += d * (cells.length - 1);
		return spacing;
	}
}
