package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
// s2d
import kha.math.FastMatrix3;

class Filter extends PPEffect {
	var textureMapTU:TextureUnit;
	var kernelCL:ConstantLocation;

	public var kernels:Array<FastMatrix3> = [];

	public inline function addKernel(kernel:FastMatrix3) {
		kernels.push(kernel);
	}

	inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.filter_frag;
	}

	inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		kernelCL = pipeline.getConstantLocation("kernel");
	}

	@:access(s2d.graphics.Renderer)
	inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(textureMapTU, Renderer.buffer.src);
		for (kernel in kernels) {
			g4.setMatrix3(kernelCL, kernel);
			g4.drawIndexedVertices();
		}
		g2.end();
	}

	public static var Sharpen(get, never):FastMatrix3;

	static inline function get_Sharpen() {
		return new FastMatrix3(0, -1, 0, -1, 5, -1, 0, -1, 0);
	}

	public static var BoxBlur(get, never):FastMatrix3;

	static inline function get_BoxBlur() {
		return new FastMatrix3(0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111);
	}

	public static var GaussianBlur(get, never):FastMatrix3;

	static inline function get_GaussianBlur() {
		return new FastMatrix3(0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625);
	}

	public static var EdgeDetectionVertical(get, never):FastMatrix3;

	static inline function get_EdgeDetectionVertical() {
		return new FastMatrix3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	}

	public static var EdgeDetectionHorizontal(get, never):FastMatrix3;

	static inline function get_EdgeDetectionHorizontal() {
		return new FastMatrix3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	}

	public static var EdgeDetectionDiagonal1(get, never):FastMatrix3;

	static inline function get_EdgeDetectionDiagonal1() {
		return new FastMatrix3(0, -1, -1, -1, 4, -1, -1, -1, 0);
	}

	public static var EdgeDetectionDiagonal2(get, never):FastMatrix3;

	static inline function get_EdgeDetectionDiagonal2() {
		return new FastMatrix3(-1, -1, 0, -1, 4, -1, 0, -1, -1);
	}

	public static var Emboss(get, never):FastMatrix3;

	static inline function get_Emboss() {
		return new FastMatrix3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	}

	public static var Laplacian(get, never):FastMatrix3;

	static inline function get_Laplacian() {
		return new FastMatrix3(0, -1, 0, -1, 4, -1, 0, -1, 0);
	}

	public static var SobelVertical(get, never):FastMatrix3;

	static inline function get_SobelVertical() {
		return new FastMatrix3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	}

	public static var SobelHorizontal(get, never):FastMatrix3;

	static inline function get_SobelHorizontal() {
		return new FastMatrix3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	}

	public static var Outline(get, never):FastMatrix3;

	static inline function get_Outline() {
		return new FastMatrix3(-1, -1, -1, -1, 8, -1, -1, -1, -1);
	}

	public static var HighPass(get, never):FastMatrix3;

	static inline function get_HighPass() {
		return new FastMatrix3(-1, -1, -1, -1, 9, -1, -1, -1, -1);
	}

	public static var RidgeDetection(get, never):FastMatrix3;

	static inline function get_RidgeDetection() {
		return new FastMatrix3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	}

	public static var DepthEnhance(get, never):FastMatrix3;

	static inline function get_DepthEnhance() {
		return new FastMatrix3(1, 1, 1, 1, -7, 1, 1, 1, 1);
	}

	public static var PrewittHorizontal(get, never):FastMatrix3;

	static inline function get_PrewittHorizontal() {
		return new FastMatrix3(-1, -1, -1, 0, 0, 0, 1, 1, 1);
	}

	public static var PrewittVertical(get, never):FastMatrix3;

	static inline function get_PrewittVertical() {
		return new FastMatrix3(-1, 0, 1, -1, 0, 1, -1, 0, 1);
	}

	public static var Identity(get, never):FastMatrix3;

	static inline function get_Identity() {
		return new FastMatrix3(0, 0, 0, 0, 1, 0, 0, 0, 0);
	}
}
