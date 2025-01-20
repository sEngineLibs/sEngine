#version 450

uniform mat3 MVP;

in vec2 vertCoord;
out vec2 fragCoord;

void main() {
    vec3 pos = MVP * vec3(vertCoord, 1.0);
    gl_Position = vec4(pos, 1.0);
    fragCoord = vertCoord * 0.5 + 0.5;
}
