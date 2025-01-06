package s2d.graphics;

import kha.Image;
import kha.Canvas;
import kha.Shaders;
// s2d
import s2d.objects.Sprite;
import s2d.graphics.shaders.LightingPass;
import s2d.graphics.shaders.GeometryPass;
import s2d.graphics.shaders.EnvLightingPass;

using s2d.core.utils.extensions.FastMatrix4Ext;

@:allow(s2d.S2D)
class RenderPath {
	static var geometryPass:GeometryPass = new GeometryPass();
	static var envLightingPass:EnvLightingPass = new EnvLightingPass();
	static var lightingPass:LightingPass = new LightingPass();

	static var gBuffer:Image; // geometry buffer
	static var ppBuffer:Array<Image> = []; // ping-pong buffer

	static inline function init(width:Int, height:Int) {
		gBuffer = Image.createRenderTarget(width, height, RGBA128, DepthOnly);
		ppBuffer.push(Image.createRenderTarget(width, height, RGBA32));
		ppBuffer.push(Image.createRenderTarget(width, height, RGBA32));
	}

	static inline function resize(width:Int, height:Int) {
		gBuffer = Image.createRenderTarget(width, height, RGBA128, DepthOnly);
		ppBuffer[0] = Image.createRenderTarget(width, height, RGBA32);
		ppBuffer[1] = Image.createRenderTarget(width, height, RGBA32);
	}

	static inline function compile() {
		geometryPass.compile(Shaders.geometry_pass_frag, Shaders.geometry_pass_vert);
		lightingPass.compile(Shaders.lighting_pass_frag, Shaders.s2d_2d_vert);
		envLightingPass.compile(Shaders.env_lighting_pass_frag, Shaders.s2d_2d_vert);

		#if S2D_PP
		#if S2D_PP_DOF
		PostProcessing.dofPass.compile(Shaders.dof_pass_frag);
		#end
		#if S2D_PP_MIST
		PostProcessing.mistPass.compile(Shaders.mist_pass_frag);
		#end
		#if S2D_PP_FILTER
		PostProcessing.filterPass.compile(Shaders.filter_pass_frag);
		#end
		#if S2D_PP_FISHEYE
		PostProcessing.fisheyePass.compile(Shaders.fisheye_pass_frag);
		#end
		#if S2D_PP_COMPOSITOR
		PostProcessing.compositorPass.compile(Shaders.compositor_pass_frag);
		#end
		#end
	}

	static inline function render(target:Canvas, stage:Stage):Image {
		var g2:kha.graphics2.Graphics, g4:kha.graphics4.Graphics;
		var sourceInd:Int = 0, targetInd:Int = 0;

		var VP = stage.viewProjection;
		var cameraPos = stage.camera.finalTransformation.getTranslation();

		// Geometry Pass
		g4 = gBuffer.g4;
		g4.begin();
		g4.clear(Black);
		g4.setPipeline(geometryPass.pipeline);
		g4.setIndexBuffer(Sprite.indices);
		g4.setVertexBuffer(Sprite.vertices);
		for (sprite in stage.sprites) {
			g4.setMatrix(geometryPass.modelCL, sprite.finalTransformation);
			g4.setMatrix(geometryPass.viewProjectionCL, VP);
			g4.setTexture(geometryPass.colorMapTU, sprite.material.colorMap);
			g4.setTexture(geometryPass.normalMapTU, sprite.material.normalMap);
			g4.setTexture(geometryPass.ormMapTU, sprite.material.ormMap);
			g4.setTexture(geometryPass.glowMapTU, sprite.material.glowMap);
			g4.setFloats(geometryPass.paramsCL, sprite.material.params);
			g4.drawIndexedVertices();
		}
		g4.end();
		sourceInd = 0;
		targetInd = 0;

		// Lighting Pass
		// environment + glow pass
		g2 = ppBuffer[targetInd].g2;
		g4 = ppBuffer[targetInd].g4;
		g2.begin();
		g4.setPipeline(envLightingPass.pipeline);
		g4.setIndexBuffer(Sprite.indices);
		g4.setVertexBuffer(Sprite.vertices);
		g4.setTexture(envLightingPass.gMapTU, gBuffer);
		#if S2D_RP_ENV_LIGHTING
		g4.setTexture(envLightingPass.envMapTU, stage.environmentMap);
		g4.setTextureParameters(envLightingPass.envMapTU, Clamp, Clamp, LinearFilter, LinearFilter, LinearMipFilter);
		#end
		g4.drawIndexedVertices();
		// stage lights
		g4.setPipeline(lightingPass.pipeline);
		g4.setIndexBuffer(Sprite.indices);
		g4.setVertexBuffer(Sprite.vertices);
		g4.setTexture(lightingPass.gMapTU, gBuffer);
		g4.setMatrix(lightingPass.invVPCL, VP.inverse());
		g4.setFloats(lightingPass.lightsDataCL, stage.lightsData);
		g4.drawIndexedVertices();
		g2.end();
		sourceInd = 0;
		targetInd = 1;

		// post-processing
		#if S2D_PP
		var invVP = VP.inverse();

		#if S2D_PP_MIST
		var mist = PostProcessing.mist;
		PostProcessing.mistPass.render(ppBuffer[targetInd], Sprite.indices, Sprite.vertices, [
			ppBuffer[sourceInd],
			// uniforms
			gBuffer,
			invVP,
			cameraPos,
			mist.near,
			mist.far,
			mist.color.R,
			mist.color.G,
			mist.color.B,
			mist.color.A
		]);
		sourceInd = 1;
		targetInd = 0;
		#end

		#if S2D_PP_DOF
		var dof = PostProcessing.dof;
		PostProcessing.dofPass.render(ppBuffer[targetInd], Sprite.indices, Sprite.vertices, [
			ppBuffer[sourceInd],
			// uniforms
			gBuffer,
			invVP,
			cameraPos,
			dof.focusDistance,
			dof.blurSize
		]);
		sourceInd = 0;
		targetInd = 1;
		#end

		#if S2D_PP_FISHEYE
		var fisheye = PostProcessing.fisheye;
		PostProcessing.fisheyePass.render(ppBuffer[targetInd], Sprite.indices, Sprite.vertices, [
			ppBuffer[sourceInd],
			// uniforms
			fisheye.position.x,
			fisheye.position.y,
			fisheye.strength
		]);
		sourceInd = 1;
		targetInd = 0;
		#end

		#if S2D_PP_FILTER
		for (i in 0...PostProcessing.filters.length) {
			sourceInd = (i + 1) % 2;
			targetInd = i % 2;
			PostProcessing.filterPass.render(ppBuffer[targetInd], Sprite.indices, Sprite.vertices, [
				ppBuffer[sourceInd],
				// uniforms
				PostProcessing.filters[i]
			]);
		}
		#end

		#if S2D_PP_COMPOSITOR
		var compositor = PostProcessing.compositor;
		g2 = ppBuffer[sourceInd].g2;
		g2.scissor(0, compositor.letterBoxHeight, target.width, target.height - compositor.letterBoxHeight * 2);
		PostProcessing.compositorPass.render(ppBuffer[sourceInd], Sprite.indices, Sprite.vertices, [
			ppBuffer[targetInd],
			// uniforms
			compositor.params
		]);
		g2.disableScissor();
		#end
		#end

		return ppBuffer[sourceInd];
	};
}
