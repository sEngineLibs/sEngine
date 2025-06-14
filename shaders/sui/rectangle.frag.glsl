#version 450

uniform vec4 rect;
uniform vec3 rectData; // packed values: [radius, softness, border width]
uniform vec4 bordCol;

#define radius rectData.x
#define softness rectData.y
#define bordWidth rectData.z

layout(location = 0) in vec4 color;
layout(location = 1) in vec2 fragCoord;
layout(location = 0) out vec4 fragColor;

float sdf(vec2 center, vec2 size) {
    vec2 q = abs(center) - size + radius;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

void main() {
    vec2 size = rect.zw;
    vec2 halfSize = size / 2.0;
    vec2 center = rect.xy + halfSize;

    float dist = sdf(fragCoord.xy - center, halfSize);

    float fillAlpha = 1.0 - smoothstep(-softness, softness, dist);
    float borderAlpha = smoothstep(bordWidth - softness, bordWidth + softness, abs(dist));

    vec4 baseColor = vec4(color.rgb, color.a * fillAlpha);
    vec4 borderColor = vec4(bordCol.rgb, bordCol.a * (1.0 - borderAlpha));
    fragColor = baseColor + borderColor * (1.0 - baseColor.a);
}
