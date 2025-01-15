package s2d.graphics.shaders;

import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:allow(s2d.graphics.Renderer)
@:access(s2d.graphics.Renderer)
@:access(s2d.objects.Sprite)
@:access(s2d.graphics.materials.Material)
class GeometryPass {
	static var pipeline:PipelineState;

	// stage uniforms
	static var mvpCL:ConstantLocation;
	// sprite uniforms
	static var spriteParamsCL:ConstantLocation;
	static var cropRectCL:ConstantLocation;
	// material uniforms
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
	static var matParamsCL:ConstantLocation;

	static inline function compile() {
		var structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);

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
		mvpCL = pipeline.getConstantLocation("MVP");
		// sprite uniforms
		spriteParamsCL = pipeline.getConstantLocation("spriteParams");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		// material uniforms
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		matParamsCL = pipeline.getConstantLocation("matParams");
	}

	static inline function render():Void {
		final g4 = Renderer.gBuffer.albedoMap.g4;
		final VP = S2D.stage.VP;
		final sprites = S2D.stage.sprites;

		g4.begin([
			Renderer.gBuffer.normalMap,
			Renderer.gBuffer.emissionMap,
			Renderer.gBuffer.ormMap
		]);
		g4.clear(Black);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		for (sprite in sprites) {
			var ct = sprite.material.sheet.curTile;
			final cropRect = ct * sprite.cropRect;

			g4.setMatrix3(mvpCL, VP * sprite._model);
			g4.setFloat2(spriteParamsCL, sprite.rotation, sprite._z);
			g4.setVector4(cropRectCL, cropRect);
			g4.setTexture(albedoMapTU, sprite.material.albedoMap);
			g4.setTexture(normalMapTU, sprite.material.normalMap);
			g4.setTexture(ormMapTU, sprite.material.ormMap);
			g4.setTexture(emissionMapTU, sprite.material.emissionMap);
			g4.setFloats(matParamsCL, sprite.material.params);
			g4.drawIndexedVertices();
		}
		g4.end();
	}
}
