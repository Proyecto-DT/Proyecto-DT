shader_type spatial;

uniform float velocidad_viento = 2.0;
uniform float fuerza_viento = 0.03;

uniform float velocidad_ventisca = 8.0;
uniform float fuerza_ventisca = 0.12;
uniform float frecuencia_rafagas = 0.4;
uniform vec3 direccion_viento = vec3(1.0, 0.0, 0.3);

uniform vec4 color_pasto : source_color = vec4(0.20, 0.65, 0.35, 1.0);
uniform float variacion_color = 0.0;

void fragment() {
    float variacion = sin(FRAGCOORD.x * 13.7 + FRAGCOORD.y * 7.3) * variacion_color;
    ALBEDO = color_pasto.rgb + vec3(variacion);
}

void vertex() {
    float altura = VERTEX.y;

    float balanceo = sin(
        TIME * velocidad_viento +
        VERTEX.x * 2.0
    );

    float rafaga =
        sin(TIME * velocidad_ventisca + VERTEX.x * 5.0)
        * cos(TIME * frecuencia_rafagas);

    float movimiento =
        (balanceo * fuerza_viento + rafaga * fuerza_ventisca)
        * altura;

    VERTEX.x += direccion_viento.x * movimiento;
    VERTEX.z += direccion_viento.z * movimiento * 0.5;
}