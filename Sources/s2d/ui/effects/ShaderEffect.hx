package s2d.ui.effects;

import kha.Image;
import se.Texture;
import s2d.ui.graphics.TextureShader;

@:structInit
abstract class ShaderEffect {
	var shader:TextureShader;

	abstract function draw(source:Image, target:Texture):Void;

	public function apply(source:Image, target:Texture) {
		final ctx = target.context2D;

		ctx.pipeline = @:privateAccess shader.pipeline;
		draw(source, target);
		ctx.pipeline = null;
	}
}
