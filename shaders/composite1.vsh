#version 120

/* COMPOSITE1.VSH — Blur pass 1 (vertical)
   GLSL 120 | [ZenShader]
*/

varying vec2 v_TexCoord;

void main() {
	gl_Position = ftransform();
	v_TexCoord = gl_MultiTexCoord0.xy;
}
