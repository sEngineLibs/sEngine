#version 450

uniform sampler2D tex;
uniform mat3 model;
uniform mat4 projectionMatrix;

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec4 vertexColor;
layout(location = 0) out vec4 color;
layout(location = 1) out vec2 fragCoord;

void main() {
    vec2 size = textureSize(tex, 0);
    gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);
    color = vertexColor;
    fragCoord = (inverse(model) * vec3(vertexPosition.xy, 1.0)).xy * size;
}
