//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared
import simd

public final class PNIMeshNode: PNMeshNode {
    public let name: String
    public let mesh: PNMesh
    public var transform: PNLTransform
    public var worldTransform: PNM2WTransform
    public weak var enclosingNode: PNScenePiece?
    public var modelUniforms: PNWModelUniforms
    public var localBound: PNBound?
    public var worldBound: PNBound?
    public var childrenMergedBound: PNBound?
    public let intrinsicBound: PNBound?
    public init(mesh: PNMesh,
                transform: PNLTransform,
                name: String = "") {
        self.name = name
        self.mesh = mesh
        self.transform = transform
        self.worldTransform = .identity
        self.enclosingNode = nil
        self.modelUniforms = .identity
        self.localBound = nil
        self.worldBound = nil
        self.childrenMergedBound = nil
        self.intrinsicBound = mesh.bound
    }
    public func write(scene: PNSceneDescription, parentIdx: PNParentIndex) -> PNNewlyWrittenIndex {
        let entity = PNEntity(type: .mesh,
                              referenceIdx: scene.models.count)
        scene.entities.add(parentIdx: parentIdx, data: entity)
        let modelReference = PNModelReference(mesh: scene.meshes.count,
                                              idx: scene.entities.count - 1)
        scene.models.append(modelReference)
        scene.meshes.append(mesh)
        return scene.entities.count - 1
    }
    public func update() {
        // Empty
    }
}
