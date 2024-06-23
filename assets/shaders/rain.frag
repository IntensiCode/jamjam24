#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

out vec4 fragColor;

uniform sampler2D u_image;

uniform float width;
uniform float height;
uniform float progress;

float rand(vec2 co) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(co.xy, vec2(a, b));
    float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

void main() {
    vec2 ic = FlutterFragCoord();
    vec2 tc = vec2(floor(ic.x) / width, floor(ic.y) / height);
    tc.x = (tc.x / 5.) * 5. + (rand(tc) - 0.5) * progress * 2.;
    tc.y = tc.y - progress * 2. * rand(tc) - progress;
    tc.x = floor(tc.x * width) / width;
    tc.y = floor(tc.y * height) / height;
    fragColor = texture(u_image, tc);
}
