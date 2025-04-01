package s2d.layouts;

import s2d.Direction;
import s2d.layouts.LayoutCell;

using se.extensions.ArrayExt;

@:dox(hide)
abstract class DirLayout<S:ElementSlots, L:LayoutCell<S>> extends Element {
	var updating:Bool = false;
	var cells:Array<CellsSlots<S, L>> = [];

	@:isVar public var spacing(default, set):Float = 10.0;
	@:inject(syncLayout) public var direction:Direction;

	public function new(name:String = "layout", ?direction:Direction, ?scene:WindowScene) {
		super(name, scene);
		this.direction = direction ?? TopToBottom | LeftToRight;
	}

	@:slot(vChildAdded)
	function add(child:Element) {
		var cell = getCell(child);
		var slots = setCellSlots(cell);
		if (slots.requiredWidthChanged != null)
			cell.onRequiredWidthChanged(slots.requiredWidthChanged);
		if (slots.fillWidthChanged != null)
			child.layout.onFillWidthChanged(slots.fillWidthChanged);
		if (slots.requiredHeightChanged != null)
			cell.onRequiredHeightChanged(slots.requiredHeightChanged);
		if (slots.fillHeightChanged != null)
			child.layout.onFillHeightChanged(slots.fillHeightChanged);
		cells.push({
			cell: cell,
			slots: slots
		});
		initCell(cell);
	}

	abstract function getCell(el:Element):L;

	abstract function setCellSlots(cell:L):CellSlots;

	abstract function initCell(cell:L):Void;

	@:slot(vChildRemoved)
	function remove(child:Element) {
		for (cellSlots in cells)
			if (cellSlots.cell.el == child) {
				cells.remove(cellSlots);
				final cell = cellSlots.cell;
				final slots = cellSlots.slots;
				if (slots.requiredWidthChanged != null)
					cell.offRequiredWidthChanged(slots.requiredWidthChanged);
				if (slots.fillWidthChanged != null)
					child.layout.offFillWidthChanged(slots.fillWidthChanged);
				if (slots.requiredHeightChanged != null)
					cell.offRequiredHeightChanged(slots.requiredHeightChanged);
				if (slots.fillHeightChanged != null)
					child.layout.offFillHeightChanged(slots.fillHeightChanged);
				cell.remove();
				cellRemoved(cell);
				return;
			}
	}

	abstract function cellRemoved(cell:L):Void;

	abstract function syncLayout():Void;

	abstract function syncSpacing(d:Float):Void;

	function set_spacing(value:Float) {
		value = Math.max(0.0, value);
		final d = value - spacing;
		spacing = value;
		syncSpacing(d);
		return spacing;
	}
}

@:dox(hide)
typedef CellsSlots<S:ElementSlots, L:LayoutCell<S>> = {
	cell:L,
	slots:CellSlots
}

@:dox(hide)
typedef CellSlots = {
	?requiredWidthChanged:Float->Void,
	?fillWidthChanged:Bool->Void,
	?requiredHeightChanged:Float->Void,
	?fillHeightChanged:Bool->Void
}
