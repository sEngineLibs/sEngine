package s2d.ui.graphics;

import kha.Canvas;
import kha.Shaders;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
// s2d
import s2d.core.utils.MathUtils;
import s2d.ui.elements.shapes.Rectangle;

class RectDrawer extends ElementDrawer<Rectangle> {
	var rectCL:ConstantLocation;
	var dataCL:ConstantLocation;

	function initStructure() {
		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float32_3X);
		structure.add("vertexColor", VertexData.UInt8_4X_Normalized);
	}

	function setShaders() {
		pipeline.vertexShader = Shaders.drawer_colored_vert;
		pipeline.fragmentShader = Shaders.rectangle_frag;
	}

	function getUniforms() {
		rectCL = pipeline.getConstantLocation("rect");
		dataCL = pipeline.getConstantLocation("rectData");
	}

	function draw(target:Canvas, rectangle:Rectangle) {
		final g2 = target.g2, g4 = target.g4;

		final softness = Math.max(rectangle.softness, 0.0);
		final radius = clamp(rectangle.radius, 0.0, rectangle.width / 2);

		g4.setFloat4(rectCL, rectangle.x, rectangle.y, rectangle.width, rectangle.height);
		g4.setFloat2(dataCL, radius, softness);
		g2.fillRect(rectangle.x - softness, rectangle.y - softness, rectangle.width + softness * 2.0, rectangle.height + softness * 2.0);
	}
}
