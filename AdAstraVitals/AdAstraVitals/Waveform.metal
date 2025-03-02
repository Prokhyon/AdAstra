//
//  Waveform.metal
//  AdAstraVitals
//
//  Created by Loris Thomas on 24.02.2025.
//


#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

// Refined ECG function
float ecg_waveform(float x, int style) {
    float stretchFactor = 1.2;  // Reduce stretch horizontally
    float t = fmod(x / stretchFactor, M_PI_F);
    
    // Increase vertical scale
    float amplitude = 1.5;

    switch (style) {
        case 1:
            if (t < 0.12) return amplitude * 0.15 * sin(t * 10);
            if (t < 0.18) return amplitude * -0.5;
            if (t < 0.21) return amplitude * 6;
            if (t < 0.25) return amplitude * -2;
            if (t < 0.3) return amplitude * -1;
            if (t < 0.5) return amplitude * 0.6 * sin((t - 0.3) * 6);
            return amplitude * 0.05 * sin(t * 12);

        case 2:
            if (t < 0.1) return amplitude * 0.12 * sin(t * 12);
            if (t < 0.16) return amplitude * -0.7;
            if (t < 0.2) return amplitude * 5;
            if (t < 0.23) return amplitude * -3;
            if (t < 0.28) return amplitude * -1.2;
            if (t < 0.45) return amplitude * 0.3 * sin((t - 0.3) * 8);
            return amplitude * 0.04 * sin(t * 15);

        case 3:
            if (t < 0.14) return amplitude * 0.18 * sin(t * 8);
            if (t < 0.2) return amplitude * -0.4;
            if (t < 0.23) return amplitude * 6.2;
            if (t < 0.27) return amplitude * -2.5;
            if (t < 0.32) return amplitude * -1.5;
            if (t < 0.55) return amplitude * 0.7 * sin((t - 0.3) * 5);
            return amplitude * 0.06 * sin(t * 10);

        case 4:
            if (t < 0.1) return amplitude * 0.12 * sin(t * 12);
            if (t < 0.16) return amplitude * -0.7;
            if (t < 0.19) return amplitude * 4;
            if (t < 0.23) return amplitude * -3;
            if (t < 0.28) return amplitude * -1.2;
            if (t < 0.4) return amplitude * 0.3 * sin((t - 0.3) * 8);
            return amplitude * 0.04 * sin(t * 15);

        default:
            return 0.0;
    }
}

// Vertex function
vertex VertexOut vertex_main(uint vertexID [[vertex_id]], constant float &phase [[buffer(0)]], constant int &style [[buffer(1)]]) {
    VertexOut out;

    float x = (float(vertexID) / 200.0) * 2.0 - 1.0; // Increased resolution (200 points)
    float y = ecg_waveform(x + phase, style) * 0.2;  // Adjusted vertical scale

    out.position = float4(x, y, 0, 1);
    out.color = float4(0.0, 1.0, 1.0, 1.0); // Cyan color
    return out;
}

// Fragment function
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
