
#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

uniform vec2 uSize;
uniform float uTime;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 p = (uv - 0.5) * 2.0;

  float dist = length(p);

  // Circular silhouette with a soft edge.
  float alpha = 1.0 - smoothstep(0.97, 1.0, dist);

  if (alpha <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  float t = uTime;

  // Multiple independent wave fields.
  // Each field moves at a different speed and direction.
  float wave1 = sin(p.x * 3.5 + sin(p.y * 2.5 + t * 0.45) * 1.5
                    + t * 0.35);

  float wave2 = cos(p.y * 4.0 - sin(p.x * 2.8 - t * 0.3) * 1.4
                    - t * 0.28);

  float wave3 = sin((p.x + p.y) * 3.0 + t * 0.2);

  float blend = (wave1 + wave2 + wave3) / 3.0;
  blend = smoothstep(-0.75, 0.75, blend);

  // Aether's warm color palette.
  vec3 deepBurntOrange = vec3(0.28, 0.055, 0.025);
  vec3 burntOrange     = vec3(0.75, 0.16, 0.035);
  vec3 vividOrange     = vec3(1.0, 0.35, 0.075);
  vec3 warmAmber       = vec3(1.0, 0.68, 0.30);

  vec3 color = mix(deepBurntOrange, burntOrange, blend);
  color = mix(color, vividOrange, smoothstep(0.2, 0.85, wave1));
  color = mix(color, warmAmber, smoothstep(0.55, 0.95, wave2) * 0.65);

  // Soft spherical lighting.
  float light = max(0.0, 1.0 - length(p - vec2(-0.35, -0.4)));
  color += vec3(1.0, 0.52, 0.22) * light * 0.16;

  // Darken the outer edge to create depth.
  float edgeShade = smoothstep(0.25, 0.98, dist);
  color *= 1.0 - edgeShade * 0.55;

  // Premultiplied alpha.
  fragColor = vec4(color * alpha, alpha);
}
