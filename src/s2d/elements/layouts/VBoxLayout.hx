package s2d.elements.layouts;

import s2d.Anchors;
import s2d.Direction;

class VBoxLayout extends Element {
	var cells:Array<LayoutCell> = [];
	var cellsSlots:Map<LayoutCell, CellSlots> = [];

	@:inject(syncFreeSpacePerCell) var fillCells:Int = 0;
	@:inject(syncFreeSpacePerCell) var freeSpace:Float = 0.0;
	@:inject(syncLayout) var freeSpacePerCell:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 10.0;
	@:inject(syncLayout) public var direction:Direction = TopToBottom;

	public function new() {
		super();
	}

	@:slot(childAdded)
	function addCell(child:Element) {
		var cell = new LayoutCell(child, this.left, new TopAnchor(), this.right, new BottomAnchor());
		var slots = {
			requiredHeightChanged: (rh:Float) -> {
				if (!cell.fillHeight)
					freeSpace += rh - cell.requiredHeight;
			},
			fillHeightChanged: (fh:Bool) -> {
				if (!fh && cell.element.layout.fillHeight)
					++fillCells;
				else if (fh && !cell.element.layout.fillHeight)
					--fillCells;
			}
		}
		cell.onRequiredHeightChanged(slots.requiredHeightChanged);
		child.layout.onFillHeightChanged(slots.fillHeightChanged);
		cells.push(cell);
		cellsSlots.set(cell, slots);

		if (cell.fillHeight)
			++fillCells;
		freeSpace -= cell.requiredHeight + (cells.length > 1 ? spacing : 0.0);
	}

	@:slot(childRemoved)
	function removeCell(child:Element) {
		if (child.visible)
			for (c in cells) {
				if (c.element == child) {
					var slots = cellsSlots.get(c);
					c.remove(child);
					c.offRequiredHeightChanged(slots.requiredHeightChanged);
					child.layout.offFillHeightChanged(slots.fillHeightChanged);
					cells.remove(c);
					cellsSlots.remove(c);
					freeSpace += c.requiredHeight + (cells.length > 1 ? spacing : 0.0);
					return;
				}
			}
	}

	@:slot(heightChanged)
	function syncHeight(previous:Float) {
		freeSpace += height - previous;
	}

	@:slot(top.paddingChanged)
	function syncTopPadding(previous:Float) {
		freeSpace += previous - top.padding;
	}

	@:slot(bottom.paddingChanged)
	function syncBottomPadding(previous:Float) {
		freeSpace += previous - bottom.padding;
	}

	function syncLayout() {
		if (cells.length > 0) {
			if (direction & BottomToTop != 0) {
				var prev = cells[0];
				prev.bottom.position = bottom.position - bottom.padding;
				prev.top.position = prev.bottom.position - prev.requiredHeight - freeSpacePerCell;
				for (cell in cells.slice(1)) {
					cell.bottom.position = prev.top.position - spacing;
					cell.top.position = cell.bottom.position - cell.requiredHeight - freeSpacePerCell;
					prev = cell;
				}
			} else {
				var prev = cells[0];
				prev.top.position = top.padding;
				prev.bottom.position = prev.top.position + prev.requiredHeight + freeSpacePerCell;
				for (cell in cells.slice(1)) {
					cell.top.position = prev.bottom.position + spacing;
					cell.bottom.position = cell.top.position + cell.requiredHeight + freeSpacePerCell;
					prev = cell;
				}
			}
		}
	}

	function syncFreeSpacePerCell() {
		if (cells.length > 0)
			if (fillCells > 0) {
				final perCell = freeSpace / fillCells;
				var fw = freeSpace;
				for (cell in cells)
					if (cell.fillHeight) {
						cell.requiredHeight = cell.clampHeight(perCell);
						fw -= cell.requiredHeight;
					}
				freeSpacePerCell = Math.max(0.0, fw / cells.length);
			} else
				freeSpacePerCell = Math.max(0.0, freeSpace / cells.length);
	}

	function set_spacing(value:Float):Float {
		final d = spacing - value;
		spacing = value;
		freeSpace += d * (cells.length - 1);
		return spacing;
	}
}

private typedef CellSlots = {
	requiredHeightChanged:Float->Void,
	fillHeightChanged:Bool->Void
}
