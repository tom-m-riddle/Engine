//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared
import simd

public final class PNIRiggedMeshNode: PNRiggedMeshNode {
    public let name: String
    public let mesh: PNMesh
    public let skeleton: PNSkeleton
    public var transform: PNLTransform
    public var worldTransform: PNM2WTransform
    public var enclosingNode: PNScenePiece?
    public var modelUniforms: PNWModelUniforms
    public var localBound: PNBound?
    public var worldBound: PNBound?
    public var childrenMergedBound: PNBound?
    public let intrinsicBound: PNBound?
    public init(mesh: PNMesh,
                skeleton: PNSkeleton,
                transform: PNLTransform,
                name: String = "") {
        self.name = name
        self.mesh = mesh
        self.skeleton = skeleton
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
        let entity = PNEntity(type: .animatedMesh,
                              referenceIdx: scene.animatedModels.count)
        scene.entities.add(parentIdx: parentIdx, data: entity)
        let modelReference = PNAnimatedModelReference(skeleton: scene.skeletons.count,
                                                      mesh: scene.meshes.count,
                                                      idx: scene.entities.count - 1)
        scene.animatedModels.append(modelReference)
        scene.meshes.append(mesh)
        scene.skeletons.append(skeleton)
        return scene.entities.count - 1
    }
    public func update() {
        // Empty
    }
}
