package se.ui.effects;

import kha.Image;
import kha.Canvas;
import se.ui.graphics.TextureShader;

@:structInit
abstract class ShaderEffect {
	var shader:TextureShader;

	abstract function draw(source:Image, target:Canvas):Void;

	public function apply(source:Image, target:Canvas) {
		final g2 = target.g2;

		g2.pipeline = @:privateAccess shader.pipeline;
		draw(source, target);
		g2.pipeline = null;
	}
}
