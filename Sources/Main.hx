import sengine.SEngine;
import s2d.objects.Sprite;

class Main {
	public static function main() {
		SEngine.start("SApp", 800, 600, true, 1, function() {
			var stage = new S2D();
			var sprite = new Sprite(stage);

			SApp.notifyOnRender(stage.draw);
			SApp.window.notifyOnResize(stage.resize(w, h));
		});
	}
}
