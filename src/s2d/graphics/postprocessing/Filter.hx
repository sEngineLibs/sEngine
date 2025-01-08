package s2d.graphics.postprocessing;

import kha.Canvas;
import kha.Shaders;
import kha.math.FastMatrix3;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;

class Filter extends PPEffect {
	var textureMapTU:TextureUnit;
	var resolutionCL:ConstantLocation;
	var kernelCL:ConstantLocation;

	public var kernels:Array<FastMatrix3> = [];

	public inline function new() {}

	public inline function addKernel(kernel:Kernel) {
		kernels.push(kernel);
	}

	override inline function setPipeline() {
		pipeline.vertexShader = Shaders.s2d_2d_vert;
		pipeline.fragmentShader = Shaders.filter_pass_frag;
	}

	override inline function getUniforms() {
		textureMapTU = pipeline.getTextureUnit("textureMap");
		resolutionCL = pipeline.getConstantLocation("resolution");
		kernelCL = pipeline.getConstantLocation("kernel");
	}

	override inline function render(target:Canvas) {
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
}

enum abstract Kernel(FastMatrix3) from FastMatrix3 to FastMatrix3 {
	public static var Identity = new FastMatrix3(0, 0, 0, 0, 1, 0, 0, 0, 0);
	public static var Sharpen = new FastMatrix3(0, -1, 0, -1, 5, -1, 0, -1, 0);
	public static var BoxBlur = new FastMatrix3(0.111, 0.111, 0.111, 0.112, 0.111, 0.111, 0.111, 0.111, 0.111);
	public static var GaussianBlur = new FastMatrix3(0.0625, 0.125, 0.0625, 0.125, 0.25, 0.125, 0.0625, 0.125, 0.0625);
	public static var EdgeDetectionVertical = new FastMatrix3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	public static var EdgeDetectionHorizontal = new FastMatrix3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	public static var EdgeDetectionDiagonal1 = new FastMatrix3(0, -1, -1, -1, 4, -1, -1, -1, 0);
	public static var EdgeDetectionDiagonal2 = new FastMatrix3(-1, -1, 0, -1, 4, -1, 0, -1, -1);
	public static var Emboss = new FastMatrix3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	public static var Laplacian = new FastMatrix3(0, -1, 0, -1, 4, -1, 0, -1, 0);
	public static var SobelVertical = new FastMatrix3(-1, 0, 1, -2, 0, 2, -1, 0, 1);
	public static var SobelHorizontal = new FastMatrix3(-1, -2, -1, 0, 0, 0, 1, 2, 1);
	public static var Outline = new FastMatrix3(-1, -1, -1, -1, 8, -1, -1, -1, -1);
	public static var HighPass = new FastMatrix3(-1, -1, -1, -1, 9, -1, -1, -1, -1);
	public static var RidgeDetection = new FastMatrix3(-2, -1, 0, -1, 1, 1, 0, 1, 2);
	public static var DepthEnhance = new FastMatrix3(1, 1, 1, 1, -7, 1, 1, 1, 1);
	public static var PrewittHorizontal = new FastMatrix3(-1, -1, -1, 0, 0, 0, 1, 1, 1);
	public static var PrewittVertical = new FastMatrix3(-1, 0, 1, -1, 0, 1, -1, 0, 1);
}
