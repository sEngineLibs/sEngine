#version 450

in float fragFactor;
out vec4 fragColor;

void main() {
    fragColor = vec4(vec3(0.0), fragFactor);
}
