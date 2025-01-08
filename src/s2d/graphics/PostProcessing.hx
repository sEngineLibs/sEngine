package s2d.graphics;

import s2d.graphics.postprocessing.*;

class PostProcessing {
	#if S2D_PP_DOF
	@:isVar public static var dof(default, never) = new DOF();
	#end
	#if S2D_PP_MIST
	@:isVar public static var mist(default, never) = new Mist();
	#end
	#if S2D_PP_FISHEYE
	@:isVar public static var fisheye(default, never) = new Fisheye();
	#end
	#if S2D_PP_FILTER
	@:isVar public static var filter(default, never) = new Filter();
	#end
	#if S2D_PP_COMPOSITOR
	@:isVar public static var compositor(default, never) = new Compositor();
	#end
}
