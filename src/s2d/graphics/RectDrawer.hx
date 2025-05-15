package s2d.graphics;

import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import se.Texture;
import s2d.elements.shapes.RoundedRectangle;

@:access(s2d.elements.Element)
@:dox(hide)
class RectDrawer extends ElementDrawer<RoundedRectangle> {
	var rectCL:ConstantLocation;
	var rectDataCL:ConstantLocation;
	var bordColCL:ConstantLocation;

	public function new() {
		var structure = new VertexStructure();
		structure.add("vertPos", Float32_3X);
		structure.add("vertColor", UInt8_4X_Normalized);

		super({
			inputLayout: [structure],
			vertexShader: Reflect.field(Shaders, "drawer_colored_vert"),
			fragmentShader: Reflect.field(Shaders, "rectangle_frag"),
			alphaBlendSource: SourceAlpha,
			alphaBlendDestination: InverseSourceAlpha,
			blendSource: SourceAlpha,
			blendDestination: InverseSourceAlpha
		});
	}

	override function setup() {
		super.setup();
		rectCL = pipeline.getConstantLocation("rect");
		rectDataCL = pipeline.getConstantLocation("rectData");
		bordColCL = pipeline.getConstantLocation("bordCol");
	}

	function draw(target:Texture, rectangle:RoundedRectangle) {
		final ctx = target.context2D, ctx3d = target.context3D;
		final rect = rectangle._rect;
		final bordCol = rectangle.border.color;

		ctx3d.setFloat4(rectCL, rectangle.absX, rectangle.absY, rectangle.width, rectangle.height);
		ctx3d.setFloat3(rectDataCL, rectangle._radius, rectangle.softness, rectangle.border.width);
		ctx3d.setFloat4(bordColCL, bordCol.r, bordCol.g, bordCol.b, bordCol.a);

		ctx.fillRect(rect.x, rect.y, rect.width, rect.height);
	}
}
