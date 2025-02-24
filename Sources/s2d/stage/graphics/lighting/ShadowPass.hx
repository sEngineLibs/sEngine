package s2d.stage.graphics.lighting;

#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import s2d.stage.objects.Light;

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
		pipeline.vertexShader = Reflect.field(Shaders, "shadow_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "shadow_frag");
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

		final ctx = target.context3D;
		ctx.begin();
		ctx.clear(White);
		if (light.isMappingShadows) {
			ctx.setPipeline(pipeline);
			ctx.setIndexBuffer(light.layer.shadowBuffer.indices);
			ctx.setVertexBuffer(light.layer.shadowBuffer.vertices);
			ctx.setMat3(vpCL, Stage.current.viewProjection);
			ctx.setVec2(lightPosCL, light._transform.global.translation);
			ctx.draw();
		}
		ctx.end();
	}
}
#end
