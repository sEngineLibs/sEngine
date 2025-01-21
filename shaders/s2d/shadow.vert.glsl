#version 450

uniform mat3 VP;

in vec2 vertCoord;

void main() {
    vec3 pos = VP * vec3(vertCoord, 1.0);
    gl_Position = vec4(pos, 1.0);
}
