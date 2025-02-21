package s2d.stage.graphics.postprocessing;

import kha.Canvas;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
import se.math.Vec2;

class Fisheye extends PPEffect {
	var textureMapTU:TextureUnit;
	var positionCL:ConstantLocation;
	var strengthCL:ConstantLocation;

	public var position:Vec2 = new Vec2(0.5, 0.5);
	public var strength:Float = 0.0;

	function setPipeline() {
		pipeline.vertexShader = Reflect.field(Shaders, "s2d_2d_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "fisheye_frag");
	}

	function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		positionCL = pipeline.getConstantLocation("fisheyePosition");
		strengthCL = pipeline.getConstantLocation("fisheyeStrength");
	}

	@:access(s2d.stage.graphics.Renderer)
	function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(@:privateAccess se.SEngine.indices);
		g4.setVertexBuffer(@:privateAccess se.SEngine.vertices);
		g4.setTexture(textureMapTU, Renderer.buffer.src);
		g4.setVector2(positionCL, position);
		g4.setFloat(strengthCL, strength);
		g4.drawIndexedVertices();
		g2.end();
	}
}
