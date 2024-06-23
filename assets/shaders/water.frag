uniform float progress;
uniform sampler2D u_texture;
varying vec4 vColor;
varying vec2 vTexCoord;

vec4 bluish = vec4(0.3, 0.3, 0.8, 1.0);
vec4 blue = vec4(0.0, 0.0, 0.2, 1.0);

void main() {
    vec2 tc = vTexCoord;
    tc.x = tc.x;
    tc.y = tc.y * 1.1;

    vec4 texColor;
    if (tc.y >= 1.0) {

        float sinOff = 3.14 * 2.0 * (progress + (tc.y - 1.0) * 8.0);
        float xoff = sin(sinOff) * 0.1;
        tc.x = (tc.x - 0.5) * 0.9 + 0.5;
        tc.x += xoff;

        tc.y = 1.0 - (tc.y - 1.0) * 3.0;
        texColor = texture2D(u_texture, tc) * bluish + blue;
    }
    else {
        texColor = texture2D(u_texture, tc);
    }

    gl_FragColor = texColor * vColor;
}
