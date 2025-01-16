package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.Shaders;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
// s2d
import s2d.math.Mat3;

class Filter extends PPEffect {
	var textureMapTU:TextureUnit;
	var resolutionCL:ConstantLocation;
	var kernelCL:ConstantLocation;

	public var kernels:Array<Mat3> = [];

	public inline function addKernel(kernel:Mat3) {
		kernels.push(kernel);
	}

	inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.filter_frag;
	}

	inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		resolutionCL = pipeline.getConstantLocation("resolution");
		kernelCL = pipeline.getConstantLocation("kernel");
	}

	inline function render(target:Canvas) {
		final g2 = target.g2;
		final g4 = target.g4;

		g2.begin();
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(S2D.indices);
		g4.setVertexBuffer(S2D.vertices);
		g4.setTexture(textureMapTU, Renderer.ppBuffer.src);
		g4.setFloat2(resolutionCL, S2D.width, S2D.height);
		for (kernel in kernels) {
			g4.setMatrix3(kernelCL, kernel);
			g4.drawIndexedVertices();
		}
		g2.end();
	}

	public static var Sharpen(get, never):Mat3;

	static inline function get_Sharpen() {
		return new Mat3(0, -1, 0, -1, 5, -1, 0, -1, 0);
	}

	public static var BoxBlur(get, never):Mat3;

	static inline function get_BoxBlur() {
		return new Mat3(0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111, 0.111);
	}

	public static var GaussianBlur(get, never):Mat3;

	static inline function get_GaussianBlur() {
		return new Mat3(0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625);
	}

	public static var EdgeDetectionVertical(get, never):Mat3;

	static inline function get_EdgeDetectionVertical() {
		return new Mat3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	}

	public static var EdgeDetectionHorizontal(get, never):Mat3;

	static inline function get_EdgeDetectionHorizontal() {
		return new Mat3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	}

	public static var EdgeDetectionDiagonal1(get, never):Mat3;

	static inline function get_EdgeDetectionDiagonal1() {
		return new Mat3(0, -1, -1, -1, 4, -1, -1, -1, 0);
	}

	public static var EdgeDetectionDiagonal2(get, never):Mat3;

	static inline function get_EdgeDetectionDiagonal2() {
		return new Mat3(-1, -1, 0, -1, 4, -1, 0, -1, -1);
	}

	public static var Emboss(get, never):Mat3;

	static inline function get_Emboss() {
		return new Mat3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	}

	public static var Laplacian(get, never):Mat3;

	static inline function get_Laplacian() {
		return new Mat3(0, -1, 0, -1, 4, -1, 0, -1, 0);
	}

	public static var SobelVertical(get, never):Mat3;

	static inline function get_SobelVertical() {
		return new Mat3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	}

	public static var SobelHorizontal(get, never):Mat3;

	static inline function get_SobelHorizontal() {
		return new Mat3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	}

	public static var Outline(get, never):Mat3;

	static inline function get_Outline() {
		return new Mat3(-1, -1, -1, -1, 8, -1, -1, -1, -1);
	}

	public static var HighPass(get, never):Mat3;

	static inline function get_HighPass() {
		return new Mat3(-1, -1, -1, -1, 9, -1, -1, -1, -1);
	}

	public static var RidgeDetection(get, never):Mat3;

	static inline function get_RidgeDetection() {
		return new Mat3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	}

	public static var DepthEnhance(get, never):Mat3;

	static inline function get_DepthEnhance() {
		return new Mat3(1, 1, 1, 1, -7, 1, 1, 1, 1);
	}

	public static var PrewittHorizontal(get, never):Mat3;

	static inline function get_PrewittHorizontal() {
		return new Mat3(-1, -1, -1, 0, 0, 0, 1, 1, 1);
	}

	public static var PrewittVertical(get, never):Mat3;

	static inline function get_PrewittVertical() {
		return new Mat3(-1, 0, 1, -1, 0, 1, -1, 0, 1);
	}

	public static var Identity(get, never):Mat3;

	static inline function get_Identity() {
		return new Mat3(0, 0, 0, 0, 1, 0, 0, 0, 0);
	}
}
