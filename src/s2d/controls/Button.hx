package s2d.controls;

import s2d.elements.Label;
import s2d.layouts.HBoxLayout;
import s2d.shapes.RoundedRectangle;

class Button extends AbstractButton {
	public var label:Label;
	public var indicator:Element;

	public function new(text:String = "Button", name:String = "button") {
		super(text, name);
		background = {
			var rect = new RoundedRectangle();
			rect.color = Color.rgb(0.75, 0.75, 0.75);
			onHoveredChanged((_) -> if (!pressed) 
				rect.color = hovered ? Color.rgb(0.85, 0.85, 0.85) : Color.rgb(0.75, 0.75, 0.75)
			);
			onPressedChanged((_) -> 
				rect.color = pressed ? Color.rgb(0.55, 0.55, 0.55) : Color.rgb(0.75, 0.75, 0.75)
			);
			rect;
		}
		content = {
			var layout = new HBoxLayout();
			layout.addChild({
				var ind = new RoundedRectangle(text);
				ind.color = Black;
				onToggled(() -> ind.color = checked ? White : Black);
				indicator = ind;
			});
			layout.addChild({
				label = new Label(text);
				label.layout.fillWidth = true;
				label.layout.fillHeight = true;
				label.color = Black;
				label.alignment = AlignCenter;
				label;
			});
			layout;
		}
	}

	@:slot(checkableChanged)
	function __syncCheckableChanged__(_) {
		indicator.visible = checkable;
	}

	@:slot(textChanged)
	function __syncTextChanged__(_) {
		label.text = text;
	}
}
