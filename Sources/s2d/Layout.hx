package s2d;

import s2d.Alignment;

#if !macro
@:build(se.macro.SMacro.build())
#end
class Layout {
	@track public var row:Int = 0;
	@track public var rowSpan:Int = 1;
	@track public var column:Int = 0;
	@track public var columnSpan:Int = 1;
	@track public var fillWidth:Bool = false;
	@track public var fillHeight:Bool = false;
	@track public var leftMargin:Float = 0.0;
	@track public var topMargin:Float = 0.0;
	@track public var rightMargin:Float = 0.0;
	@track public var bottomMargin:Float = 0.0;
	@track public var alignment:Alignment = Center;

	public var margins(never, set):Float;

	public function new() {}

	public function setMargins(value:Float):Void {
		leftMargin = value;
		topMargin = value;
		rightMargin = value;
		bottomMargin = value;
	}

	private inline function set_margins(value:Float) {
		setMargins(value);
		return value;
	}
}
