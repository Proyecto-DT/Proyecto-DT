shader_type spatial;

uniform vec4 grass_color : source_color = vec4(0.329, 0.710, 0.502, 1.0);

void fragment() {
    float grass = abs(sin(UV.x * 200.0));

    vec3 dark = grass_color.rgb * 0.8;
    vec3 light = grass_color.rgb * 1.2;

    ALBEDO = mix(dark, light, smoothstep(0.8, 1.0, grass));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
