#version 450

uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D emissionMap;
uniform sampler2D ormMap;

#if (S2D_SPRITE_INSTANCING != 1)
uniform mat3 model;
uniform float depth;
#else
in mat3 model;
in float depth;
#endif

in vec2 fragUV;

layout(location = 0) out vec4 depthColor;
layout(location = 1) out vec4 albedoColor;
layout(location = 2) out vec4 normalColor;
layout(location = 3) out vec4 emissionColor;
layout(location = 4) out vec4 ormColor;

void main() {
    vec4 albedo = texture(albedoMap, fragUV);
    albedo.a = step(0.5, albedo.a);

    vec3 normal = texture(normalMap, fragUV).rgb * 2.0 - 1.0;
    normal.xy = inverse(mat2(model)) * normal.xy;
    normal = normalize(vec3(normal.xy, normal.z));
    normal = normal * 0.5 + 0.5;

    vec3 emission = texture(emissionMap, fragUV).rgb;
    vec3 orm = texture(ormMap, fragUV).rgb;

    depthColor = vec4(vec3(depth), 1.0);
    albedoColor = vec4(albedo.rgb / albedo.a, albedo.a);
    normalColor = vec4(normal, albedo.a);
    emissionColor = vec4(emission, albedo.a);
    ormColor = vec4(orm, albedo.a);
    if (albedo.a == 1.0)
        gl_FragDepth = 1.0; // this needs to be fixed
}
