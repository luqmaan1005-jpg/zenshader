#version 120

/* GBUFFERS_WATER.VSH — Water with wave displacement
   GLSL 120 | [ZenShader]
   
   Displaces water vertices with low-frequency waves
   for a subtle, natural surface undulation.
*/

attribute vec3 mc_Entity;

varying vec4 v_Color;
varying vec3 v_Normal;
varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec3 v_WaveNormal;
varying vec2 v_LightCoord;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float waveHeight;

/* Gerstner wave: realistic ocean-like displacement */
vec3 getWaveDisplacement(vec3 worldPos, float time) {
	vec3 disp = vec3(0.0);
	float waveAmp = 0.15 * waveHeight;
	float waveFreq = 0.1;
	float waveSpeed = 0.5;
	
	// Primary wave (long wavelength)
	float wave1 = sin(worldPos.x * waveFreq + time * waveSpeed) * waveAmp;
	float wave2 = sin(worldPos.z * waveFreq * 0.7 + time * waveSpeed * 0.8) * waveAmp * 0.6;
	
	disp.y = wave1 + wave2;
	disp.x = cos(worldPos.x * waveFreq + time * waveSpeed) * waveAmp * 0.3;
	disp.z = cos(worldPos.z * waveFreq * 0.7 + time * waveSpeed * 0.8) * waveAmp * 0.2;
	
	return disp;
}

void main() {
	// Calculate world position for wave sampling
	vec3 worldPos = gl_Vertex + cameraPosition;
	
	// Apply wave displacement
	vec3 waveDisp = getWaveDisplacement(worldPos, frameTimeCounter);
	vec3 displacedPos = gl_Vertex + waveDisp;
	
	// Transform to view space
	vec4 viewPos = gbufferModelView * vec4(displacedPos, 1.0);
	gl_Position = gbufferProjection * viewPos;
	
	// World position (for reflection/refraction calcs later)
	v_WorldPos = (gbufferModelViewInverse * viewPos).xyz + cameraPosition;
	
	// Normal (will be recomputed based on wave in fragment shader)
	v_Normal = normalize(mat3(gbufferModelView) * gl_Normal);
	
	// Approximate wave-affected normal
	float waveDerivX = cos(worldPos.x * 0.1 + frameTimeCounter * 0.5) * 0.15 * 0.3;
	float waveDerivZ = cos(worldPos.z * 0.07 + frameTimeCounter * 0.4) * 0.15 * 0.2;
	v_WaveNormal = normalize(v_Normal + vec3(waveDerivX, 0.0, waveDerivZ));
	
	// UV and light coords
	v_TexCoord = gl_MultiTexCoord0.xy;
	v_LightCoord = gl_MultiTexCoord1.xy / 16.0;
	
	v_Color = gl_Color;
}
