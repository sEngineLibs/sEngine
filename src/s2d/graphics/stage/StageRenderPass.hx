package s2d.graphics.stage;

import se.graphics.ShaderPass;
import s2d.stage.Stage;

@:dox(hide)
abstract class StageRenderPass extends ShaderPass {
	abstract function render(stage:Stage):Void;
}
