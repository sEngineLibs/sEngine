package s2d.graphics.stage;

import se.Texture;
import se.graphics.ShaderPipeline;
import se.graphics.ShaderPass;
import s2d.stage.Stage;

abstract class StageRenderPass extends ShaderPass {
	abstract function render(target:Texture, stage:Stage):Void;
}
