#version 450

uniform sampler2D textureMap;

in vec2 fragUV;
out vec4 fragColor;

void main() {
    vec4 color = texture(textureMap, fragUV);
    fragColor = vec4(color.rgb / color.a, color.a);
}
