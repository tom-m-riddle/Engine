//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared

/// Interface used to describe a minimal scene node.
/// In hierarchical structure embedded in ``PNNode``, when it is used as ``PNScenePiece``.
public protocol PNSceneNode: AnyObject {
    var name: String { get }
    var transform: PNLTransform { get set }
    var worldTransform: PNM2WTransform { get set }
    var enclosingNode: PNScenePiece? { get set }
    var modelUniforms: PNWModelUniforms { get set }
    var localBound: PNBound? { get set }
    var worldBound: PNBound? { get set }
    var childrenMergedBound: PNBound? { get set }
    var intrinsicBound: PNBound? { get }
    func update()
    func write(scene: PNSceneDescription, parentIdx: PNParentIndex) -> PNNewlyWrittenIndex
}
