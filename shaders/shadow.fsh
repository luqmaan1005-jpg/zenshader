#version 120

/* SHADOW.FSH — Shadow depth output
   GLSL 120 | [ZenShader]
*/

varying vec2 v_TexCoord;

uniform sampler2D texture;

void main() {
	// Discard fully transparent pixels
	if (texture2D(texture, v_TexCoord).a < 0.5) {
		discard;
	}
	
	// Depth is automatically written to shadowtex0
	// gl_FragDepth is implicit in ortho shadow rendering
}
