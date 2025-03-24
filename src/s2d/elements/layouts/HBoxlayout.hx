package s2d.elements.layouts;

import s2d.Anchors;
import s2d.Direction;
import s2d.Box.SingleElementBox;

class HBoxLayout extends Element {
	var cells:Array<SingleElementBox> = [];
	var cellsSlots:Map<SingleElementBox, CellSlots> = [];

	@:inject(syncFreeSpacePerCell) var fillCells:Int = 0;
	@:inject(syncFreeSpacePerCell) var freeSpace:Float = 0.0;
	@:inject(syncLayout) var freeSpacePerCell:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 10.0;
	@:inject(syncLayout) public var direction:Direction = LeftToRight;

	public function new(?parent:Element) {
		super(parent);
	}

	@:slot(childAdded)
	function addCell(child:Element) {
		var cell = new SingleElementBox(child, new AnchorLine(1.0), this.top, new AnchorLine(-1.0), this.bottom);
		var slots = {
			requiredWidthChanged: (rw:Float) -> {
				if (!cell.fillWidth)
					freeSpace += rw - cell.requiredWidth;
			},
			fillWidthChanged: (fw:Bool) -> {
				if (!fw && cell.element.layout.fillWidth)
					++fillCells;
				else if (fw && !cell.element.layout.fillWidth)
					--fillCells;
			}
		}
		cell.onRequiredWidthChanged(slots.requiredWidthChanged);
		child.layout.onFillWidthChanged(slots.fillWidthChanged);
		cells.push(cell);
		cellsSlots.set(cell, slots);

		if (cell.fillWidth)
			++fillCells;
		freeSpace -= cell.requiredWidth + (cells.length > 1 ? spacing : 0.0);
	}

	@:slot(childRemoved)
	function removeCell(child:Element) {
		if (child.visible)
			for (c in cells) {
				if (c.element == child) {
					var slots = cellsSlots.get(c);
					c.remove(child);
					c.offRequiredWidthChanged(slots.requiredWidthChanged);
					child.layout.offFillWidthChanged(slots.fillWidthChanged);
					cells.remove(c);
					cellsSlots.remove(c);
					freeSpace += c.requiredWidth + (cells.length > 1 ? spacing : 0.0);
					return;
				}
			}
	}

	@:slot(widthChanged)
	function syncWidth(previous:Float) {
		freeSpace += width - previous;
	}

	@:slot(left.paddingChanged)
	function syncLeftPadding(previous:Float) {
		freeSpace += previous - left.padding;
	}

	@:slot(right.paddingChanged)
	function syncRightPadding(previous:Float) {
		freeSpace += previous - right.padding;
	}

	function syncLayout() {
		if (cells.length > 0) {
			if (direction & RightToLeft != 0) {
				var prev = cells[0];
				prev.right.position = right.position - right.padding;
				prev.left.position = prev.right.position - prev.requiredWidth - freeSpacePerCell;
				for (cell in cells.slice(1)) {
					cell.right.position = prev.left.position - spacing;
					cell.left.position = cell.right.position - cell.requiredWidth - freeSpacePerCell;
					prev = cell;
				}
			} else {
				var prev = cells[0];
				prev.left.position = left.padding;
				prev.right.position = prev.left.position + prev.requiredWidth + freeSpacePerCell;
				for (cell in cells.slice(1)) {
					cell.left.position = prev.right.position + spacing;
					cell.right.position = cell.left.position + cell.requiredWidth + freeSpacePerCell;
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
					if (cell.fillWidth) {
						cell.requiredWidth = cell.clampWidth(perCell);
						fw -= cell.requiredWidth;
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
	requiredWidthChanged:Float->Void,
	fillWidthChanged:Bool->Void
}
