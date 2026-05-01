//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

#include "Shadow.h"

using namespace metal;

// 16-point Poisson disk — well-distributed 2D offsets for spot/directional PCF.
constant float2 kPoissonDisk[16] = {
    float2(-0.9420, -0.3991), float2( 0.9456, -0.7689),
    float2(-0.0942, -0.9294), float2( 0.3450,  0.2939),
    float2(-0.9159,  0.4577), float2(-0.8154, -0.8791),
    float2(-0.3828,  0.2768), float2( 0.9748,  0.7565),
    float2( 0.4432, -0.9751), float2( 0.5374, -0.4737),
    float2(-0.2650, -0.4189), float2( 0.7920,  0.1909),
    float2(-0.2419,  0.9971), float2(-0.8141,  0.9144),
    float2( 0.1998,  0.7864), float2( 0.1438, -0.1410)
};

// 16-point Poisson sphere — well-distributed 3D offsets for point-light PCF.
constant float3 kPoissonSphere[16] = {
    float3(-0.7499, -0.4811,  0.4152), float3( 0.4951, -0.7979,  0.0553),
    float3(-0.1119, -0.3516, -0.8599), float3( 0.8192,  0.3498, -0.3551),
    float3(-0.4228,  0.6617,  0.5956), float3( 0.1787, -0.9718, -0.1544),
    float3(-0.9307,  0.1247, -0.3432), float3( 0.6124,  0.7895,  0.0421),
    float3(-0.2041,  0.6812, -0.7027), float3( 0.7733, -0.2956,  0.5601),
    float3(-0.5614,  0.1543,  0.8131), float3( 0.0875,  0.9912, -0.1001),
    float3(-0.8447, -0.5293, -0.0758), float3( 0.3621, -0.1874, -0.9130),
    float3( 0.0197,  0.4239,  0.9056), float3(-0.3001, -0.8849,  0.3552)
};

float pcfDepth(metal::depth2d_array<float> shadowMaps,
               uint layer,
               float2 sampleCoordinate,
               int2 samples,
               float countedDepth,
               float bias) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float2 texelSize = float2(1.0f) / float2(shadowMaps.get_width(), shadowMaps.get_height());
    float filterRadius = float(samples.x);
    float threshold = countedDepth - bias;

    // Sentinel check: 4 samples spread ~90° apart across the disk.
    // If all agree the pixel is uniformly lit or shadowed, skip the remaining 12 taps.
    float s0  = threshold > shadowMaps.sample(textureSampler, sampleCoordinate + kPoissonDisk[ 0] * filterRadius * texelSize, layer) ? 1.0f : 0.0f;
    float s4  = threshold > shadowMaps.sample(textureSampler, sampleCoordinate + kPoissonDisk[ 4] * filterRadius * texelSize, layer) ? 1.0f : 0.0f;
    float s8  = threshold > shadowMaps.sample(textureSampler, sampleCoordinate + kPoissonDisk[ 8] * filterRadius * texelSize, layer) ? 1.0f : 0.0f;
    float s12 = threshold > shadowMaps.sample(textureSampler, sampleCoordinate + kPoissonDisk[12] * filterRadius * texelSize, layer) ? 1.0f : 0.0f;
    if (s0 == s4 && s4 == s8 && s8 == s12)
        return s0;

    // Shadow edge: run all 16 taps, reusing the 4 sentinel results.
    float result = s0 + s4 + s8 + s12;
    for (int i = 0; i < 16; ++i) {
        if (i == 0 || i == 4 || i == 8 || i == 12) continue;
        float2 coord = sampleCoordinate + kPoissonDisk[i] * filterRadius * texelSize;
        result += threshold > shadowMaps.sample(textureSampler, coord, layer) ? 1.0f : 0.0f;
    }
    return result / 16.0f;
}

float pcfDepth(metal::depthcube_array<float> shadowMaps,
               uint layer,
               float3 sampleCoordinate,
               int3 samples,
               float countedDepth,
               float bias,
               float offset) {
    constexpr sampler s(mag_filter::linear, min_filter::linear);
    float threshold = countedDepth - bias;

    // Sentinel check: 4 well-separated sphere samples.
    float s0  = threshold > shadowMaps.sample(s, sampleCoordinate + kPoissonSphere[ 0] * offset, layer) ? 1.0f : 0.0f;
    float s4  = threshold > shadowMaps.sample(s, sampleCoordinate + kPoissonSphere[ 4] * offset, layer) ? 1.0f : 0.0f;
    float s8  = threshold > shadowMaps.sample(s, sampleCoordinate + kPoissonSphere[ 8] * offset, layer) ? 1.0f : 0.0f;
    float s12 = threshold > shadowMaps.sample(s, sampleCoordinate + kPoissonSphere[12] * offset, layer) ? 1.0f : 0.0f;
    if (s0 == s4 && s4 == s8 && s8 == s12)
        return s0;

    // Shadow edge: run all 16 taps, reusing the 4 sentinel results.
    float result = s0 + s4 + s8 + s12;
    for (int i = 0; i < 16; ++i) {
        if (i == 0 || i == 4 || i == 8 || i == 12) continue;
        result += threshold > shadowMaps.sample(s, sampleCoordinate + kPoissonSphere[i] * offset, layer) ? 1.0f : 0.0f;
    }
    return clamp(result / 16.0f, 0.0f, 1.0f);
}
