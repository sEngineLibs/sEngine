package se.graphics;

@:forward.new
@:forward(begin, end, clear, flush)
@:forward(pipeline, font, fontsize)
@:forward(drawRect, fillRect, fillTriangle, drawLine, drawCharacters, drawImage, drawScaledImage, drawSubImage, drawScaledSubImage)
abstract G2(kha.graphics2.Graphics) from kha.graphics2.Graphics to kha.graphics2.Graphics {
	public var color(get, set):Color;

	inline function get_color():Color {
		return this.color;
	}

	inline function set_color(value:Color):Color {
		this.color = value;
		return this.color;
	}
}
