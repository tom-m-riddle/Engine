//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared

public final class PNIAmbientLightNode: PNAmbientLightNode {
    public let name: String
    public let light: PNAmbientLight
    public var transform: PNLTransform
    public var worldTransform: PNM2WTransform
    public weak var enclosingNode: PNScenePiece?
    public var modelUniforms: PNWModelUniforms
    public var localBound: PNBound?
    public var worldBound: PNBound?
    public var childrenMergedBound: PNBound?
    public let intrinsicBound: PNBound?
    public init(light: PNAmbientLight,
                transform: PNLTransform,
                name: String = "") {
        self.name = name
        self.light = light
        self.transform = transform
        self.worldTransform = .identity
        self.enclosingNode = nil
        self.modelUniforms = .identity
        self.localBound = nil
        self.worldBound = nil
        self.childrenMergedBound = nil
        self.intrinsicBound = light.bound
    }
    public func write(scene: PNSceneDescription, parentIdx: PNParentIndex) -> PNNewlyWrittenIndex {
        let entity = PNEntity(type: .ambientLight,
                              referenceIdx: scene.ambientLights.count)
        scene.entities.add(parentIdx: parentIdx, data: entity)
        let underlyinglight = AmbientLight(diameter: light.diameter,
                                           color: light.color,
                                           intensity: light.intensity,
                                           idx: Int32(scene.entities.count - 1))
        scene.ambientLights.append(underlyinglight)
        return scene.entities.count - 1
    }
    public func update() {
        // Empty
    }
}
