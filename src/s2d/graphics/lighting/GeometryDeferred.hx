package s2d.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_DEFERRED == 1)
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.SpriteAtlas)
@:access(s2d.objects.Sprite)
class GeometryDeferred {
	public static var structures:Array<VertexStructure> = [];
	// GEOMETRY PASS
	static var pipeline:PipelineState;
	static var viewProjectionCL:ConstantLocation;
	#if (S2D_SPRITE_INSTANCING != 1) static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation; #end // S2D_SPRITE_INSTANCING
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;

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
		pipeline.fragmentShader = Shaders.geometry_frag;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();

		// GEOMETRY PASS
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		#if (S2D_SPRITE_INSTANCING != 1) modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect"); #end // S2D_SPRITE_INSTANCING
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");
	}

	public static inline function render():Void {
		final g4 = Renderer.buffer.albedoMap.g4;
		final viewProjection = S2D.stage.viewProjection;

		g4.begin([Renderer.buffer.normalMap, Renderer.buffer.emissionMap, Renderer.buffer.ormMap]);
		g4.clear(Black);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		#if (S2D_SPRITE_INSTANCING != 1)
		g4.setVertexBuffer(S2D.vertices);
		#end
		g4.setMatrix3(viewProjectionCL, viewProjection);
		for (layer in S2D.stage.layers) {
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
