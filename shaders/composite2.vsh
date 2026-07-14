#version 120

/* COMPOSITE2.VSH — Blur pass 2 (horizontal)
   GLSL 120 | [ZenShader]
*/

varying vec2 v_TexCoord;

void main() {
	gl_Position = ftransform();
	v_TexCoord = gl_MultiTexCoord0.xy;
}
