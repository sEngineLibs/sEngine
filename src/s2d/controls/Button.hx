package s2d.controls;

import s2d.elements.Text;
import s2d.layouts.HBoxLayout;
import s2d.elements.shapes.RoundedRectangle;

class Button extends AbstractButton {
	public var label:Text;

	@alias public var text:String = label.text;

	public function new(text:String = "Button", name:String = "button") {
		super(name);
		background = {
			var rect = new RoundedRectangle();
			rect.color = Color.rgb(0.75, 0.75, 0.75);
			onHoveredChanged((_) -> if (!pressed) {
				rect.color = hovered ? Color.rgb(0.85, 0.85, 0.85) : Color.rgb(0.75, 0.75, 0.75);
			});
			onPressedChanged((_) -> {
				rect.color = pressed ? Color.rgb(0.55, 0.55, 0.55) : Color.rgb(0.75, 0.75, 0.75);
			});
			rect;
		}
		content = {
			var layout = new HBoxLayout();
			layout.addChild({
				label = new Text(text);
				label.layout.fillWidth = true;
				label.layout.fillHeight = true;
				label.color = Black;
				label.alignment = AlignCenter;
				label;
			});
			layout;
		}
	}
}
