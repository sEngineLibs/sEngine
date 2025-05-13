package s2d.controls;

import se.events.MouseEvents;
import s2d.elements.Text;
import s2d.elements.Element;
import s2d.elements.layouts.HBoxLayout;
import s2d.elements.shapes.RoundedRectangle;

class Button extends AbstractButton {
	public var label:Text;
	public var indicator:Element;

	@alias public var checkable:Bool = indicator.visible;
	@alias public var text:String = label.text;

	@track public var checked:Bool = false;

	@:signal function toggled();

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
				var ind = new RoundedRectangle(text);
				ind.color = Black;
				onToggled(() -> ind.color = checked ? White : Black);
				indicator = ind;
			});
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

	override function __syncMouseReleased__(m:MouseButtonEvent) {
		super.__syncMouseReleased__(m);
		if (checkable && hovered) {
			checked = !checked;
			toggled();
		}
	}
}
