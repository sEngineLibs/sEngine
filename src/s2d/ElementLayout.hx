package s2d;

import s2d.Alignment;

#if !macro
@:build(se.macro.SMacro.build())
#end
@:nullSafety(Strict)
class ElementLayout {
	@track @:isVar public var row(default, set):Int = 0;
	@track @:isVar public var rowSpan(default, set):Int = 1;
	@track @:isVar public var column(default, set):Int = 0;
	@track @:isVar public var columnSpan(default, set):Int = 1;
	@track public var alignment:Alignment = AlignCenter;
	@track public var fillWidth:Bool = false;
	@track public var fillHeight:Bool = false;
	@track public var minimumWidth:Float = Math.NEGATIVE_INFINITY;
	@track public var maximumWidth:Float = Math.POSITIVE_INFINITY;
	@track public var minimumHeight:Float = Math.NEGATIVE_INFINITY;
	@track public var maximumHeight:Float = Math.POSITIVE_INFINITY;
	@track public var preferredWidth:Float = Math.NaN;
	@track public var preferredHeight:Float = Math.NaN;

	public function new() {}

	function set_row(value:Int):Int {
		row = value < 0 ? 0 : value;
		return row;
	}

	function set_rowSpan(value:Int):Int {
		rowSpan = value < 1 ? 1 : value;
		return rowSpan;
	}

	function set_column(value:Int):Int {
		column = value < 0 ? 0 : value;
		return column;
	}

	function set_columnSpan(value:Int):Int {
		columnSpan = value < 1 ? 1 : value;
		return columnSpan;
	}
}
