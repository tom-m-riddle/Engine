//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import simd

/// Interface encapsulating operations that can be performed on bounds.
public protocol PNBoundInteractor {
    func overlap(_ lhs: PNBound, _ rhs: PNBound) -> Bool
    func merge(_ lhs: PNBound, rhs: PNBound) -> PNBound
    func isEqual(_ lhs: PNBound, _ rhs: PNBound) -> Bool
    func intersect(_ bound: PNBound, ray: PNRay) -> Bool
    func intersectionPoint(_ bound: PNBound, ray: PNRay) -> PNPoint3D?
    func width(_ bound: PNBound) -> Float
    func height(_ bound: PNBound) -> Float
    func depth(_ bound: PNBound) -> Float
    func volume(_ bound: PNBound) -> Float
    func center(_ bound: PNBound) -> PNPoint3D
    func multiply(_ lhs: simd_float4x4, _ rhs: PNBound) -> PNBound
    func from(inverseProjection: simd_float4x4) -> PNBound
    func from(_ corners: [simd_float3]) -> PNBound
    func corners(_ bound: PNBound) -> [simd_float3]
}
