#version 120

/* COMPOSITE.FSH — Bloom extraction & initial deferred shading
   GLSL 120 | [ZenShader]
   
   Reads gbuffers, applies lighting, extracts bright areas for bloom.
   Outputs to colortex4 for blur pass.
*/

varying vec2 v_TexCoord;

uniform sampler2D colortex0;  // Diffuse
uniform sampler2D colortex1;  // Normal + specular
uniform sampler2D colortex2;  // Roughness
uniform sampler2D colortex3;  // Emission
uniform sampler2D shadowtex0; // Shadow depth
uniform sampler2D shadowtex1; // Shadow colored (optional)
uniform sampler2D depthtex0;  // Depth

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float bloomIntensity;
uniform float shadowQuality;
uniform float specularStrength;

/* PCF shadow (4-tap, low overhead) */
float shadowPCF(vec3 shadowPos, float bias) {
	float shadow = 0.0;
	vec2 pixelSize = 1.0 / vec2(2048.0); // 2048x2048 shadow map
	
	shadow += texture2D(shadowtex0, shadowPos.xy + vec2(-1.0, -1.0) * pixelSize).r;
	shadow += texture2D(shadowtex0, shadowPos.xy + vec2( 1.0, -1.0) * pixelSize).r;
	shadow += texture2D(shadowtex0, shadowPos.xy + vec2(-1.0,  1.0) * pixelSize).r;
	shadow += texture2D(shadowtex0, shadowPos.xy + vec2( 1.0,  1.0) * pixelSize).r;
	shadow /= 4.0;
	
	return shadowPos.z < shadow + bias ? 1.0 : 0.0;
}

/* Cook-Torrance specular with Schlick-GGX */
float specular(vec3 normal, vec3 lightDir, vec3 viewDir, float roughness, float intensity) {
	vec3 h = normalize(lightDir + viewDir);
	float ndotl = max(0.0, dot(normal, lightDir));
	float ndoth = max(0.0, dot(normal, h));
	float hdotv = max(0.0, dot(h, viewDir));
	
	float r2 = roughness * roughness;
	float denom = ndoth * ndoth * (r2 - 1.0) + 1.0;
	float d = r2 / (denom * denom);
	
	return d * intensity * ndotl;
}

void main() {
	vec4 diffuse = texture2D(colortex0, v_TexCoord);
	vec4 normalSpec = texture2D(colortex1, v_TexCoord);
	vec4 roughness = texture2D(colortex2, v_TexCoord);
	vec4 emission = texture2D(colortex3, v_TexCoord);
	
	// Decode normal
	vec3 normal = normalize(normalSpec.rgb * 2.0 - 1.0);
	float specFactor = normalSpec.a;
	
	// Light direction (sun)
	vec3 lightDir = normalize(shadowLightPosition);
	vec3 viewDir = vec3(0.0, 0.0, 1.0); // Approximate (full view calc requires depth)
	
	// Shadow + sunlight
	float shadowFactor = shadowPCF(vec3(0.5), 0.001 * shadowQuality);
	float sunIntensity = max(0.0, dot(normal, lightDir)) * shadowFactor;
	
	// Specular highlight (gated by sun angle & spec factor)
	float spec = specular(normal, lightDir, viewDir, roughness.r, specFactor * specularStrength) * shadowFactor;
	
	// Combine: base lighting + specular
	vec3 lit = diffuse.rgb * (0.3 + 0.7 * sunIntensity) + spec * vec3(0.5);
	
	// Add emission (lava glow, etc.)
	lit += emission.rgb * emission.a * 2.0;
	
	// Bloom extraction (bright areas, esp. emission)
	float brightness = dot(lit, vec3(0.299, 0.587, 0.114));
	float bloomThreshold = 0.5;
	float bloom = max(0.0, brightness - bloomThreshold) * bloomIntensity;
	
	gl_FragColor = vec4(lit + bloom * vec3(1.0), diffuse.a);
}
