#version 120

/* FINAL.FSH — Final composite & tonemapping
   GLSL 120 | [ZenShader]
   
   - Blends bloom back into scene
   - Applies tonemapping (Reinhard)
   - Color grading (saturation, brightness)
   - Fog (subtle)
*/

varying vec2 v_TexCoord;

uniform sampler2D colortex0;  // Scene (lit)
uniform sampler2D colortex4;  // Bloom (blurred)
uniform sampler2D depthtex0;  // Depth

uniform float bloomIntensity;
uniform float fogDensity;
uniform float saturation;
uniform float brightness;
uniform float frameTimeCounter;

/* Reinhard tonemapping */
vec3 tonemap(vec3 color) {
	return color / (color + vec3(1.0));
}

/* Inverse tonemap (for brightness adjustment) */
vec3 invTonemap(vec3 color) {
	return color / (vec3(1.0) - color);
}

/* Simple saturation adjustment */
vec3 adjustSaturation(vec3 color, float sat) {
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	return mix(vec3(gray), color, sat);
}

void main() {
	vec3 scene = texture2D(colortex0, v_TexCoord).rgb;
	vec3 bloom = texture2D(colortex4, v_TexCoord).rgb;
	float depth = texture2D(depthtex0, v_TexCoord).r;
	
	// Blend bloom (multiplicative, subtle)
	vec3 final = scene + bloom * 0.3 * bloomIntensity;
	
	// Tonemapping
	final = tonemap(final);
	
	// Brightness
	final *= brightness;
	
	// Saturation
	final = adjustSaturation(final, saturation);
	
	// Fog (light mist, only at far distances)
	float fogFactor = clamp((depth - 0.8) * fogDensity, 0.0, 0.3);
	vec3 fogColor = vec3(0.8, 0.85, 0.9); // Light sky color
	final = mix(final, fogColor, fogFactor);
	
	// Clamp to valid range
	gl_FragColor = vec4(clamp(final, 0.0, 1.0), 1.0);
}
