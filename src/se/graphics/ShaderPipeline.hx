package se.graphics;

import kha.graphics4.CullMode;
import kha.graphics4.CompareMode;
import kha.graphics4.StencilValue;
import kha.graphics4.StencilAction;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexStructure;

@:forward()
@:forward.new
extern abstract ShaderPipeline(PipelineState) from PipelineState to PipelineState {
	@:from
	static inline function fromState(state:ShaderPipelineState):ShaderPipeline {
		final pipeline = new PipelineState();
		pipeline.inputLayout = state.inputLayout;
		pipeline.vertexShader = state.vertexShader;
		pipeline.fragmentShader = state.fragmentShader;

		pipeline.cullMode = state.cullMode ?? pipeline.cullMode;
		pipeline.depthWrite = state.depthWrite ?? pipeline.depthWrite;
		pipeline.depthMode = state.depthMode ?? pipeline.depthMode;

		pipeline.stencilFrontMode = state.stencilFrontMode ?? pipeline.stencilFrontMode;
		pipeline.stencilFrontBothPass = state.stencilFrontBothPass ?? pipeline.stencilFrontBothPass;
		pipeline.stencilFrontDepthFail = state.stencilFrontDepthFail ?? pipeline.stencilFrontDepthFail;
		pipeline.stencilFrontFail = state.stencilFrontFail ?? pipeline.stencilFrontFail;
		pipeline.stencilBackMode = state.stencilBackMode ?? pipeline.stencilBackMode;
		pipeline.stencilBackBothPass = state.stencilBackBothPass ?? pipeline.stencilBackBothPass;
		pipeline.stencilBackDepthFail = state.stencilBackDepthFail ?? pipeline.stencilBackDepthFail;
		pipeline.stencilBackFail = state.stencilBackFail ?? pipeline.stencilBackFail;
		pipeline.stencilReferenceValue = state.stencilReferenceValue ?? pipeline.stencilReferenceValue;
		pipeline.stencilReadMask = state.stencilReadMask ?? pipeline.stencilReadMask;
		pipeline.stencilWriteMask = state.stencilWriteMask ?? pipeline.stencilWriteMask;

		pipeline.blendSource = state.blendSource ?? pipeline.blendSource;
		pipeline.blendDestination = state.blendDestination ?? pipeline.blendDestination;
		pipeline.blendOperation = state.blendOperation ?? pipeline.blendOperation;
		pipeline.alphaBlendSource = state.alphaBlendSource ?? pipeline.alphaBlendSource;
		pipeline.alphaBlendDestination = state.alphaBlendDestination ?? pipeline.alphaBlendDestination;
		pipeline.alphaBlendOperation = state.alphaBlendOperation ?? pipeline.alphaBlendOperation;

		pipeline.colorWriteMask = state.colorWriteMask ?? true;
		pipeline.colorWriteMaskRed = state.colorWriteMaskRed ?? pipeline.colorWriteMaskRed;
		pipeline.colorWriteMaskGreen = state.colorWriteMaskGreen ?? pipeline.colorWriteMaskGreen;
		pipeline.colorWriteMaskBlue = state.colorWriteMaskBlue ?? pipeline.colorWriteMaskBlue;
		pipeline.colorWriteMaskAlpha = state.colorWriteMaskAlpha ?? pipeline.colorWriteMaskAlpha;
		pipeline.colorWriteMasksRed = state.colorWriteMasksRed ?? pipeline.colorWriteMasksRed;
		pipeline.colorWriteMasksGreen = state.colorWriteMasksGreen ?? pipeline.colorWriteMasksGreen;
		pipeline.colorWriteMasksBlue = state.colorWriteMasksBlue ?? pipeline.colorWriteMasksBlue;
		pipeline.colorWriteMasksAlpha = state.colorWriteMasksAlpha ?? pipeline.colorWriteMasksAlpha;

		pipeline.colorAttachmentCount = state.colorAttachmentCount ?? pipeline.colorAttachmentCount;
		pipeline.colorAttachments = state.colorAttachments ?? pipeline.colorAttachments;

		pipeline.depthStencilAttachment = state.depthStencilAttachment ?? pipeline.depthStencilAttachment;
		pipeline.conservativeRasterization = state.conservativeRasterization ?? pipeline.conservativeRasterization;

		pipeline.compile();
		return pipeline;
	}
}

typedef ShaderPipelineState = {
	var inputLayout:Array<VertexStructure>;
	var vertexShader:VertexShader;
	var fragmentShader:FragmentShader;

	var ?cullMode:CullMode;
	var ?depthWrite:Bool;
	var ?depthMode:CompareMode;
	var ?stencilFrontMode:CompareMode;
	var ?stencilFrontBothPass:StencilAction;
	var ?stencilFrontDepthFail:StencilAction;
	var ?stencilFrontFail:StencilAction;
	var ?stencilBackMode:CompareMode;
	var ?stencilBackBothPass:StencilAction;
	var ?stencilBackDepthFail:StencilAction;
	var ?stencilBackFail:StencilAction;
	var ?stencilReferenceValue:StencilValue;
	var ?stencilReadMask:Int;
	var ?stencilWriteMask:Int;
	var ?blendSource:BlendingFactor;
	var ?blendDestination:BlendingFactor;
	var ?blendOperation:BlendingOperation;
	var ?alphaBlendSource:BlendingFactor;
	var ?alphaBlendDestination:BlendingFactor;
	var ?alphaBlendOperation:BlendingOperation;
	var ?colorWriteMask:Bool;
	var ?colorWriteMaskRed:Bool;
	var ?colorWriteMaskGreen:Bool;
	var ?colorWriteMaskBlue:Bool;
	var ?colorWriteMaskAlpha:Bool;
	var ?colorWriteMasksRed:Array<Bool>;
	var ?colorWriteMasksGreen:Array<Bool>;
	var ?colorWriteMasksBlue:Array<Bool>;
	var ?colorWriteMasksAlpha:Array<Bool>;
	var ?colorAttachmentCount:Int;
	var ?colorAttachments:Array<TextureFormat>;
	var ?depthStencilAttachment:DepthStencilFormat;
	var ?conservativeRasterization:Bool;
}
