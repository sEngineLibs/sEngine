package s2d.graphics;

import kha.Image;
// s2d
#if (S2D_RP_LIGHTING_DEFFERED == 1)
import s2d.graphics.lighting.GeometryDeferred;
import s2d.graphics.lighting.LightingDeferred;
#else
import s2d.graphics.lighting.LightingForward;
#end

@:allow(s2d.graphics.postprocessing.PPEffect)
@:access(s2d.graphics.postprocessing.PPEffect)
class Renderer {
	static var commands:Array<Void->Void>;
	static var buffer:RenderBuffer;

	public static inline function init(width:Int, height:Int) {
		buffer = new RenderBuffer(width, height);

		#if (S2D_RP_LIGHTING_DEFFERED == 1)
		commands = [GeometryDeferred.render, LightingDeferred.render];
		#else
		commands = [LightingForward.render];
		#end

		#if S2D_PP_MIST
		PostProcessing.mist.index = 2;
		PostProcessing.mist.enable();
		#end

		#if S2D_PP_DOF
		PostProcessing.dof.index = 3;
		PostProcessing.dof.enable();
		#end

		#if S2D_PP_BLOOM
		PostProcessing.bloom.index = 3;
		PostProcessing.bloom.enable();
		#end

		#if S2D_PP_FISHEYE
		PostProcessing.fisheye.index = 4;
		PostProcessing.fisheye.enable();
		#end

		#if S2D_PP_FILTER
		PostProcessing.filter.index = 5;
		PostProcessing.filter.enable();
		#end

		#if S2D_PP_COMPOSITOR
		PostProcessing.compositor.index = 6;
		PostProcessing.compositor.enable();
		#end
	}

	public static inline function resize(width:Int, height:Int) {
		buffer.resize(width, height);
	}

	public static inline function compile() {
		#if (S2D_RP_LIGHTING_DEFFERED == 1)
		GeometryDeferred.compile();
		LightingDeferred.compile();
		#else
		LightingForward.compile();
		#end

		#if S2D_PP_DOF
		PostProcessing.dof.compile();
		#end
		#if S2D_PP_MIST
		PostProcessing.mist.compile();
		#end
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
}
