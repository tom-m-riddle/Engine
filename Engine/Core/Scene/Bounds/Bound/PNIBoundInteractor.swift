//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import simd

public struct PNIBoundInteractor: PNBoundInteractor {
    public init() {
        // Default
    }
    public func isEqual(_ lhs: PNBound, _ rhs: PNBound) -> Bool {
        lhs.min == rhs.min && lhs.max == rhs.max
    }
    public func overlap(_ lhs: PNBound, _ rhs: PNBound) -> Bool {
        lhs.max.x > rhs.min.x &&
        lhs.min.x < rhs.max.x &&
        lhs.max.y > rhs.min.y &&
        lhs.min.y < rhs.max.y &&
        lhs.max.z > rhs.min.z &&
        lhs.min.z < rhs.max.z
    }
    public func merge(_ lhs: PNBound, rhs: PNBound) -> PNBound {
        PNBound(min: [min(lhs.min.x, rhs.min.x),
                      min(lhs.min.y, rhs.min.y),
                      min(lhs.min.z, rhs.min.z)],
                max: [max(lhs.max.x, rhs.max.x),
                      max(lhs.max.y, rhs.max.y),
                      max(lhs.max.z, rhs.max.z)])
    }
    public func intersect(_ bound: PNBound, ray: PNRay) -> Bool {
        intersectionPoint(bound, ray: ray) != nil
    }
    public func intersectionPoint(_ bound: PNBound, ray: PNRay) -> PNPoint3D? {
        let minX = (bound.min.x - ray.origin.x) * ray.inverseDirection.x
        let maxX = (bound.max.x - ray.origin.x) * ray.inverseDirection.x
        let minY = (bound.min.y - ray.origin.y) * ray.inverseDirection.y
        let maxY = (bound.max.y - ray.origin.y) * ray.inverseDirection.y
        let minZ = (bound.min.z - ray.origin.z) * ray.inverseDirection.z
        let maxZ = (bound.max.z - ray.origin.z) * ray.inverseDirection.z
        let tMin = max(max(min(minX, maxX), min(minY, maxY)), min(minZ, maxZ))
        let tMax = min(min(max(minX, maxX), max(minY, maxY)), max(minZ, maxZ))
        if tMax >= 0 && tMin <= tMax {
            let factor = tMin > 0 && tMax > 0 ? min(tMax, tMin) : max(tMin, tMax)
            return PNPoint3D(factor * ray.direction.x + ray.origin.x,
                             factor * ray.direction.y + ray.origin.y,
                             factor * ray.direction.z + ray.origin.z)
        }
        return nil
    }
    public func width(_ bound: PNBound) -> Float {
        abs(bound.max.x - bound.min.x)
    }
    public func height(_ bound: PNBound) -> Float {
        abs(bound.max.y - bound.min.y)
    }
    public func depth(_ bound: PNBound) -> Float {
        abs(bound.max.z - bound.min.z)
    }
    public func volume(_ bound: PNBound) -> Float {
        width(bound) * height(bound) * depth(bound)
    }
    public func center(_ bound: PNBound) -> PNPoint3D {
        [avg(bound.min.x, bound.max.x),
         avg(bound.min.y, bound.max.y),
         avg(bound.min.z, bound.max.z)]
    }
    public func corners(_ bound: PNBound) -> [simd_float3] {
        [simd_float3(bound.min.x, bound.min.y, bound.min.z),
         simd_float3(bound.max.x, bound.min.y, bound.min.z),
         simd_float3(bound.min.x, bound.min.y, bound.max.z),
         simd_float3(bound.max.x, bound.min.y, bound.max.z),
         simd_float3(bound.min.x, bound.max.y, bound.min.z),
         simd_float3(bound.max.x, bound.max.y, bound.min.z),
         simd_float3(bound.min.x, bound.max.y, bound.max.z),
         simd_float3(bound.max.x, bound.max.y, bound.max.z)]
    }
    public func from(_ corners: [simd_float3]) -> PNBound {
        var minV = simd_float3(repeating: Float.infinity)
        var maxV = simd_float3(repeating: -Float.infinity)
        for c in corners {
            minV = simd_min(minV, c)
            maxV = simd_max(maxV, c)
        }
        return PNBound(min: minV, max: maxV)
    }
    public func multiply(_ lhs: simd_float4x4, _ rhs: PNBound) -> PNBound {
        from(corners(rhs).map { (lhs * simd_float4($0, 1)).xyz })
    }
    public func from(inverseProjection: simd_float4x4) -> PNBound {
        let ndcCorners: [simd_float4] = [
            [-1, -1, 0, 1], [ 1, -1, 0, 1], [-1, -1, 1, 1], [ 1, -1, 1, 1],
            [-1,  1, 0, 1], [ 1,  1, 0, 1], [-1,  1, 1, 1], [ 1,  1, 1, 1]
        ]
        return from(ndcCorners.map { v -> simd_float3 in
            var p = inverseProjection * v
            p /= p.w
            return p.xyz
        })
    }
}
