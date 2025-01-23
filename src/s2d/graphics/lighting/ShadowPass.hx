package s2d.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;

class ShadowPass {
	static var structure:VertexStructure;
	static var pipeline:PipelineState;

	public static function compile() {
		structure = new VertexStructure();
		structure.add("vertData", Float32_4X);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.shadow_vert;
		pipeline.fragmentShader = Shaders.shadow_frag;
		pipeline.depthWrite = false;
		pipeline.depthMode = Greater;
		pipeline.depthStencilAttachment = DepthOnly;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.blendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();
	}

	@:access(s2d.Layer)
	@:access(s2d.ShadowBuffers)
	@:access(s2d.graphics.Renderer)
	public static function render():Void {
		for (layer in S2D.stage.layers) {
			for (shadowBuffer in layer.shadowBuffers.buffers) {
				final target = @:privateAccess shadowBuffer.map;
				target.setDepthStencilFrom(Renderer.buffer.depthMap);
				final g4 = target.g4;

				g4.begin();
				g4.clear(White);
				g4.setPipeline(pipeline);
				g4.setIndexBuffer(layer.shadowBuffers.indices);
				g4.setVertexBuffer(@:privateAccess shadowBuffer.vertices);
				g4.drawIndexedVertices();
				g4.end();
			}
		}
	}
}
#end
