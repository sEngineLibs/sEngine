package se.s2d.ui.graphics;

import kha.Canvas;
import kha.Shaders;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import se.math.VectorMath;
import se.s2d.ui.elements.shapes.Rectangle;

class RectDrawer extends ElementDrawer<Rectangle> {
	var rectCL:ConstantLocation;
	var rectDataCL:ConstantLocation;
	var bordColorCL:ConstantLocation;

	function initStructure() {
		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float32_3X);
		structure.add("vertexColor", VertexData.UInt8_4X_Normalized);
	}

	function setShaders() {
		pipeline.vertexShader = Reflect.field(Shaders, "drawer_colored_vert");
		pipeline.fragmentShader = Reflect.field(Shaders, "rectangle_frag");
	}

	function getUniforms() {
		rectCL = pipeline.getConstantLocation("rect");
		rectDataCL = pipeline.getConstantLocation("rectData");
		bordColorCL = pipeline.getConstantLocation("bordColor");
	}

	function draw(target:Canvas, rectangle:Rectangle) {
		final g2 = target.g2, g4 = target.g4;

		final border = rectangle.border;
		final radius = clamp(rectangle.radius, 0.0, Math.min(rectangle.width, rectangle.height) / 2);

		g4.setFloat4(rectCL, rectangle.x, rectangle.y, rectangle.width, rectangle.height);
		g4.setFloat4(rectDataCL, radius, rectangle.softness, border.width, border.softness);
		g4.setVector4(bordColorCL, border.color.RGBA);

		final offset = Math.max(rectangle.softness, border.width + border.softness);

		g2.fillRect(rectangle.x - offset, rectangle.y - offset, rectangle.width + offset * 2.0, rectangle.height + offset * 2.0);
	}
}
