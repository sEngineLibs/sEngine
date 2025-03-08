package s2d;

abstract class UISceneElement extends Element {
	public inline function new(?parent:Element) {
		super(parent ?? UIScene.current);
	}
}
