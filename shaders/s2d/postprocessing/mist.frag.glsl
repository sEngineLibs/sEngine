#version 450

uniform sampler2D depthMap;
uniform sampler2D textureMap;
uniform vec2 mistScale;
uniform vec4 mistColor;

in vec2 fragCoord;
out vec4 fragColor;

void main() {
    float depth = texture(depthMap, fragCoord).r;
    vec3 color = texture(textureMap, fragCoord).rgb;

    // mist
    float mist = mix(mistScale.x, mistScale.y, depth);
    color += mistColor.rgb * mistColor.a * mist;

    fragColor = vec4(color, 1.0);
}
