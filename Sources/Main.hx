import kha.System;
import s2d.graphics.materials.PBRMaterial;
import sengine.SEngine;
import s2d.objects.Light;
import s2d.objects.Sprite;

class Main {
	public static function main() {
		var stage = SEngine.stage;

		SEngine.start("SApp", 800, 600, false, 1, function() {
			var sprite = new Sprite(stage);
			var mat = new PBRMaterial();
			mat.emissionColor = Color.fromFloats(0.1, 0.1, 0.1);
			sprite.material = mat;
			var light = new Light(stage);
		});
	}
}
