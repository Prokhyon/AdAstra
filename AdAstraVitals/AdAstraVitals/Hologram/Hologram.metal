//
//  Hologram.metal
//  AdAstraVitals
//
//  Created by Loris Thomas on 14.02.2025.
//


#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 noise(float2 position, half4 currentColor, float time) {
    float value = fract(sin(dot(position + time, float2(12.9898, 78.233))) * 43758.5453);
    return half4(value, value, value, 1) * currentColor.a;
}

[[ stitchable ]] float2 simpleWave(float2 position, float time) {
//    return position + float2 (0, sin(time + position.x / 20)) * 10;
    return position + float2 (sin(time + position.y / 20), sin(time + position.x / 20)) * 5;
}

[[ stitchable ]] float2 complexWave(float2 position, float time, float2 size, float speed, float strength, float frequency) {
    float2 normalizedPosition = position / size;
    float moveAmount = time * speed;

    position.x += sin((normalizedPosition.x + moveAmount) * frequency) * strength;
    position.y += cos((normalizedPosition.y + moveAmount) * frequency) * strength;

    return position;
}

[[ stitchable ]] half4 emboss(float2 position, SwiftUI::Layer layer, float strength) {
    half4 current_color = layer.sample(position);
    half4 new_color = current_color;

    new_color += layer.sample(position + 1) * strength;
    new_color -= layer.sample(position - 1) * strength;

    return half4(new_color);
}


[[ stitchable ]] half4 hologramLayer(SwiftUI::Layer layer, float2 position, float time) {
    half4 originalColor = layer.sample(position);
    
    // Scanline effect
    float scanline = sin(position.y * 0.1 + time * 5.0) * 0.1;

    // Horizontal glitch effect
    float glitch = sin(time * 2.0 + position.y * 0.05) * 2.0;
    float2 glitchOffset = float2(glitch, 0);

    // RGB Chromatic aberration
    half4 colorR = layer.sample(position + float2(1.5, 0));
    half4 colorB = layer.sample(position - float2(1.5, 0));
    half4 colorG = originalColor;

    half4 chromaticColor = half4(colorR.r, colorG.g, colorB.b, originalColor.a);
    half4 finalColor = mix(originalColor, chromaticColor, 0.5);
    
    finalColor *= 1.0 + scanline;
    finalColor *= 1.0 - (fract(time * 0.5) * 0.2);
    
    finalColor.a *= 0.8;
    return finalColor;
}

/// A shader that creates a holographic blue effect by mapping brightness values to shades of blue.
/// Dark colors are deep blue, mid-tones are cyan, and bright areas shift towards white-blue.
///
/// - Parameter position: The user-space coordinate of the current pixel.
/// - Parameter color: The current color of the pixel.
/// - Returns: The new pixel color with a holographic blue effect.
[[ stitchable ]] half4 infrablue(float2 position, half4 color) {
    if (color.a > 0) {
        // Define darker and richer holographic colors
        half3 deepBlue = half3(0.0h, 0.0h, 0.2h);  // Dark navy blue
        half3 midBlue = half3(0.0h, 0.3h, 0.8h);   // A deep electric blue
        half3 cyan = half3(0.0h, 1.0h, 1.0h);      // Pure cyan
        
        // Convert input color to perceived brightness (luma)
        half3 grayValues = half3(0.2125h, 0.7154h, 0.0721h);
        half luma = dot(color.rgb, grayValues);

        // Declare the final color
        half3 newColor;

        // Apply blending based on brightness level
        if (luma < 0.4h) {
            newColor = mix(deepBlue, midBlue, luma / 0.4h);
        } else {
            newColor = mix(midBlue, cyan, (luma - 0.4h) / 0.6h);
        }

        // Apply transparency and return final color
        return half4(newColor * 0.9h, 1.0h) * color.a; // Slightly dim to emphasize hologram depth
    } else {
        return color; // Keep transparency
    }
}

[[ stitchable ]] half4 scanlines(float2 position, half4 color, float time) {
    float scanline = sin(position.y * 0.1 + time * 5.0) * 0.1;
    return color * (1.0h + scanline);
}

