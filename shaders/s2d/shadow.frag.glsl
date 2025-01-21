#version 450

in float fragFactor;
out vec4 fragColor;

void main() {
    fragColor = vec4(0.0, 0.0, 0.0, fragFactor);
}
