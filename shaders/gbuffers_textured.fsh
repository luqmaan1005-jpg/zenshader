#version 120

/* GBUFFERS_TEXTURED.FSH — Entities & custom textured blocks
   GLSL 120 | [ZenShader]
*/

varying vec4 v_Color;
varying vec3 v_Normal;
varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec2 v_LightCoord;

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	vec4 texColor = texture2D(texture, v_TexCoord);
	vec3 light = texture2D(lightmap, v_LightCoord).rgb;
	
	vec3 diffuse = texColor.rgb * v_Color.rgb * light;
	vec3 normal = normalize(v_Normal) * 0.5 + 0.5;
	
	gl_FragData[0] = vec4(diffuse, texColor.a);
	gl_FragData[1] = vec4(normal, 0.1);
	gl_FragData[2] = vec4(0.8, 1.0, 0.0, 1.0);
	gl_FragData[3] = vec4(0.0, 0.0, 0.0, 0.0);
}
