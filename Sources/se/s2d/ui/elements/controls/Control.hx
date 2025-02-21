package se.s2d.ui.elements.controls;

import se.s2d.ui.elements.UIElement;

abstract class Control extends UIElement {
	var mouseArea:MouseArea;

	public var background:UIElement;
	public var content:UIElement;

	public var hovered(get, never):Bool;
	public var pressed(get, never):Bool;

	function new(?scene:UIScene) {
		super(scene);
		addChild(background);
		background.anchors.fill(this);
		addChild(content);
		content.anchors.fill(this);

		mouseArea = new MouseArea(scene);
		mouseArea.anchors.fill(this);
	}

	public function notifyOnHoveredChanged(f:Bool->Void):Void {
		// mouseArea.notifyOnEntered(() -> f(true));
		// mouseArea.notifyOnExited(() -> f(false));
	}

	public function notifyOnClicked(f:Bool->Void):Void {
		// mouseArea.notifyOnClicked(() -> f(true));
	}

	function get_hovered():Bool {
		return mouseArea.entered;
	}

	function get_pressed():Bool {
		return mouseArea.pressed;
	}
}
