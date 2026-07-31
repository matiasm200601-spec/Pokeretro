uniform float u_Time;
uniform sampler2D u_Tex0;
uniform sampler2D u_Tex1;
varying vec2 v_TexCoord;

vec2 direction = vec2(0.3,1.0);
float speed = 0.03;
float pressure = 0.6;
float zoom = 0.5;
float cole = 0.0;
void main(void)
{
    vec2 direction = vec2(0.1,0.1);
	vec2 offset = (v_TexCoord + (direction * u_Time * speed)) / zoom;
    vec3 bgcol = texture2D(u_Tex0, v_TexCoord).xyz;
    vec3 fogcol = texture2D(u_Tex1, offset).xyz;
    vec3 col = bgcol + fogcol*pressure;
    gl_FragColor = vec4(col,0.1);
}
