#version 450

uniform mat3 MVP;
uniform vec4 cropRect;

in vec2 vertCoord;
out vec2 fragUV;

void main() {
    vec3 pos = MVP * vec3(vertCoord, 1.0);
    gl_Position = vec4(pos, 1.0);
    fragUV = cropRect.xy + (vertCoord * 0.5 + 0.5) * (cropRect.zw - cropRect.xy);
}
