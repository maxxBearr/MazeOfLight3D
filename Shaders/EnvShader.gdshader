shader_type spatial;
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color;
uniform int shading_levels : hint_range(1, 10) = 3;
uniform float min_brightness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(texture_albedo, UV);
    ALBEDO = albedo.rgb * tex_color.rgb;
    EMISSION = ALBEDO * min_brightness;
}

void light() {
    float NdotL = dot(NORMAL, LIGHT);
    float light_amount = floor(NdotL * float(shading_levels)) / float(shading_levels);
    light_amount = max(0.0, light_amount);
    DIFFUSE_LIGHT += ALBEDO * light_amount * ATTENUATION * LIGHT_COLOR;
}