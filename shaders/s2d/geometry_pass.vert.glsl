#version 450

uniform mat3 VP;
uniform mat3 model;
uniform vec4 cropRect;

in vec2 vertCoord;
out vec3 fragPos;
out vec2 fragUV;

void main() {
    gl_Position = vec4(VP * model * vec3(vertCoord, 0.0), 1.0);
    fragPos = gl_Position.xyz * 0.5 + 0.5;
    fragUV = cropRect.xy + (vertCoord * 0.5 + 0.5) * (cropRect.zw - cropRect.xy);
}
