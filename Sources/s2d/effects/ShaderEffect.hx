package s2d.effects;

import kha.Image;
import se.Texture;
import s2d.graphics.TextureShader;

@:structInit
abstract class ShaderEffect {
	var shader:TextureShader;

	abstract function draw(source:Image, target:Texture):Void;

	public function apply(source:Image, target:Texture) {
		final ctx = target.ctx2D;

		ctx.pipeline = @:privateAccess shader.pipeline;
		draw(source, target);
		ctx.pipeline = null;
	}
}
