shader_type spatial;

// Viento base
uniform float wind_speed = 2.0;
uniform float wind_strength = 0.03;

// Ventisca
uniform float blizzard_speed = 8.0;
uniform float blizzard_strength = 0.12;
uniform float gust_frequency = 0.4;   // qué tan seguido vienen ráfagas
uniform vec3  wind_direction = vec3(1.0, 0.0, 0.3); // dirección del viento
uniform vec4 grass_color : source_color = vec4(0.20, 0.65, 0.35, 1.0);
uniform float color_variation = 0.0;

// ...resto del shader de viento...

void fragment() {
    // Variación sutil de tono entre briznas
    float vary = sin(FRAGCOORD.x * 13.7 + FRAGCOORD.y * 7.3) * color_variation;
    ALBEDO = grass_color.rgb + vec3(vary);
}
void vertex() {
    float height = VERTEX.y;

    // Vaivén suave base (igual que antes)
    float sway = sin(
        TIME * wind_speed +
        VERTEX.x * 2.0
    );

    // Ráfaga de ventisca: onda más rápida e irregular
    float gust = sin(TIME * blizzard_speed + VERTEX.x * 5.0)
               * cos(TIME * gust_frequency);  // modulación de intensidad

    // Combinar ambos efectos, escalados por altura
    float total = (sway * wind_strength + gust * blizzard_strength) * height;

    // Aplicar en la dirección del viento (no solo en X)
    VERTEX.x += wind_direction.x * total;
    VERTEX.z += wind_direction.z * total * 0.5;
}