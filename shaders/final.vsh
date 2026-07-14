#version 120

/* FINAL.VSH — Final output pass
   GLSL 120 | [ZenShader]
*/

varying vec2 v_TexCoord;

void main() {
	gl_Position = ftransform();
	v_TexCoord = gl_MultiTexCoord0.xy;
}
