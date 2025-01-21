#version 450

in vec4 vertData;
out float fragFactor;

void main() {
    gl_Position = vec4(vertData.xyz, 1.0);
    fragFactor = vertData.w;
}
