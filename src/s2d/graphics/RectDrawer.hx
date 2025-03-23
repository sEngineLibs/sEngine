package s2d.graphics;

import kha.Shaders;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import se.Texture;
import se.math.VectorMath;
import s2d.elements.shapes.RoundedRectangle;

class RectDrawer extends ElementDrawer<RoundedRectangle> {
	var rectCL:ConstantLocation;
	var rectDataCL:ConstantLocation;

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
	}

	function draw(target:Texture, rectangle:RoundedRectangle) {
		final ctx = target.ctx2D, ctx3d = target.ctx3D;

		final radius = clamp(rectangle.radius, 0.0, min(rectangle.width, rectangle.height) * 0.5);
		final offset = max(rectangle.softness, 0.0);

		ctx3d.setFloat4(rectCL, rectangle.x, rectangle.y, rectangle.width, rectangle.height);
		ctx3d.setFloat2(rectDataCL, radius, rectangle.softness);

		ctx.fillRect(rectangle.left.position
			- offset, rectangle.top.position
			- offset, rectangle.width
			+ offset * 2.0, rectangle.height
			+ offset * 2.0);
	}
}
