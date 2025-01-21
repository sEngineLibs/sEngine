#version 450

uniform mat3 viewProjection;
#if (S2D_SPRITE_INSTANCING != 1)
uniform float depth;
uniform mat3 model;
uniform vec4 cropRect;
#else
in vec4 cropRect;
in vec3 model0;
in vec3 model1;
in vec3 model2;
in float spriteDepth;
out mat3 model;
out float depth;
#endif

in vec2 vertPos;
out vec2 fragCoord;
out vec2 fragUV;

void main() {
    #if (S2D_SPRITE_INSTANCING == 1)
    model = mat3(model0, model1, model2);
    depth = spriteDepth;
    #endif
    vec3 pos = viewProjection * model * vec3(vertPos, 1.0);
    gl_Position = vec4(pos.xy, depth, 1.0);

    fragCoord = gl_Position.xy;
    fragUV = cropRect.xy + (vertPos.xy * 0.5 + 0.5) * cropRect.zw;
}
