//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared

public final class PNISpotLightNode: PNSpotLightNode {
    public let name: String
    public let light: PNSpotLight
    public var transform: PNLTransform
    public var worldTransform: PNM2WTransform
    public weak var enclosingNode: PNScenePiece?
    public var modelUniforms: PNWModelUniforms
    public var localBound: PNBound?
    public var worldBound: PNBound?
    public var childrenMergedBound: PNBound?
    public let intrinsicBound: PNBound?
    public init(light: PNSpotLight,
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
        let entity = PNEntity(type: .spotLight, referenceIdx: scene.spotLights.count)
        scene.entities.add(parentIdx: parentIdx, data: entity)
        scene.spotLights.append(SpotLight.make(light: light,
                                               index: scene.entities.count - 1))
        return scene.entities.count - 1
    }
    public func update() {
        // Empty
    }
}
