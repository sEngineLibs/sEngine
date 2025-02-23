package s2d.ui;

import s2d.Alignment;

class Layout {
	public var alignment:Alignment = Center;
	public var leftMargin:Float = 0.0;
	public var topMargin:Float = 0.0;
	public var rightMargin:Float = 0.0;
	public var bottomMargin:Float = 0.0;
	public var margins(never, set):Float;
	public var row:Int = 0;
	public var rowSpan:Int = 1;
	public var column:Int = 0;
	public var columnSpan:Int = 1;
	public var fillHeight:Bool = false;
	public var fillWidth:Bool = false;

	public function new() {}

	public function setMargins(value:Float):Void {
		leftMargin = value;
		topMargin = value;
		rightMargin = value;
		bottomMargin = value;
	}

	function set_margins(value:Float) {
		setMargins(value);
		return value;
	}
}
