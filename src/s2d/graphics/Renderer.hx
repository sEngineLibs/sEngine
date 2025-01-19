package s2d.graphics;

import kha.Image;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

@:access(s2d.Stage)
@:access(s2d.Layer)
@:access(s2d.SpriteAtlas)
@:access(s2d.objects.Sprite)
@:access(s2d.graphics.Renderer)
@:access(s2d.graphics.Lighting)
@:access(s2d.graphics.postprocessing.PPEffect)
class Renderer {
	static var commands:Array<Void->Void>;
	static var buffer:RenderBuffer;

	public static inline function init(width:Int, height:Int) {
		buffer = new RenderBuffer(width, height);
		commands = [draw];

		#if S2D_PP_BLOOM
		PostProcessing.bloom.index = 1;
		PostProcessing.bloom.enable();
		#end

		#if S2D_PP_FISHEYE
		PostProcessing.fisheye.index = 2;
		PostProcessing.fisheye.enable();
		#end

		#if S2D_PP_FILTER
		PostProcessing.filter.index = 3;
		PostProcessing.filter.enable();
		#end

		#if S2D_PP_COMPOSITOR
		PostProcessing.compositor.index = 4;
		PostProcessing.compositor.enable();
		#end
	}

	public static inline function resize(width:Int, height:Int) {
		buffer.resize(width, height);
	}

	public static inline function compile() {
		setPipelines();

		#if S2D_PP_BLOOM
		PostProcessing.bloom.compile();
		#end
		#if S2D_PP_FILTER
		PostProcessing.filter.compile();
		#end
		#if S2D_PP_FISHEYE
		PostProcessing.fisheye.compile();
		#end
		#if S2D_PP_COMPOSITOR
		PostProcessing.compositor.compile();
		#end
	}

	public static inline function render():Image {
		for (command in commands)
			command();
		return buffer.tgt;
	};

	static var structures:Array<VertexStructure> = [];
	// LIGHTING PASS
	static var pipeline:PipelineState;
	static var lightsDataCL:ConstantLocation;
	static var viewProjectionCL:ConstantLocation;
	#if (S2D_RP_ENV_LIGHTING == 1) static var envMapTU:TextureUnit; #end // S2D_RP_ENV_LIGHTING
	static var albedoMapTU:TextureUnit;
	static var normalMapTU:TextureUnit;
	static var emissionMapTU:TextureUnit;
	static var ormMapTU:TextureUnit;
	#if (S2D_RP_LIGHTING_DEFERRED != 1)
	#if (S2D_SPRITE_INSTANCING != 1)
	static var depthCL:ConstantLocation;
	static var modelCL:ConstantLocation;
	static var cropRectCL:ConstantLocation;
	#end // S2D_SPRITE_INSTANCING

	#else // S2D_RP_LIGHTING_DEFERRED
	// GEOMETRY PASS
	static var geomPipeline:PipelineState;
	static var geomViewProjectionCL:ConstantLocation;
	#if (S2D_SPRITE_INSTANCING != 1)
	static var geomDepthCL:ConstantLocation;
	static var geomModelCL:ConstantLocation;
	static var geomCropRectCL:ConstantLocation;
	#end // S2D_SPRITE_INSTANCING
	static var geomAlbedoMapTU:TextureUnit;
	static var geomNormalMapTU:TextureUnit;
	static var geomORMMapTU:TextureUnit;
	static var geomEmissionMapTU:TextureUnit;

	// ENVIRONMENT PASS
	static var envPipeline:PipelineState;
	#if (S2D_RP_ENV_LIGHTING == 1)
	static var envAlbedoMapTU:TextureUnit;
	static var envNormalMapTU:TextureUnit;
	static var envORMMapTU:TextureUnit;
	#end // S2D_RP_ENV_LIGHTING
	static var envEmissionMapTU:TextureUnit;
	#end // S2D_RP_LIGHTING_DEFERRED

