package s2d.graphics.lighting;

#if (S2D_LIGHTING_SHADOWS == 1)
import kha.Canvas;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;

class ShadowCaster {
	static var structure:VertexStructure;
	static var pipeline:PipelineState;
	static var vpCL:ConstantLocation;

	public static inline function compile() {
		structure = new VertexStructure();
		structure.add("vertCoord", Float32_2X);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.shadow_vert;
		pipeline.fragmentShader = Shaders.shadow_frag;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();

		vpCL = pipeline.getConstantLocation("VP");
	}

	@:access(s2d.Layer)
	public static inline function drawShadows(target:Canvas, layer:Layer):Void {
		final g4 = target.g4;
		final viewProjection = S2D.stage.viewProjection;

		g4.begin();
		g4.clear(White);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(layer.shadowIndices);
		g4.setVertexBuffer(layer.shadowVertices);
		g4.setMatrix3(vpCL, viewProjection);
		g4.drawIndexedVertices();
		g4.end();
	}
}
#end
