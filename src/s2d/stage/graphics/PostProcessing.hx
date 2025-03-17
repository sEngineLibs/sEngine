package s2d.stage.graphics;

#if S2D_PP_BLOOM
import s2d.stage.graphics.postprocessing.Bloom;
#end
#if S2D_PP_FISHEYE
import s2d.stage.graphics.postprocessing.Fisheye;
#end
#if S2D_PP_FILTER
import s2d.stage.graphics.postprocessing.Filter;
#end
#if S2D_PP_COMPOSITOR
import s2d.stage.graphics.postprocessing.Compositor;
#end

class PostProcessing {
	#if S2D_PP_BLOOM
	@:isVar public static var bloom(default, never) = new Bloom();
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
