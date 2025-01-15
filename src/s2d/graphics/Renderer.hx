package s2d.graphics;

import kha.Image;
// s2d
import s2d.graphics.shaders.*;

@:allow(s2d.graphics.postprocessing.PPEffect)
@:access(s2d.graphics.postprocessing.PPEffect)
class Renderer {
	static var commands:Array<Void->Void>;

	static var gBuffer:GBuffer;
	static var ppBuffer:PingPongBuffer;

	public static inline function init(width:Int, height:Int) {
		resize(width, height);
		commands = [GeometryPass.render, LightingPass.render];

		#if S2D_PP_MIST
		PostProcessing.mist.index = 2;
		PostProcessing.mist.enable();
		#end

		#if S2D_PP_DOF
		PostProcessing.dof.index = 3;
		PostProcessing.dof.enable();
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
		gBuffer = new GBuffer(width, height);
		ppBuffer = new PingPongBuffer(width, height);
	}

	public static inline function compile() {
		GeometryPass.compile();
		LightingPass.compile();

		#if S2D_PP_DOF
		PostProcessing.dof.compile();
		#end
		#if S2D_PP_MIST
		PostProcessing.mist.compile();
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
		return ppBuffer.tgt;
	};
}
