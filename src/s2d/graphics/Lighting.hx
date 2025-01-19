package s2d.graphics;

import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.Stage)
@:access(s2d.Layer)
@:access(s2d.graphics.Renderer)
@:access(s2d.objects.Sprite)
class Lighting {
	static var pipeline:PipelineState;
	static var structures:Array<VertexStructure> = [];

	// stage uniforms
	static var viewProjectionCL:ConstantLocation;
	static var lightsDataCL:ConstantLocation;
	#if (S2D_RP_ENV_LIGHTING == 1)
	static var envMapTU:TextureUnit;
	#end
	// sprite uniforms
	static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation;
	// material uniforms
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;

	static inline function compile() {
		// coord
		structures.push(new VertexStructure());
		structures[0].add("vertCoord", Float32_2X);

		pipeline = new PipelineState();
		pipeline.inputLayout = structures;
		pipeline.vertexShader = Shaders.sprite_vert;
		pipeline.fragmentShader = Shaders.sprite_frag;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();

		// stage uniforms
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		modelCL = pipeline.getConstantLocation("model");
		lightsDataCL = pipeline.getConstantLocation("lightsData");
		#if (S2D_RP_ENV_LIGHTING == 1)
		envMapTU = pipeline.getTextureUnit("envMap");
		#end
		// sprite uniforms
		cropRectCL = pipeline.getConstantLocation("cropRect");
		// material uniforms
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");
	}

	static inline function render():Void {
		final g4 = Renderer.buffer.tgt.g4;
		final viewProjection = S2D.stage.viewProjection;

		g4.begin();
		g4.clear(Black);
		g4.setPipeline(pipeline);
		#if (S2D_RP_ENV_LIGHTING == 1)
		g4.setTexture(envMapTU, S2D.stage.environmentMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		g4.setMatrix3(viewProjectionCL, viewProjection);
		for (layer in S2D.stage.layers) {
			g4.setFloats(lightsDataCL, layer.lightsData);
			for (sprite in layer.sprites) {
				g4.setIndexBuffer(sprite.indices);
				g4.setVertexBuffer(sprite.vertices);
				g4.setTexture(albedoMapTU, sprite.albedoMap);
				g4.setTexture(normalMapTU, sprite.normalMap);
				g4.setTexture(ormMapTU, sprite.ormMap);
				g4.setTexture(emissionMapTU, sprite.emissionMap);
				g4.setMatrix3(modelCL, sprite._model);
				g4.setVector4(cropRectCL, sprite.cropRect);
				g4.drawIndexedVertices();
			}
		}
		g4.end();
	}
}
