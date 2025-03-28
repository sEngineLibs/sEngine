package s2d.layouts;

import s2d.Anchors;
import s2d.Direction;

using se.extensions.ArrayExt;

class HBoxLayout extends Element {
	var cells:Array<LayoutCell> = [];
	var cellsSlots:Map<LayoutCell, {
		requiredWidthChanged:Float->Void,
		fillWidthChanged:Bool->Void
	}> = [];

	@:inject(syncFreeSpacePerCell) var fillCells:Int = 0;
	@:inject(syncFreeSpacePerCell) var freeSpace:Float = 0.0;
	@:inject(syncLayout) var freeSpacePerCell:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 10.0;
	@:inject(syncLayout) public var direction:Direction = LeftToRight;

	public function new(?scene:WindowScene) {
		super(scene);
	}

	@:slot(vChildAdded)
	function add(child:Element) {
		var cell = getCell(child);
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

	@:slot(vChildRemoved)
	function remove(child:Element) {
		for (cell in cells)
			if (cell.element == child) {
				removeCell(cell);
				freeSpace += cell.requiredWidth + (cells.length > 1 ? spacing : 0.0);
				return;
			}
	}

	function getCell(el:Element) {
		var top = new TopAnchor();
		top.bindTo(this.top);
		var bottom = new BottomAnchor();
		bottom.bindTo(this.bottom);

		var left = new LeftAnchor();
		var right = new RightAnchor();
		if (direction & RightToLeft != 0) {
			if (cells.length == 0)
				right.bindTo(this.right);
			else {
				right.margin = spacing;
				right.bindTo(cells.last().left);
			}
		} else {
			if (cells.length == 0)
				left.bindTo(this.left);
			else {
				left.margin = spacing;
				left.bindTo(cells.last().right);
			}
		}
		return new LayoutCell(el, left, top, right, bottom);
	}

	function removeCell(cell:LayoutCell) {
		var slots = cellsSlots.get(cell);
		cellsSlots.remove(cell);
		cells.remove(cell);
		var el = cell.element;
		cell.remove(el);
		cell.offRequiredWidthChanged(slots.requiredWidthChanged);
		el.layout.offFillWidthChanged(slots.fillWidthChanged);
	}

	function syncLayout() {
		if (direction & RightToLeft != 0)
			for (cell in cells)
				cell.left.position = cell.right.position - cell.requiredWidth - freeSpacePerCell;
		else
			for (cell in cells)
				cell.right.position = cell.left.position + cell.requiredWidth + freeSpacePerCell;
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

	function set_spacing(value:Float):Float {
		value = Math.max(0.0, value);
		final d = spacing - value;
		spacing = value;
		if (cells.length > 1) {
			if (direction & RightToLeft != 0)
				for (cell in cells.slice(1))
					cell.right.margin = spacing;
			else
				for (cell in cells.slice(1))
					cell.left.margin = spacing;
			freeSpace += d * (cells.length - 1);
		}
		return spacing;
	}
}
