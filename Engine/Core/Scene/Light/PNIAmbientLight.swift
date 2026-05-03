//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import simd

public struct PNIAmbientLight: PNAmbientLight {
    public let diameter: Float
    public let color: PNColorRGB
    public let intensity: Float
    public let bound: PNBound
    public init(diameter: Float,
                color: PNColorRGB,
                intensity: Float) {
        assertValid(color: color)
        self.diameter = diameter
        self.color = color
        self.intensity = intensity
        let radius = diameter / 2
        self.bound = PNBound(min: [-radius, -radius, -radius],
                             max: [radius, radius, radius])
    }
}
