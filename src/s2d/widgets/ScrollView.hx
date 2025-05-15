package s2d.widgets;

import se.events.MouseEvents;
import s2d.elements.Element;

class ScrollView extends Element {
	public var scrollDelta:Float = 10.0;

	public function new(name:String = "scrollView") {
		super(name);
	}

	@:slot(mouseScrolled)
	function scrolled(m:MouseScrollEvent) {
		for (c in children)
			c.y -= m.delta * scrollDelta;
	}
}
