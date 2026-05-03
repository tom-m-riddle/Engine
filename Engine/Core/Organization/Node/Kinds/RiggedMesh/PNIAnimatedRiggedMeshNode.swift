//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared
import simd

public final class PNIAnimatedRiggedMeshNode: PNAnimatedRiggedMeshNode {
    public let name: String
    public let mesh: PNMesh
    public var skeleton: PNSkeleton
    public var animator: PNAnimator
    public var animation: PNAnimatedCoordinateSpace
    public var transform: PNLTransform
    public var worldTransform: PNM2WTransform
    public weak var enclosingNode: PNScenePiece?
    public var modelUniforms: PNWModelUniforms
    public var localBound: PNBound?
    public var worldBound: PNBound?
    public var childrenMergedBound: PNBound?
    public var intrinsicBound: PNBound?
    public init(mesh: PNMesh,
                skeleton: PNSkeleton,
                animator: PNAnimator,
                animation: PNAnimatedCoordinateSpace,
                name: String = "") {
        self.name = name
        self.mesh = mesh
        self.skeleton = skeleton
        self.animator = animator
        self.animation = animation
        self.transform = animator.transform(coordinateSpace: animation)
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
        transform = animator.transform(coordinateSpace: animation)
    }
}
