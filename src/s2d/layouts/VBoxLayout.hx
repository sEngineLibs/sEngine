package s2d.layouts;

import s2d.Anchors;
import s2d.Direction;

using se.extensions.ArrayExt;

class VBoxLayout extends Element {
	var cells:Array<LayoutCell> = [];
	var cellsSlots:Map<LayoutCell, {
		requiredHeightChanged:Float->Void,
		fillHeightChanged:Bool->Void
	}> = [];

	@:inject(syncFreeSpacePerCell) var fillCells:Int = 0;
	@:inject(syncFreeSpacePerCell) var freeSpace:Float = 0.0;
	@:inject(syncLayout) var freeSpacePerCell:Float = 0.0;

	@:isVar public var spacing(default, set):Float = 10.0;
	@:inject(syncLayout) public var direction:Direction = TopToBottom;

	public function new(?scene:WindowScene) {
		super(scene);
	}

	@:slot(vChildAdded)
	function add(child:Element) {
		var cell = getCell(child);
		var slots = {
			requiredHeightChanged: (rw:Float) -> {
				if (!cell.fillHeight)
					freeSpace += rw - cell.requiredHeight;
			},
			fillHeightChanged: (fw:Bool) -> {
				if (!fw && cell.element.layout.fillHeight)
					++fillCells;
				else if (fw && !cell.element.layout.fillHeight)
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

	@:slot(vChildRemoved)
	function remove(child:Element) {
		for (cell in cells)
			if (cell.element == child) {
				removeCell(cell);
				freeSpace += cell.requiredHeight + (cells.length > 1 ? spacing : 0.0);
				return;
			}
	}

	function getCell(el:Element) {
		var left = new LeftAnchor();
		left.bindTo(this.left);
		var right = new RightAnchor();
		right.bindTo(this.right);

		var top = new TopAnchor();
		var bottom = new BottomAnchor();
		if (direction & BottomToTop != 0) {
			if (cells.length == 0)
				bottom.bindTo(this.bottom);
			else {
				bottom.margin = spacing;
				bottom.bindTo(cells.last().top);
			}
		} else {
			if (cells.length == 0)
				top.bindTo(this.top);
			else {
				top.margin = spacing;
				top.bindTo(cells.last().bottom);
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
		cell.offRequiredHeightChanged(slots.requiredHeightChanged);
		el.layout.offFillHeightChanged(slots.fillHeightChanged);
	}

	function syncLayout() {
		if (direction & BottomToTop != 0)
			for (cell in cells)
				cell.top.position = cell.bottom.position - cell.requiredHeight - freeSpacePerCell;
		else
			for (cell in cells)
				cell.bottom.position = cell.top.position + cell.requiredHeight + freeSpacePerCell;
	}

	function syncFreeSpacePerCell() {
		if (cells.length > 0)
			if (fillCells > 0) {
				final perCell = freeSpace / fillCells;
				var fh = freeSpace;
				for (cell in cells)
					if (cell.fillHeight) {
						cell.requiredHeight = cell.clampHeight(perCell);
						fh -= cell.requiredHeight;
					}
				freeSpacePerCell = Math.max(0.0, fh / cells.length);
			} else
				freeSpacePerCell = Math.max(0.0, freeSpace / cells.length);
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

	function set_spacing(value:Float):Float {
		value = Math.max(0.0, value);
		final d = spacing - value;
		spacing = value;
		if (cells.length > 1) {
			if (direction & BottomToTop != 0)
				for (cell in cells.slice(1))
					cell.bottom.margin = spacing;
			else
				for (cell in cells.slice(1))
					cell.top.margin = spacing;
			freeSpace += d * (cells.length - 1);
		}
		return spacing;
	}
}
