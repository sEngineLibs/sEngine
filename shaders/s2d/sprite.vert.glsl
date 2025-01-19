#version 450

uniform mat3 viewProjection;
uniform mat3 model;
uniform vec4 cropRect;

in vec2 vertCoord;
out vec2 fragCoord;
out vec2 fragUV;

void main() {
    gl_Position = vec4(viewProjection * model * vec3(vertCoord, 1.0), 1.0);

    fragCoord = gl_Position.xy;
    fragUV = cropRect.xy + (vertCoord.xy * 0.5 + 0.5) * cropRect.zw;
}
