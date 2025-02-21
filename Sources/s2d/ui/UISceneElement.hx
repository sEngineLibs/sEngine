package s2d.ui;

abstract class UISceneElement extends UIElement {
	public function new(?parent:UIElement) {
		super(parent ?? UIScene.current);
	}
}
