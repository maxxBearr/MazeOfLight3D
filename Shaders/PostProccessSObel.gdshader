shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// OUTLINE SETTINGS
uniform float edge_thickness : hint_range(0.5, 3.0) = 1.0;
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.1;

// FILM GRAIN SETTINGS
uniform float grain_amount : hint_range(0.0, 0.3) = 0.05;
uniform float grain_speed : hint_range(0.0, 10.0) = 1.0;

// CHROMATIC ABERRATION SETTINGS
uniform float chromatic_aberration : hint_range(0.0, 5.0) = 1.0;
uniform float cool_color_boost : hint_range(1.0, 3.0) = 1.5; // Extra aberration for blues/greens

// COOL COLOR EDGE ENHANCEMENT
uniform float edge_hue_shift : hint_range(0.0, 0.3) = 0.08; // How much to shift hue on edges for cool colors
uniform float edge_color_mix : hint_range(0.0, 1.0) = 0.4; // Blend between black edge and hue-shifted color

// COLOR ADJUSTMENT SETTINGS
uniform float saturation : hint_range(0.0, 3.0) = 1.3;
uniform float posterize_levels : hint_range(2.0, 256.0) = 16.0;
uniform bool enable_posterize = false;

// Random noise function
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Convert RGB to HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec2 pixel_size = 1.0 / SCREEN_PIXEL_SIZE;
    float offset = edge_thickness / 1000.0;

    // Sample center to detect hue for cool color detection
    vec3 center_sample = texture(screen_texture, SCREEN_UV).rgb;
    vec3 center_hsv = rgb2hsv(center_sample);
    float hue = center_hsv.x;

    // Calculate cool factor (peaks for greens, cyans, blues: hue ~0.2 to ~0.75)
    float cool_factor = smoothstep(0.15, 0.3, hue) * smoothstep(0.8, 0.65, hue);

    // Chromatic aberration with cool color boost
    float base_aberration = chromatic_aberration / 1000.0;
    float aberration_offset = base_aberration * mix(1.0, cool_color_boost, cool_factor);

    // Sample with chromatic aberration
    float r = texture(screen_texture, SCREEN_UV + vec2(aberration_offset, 0.0)).r;
    float g = texture(screen_texture, SCREEN_UV).g;
    float b = texture(screen_texture, SCREEN_UV - vec2(aberration_offset, 0.0)).b;
    vec3 aberrated = vec3(r, g, b);

    // Sobel kernel for edge detection
    vec3 n  = texture(screen_texture, SCREEN_UV + vec2(0.0, -offset)).rgb;
    vec3 s  = texture(screen_texture, SCREEN_UV + vec2(0.0, offset)).rgb;
    vec3 e  = texture(screen_texture, SCREEN_UV + vec2(offset, 0.0)).rgb;
    vec3 w  = texture(screen_texture, SCREEN_UV + vec2(-offset, 0.0)).rgb;
    vec3 nw = texture(screen_texture, SCREEN_UV + vec2(-offset, -offset)).rgb;
    vec3 ne = texture(screen_texture, SCREEN_UV + vec2(offset, -offset)).rgb;
    vec3 sw = texture(screen_texture, SCREEN_UV + vec2(-offset, offset)).rgb;
    vec3 se = texture(screen_texture, SCREEN_UV + vec2(offset, offset)).rgb;

    // Sobel operator using luminance
    vec3 luma_weights = vec3(0.299, 0.587, 0.114);
    float lum_n  = dot(n, luma_weights);
    float lum_s  = dot(s, luma_weights);
    float lum_e  = dot(e, luma_weights);
    float lum_w  = dot(w, luma_weights);
    float lum_nw = dot(nw, luma_weights);
    float lum_ne = dot(ne, luma_weights);
    float lum_sw = dot(sw, luma_weights);
    float lum_se = dot(se, luma_weights);

    float gx = -lum_nw - 2.0*lum_w - lum_sw + lum_ne + 2.0*lum_e + lum_se;
    float gy = -lum_nw - 2.0*lum_n - lum_ne + lum_sw + 2.0*lum_s + lum_se;

    float edge = length(vec2(gx, gy));

    // Edge coloring with hue shift for cool colors
    vec3 final_color;
    if (edge > edge_threshold) {
        if (cool_factor > 0.1) {
            // For cool colors: shift hue and blend with edge color
            vec3 edge_hsv = rgb2hsv(aberrated);
            edge_hsv.x = fract(edge_hsv.x + edge_hue_shift); // shift hue toward warmer
            edge_hsv.y = min(edge_hsv.y * 1.3, 1.0); // boost saturation on edge
            vec3 shifted_color = hsv2rgb(edge_hsv);
            final_color = mix(edge_color.rgb, shifted_color, edge_color_mix);
        } else {
            // For warm colors: use normal edge color
            final_color = edge_color.rgb;
        }
    } else {
        final_color = aberrated;
    }

    // Apply saturation adjustment
    vec3 hsv = rgb2hsv(final_color);
    hsv.y *= saturation;
    hsv.y = clamp(hsv.y, 0.0, 1.0);
    final_color = hsv2rgb(hsv);

    // Apply posterization if enabled
    if (enable_posterize) {
        final_color = floor(final_color * posterize_levels) / posterize_levels;
    }

    // Add film grain
    float noise = rand(SCREEN_UV + vec2(TIME * grain_speed));
    noise = (noise - 0.5) * grain_amount;
    final_color += noise;

    COLOR.rgb = final_color;
}