package s2d.elements;

class TextInput extends Label {
	public function new(?parent:Element) {
		super(parent);

		onKeyboardPressed(c -> text += c);
		onKeyboardKeyDown(Backspace, () -> text = text.substring(0, text.length - 1));
	}
}
