#version 120

/* GBUFFERS_TEXTURED.VSH — Entities & custom textured blocks
   GLSL 120 | [ZenShader]
*/

varying vec4 v_Color;
varying vec3 v_Normal;
varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec2 v_LightCoord;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

void main() {
	vec4 viewPos = gbufferModelView * vec4(gl_Vertex, 1.0);
	gl_Position = gbufferProjection * viewPos;
	
	v_WorldPos = (gbufferModelViewInverse * viewPos).xyz + cameraPosition;
	v_Normal = normalize(mat3(gbufferModelView) * gl_Normal);
	v_TexCoord = gl_MultiTexCoord0.xy;
	v_LightCoord = gl_MultiTexCoord1.xy / 16.0;
	v_Color = gl_Color;
}
