package s2d.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
// s2d
import s2d.objects.Light;

class ShadowPass {
	public static var structure:VertexStructure;
	static var pipeline:PipelineState;
	static var vpCL:ConstantLocation;
	static var lightPosCL:ConstantLocation;

	public static function compile() {
		structure = new VertexStructure();
		structure.add("vertData", Float32_4X);
		structure.add("opacity", Float32_1X);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.shadow_vert;
		pipeline.fragmentShader = Shaders.shadow_frag;
		pipeline.depthWrite = true;
		pipeline.depthMode = Less;
		pipeline.cullMode = CounterClockwise;
		pipeline.depthStencilAttachment = DepthOnly;
		pipeline.alphaBlendSource = SourceAlpha;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.compile();

		vpCL = pipeline.getConstantLocation("VP");
		lightPosCL = pipeline.getConstantLocation("lightPos");
	}

	public static function render(light:Light):Void @:privateAccess {
		final target = @:privateAccess Renderer.buffer.shadowMap;
		target.setDepthStencilFrom(Renderer.buffer.depthMap);

		final g4 = target.g4;
		g4.begin();
		g4.clear(White);
		if (light.isMappingShadows) {
			g4.setPipeline(pipeline);
			g4.setIndexBuffer(light.layer.shadowBuffer.indices);
			g4.setVertexBuffer(light.layer.shadowBuffer.vertices);
			g4.setMatrix3(vpCL, Stage.current.viewProjection);
			g4.setVector2(lightPosCL, light.finalModel.translation);
			g4.drawIndexedVertices();
		}
		g4.end();
	}
}
#end
