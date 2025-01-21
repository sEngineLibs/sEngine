package s2d.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
import kha.Image;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;

class ShadowCaster {
	static var structure:VertexStructure;
	static var pipeline:PipelineState;

	public static inline function compile() {
		structure = new VertexStructure();
		structure.add("vertData", Float32_4X);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.shadow_vert;
		pipeline.fragmentShader = Shaders.shadow_frag;
		pipeline.depthWrite = false;
		pipeline.depthMode = Greater;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();
	}

	@:access(s2d.Layer)
	public static inline function render(target:Image, layer:Layer):Void {
		final g4 = target.g4;
		target.setDepthStencilFrom(Renderer.buffer.depthMap);

		g4.begin();
		g4.clear(White);
		g4.setPipeline(pipeline);
		g4.setIndexBuffer(layer.shadowIndices);
		g4.setVertexBuffer(layer.shadowVertices);
		g4.drawIndexedVertices();
		g4.end();
	}
}
#end