	static inline function setPipelines() {
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

		#if (S2D_RP_LIGHTING_DEFERRED != 1)
		// FORWARD LIGHTING PASS
		pipeline = new PipelineState();
		pipeline.inputLayout = structures;
		pipeline.vertexShader = Shaders.sprite_vert;
		pipeline.fragmentShader = Shaders.lighting_forward_frag;
		pipeline.depthWrite = true;
		pipeline.depthMode = Less;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();
		#else // S2D_RP_LIGHTING_DEFERRED

		// GEOMETRY PASS
		geomPipeline = new PipelineState();
		geomPipeline.inputLayout = structures;
		geomPipeline.vertexShader = Shaders.sprite_vert;
		geomPipeline.fragmentShader = Shaders.geometry_frag;
		geomPipeline.depthWrite = true;
		geomPipeline.depthMode = Less;
		geomPipeline.compile();

		// DEFERRED LIGHTING PASS
		pipeline = new PipelineState();
		pipeline.inputLayout = [structures[0]];
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.lighting_deferred_frag;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = BlendOne;
		pipeline.blendOperation = Add;
		pipeline.compile();

		// ENVIRONMENT PASS
		envPipeline = new PipelineState();
		envPipeline.inputLayout = [structures[0]];
		envPipeline.vertexShader = Shaders.s2d_2d_vert;
		envPipeline.fragmentShader = Shaders.env_lighting_deferred_frag;
		envPipeline.blendSource = BlendOne;
		envPipeline.blendDestination = BlendOne;
		envPipeline.blendOperation = Add;
		envPipeline.compile();
		#end // S2D_RP_LIGHTING_DEFERRED

		// LIGHTING PASS
		lightsDataCL = pipeline.getConstantLocation("lightsData");
		viewProjectionCL = pipeline.getConstantLocation("viewProjection");
		albedoMapTU = pipeline.getTextureUnit("albedoMap");
		normalMapTU = pipeline.getTextureUnit("normalMap");
		emissionMapTU = pipeline.getTextureUnit("emissionMap");
		ormMapTU = pipeline.getTextureUnit("ormMap");

		#if (S2D_RP_LIGHTING_DEFERRED != 1)
		#if (S2D_RP_ENV_LIGHTING == 1) envMapTU = pipeline.getTextureUnit("envMap"); #end // S2D_RP_ENV_LIGHTING
		#if (S2D_SPRITE_INSTANCING != 1)
		depthCL = pipeline.getConstantLocation("depth");
		modelCL = pipeline.getConstantLocation("model");
		cropRectCL = pipeline.getConstantLocation("cropRect");
		#end // S2D_SPRITE_INSTANCING
		#else // S2D_RP_LIGHTING_DEFERRED

		// GEOMETRY PASS
		geomViewProjectionCL = geomPipeline.getConstantLocation("viewProjection");
		#if (S2D_SPRITE_INSTANCING != 1)
		geomDepthCL = pipeline.getConstantLocation("depth");
		geomModelCL = geomPipeline.getConstantLocation("model");
		geomCropRectCL = geomPipeline.getConstantLocation("cropRect");
		#end // S2D_SPRITE_INSTANCING
		geomAlbedoMapTU = geomPipeline.getTextureUnit("albedoMap");
		geomNormalMapTU = geomPipeline.getTextureUnit("normalMap");
		geomEmissionMapTU = geomPipeline.getTextureUnit("emissionMap");
		geomORMMapTU = geomPipeline.getTextureUnit("ormMap");

		// ENVIRONMENT PASS
		#if (S2D_RP_ENV_LIGHTING == 1)
		envMapTU = envPipeline.getTextureUnit("envMap");
		envAlbedoMapTU = envPipeline.getTextureUnit("albedoMap");
		envNormalMapTU = envPipeline.getTextureUnit("normalMap");
		envORMMapTU = envPipeline.getTextureUnit("ormMap");
		#end // S2D_RP_ENV_LIGHTING
		envEmissionMapTU = envPipeline.getTextureUnit("emissionMap");
		#end // S2D_RP_LIGHTING_DEFERRED
	}

	static inline function draw():Void {
		var g4:kha.graphics4.Graphics;

		final viewProjection = S2D.stage.viewProjection;

		#if (S2D_RP_LIGHTING_DEFERRED == 1)
		g4 = buffer.albedoMap.g4;
		g4.begin([buffer.normalMap, buffer.emissionMap, buffer.ormMap]);
		g4.clear(Black, 1.0);
		g4.setPipeline(geomPipeline);
		g4.setIndexBuffer(S2D.indices);
		#if (S2D_SPRITE_INSTANCING != 1)
		g4.setVertexBuffer(S2D.vertices);
		#end
		g4.setMatrix3(geomViewProjectionCL, viewProjection);
		for (layer in S2D.stage.layers) {
			#if (S2D_SPRITE_INSTANCING == 1)
			for (atlas in layer.spriteAtlases) {
				atlas.update();

				g4.setVertexBuffers(atlas.vertices);
				g4.setTexture(geomAlbedoMapTU, atlas.albedoMap);
				g4.setTexture(geomNormalMapTU, atlas.normalMap);
				g4.setTexture(geomORMMapTU, atlas.ormMap);
				g4.setTexture(geomEmissionMapTU, atlas.emissionMap);
				g4.drawIndexedVerticesInstanced(atlas.sprites.length);
			}
			#else
			for (sprite in layer.sprites) {
				g4.setMatrix3(geomModelCL, sprite._model);
				g4.setVector4(geomCropRectCL, sprite.cropRect);
				g4.setTexture(geomAlbedoMapTU, sprite.atlas.albedoMap);
				g4.setTexture(geomNormalMapTU, sprite.atlas.normalMap);
				g4.setTexture(geomORMMapTU, sprite.atlas.ormMap);
				g4.setTexture(geomEmissionMapTU, sprite.atlas.emissionMap);
				g4.drawIndexedVertices();
			}
			#end
		}
		g4.end();
		#end // S2D_RP_LIGHTING_DEFERRED

		g4 = buffer.tgt.g4;

		g4.begin();
		g4.clear(Black, 1.0);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setMatrix3(viewProjectionCL, viewProjection);
		#if (S2D_RP_LIGHTING_DEFERRED != 1)
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
		#else // S2D_RP_LIGHTING_DEFERRED
		g4.setVertexBuffer(S2D.vertices);
		// stage lights
		g4.setTexture(albedoMapTU, buffer.albedoMap);
		g4.setTexture(normalMapTU, buffer.normalMap);
		g4.setTexture(emissionMapTU, buffer.emissionMap);
		g4.setTexture(ormMapTU, buffer.ormMap);
		for (layer in S2D.stage.layers) {
			g4.setFloats(lightsDataCL, layer.lightsData);
			g4.drawIndexedVertices();
		}
		// emission + environment
		g4.setPipeline(envPipeline);
		g4.setTexture(envEmissionMapTU, buffer.emissionMap);
		#if (S2D_RP_ENV_LIGHTING == 1)
		g4.setTexture(envMapTU, S2D.stage.environmentMap);
		g4.setTexture(envAlbedoMapTU, buffer.albedoMap);
		g4.setTexture(envNormalMapTU, buffer.normalMap);
		g4.setTexture(envORMMapTU, buffer.ormMap);
		g4.setTextureParameters(envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		g4.drawIndexedVertices();
		#end // S2D_RP_LIGHTING_DEFERRED
		g4.end();
	}
}
