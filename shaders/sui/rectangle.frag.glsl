#version 450

uniform vec4 rect;
uniform vec2 rectData; // [radius, softness]

layout(location = 0) in vec4 color;
layout(location = 1) in vec2 fragCoord;
layout(location = 0) out vec4 fragColor;

float roundedBoxSDF(vec2 center, vec2 size, float radius) {
    vec2 q = abs(center) - size + radius;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

void main() {
    vec2 size = rect.zw;
    vec2 halfSize = size / 2.0;
    vec2 center = rect.xy + halfSize;
    float radius = rectData.x;
    float softness = rectData.y;

    float dist = roundedBoxSDF(fragCoord.xy - center, halfSize, radius);
    float alpha = 1.0 - smoothstep(-softness, softness, dist);

    fragColor = color * alpha;
}
