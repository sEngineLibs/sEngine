package s2d.ui.graphics;

import se.Texture;
import kha.Shaders;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import se.math.VectorMath;
import s2d.ui.elements.shapes.RoundedRectangle;

class RectDrawer extends ElementDrawer<RoundedRectangle> {
	var rectCL:ConstantLocation;
	var rectDataCL:ConstantLocation;
	var bordColorCL:ConstantLocation;

	inline function initStructure() {
		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float32_3X);
		structure.add("vertexColor", VertexData.UInt8_4X_Normalized);
	}

	inline function setShaders() {
		pipeline.vertexShader = Reflect.field(Shaders, "drawer_colored_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "rectangle_frag");
	}

	inline function getUniforms() {
		rectCL = pipeline.getConstantLocation("rect");
		rectDataCL = pipeline.getConstantLocation("rectData");
		bordColorCL = pipeline.getConstantLocation("bordColor");
	}

	inline function draw(target:Texture, rectangle:RoundedRectangle) {
		final ctx = target.context2D, ctx3d = target.context3D;

		final border = rectangle.border;
		final radius = clamp(rectangle.radius, 0.0, Math.min(rectangle.width, rectangle.height) / 2);

		ctx3d.setFloat4(rectCL, rectangle.x, rectangle.y, rectangle.width, rectangle.height);
		ctx3d.setFloat4(rectDataCL, radius, rectangle.softness, border.width, border.softness);
		ctx3d.setVec4(bordColorCL, border.color.RGBA);

		final offset = Math.max(rectangle.softness, border.width + border.softness);

		ctx.fillRect(rectangle.x - offset, rectangle.y - offset, rectangle.width + offset * 2.0, rectangle.height + offset * 2.0);
	}
}
