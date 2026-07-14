#version 120

/* SHADOW.VSH — Shadow map depth rendering (sun)
   GLSL 120 | [ZenShader]
   
   Renders depth from the sun's perspective for PCF shadow lookups.
   No complex lighting here — just depth.
*/

varying vec2 v_TexCoord;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;

void main() {
	// Standard ortho projection from sun
	gl_Position = gbufferProjection * (gbufferModelView * vec4(gl_Vertex, 1.0));
	v_TexCoord = gl_MultiTexCoord0.xy;
}
