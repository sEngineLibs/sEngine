package s2d.graphics;

import kha.Image;
// s2d
import s2d.graphics.Lighting;

@:access(s2d.graphics.Lighting)
@:access(s2d.graphics.postprocessing.PPEffect)
class Renderer {
	static var commands:Array<Void->Void>;
	static var buffer:RenderBuffer;

	public static inline function init(width:Int, height:Int) {
		buffer = new RenderBuffer(width, height);
		commands = [Lighting.render];

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
		Lighting.compile();

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
