package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
// s2d
import s2d.math.SMath;

class DOF extends PPEffect {
	var textureMapTU:TextureUnit;
	var depthMapTU:TextureUnit;
	var cameraPosCL:ConstantLocation;
	var focusDistanceCL:ConstantLocation;
	var blurSizeCL:ConstantLocation;

	public var focusDistance:Float = 0.5;
	public var blurSize:Float = 0.0;

	inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.dof_frag;
	}

	inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		depthMapTU = pipeline.getTextureUnit("depthMap");
		cameraPosCL = pipeline.getConstantLocation("cameraPos");
		focusDistanceCL = pipeline.getConstantLocation("focusDistance");
		blurSizeCL = pipeline.getConstantLocation("blurSize");
	}

	inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		final c = S2D.stage.camera;
		final camPos = vec3(c.x, c.y, c.z);

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(depthMapTU, Renderer.buffer.depthMap);
		g4.setTexture(textureMapTU, Renderer.buffer.src);
		g4.setVector3(cameraPosCL, camPos);
		g4.setFloat(focusDistanceCL, focusDistance);
		g4.setFloat(blurSizeCL, blurSize);
		g4.drawIndexedVertices();
		g2.end();
	}
}
