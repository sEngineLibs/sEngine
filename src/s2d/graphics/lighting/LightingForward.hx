package s2d.graphics.lighting;

#if (S2D_RP_LIGHTING == 1)
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.Layer)
@:access(s2d.SpriteAtlas)
@:access(s2d.objects.Sprite)
class LightingForward {
	public static var structures:Array<VertexStructure> = [];
	static var pipeline:PipelineState;
	static var lightsDataCL:ConstantLocation;
	static var viewProjectionCL:ConstantLocation;
	#if (S2D_RP_ENV_LIGHTING == 1) static var envMapTU:TextureUnit; #end // S2D_RP_ENV_LIGHTING
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	#if (S2D_SPRITE_INSTANCING != 1) static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation; #end // S2D_SPRITE_INSTANCING

	public static inline function compile() {
		// coord
		structures.push(new VertexStructure());
		structures[0].add("vertCoord", Float32_2X);

		#if (S2D_SPRITE_INSTANCING == 1)
		structures.push(new VertexStructure());
		structures[1].instanced = true;
		structures[1].add("cropRect", Float32_4X);
		structures.push(new VertexStructure());
		structures[2].instanced = true;
		structures[2].add("model0", Float32_3X);
		structures[2].add("model1", Float32_3X);
		structures[2].add("model2", Float32_3X);
		#end // S2D_SPRITE_INSTANCING

		pipeline = new PipelineState();
		pipeline.inputLayout = structures;
		pipeline.vertexShader = Shaders.sprite_vert;
		pipeline.fragmentShader = Shaders.lighting_forward_frag;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();

		// LIGHTING PASS
		lightsDataCL = pipeline.getConstantLocation("lightsData");
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");

		#if (S2D_RP_ENV_LIGHTING == 1) envMapTU = pipeline.getTextureUnit("envMap"); #end // S2D_RP_ENV_LIGHTING
		#if (S2D_SPRITE_INSTANCING != 1) modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect"); #end // S2D_SPRITE_INSTANCING
	}

	public static inline function render():Void {
		final g4 = Renderer.buffer.tgt.g4;
		final viewProjection = S2D.stage.viewProjection;

		g4.begin();
		g4.clear(Black);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setMatrix3(viewProjectionCL, viewProjection);
		#if (S2D_SPRITE_INSTANCING != 1)
		g4.setVertexBuffer(S2D.vertices);
		#end
		#if (S2D_RP_ENV_LIGHTING == 1)
		g4.setTexture(envMapTU, S2D.stage.environmentMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		for (layer in S2D.stage.layers) {
			g4.setFloats(lightsDataCL, layer.lightsData);
			#if (S2D_SPRITE_INSTANCING == 1)
			for (atlas in layer.spriteAtlases) {
				atlas.update();

				g4.setVertexBuffers(atlas.vertices);
				g4.setTexture(albedoMapTU, atlas.albedoMap);
				g4.setTexture(normalMapTU, atlas.normalMap);
				g4.setTexture(ormMapTU, atlas.ormMap);
				g4.setTexture(emissionMapTU, atlas.emissionMap);
				g4.drawIndexedVerticesInstanced(atlas.sprites.length);
			}
			#else
			for (sprite in layer.sprites) {
				g4.setMatrix3(modelCL, sprite._model);
				g4.setVector4(cropRectCL, sprite.cropRect);
				g4.setTexture(albedoMapTU, sprite.atlas.albedoMap);
				g4.setTexture(normalMapTU, sprite.atlas.normalMap);
				g4.setTexture(ormMapTU, sprite.atlas.ormMap);
				g4.setTexture(emissionMapTU, sprite.atlas.emissionMap);
				g4.drawIndexedVertices();
			}
			#end
		}
		g4.end();
	}
}
#end
