// ###################
// Eclipse glow for Ghostty: a soft rose light rising from the bottom-right corner, turning plum as
// it fades into the dark. Only the background gets it (text stays as it is); still, not animated
// ###################

const vec3 ROSE = vec3(0.941, 0.396, 0.584);  // #f06595
const vec3 PLUM = vec3(0.616, 0.306, 0.867);  // #9d4edd
const float STRENGTH = 0.16;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    // distance from the bottom-right corner, stretched to the window's shape
    vec2 d = (uv - vec2(1.0, 0.0)) * vec2(iResolution.x / iResolution.y, 1.0);
    float glow = exp(-2.2 * length(d));
    vec3 light = mix(PLUM, ROSE, glow) * glow * STRENGTH;

    // text is brighter than the background; keep the light off it
    float text = smoothstep(0.18, 0.45, max(term.r, max(term.g, term.b)));
    fragColor = vec4(term.rgb + light * (1.0 - text) * term.a, term.a);
}
