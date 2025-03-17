package s2d;

import s2d.Alignment;

#if !macro
@:build(se.macro.SMacro.build())
#end
class ElementLayout {
	@:inject(dirty) public var alignment:Alignment = AlignCenter;
	@:inject(dirty) public var fillWidth:Bool = false;
	@:inject(dirty) public var fillHeight:Bool = false;
	@:inject(dirty) public var row:Int = 0;
	@:inject(dirty) public var rowSpan:Int = 1;
	@:inject(dirty) public var column:Int = 0;
	@:inject(dirty) public var columnSpan:Int = 1;

	@:signal function dirty():Void;

	public function new() {}
}
