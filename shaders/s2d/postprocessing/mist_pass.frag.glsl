#version 450

#include "s2d/std/gbuffer"

uniform sampler2D textureMap;
uniform sampler2D gBuffer;
uniform mat4 invVP;
uniform vec3 cameraPos;
uniform vec2 mistScale;
uniform vec4 mistColor;

in vec2 fragCoord;
out vec4 fragColor;

void main() {
    vec3 position = unpackGBufferPosition(gBuffer, fragCoord);
    vec4 worldPos = invVP * vec4(position * 2.0 - 1.0, 1.0);
    position = worldPos.xyz / worldPos.w;
    float cameraDist = 1.0 - abs(position.z - cameraPos.z);

    vec3 color = texture(textureMap, fragCoord).rgb;

    // mist
    float mist = smoothstep(0.0, 1.0, mistScale.x + cameraDist * (mistScale.y - mistScale.x));
    color += mistColor.rgb * mistColor.a * mist;

    fragColor = vec4(color, 1.0);
}
