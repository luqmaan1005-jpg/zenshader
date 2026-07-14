#version 120

/* GBUFFERS_TEXTURED.FSH — Entities & custom textured blocks
   GLSL 120 | [ZenShader]
*/

varying vec4 vColor;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec3 vWorldPos;
varying vec2 vLightCoord;

uniform sampler2D texture;
uniform sampler2D lightmap;

void main() {
	vec4 texCol = texture2D(texture, vTexCoord);
	vec3 lightCol = texture2D(lightmap, vLightCoord).rgb;
	
	vec3 diffuseCol = texCol.rgb * vColor.rgb * lightCol;
	vec3 normalCol = normalize(vNormal) * 0.5 + 0.5;
	
	gl_FragData[0] = vec4(diffuseCol, texCol.a);
	gl_FragData[1] = vec4(normalCol, 0.1);
	gl_FragData[2] = vec4(0.8, 1.0, 0.0, 1.0);
	gl_FragData[3] = vec4(0.0, 0.0, 0.0, 0.0);
}
