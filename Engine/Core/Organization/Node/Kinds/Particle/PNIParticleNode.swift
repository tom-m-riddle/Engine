//
//  Copyright © 2022 Mateusz Stompór. All rights reserved.
//

import PNShared
import simd

public final class PNIParticleNode: PNParticleNode {
    public let name: String
    public var provider: PNRenderableParticlesProvider
    public var transform: PNLTransform
    public var worldTransform: PNM2WTransform
    public weak var enclosingNode: PNScenePiece?
    public var modelUniforms: PNWModelUniforms
    public var localBound: PNBound?
    public var worldBound: PNBound?
    public var childrenMergedBound: PNBound?
    public var intrinsicBound: PNBound? {
        provider.positioningRules.bound
    }
    public init(provider: PNRenderableParticlesProvider,
                transform: PNLTransform,
                name: String = "") {
        self.name = name
        self.provider = provider
        self.transform = transform
        self.worldTransform = .identity
        self.enclosingNode = nil
        self.modelUniforms = .identity
        self.localBound = nil
        self.worldBound = nil
        self.childrenMergedBound = nil
    }
    public func write(scene: PNSceneDescription, parentIdx: PNParentIndex) -> PNNewlyWrittenIndex {
        let entity = PNEntity(type: .particle,
                              referenceIdx: scene.particles.count)
        scene.entities.add(parentIdx: parentIdx, data: entity)
        scene.particles.append(PNParticleSystem(index: scene.entities.count - 1,
                                                atlas: provider.atlas,
                                                particles: provider.provider,
                                                positioningRules: provider.positioningRules))
        return scene.entities.count - 1
    }
    public func update() {
        // Empty
    }
}
