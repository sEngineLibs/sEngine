#version 450

uniform mat4 VP;
uniform mat4 model;
uniform vec4 cropRect;

in vec3 vertPos;
in vec2 vertUV;
out vec3 fragPos;
out vec2 fragUV;

void main() {
    gl_Position = VP * model * vec4(vertPos, 1.0);
    fragPos = gl_Position.xyz * 0.5 + 0.5;
    fragUV = cropRect.xy + vertUV * (cropRect.zw - cropRect.xy);
}
