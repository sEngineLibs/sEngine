#include "s2d/std/packing"

vec4 packGBuffer(vec3 color, vec3 normal, vec3 glow, vec3 orm, float alpha) {
    return vec4(
        pack(vec4(color.r, normal.r, glow.r, orm.r)),
        pack(vec4(color.g, normal.g, glow.g, orm.g)),
        pack(vec4(color.b, normal.b, glow.b, orm.b)),
        alpha
    );
}

void unpackRGB(sampler2D tex, vec2 uv, out vec4 upR, out vec4 upG, out vec4 upB) {
    vec4 packed = texture(tex, uv);
    upR = unpack(packed.r);
    upG = unpack(packed.g);
    upB = unpack(packed.b);
}

vec3 unpackGBufferColor(vec4 upR, vec4 upG, vec4 upB) {
    return vec3(upR.r, upG.r, upB.r);
}

vec3 unpackGBufferColor(sampler2D tex, vec2 uv) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    return unpackGBufferColor(upR, upG, upB);
}

vec3 unpackGBufferNormal(vec4 upR, vec4 upG, vec4 upB) {
    return vec3(upR.g, upG.g, upB.g);
}

vec3 unpackGBufferNormal(sampler2D tex, vec2 uv) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    return unpackGBufferNormal(upR, upG, upB);
}

vec3 unpackGBufferGlow(vec4 upR, vec4 upG, vec4 upB) {
    return vec3(upR.b, upG.b, upB.b);
}

vec3 unpackGBufferGlow(sampler2D tex, vec2 uv) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    return unpackGBufferGlow(upR, upG, upB);
}

vec3 unpackGBufferORM(vec4 upR, vec4 upG, vec4 upB) {
    return vec3(upR.a, upG.a, upB.a);
}

vec3 unpackGBufferORM(sampler2D tex, vec2 uv) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    return unpackGBufferORM(upR, upG, upB);
}

void unpackGBuffer(sampler2D tex, vec2 uv, out vec3 color, out vec3 normal, out vec3 glow, out vec3 orm) {
    vec4 upR, upG, upB;
    unpackRGB(tex, uv, upR, upG, upB);

    color = unpackGBufferColor(upR, upG, upB);
    normal = unpackGBufferNormal(upR, upG, upB);
    glow = unpackGBufferGlow(upR, upG, upB);
    orm = unpackGBufferORM(upR, upG, upB);
}

vec3 unpackGBufferPosition(sampler2D tex, vec2 uv) {
    vec3 normal = unpackGBufferNormal(tex, uv);
    return vec3(uv, normal.z);
}
