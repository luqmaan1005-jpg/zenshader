#version 120

/* COMPOSITE2.FSH — Separable blur pass 2 (horizontal)
   GLSL 120 | [ZenShader]
   
   Gaussian blur in X direction only.
   Output is final bloom map ready for final.fsh blending.
*/

varying vec2 v_TexCoord;

uniform sampler2D colortex4;
uniform vec2 screenSize;

void main() {
	vec3 color = vec3(0.0);
	float weights[5] = float[](0.227, 0.194, 0.121, 0.054, 0.016);
	vec2 texelSize = vec2(1.0 / screenSize.x, 0.0);
	
	// Center
	color += texture2D(colortex4, v_TexCoord).rgb * weights[0];
	
	// +/- offsets
	for (int i = 1; i < 5; i++) {
		color += texture2D(colortex4, v_TexCoord + texelSize * float(i)).rgb * weights[i];
		color += texture2D(colortex4, v_TexCoord - texelSize * float(i)).rgb * weights[i];
	}
	
	gl_FragColor = vec4(color, 1.0);
}
