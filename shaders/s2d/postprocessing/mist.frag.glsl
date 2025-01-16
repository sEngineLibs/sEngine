#version 450

uniform sampler2D normalMap;
uniform sampler2D textureMap;
uniform vec3 cameraPos;
uniform vec2 mistScale;
uniform vec4 mistColor;

in vec2 fragCoord;
out vec4 fragColor;

void main() {
    vec3 normal = texture(normalMap, fragCoord).rgb;
    float cameraDist = 1.0 - abs(normal.z - cameraPos.z);

    vec3 color = texture(textureMap, fragCoord).rgb;

    // mist
    float mist = smoothstep(0.0, 1.0, mix(mistScale.x, mistScale.y, cameraDist));
    color += mistColor.rgb * mistColor.a * mist;

    fragColor = vec4(color, 1.0);
}