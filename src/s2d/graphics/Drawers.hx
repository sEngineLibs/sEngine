package s2d.graphics;

@:allow(se.App)
class Drawers {
	public static var rectDrawer:RectDrawer = new RectDrawer();

	static function compile() {
		rectDrawer.compile();
	}
}
