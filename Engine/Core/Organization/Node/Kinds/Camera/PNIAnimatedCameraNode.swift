//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared

public final class PNIAnimatedCameraNode: PNAnimatedCameraNode {
    public let name: String
    public var camera: PNCamera
    public var animator: PNAnimator
    public var animation: PNAnimatedCoordinateSpace
    public var transform: PNLTransform
    public var worldTransform: PNM2WTransform
    public weak var enclosingNode: PNScenePiece?
    public var modelUniforms: PNWModelUniforms
    public var localBound: PNBound?
    public var worldBound: PNBound?
    public var childrenMergedBound: PNBound?
    public let intrinsicBound: PNBound?
    public init(camera: PNCamera,
                animator: PNAnimator,
                animation: PNAnimatedCoordinateSpace,
                name: String = "") {
        self.name = name
        self.camera = camera
        self.animator = animator
        self.animation = animation
        self.transform = animator.transform(coordinateSpace: animation)
        self.worldTransform = .identity
        self.enclosingNode = nil
        self.modelUniforms = .identity
        self.localBound = nil
        self.worldBound = nil
        self.childrenMergedBound = nil
        self.intrinsicBound = camera.bound
    }
    public func write(scene: PNSceneDescription, parentIdx: PNParentIndex) -> PNNewlyWrittenIndex {
        scene.entities.add(parentIdx: parentIdx, data: PNEntity(type: .camera,
                                                                referenceIdx: scene.cameras.count))
        scene.cameras.append(camera)
        let uniform = CameraUniforms(projectionMatrix: camera.projectionMatrix,
                                     index: Int32(scene.entities.count - 1))
        scene.cameraUniforms.append(uniform)
        scene.activeCameraIdx = scene.entities.count - 1
        return scene.entities.count - 1
    }
    public func update() {
        transform = animator.transform(coordinateSpace: animation)
    }
}
