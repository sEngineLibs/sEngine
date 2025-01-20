#version 450

uniform sampler2D textureMap;

in vec2 fragCoord;
out vec4 fragColor;

void main() {
    float alpha = texture(textureMap, fragCoord).a;
    fragColor = vec4(vec3(1.0 / alpha), alpha);
}
