#version 120

/* COMPOSITE.VSH — Post-processing pass (screen-space)
   GLSL 120 | [ZenShader]
   
   Simple full-screen quad for composite passes.
*/

varying vec2 v_TexCoord;

void main() {
	gl_Position = ftransform();
	v_TexCoord = gl_MultiTexCoord0.xy;
}
