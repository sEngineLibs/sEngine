package s2d.ui.elements.controls;

import s2d.ui.elements.UIElement;

abstract class Control extends UIElement {
	public var background:UIElement;
	public var content:UIElement;

	function new(?scene:UIScene) {
		super(scene);
		addChild(background);
		background.anchors.fill(this);
		addChild(content);
		content.anchors.fill(this);
	}
}
