//
//  Copyright © 2026 Mateusz Stompór. All rights reserved.
//

import simd

class PNNodeUpdater {
    private let interactor = PNIBoundInteractor()
    init() {
        // Empty
    }
    func update(rootNode: PNScenePiece) {
        let sceneUpdateInterval = psignposter.beginInterval("Scene update")
        update(from: rootNode, worldTransform: .identity)
        psignposter.endInterval("Scene update", sceneUpdateInterval)
    }
    private func update(from node: PNScenePiece, worldTransform: simd_float4x4) {
        let concatenatedTransform = worldTransform * node.data.transform

        node.data.worldTransform = concatenatedTransform
        node.data.modelUniforms = PNWModelUniforms(modelMatrix: concatenatedTransform,
                                                   modelMatrixInverse: concatenatedTransform.inverse)

        if node.children.isEmpty {
            node.data.localBound = node.data.intrinsicBound.map { interactor.multiply(node.data.transform, $0) }
            node.data.childrenMergedBound = nil
        } else {
            for child in node.children {
                update(from: child, worldTransform: concatenatedTransform)
            }
            let localBounds = node.children.compactMap { $0.data.localBound }
            let mergedLocalBounds = localBounds.reduce { interactor.merge($0, rhs: $1) }
            node.data.childrenMergedBound = mergedLocalBounds

            if let bb = node.data.intrinsicBound {
                if let childrenBound = mergedLocalBounds {
                    node.data.localBound = interactor.multiply(node.data.transform, interactor.merge(bb, rhs: childrenBound))
                } else {
                    node.data.localBound = interactor.multiply(node.data.transform, bb)
                }
            } else {
                node.data.localBound = mergedLocalBounds.map { interactor.multiply(node.data.transform, $0) }
            }
        }
        node.data.worldBound = node.data.localBound.map { interactor.multiply(worldTransform, $0) }
    }
}
