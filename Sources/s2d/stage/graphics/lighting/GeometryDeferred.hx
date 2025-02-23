package s2d.stage.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_DEFERRED == 1)
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.stage.SpriteAtlas)
@:access(s2d.stage.objects.Sprite)
class GeometryDeferred {
	public static var structures:Array<VertexStructure> = [];
	static var pipeline:PipelineState;
	static var viewProjectionCL:ConstantLocation;
	#if (S2D_SPRITE_INSTANCING != 1)
	static var depthCL:ConstantLocation;
	static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation;
	#end // S2D_SPRITE_INSTANCING
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;

	public static function compile() {
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
		structures.push(new VertexStructure());
		structures[3].instanced = true;
		structures[3].add("depth", Float32_1X);
		#end // S2D_SPRITE_INSTANCING

		pipeline = new PipelineState();
		pipeline.inputLayout = structures;
		pipeline.vertexShader = Reflect.field(Shaders, "sprite_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "geometry_frag");
		pipeline.depthWrite = true;
		pipeline.depthMode = Less;
		pipeline.depthStencilAttachment = DepthOnly;
		pipeline.compile();

		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		#if (S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end // S2D_SPRITE_INSTANCING
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");
	}

	@:access(s2d.stage.graphics.Renderer)
	public static function render():Void {
		final ctx = Renderer.buffer.depthMap.context3D;
		ctx.begin([
			Renderer.buffer.albedoMap,
			Renderer.buffer.normalMap,
			Renderer.buffer.emissionMap,
			Renderer.buffer.ormMap
		]);
		ctx.clear(Black, 1.0);
		ctx.setPipeline(pipeline);
		ctx.setIndexBuffer(@:privateAccess se.SEngine.indices);
		#if (S2D_SPRITE_INSTANCING != 1)
		ctx.setVertexBuffer(@:privateAccess se.SEngine.vertices);
		#end
		ctx.setMatrix3(viewProjectionCL, Stage.current.viewProjection);
		for (layer in Stage.current.layers) {
			#if (S2D_LIGHTING_SHADOWS == 1)
			@:privateAccess layer.shadowBuffer.updateBuffersData();
			#end
			#if (S2D_SPRITE_INSTANCING == 1)
			for (atlas in layer.spriteAtlases) {
				ctx.setVertexBuffers(atlas.vertices);
				ctx.setTexture(albedoMapTU, atlas.albedoMap);
				ctx.setTexture(normalMapTU, atlas.normalMap);
				ctx.setTexture(ormMapTU, atlas.ormMap);
				ctx.setTexture(emissionMapTU, atlas.emissionMap);
				ctx.drawIndexedVerticesInstanced(atlas.sprites.length);
			}
			#else
			for (sprite in layer.sprites) {
				ctx.setFloat(depthCL, sprite.z);
				ctx.setMatrix3(modelCL, sprite.finalModel);
				ctx.setVector4(cropRectCL, sprite.cropRect);
				ctx.setTexture(albedoMapTU, sprite.atlas.albedoMap);
				ctx.setTexture(normalMapTU, sprite.atlas.normalMap);
				ctx.setTexture(ormMapTU, sprite.atlas.ormMap);
				ctx.setTexture(emissionMapTU, sprite.atlas.emissionMap);
				ctx.drawIndexedVertices();
			}
			#end
		}
		ctx.end();
	}
}
#end