[[ stitchable ]] half4 chromaticAberration(float2 position, SwiftUI::Layer layer) {
    half4 colorR = layer.sample(position + float2(1.5, 0));
    half4 colorB = layer.sample(position - float2(1.5, 0));
    half4 colorG = layer.sample(position);
    
    return half4(colorR.r, colorG.g, colorB.b, colorG.a);
}

[[ stitchable ]] float2 glitchOffset(float2 position, float time) {
    float glitch = sin(position.y * 0.1 + time * 10.0) * 2.0;
    return position + float2(glitch, 0);
}

[[ stitchable ]] half4 flicker(half4 color, float time) {
    float randomFactor = fract(sin(time * 1234.567) * 43758.5453);  // Generate randomness
    float intensity = 0.85 + randomFactor * 0.3;  // Flicker between 85% and 115% brightness
    return color * intensity;
}

[[ stitchable ]] float2 distortion(float2 position, float time) {
    float wave = sin(position.y * 0.05 + time * 5.0) * 3.0;
    return position + float2(wave, 0);
}

[[ stitchable ]] half4 pixelMesh(float2 position, half4 color, float2 resolution) {
    float2 gridSize = float2(2.5, 2.5); // Larger pixelated effect
    float2 gridPos = floor(position / gridSize) * gridSize + gridSize / 2.0; // Snap position to grid center
    float dist = length(position - gridPos); // Get distance from grid center

    float pixelThreshold = 0.8; // Bigger dots to be visible
    if (dist > pixelThreshold) {
        return half4(0, 0, 0, 0);
    }

    return color; // Keep dot color
}

[[ stitchable ]] half4 edgeGlow(float2 position, SwiftUI::Layer layer) {
    half4 current = layer.sample(position);
    half4 left = layer.sample(position + float2(-1, 0));
    half4 right = layer.sample(position + float2(1, 0));
    half4 up = layer.sample(position + float2(0, -1));
    half4 down = layer.sample(position + float2(0, 1));

    half4 edgeColor = abs(left - right) + abs(up - down);
    edgeColor *= 1.5; // Enhance the glow effect

    return max(current, edgeColor); // Combine with original color
}

[[ stitchable ]] float2 hologramDrift(float2 position, float time) {
    float drift = sin(time * 2.0 + position.y * 0.02) * 2.0;
    return position + float2(drift, 0);
}

[[ stitchable ]] half4 signalJitter(float2 position, half4 color, float time) {
    float glitch = step(fract(time * 0.5), 0.1); // 10% of the time, apply glitch
    return mix(color, half4(0, 0, 0, 1), glitch); // Replace parts with black
}

[[ stitchable ]] half4 colorPlanes(float2 position, SwiftUI::Layer layer, float2 size, float time) {
    // Sample the original color
    half4 color = layer.sample(position);
    
    // Convert input color to perceived brightness (luma)
    half3 grayValues = half3(0.2125h, 0.7154h, 0.0721h);
    half luma = dot(color.rgb, grayValues);
    
    // Explicitly cast `luma` to float to avoid ambiguity in smoothstep
    float lumaF = float(luma);
    
    // Create a stronger, randomized offset for the glitch effect
    float2 randomOffset = float2(sin(time * 15.0 + position.y * 0.05), cos(time * 12.0 + position.x * 0.03)) * 5.0;
    
    // Make the effect stronger in darker OR very bright areas
    float glitchMask = smoothstep(0.1, 0.7, lumaF) + smoothstep(0.7, 1.0, lumaF);

    // Compute a distance factor to fade effect near edges
    float2 normPos = position / size;  // Normalize between 0 and 1
    float edgeFactor = smoothstep(0.05, 0.2, normPos.x) *
                       smoothstep(0.05, 0.2, normPos.y) *
                       smoothstep(0.95, 0.8, normPos.x) *
                       smoothstep(0.95, 0.8, normPos.y);

    // Reduce glitch strength near edges
    float glitchStrength = glitchMask * edgeFactor;
    
    // Apply the glitch with stronger offsets
    float2 red = position - (randomOffset * glitchStrength * 1.5);
    float2 blue = position + (randomOffset * glitchStrength);
    
    // Apply the glitch shift to red and blue channels
    color.r = layer.sample(red).r;
    color.b = layer.sample(blue).b;
    
    // Blend with original color to keep a semi-realistic effect
    return mix(color, layer.sample(position), 0.0) * color.a;
}
