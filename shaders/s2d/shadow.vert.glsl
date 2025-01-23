#version 450

layout(location = 0) in vec4 vertData;
layout(location = 0) out float fragFactor;

void main() {
    gl_Position = vec4(vertData.xyz, 1.0);
    fragFactor = vertData.w;
}
