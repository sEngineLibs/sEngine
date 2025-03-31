package s2d.graphics;

import kha.Shaders;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import se.Texture;
import s2d.shapes.RoundedRectangle;

@:access(s2d.Element)
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
		final rect = rectangle._rect;

		ctx3d.setFloat4(rectCL, rectangle.absX, rectangle.absY, rectangle.width, rectangle.height);
		ctx3d.setFloat2(rectDataCL, rectangle._radius, rectangle.softness);
		ctx.fillRect(rect.x, rect.y, rect.width, rect.height);
	}
}
