#version 450

uniform vec2 spriteParams;
#define spriteRotation spriteParams[0]
#define spriteZ spriteParams[1]

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D ormMap;
uniform sampler2D emissionMap;

uniform float matParams[2];
#define depthScale matParams[0]
#define emissionStrength matParams[1]

in vec2 fragUV;

layout(location = 0) out vec3 albedoColor;
layout(location = 1) out vec3 normalColor;
layout(location = 2) out vec3 emissionColor;
layout(location = 3) out vec3 ormColor;

void main() {
    // fetch material textures
    vec4 albedo = texture(albedoMap, fragUV);
    if (albedo.a < 0.5)
        discard;

    albedoColor = albedo.rgb;
    normalColor = texture(normalMap, fragUV).rgb;
    emissionColor = texture(emissionMap, fragUV).rgb * emissionStrength;
    ormColor = texture(ormMap, fragUV).rgb;

    // tangent space -> world space
    vec2 n = normalColor.xy * 2.0 - 1.0;
    float rotSin = sin(-spriteRotation);
    float rotCos = cos(-spriteRotation);
    normalColor.x = rotCos * n.x - rotSin * n.y;
    normalColor.y = rotSin * n.x + rotCos * n.y;
    normalColor.xy = normalColor.xy * 0.5 + 0.5;
    normalColor.z = spriteZ + normalColor.z * depthScale;
}
