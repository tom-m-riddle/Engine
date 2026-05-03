//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import simd

public struct PNIOmniLight: PNOmniLight {
    public let farPlane: Float
    public let nearPlane: Float
    public let color: PNColorRGB
    public let intensity: Float
    public var influenceRadius: Float
    public let castsShadows: Bool
    public let projectionMatrix: simd_float4x4
    public let projectionMatrixInverse: simd_float4x4
    public let bound: PNBound
    public init(color: PNColorRGB,
                intensity: Float,
                influenceRadius: Float,
                castsShadows: Bool) {
        assertValid(color: color)
        let nearPlance: Float = 0.01
        self.color = color
        self.intensity = intensity
        self.influenceRadius = influenceRadius
        self.castsShadows = castsShadows
        self.projectionMatrix = simd_float4x4.perspectiveProjectionRightHand(fovyRadians: Float(90).radians,
                                                                             aspect: 1,
                                                                             nearZ: nearPlance,
                                                                             farZ: influenceRadius)
        self.projectionMatrixInverse = projectionMatrix.inverse
        self.bound = PNIOmniLight.computeBound(projectionMatrixInverse: projectionMatrixInverse)
        self.nearPlane = nearPlance
        self.farPlane = influenceRadius
    }
    private static func computeBound(projectionMatrixInverse: simd_float4x4) -> PNBound {
        let interactor = PNIBoundInteractor()
        let projectionBound = interactor.from(inverseProjection: projectionMatrixInverse)
        guard let merged = [
            interactor.multiply(PNSurroundings.positiveX, projectionBound),
            interactor.multiply(PNSurroundings.negativeX, projectionBound),
            interactor.multiply(PNSurroundings.positiveY, projectionBound),
            interactor.multiply(PNSurroundings.negativeY, projectionBound),
            interactor.multiply(PNSurroundings.positiveZ, projectionBound),
            interactor.multiply(PNSurroundings.negativeZ, projectionBound)
        ].reduce({ interactor.merge($0, rhs: $1) }) else {
            fatalError("Reduce returned nil even if it never should in this circumstances")
        }
        return merged
    }
}
