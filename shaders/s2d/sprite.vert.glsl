#version 450

uniform mat3 MVP;
uniform vec4 cropRect;

in vec2 vertCoord;
out vec2 fragUV;
out vec2 fragCoord;

void main() {
    // calculate vertex position
    vec3 pos = MVP * vec3(vertCoord, 1.0);
    gl_Position = vec4(pos, 1.0);

    // calculate UV
    fragUV = mix(cropRect.xy, cropRect.zw, vertCoord * 0.5 + 0.5);
    fragCoord = pos.xy * 0.5 + 0.5;
}
