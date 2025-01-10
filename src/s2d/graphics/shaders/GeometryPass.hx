package s2d.graphics.shaders;

import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation; // s2d
import s2d.objects.Sprite;

@:allow(s2d.graphics.Renderer) @:access(s2d.graphics.Renderer) class GeometryPass {
	static var pipeline:PipelineState;

	// stage uniforms
	static var VPCL:ConstantLocation;
	// sprite uniforms
	static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation;
	// material uniforms
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
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
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		paramsCL = pipeline.getConstantLocation("Params");
	}

	static inline function render():Void {
		#if (S2D_RP_PACK_GBUFFER == 1)
		final g4 = Renderer.gBuffer.g4;
		#else
		final g4 = Renderer.gBuffer[0].g4;
		#end
		final VP = S2D.stage.VP;
		final sprites = S2D.stage.sprites;

		#if (S2D_RP_PACK_GBUFFER == 1)
		g4.begin();
		#else
		g4.begin([Renderer.gBuffer[1], Renderer.gBuffer[2], Renderer.gBuffer[3]]);
		#end
		g4.clear(Black);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(Sprite.indices);
		g4.setVertexBuffer(Sprite.vertices);
		for (sprite in sprites) {
			final cropRect = sprite.material.SpriteSheet.curTile.crop(sprite.cropRect);

			g4.setMatrix(VPCL, VP);
			g4.setMatrix(modelCL, sprite.finalTransformation.matrix);
			g4.setVector4(cropRectCL, cropRect);
			g4.setTexture(albedoMapTU, sprite.material.albedoMap);
			g4.setTexture(normalMapTU, sprite.material.normalMap);
			g4.setTexture(ormMapTU, sprite.material.ormMap);
			g4.setTexture(emissionMapTU, sprite.material.emissionMap);
			g4.setFloats(paramsCL, sprite.material.params);
			g4.drawIndexedVertices();
		}
		g4.end();
	}
}
