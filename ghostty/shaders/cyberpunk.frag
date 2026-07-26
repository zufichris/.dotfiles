void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 terminalColor = texture(iChannel0, uv);
    
    float time = iTime * 0.3;
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    
    float angle1 = time + dist * 3.14159;
    float angle2 = time * 1.5 - uv.x * 6.28318;
    float angle3 = time * 0.7 + uv.y * 4.71238;
    
    vec3 cyan = vec3(0.0, 0.8, 1.0);
    vec3 magenta = vec3(1.0, 0.0, 0.6);
    vec3 purple = vec3(0.6, 0.2, 1.0);
    vec3 darkBlue = vec3(0.1, 0.1, 0.4);
    
    float wave1 = sin(angle1) * 0.5 + 0.5;
    float wave2 = sin(angle2) * 0.5 + 0.5;
    float wave3 = cos(angle3) * 0.5 + 0.5;
    
    vec3 gradient1 = mix(darkBlue, cyan, wave1);
    vec3 gradient2 = mix(purple, magenta, wave2);
    vec3 finalGradient = mix(gradient1, gradient2, wave3);
    
    float scanlines = sin(uv.y * 400.0 + time * 2.0) * 0.02 + 0.98;
    finalGradient *= scanlines;
    
    float glitchTime = floor(time * 4.0) / 4.0; // Stepped time for glitch
    float glitch = step(0.98, sin(glitchTime * 50.0 + uv.y * 100.0));
    vec2 glitchUV = uv + vec2(glitch * 0.01, 0.0);
    vec4 glitchedTerminal = texture(iChannel0, glitchUV);
    
    float aberration = 0.002;
    vec4 redChannel = texture(iChannel0, uv + vec2(aberration, 0.0));
    vec4 blueChannel = texture(iChannel0, uv - vec2(aberration, 0.0));
    vec4 chromaticTerminal = vec4(redChannel.r, terminalColor.g, blueChannel.b, terminalColor.a);
    
    vec4 finalTerminal = mix(chromaticTerminal, glitchedTerminal, glitch * 0.3);
    
    float brightness = dot(finalTerminal.rgb, vec3(0.299, 0.587, 0.114));
    vec3 glowColor = mix(cyan, magenta, sin(time + brightness * 10.0) * 0.5 + 0.5);
    vec3 textGlow = finalTerminal.rgb + glowColor * brightness * brightness * 0.4;
    float vignette = 1.0 - smoothstep(0.4, 1.2, dist);
    
    float textMask = step(0.1, brightness);
    vec3 backgroundBlend = finalGradient * (1.0 - textMask * 0.8);
    vec3 finalColor = mix(backgroundBlend, textGlow, textMask);
    
    finalColor *= vignette;
    
    float grain = (fract(sin(dot(uv + time, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.05;
    finalColor += grain;
    
    vec2 curve = uv * 2.0 - 1.0;
    curve *= 1.0 + dot(curve, curve) * 0.02; // Very subtle curve
    curve = curve * 0.5 + 0.5;
    float edgeFade = smoothstep(0.0, 0.05, curve.x) * 
                     smoothstep(1.0, 0.95, curve.x) * 
                     smoothstep(0.0, 0.05, curve.y) * 
                     smoothstep(1.0, 0.95, curve.y);
    
    finalColor *= edgeFade;
    
    fragColor = vec4(finalColor, finalTerminal.a);
}
