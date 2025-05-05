package s2d.graphics;

@:allow(se.App)
class Drawers {
	public static var rectDrawer:RectDrawer;
	public static var stageDrawer:StageDrawer;

	static function compile() {
		rectDrawer = new RectDrawer();
		stageDrawer = new StageDrawer();
	}
}
