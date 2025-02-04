package s2d.ui.elements.layouts;

import s2d.ui.positioning.Anchors.AnchorLine;

class ColumnLayout extends UIElement {
	var lines:Array<AnchorLine>;

	public var spacing:Float = 0.0;

	public function new(?scene:UIScene) {
		super(scene);
	}

	override function addChild(value:UIElement) {
		super.addChild(value);
		updateLayout();
	}

	override function removeChild(value:UIElement) {
		super.addChild(value);
		updateLayout();
	}

	function updateLayout():Void {
		lines = [
			for (i in 0...children.length)
				@:privateAccess new AnchorLine(top, 1.0, i / children.length * height)
		];
		lines.push(bottom);
	}
}
