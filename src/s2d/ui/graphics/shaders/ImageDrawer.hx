package score.graphics.shaders;

import kha.Canvas;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.TextureUnit;

class ImageDrawer extends Shader {
	var imageTU:TextureUnit;

	override function initStructure() {
		structure = new VertexStructure();
		structure.add("vertPos", VertexData.Float32_3X);
		structure.add("vertUV", VertexData.Float32_2X);
	}

	override function getUniforms() {
		imageTU = pipeline.getTextureUnit("tex");
	}

	override function setUniforms(target:Canvas, ?uniforms:Dynamic) {
		target.g4.setTexture(imageTU, uniforms[0]);
	}
}
