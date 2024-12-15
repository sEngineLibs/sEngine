import sengine.SEngine;
import s2d.objects.Sprite;

class Main {
	public static function main() {
		var stage = SEngine.stage;

		SEngine.start("SApp", 800, 600, false, 1, function() {
			var sprite = new Sprite(stage);
		});
	}
}
