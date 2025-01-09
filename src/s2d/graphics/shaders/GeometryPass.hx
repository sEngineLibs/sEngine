package s2d.graphics.shaders;

import kha.math.FastVector4;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
// s2d
import s2d.objects.Sprite;

@:allow(s2d.graphics.Renderer)
@:access(s2d.graphics.Renderer)
class GeometryPass {
	static var pipeline:PipelineState;

	// stage uniforms
	static var VPCL:ConstantLocation;
	// sprite uniforms
	static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation;
	// material uniforms
	static var colorMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	static var glowMapTU:TextureUnit;
	static var paramsCL:ConstantLocation;

	static inline function compile() {
		var structure = new VertexStructure();
		structure.add("vertPos", Float32_3X);
		structure.add("vertUV", Float32_2X);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.geometry_pass_vert;
		pipeline.fragmentShader = Shaders.geometry_pass_frag;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();

		// stage uniforms
		VPCL = pipeline.getConstantLocation("VP");
		// sprite uniforms
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		// material uniforms
		colorMapTU = pipeline.getTextureUnit("colorMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");
		glowMapTU = pipeline.getTextureUnit("glowMap");
		paramsCL = pipeline.getConstantLocation("Params");
	}

	static inline function render():Void {
		final g4 = Renderer.gBuffer.g4;
		final VP = S2D.stage.VP;
		final sprites = S2D.stage.sprites;

		g4.begin();
		g4.clear(Black);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(Sprite.indices);
		g4.setVertexBuffer(Sprite.vertices);
		for (sprite in sprites) {
			final cropRect = sprite.material.tilesheet.curTile.crop(sprite.cropRect);
			
			g4.setMatrix(VPCL, VP);
			g4.setMatrix(modelCL, sprite.finalTransformation);
			g4.setVector4(cropRectCL, cropRect);
			g4.setTexture(colorMapTU, sprite.material.colorMap);
			g4.setTexture(normalMapTU, sprite.material.normalMap);
			g4.setTexture(ormMapTU, sprite.material.ormMap);
			g4.setTexture(glowMapTU, sprite.material.glowMap);
			g4.setFloats(paramsCL, sprite.material.params);
			g4.drawIndexedVertices();
		}
		g4.end();
	}
}
