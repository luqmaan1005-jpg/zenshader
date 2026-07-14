#version 120

/* GBUFFERS_TEXTURED.VSH — Entities & custom textured blocks
   GLSL 120 | [ZenShader]
*/

varying vec4 vColor;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec3 vWorldPos;
varying vec2 vLightCoord;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

void main() {
	vec4 viewPosition = gbufferModelView * vec4(gl_Vertex, 1.0);
	gl_Position = gbufferProjection * viewPosition;
	
	vWorldPos = (gbufferModelViewInverse * viewPosition).xyz + cameraPosition;
	vNormal = normalize(mat3(gbufferModelView) * gl_Normal);
	vTexCoord = gl_MultiTexCoord0.xy;
	vLightCoord = gl_MultiTexCoord1.xy / 16.0;
	vColor = gl_Color;
}
