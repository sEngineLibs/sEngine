#version 450

uniform sampler2D textureMap;
uniform vec2 resolution;
uniform vec3 params;
#define radius params[0]
#define threshold params[1]
#define intensity params[2]

in vec2 fragCoord;
out vec4 fragColor;

vec3 bloom(sampler2D tex, vec2 texelSize, vec2 coord) {
    const float mipLevel = sqrt(radius);

    vec3 col = vec3(0.0);
    texelSize *= radius;

    col += textureLod(tex, coord + vec2(-1, -1) * texelSize, mipLevel).rgb * 1 / 16;
    col += textureLod(tex, coord + vec2(0, -1) * texelSize, mipLevel).rgb * 1 / 8;
    col += textureLod(tex, coord + vec2(1, -1) * texelSize, mipLevel).rgb * 1 / 16;

    col += textureLod(tex, coord + vec2(-1, 0) * texelSize, mipLevel).rgb * 1 / 8;
    col += textureLod(tex, coord + vec2(0, 0) * texelSize, mipLevel).rgb * 1 / 4;
    col += textureLod(tex, coord + vec2(1, 0) * texelSize, mipLevel).rgb * 1 / 8;

    col += textureLod(tex, coord + vec2(-1, 1) * texelSize, mipLevel).rgb * 1 / 16;
    col += textureLod(tex, coord + vec2(0, 1) * texelSize, mipLevel).rgb * 1 / 8;
    col += textureLod(tex, coord + vec2(1, 1) * texelSize, mipLevel).rgb * 1 / 16;

    return smoothstep(threshold, 1.0, col);
}

void main() {
    vec2 texelSize = 1.0 / resolution;
    vec3 col = texture(textureMap, fragCoord).rgb;
    col += intensity * bloom(textureMap, texelSize, fragCoord);
    fragColor = vec4(col, 1.0);
}
