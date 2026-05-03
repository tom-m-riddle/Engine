//
//  Copyright © 2022 Mateusz Stompór. All rights reserved.
//

@testable import Engine
import simd
import XCTest

class PNISceneNodeTests: XCTestCase {
    private let nodeUpdate = PNNodeUpdater()
    func testSingleNode() throws {
        let node = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [2, 0, 0])))
        nodeUpdate.update(rootNode: node)

        XCTAssertEqual(node.data.transform, .translation(vector: [2, 0, 0]))
        XCTAssertNil(node.data.intrinsicBound)
        XCTAssertNil(node.data.localBound)
        XCTAssertNil(node.data.worldBound)
        XCTAssertEqual(node.data.modelUniforms.modelMatrix.translation, [2, 0, 0])
        XCTAssertNil(node.data.childrenMergedBound)
        XCTAssertIdentical(node, node.data.enclosingNode)
    }
    func testNestedNodes() throws {
        let node = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [1, 2, 3])))
        let parent = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [4, 5, 6])))
        let grandParent = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [7, 8, 9])))
        parent.add(child: node)
        grandParent.add(child: parent)
        nodeUpdate.update(rootNode: grandParent)

        XCTAssertEqual(node.data.transform.translation, [1, 2, 3])
        XCTAssertEqual(node.data.worldTransform.translation, [12, 15, 18])
        XCTAssertEqual(node.data.modelUniforms.modelMatrix.translation, [12, 15, 18])
        XCTAssertEqual(parent.data.transform.translation, [4, 5, 6])
        XCTAssertEqual(parent.data.worldTransform.translation, [11, 13, 15])
        XCTAssertEqual(parent.data.modelUniforms.modelMatrix.translation, [11, 13, 15])
        XCTAssertEqual(grandParent.data.transform.translation, [7, 8, 9])
        XCTAssertEqual(grandParent.data.worldTransform.translation, [7, 8, 9])
        XCTAssertEqual(grandParent.data.modelUniforms.modelMatrix.translation, [7, 8, 9])
    }
    func testNestedNodesMovingNoChange() throws {
        let node = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [1, 2, 3])))
        let parent = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [4, 5, 6])))
        let grandParent = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [7, 8, 9])))
        parent.add(child: node)
        grandParent.add(child: parent)
        func assertion() {
            XCTAssertEqual(node.data.transform.translation, [1, 2, 3])
            XCTAssertEqual(node.data.worldTransform.translation, [12, 15, 18])
            XCTAssertEqual(node.data.modelUniforms.modelMatrix.translation, [12, 15, 18])
            XCTAssertEqual(parent.data.transform.translation, [4, 5, 6])
            XCTAssertEqual(parent.data.worldTransform.translation, [11, 13, 15])
            XCTAssertEqual(parent.data.modelUniforms.modelMatrix.translation, [11, 13, 15])
            XCTAssertEqual(grandParent.data.transform.translation, [7, 8, 9])
            XCTAssertEqual(grandParent.data.worldTransform.translation, [7, 8, 9])
            XCTAssertEqual(grandParent.data.modelUniforms.modelMatrix.translation, [7, 8, 9])
        }
        nodeUpdate.update(rootNode: grandParent)
        assertion()

        node.data.transform = .translation(vector: [1, 2, 3])
        parent.data.transform = .translation(vector: [4, 5, 6])
        grandParent.data.transform = .translation(vector: [7, 8, 9])

        nodeUpdate.update(rootNode: grandParent)
        assertion()

        node.data.transform = .translation(vector: [-1, -2, -3])
        node.data.transform = .translation(vector: [1, 2, 3])

        nodeUpdate.update(rootNode: grandParent)
        assertion()
    }
    func testBoundingBox() throws {
        let bb = PNBound(min: [-1, -1, -1], max: [1, 1, 1])
        let node = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [1, 2, 3]),
                                                        bound: bb))
        nodeUpdate.update(rootNode: node)
        XCTAssertEqual(node.data.worldTransform.translation, [1, 2, 3])
        XCTAssertEqual(node.data.worldTransform.translation,
                       node.data.transform.translation)
        XCTAssertEqual(node.data.worldBound?.min, node.data.localBound?.min)
        XCTAssertEqual(node.data.worldBound?.max, node.data.localBound?.max)
        XCTAssertEqual(node.data.worldBound?.min, [0, 1, 2])
        XCTAssertEqual(node.data.worldBound?.max, [2, 3, 4])
    }
    func testBoundingBoxNestedWithTranslations() throws {
        let bb = PNBound(min: [-1, -1, -1], max: [1, 1, 1])
        let node = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [1, 2, 3]),
                                                        bound: bb))
        let parentBb = PNBound(min: [2, 2, 2], max: [4, 4, 4])
        let parentNode = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [4, 5, 6]),
                                                              bound: parentBb))
        parentNode.add(child: node)
        nodeUpdate.update(rootNode: parentNode)
        XCTAssertEqual(parentNode.data.worldTransform.translation, [4, 5, 6])
        XCTAssertEqual(node.data.worldTransform.translation, [5, 7, 9])
        if let bbChild = node.data.worldBound,
           let bbParent = parentNode.data.worldBound,
           let bbChildLocal = node.data.localBound,
           let childrenMerged = parentNode.data.childrenMergedBound {
            XCTAssertEqual(bbChild.min, [4, 6, 8])
            XCTAssertEqual(bbChild.max, [6, 8, 10])
            XCTAssertEqual(bbParent.min, [4, 6, 8])
            XCTAssertEqual(bbParent.max, [8, 9, 10])
            XCTAssertEqual(childrenMerged.min, [0, 1, 2])
            XCTAssertEqual(childrenMerged.max, [2, 3, 4])
            XCTAssertEqual(childrenMerged.min, bbChildLocal.min)
            XCTAssertEqual(childrenMerged.max, bbChildLocal.max)
        } else {
            XCTFail("Unexpected nil")
        }
    }
    func testBoundingBoxNestedNoTranslation() throws {
        let firstBb = PNBound(min: [-1, -1, -1], max: [5, 5, 5])
        let firstNode = PNScenePiece.make(data: PNISceneNode(transform: .identity,
                                                             bound: firstBb))
        let secondBb = PNBound(min: [-4, -4, -4], max: [2, 2, 2])
        let secondNode = PNScenePiece.make(data: PNISceneNode(transform: .identity,
                                                              bound: secondBb))
        let parentBb = PNBound(min: [-10, -10, -10], max: [4, 4, 4])
        let parentNode = PNScenePiece.make(data: PNISceneNode(transform: .identity,
                                                              bound: parentBb))
        parentNode.add(child: firstNode)
        parentNode.add(child: secondNode)
        nodeUpdate.update(rootNode: parentNode)
        XCTAssertEqual(firstNode.data.worldBound?.min, [-1, -1, -1])
        XCTAssertEqual(firstNode.data.worldBound?.max, [5, 5, 5])
        XCTAssertEqual(secondNode.data.worldBound?.min, [-4, -4, -4])
        XCTAssertEqual(secondNode.data.worldBound?.max, [2, 2, 2])
        XCTAssertEqual(parentNode.data.childrenMergedBound?.min, [-4, -4, -4])
        XCTAssertEqual(parentNode.data.childrenMergedBound?.max, [5, 5, 5])
        XCTAssertEqual(parentNode.data.worldBound?.min, [-10, -10, -10])
        XCTAssertEqual(parentNode.data.worldBound?.max, [5, 5, 5])
    }
    func testBoundingBoxReloading() throws {
        let bb = PNBound(min: [-1, -1, -1], max: [1, 1, 1])
        let node = PNScenePiece.make(data: PNISceneNode(transform: .identity, bound: bb))
        node.data.transform = .scale(factor: 2)

        nodeUpdate.update(rootNode: node)

        XCTAssertEqual(node.data.transform, .scale(factor: 2))
        XCTAssertEqual(node.data.worldTransform, .scale(factor: 2))
        XCTAssertEqual(node.data.intrinsicBound?.min, [-1, -1, -1])
        XCTAssertEqual(node.data.intrinsicBound?.max, [1, 1, 1])
        XCTAssertNil(node.data.childrenMergedBound)
        XCTAssertEqual(node.data.localBound?.min, [-2, -2, -2])
        XCTAssertEqual(node.data.localBound?.max, [2, 2, 2])
        XCTAssertEqual(node.data.worldBound?.max, [2, 2, 2])
    }
    func testInitialNodeState() throws {
        let node = PNScenePiece.make(data: PNISceneNode())
        nodeUpdate.update(rootNode: node)

        XCTAssertNil(node.data.intrinsicBound)
        XCTAssertNil(node.data.worldBound)
        XCTAssertNil(node.data.localBound)
        XCTAssertNil(node.data.childrenMergedBound)
        XCTAssertEqual(node.data.worldTransform, .identity)
        XCTAssertEqual(node.data.transform, .identity)
    }
    func testMinimalBoard() throws {
        let boardBound = PNBound(min: [-30, -2, -30], max: [30, -1, 30])
        let boardNode = PNScenePiece.make(data: PNISceneNode(bound: boardBound))
        let transformNode = PNScenePiece.make(data: PNISceneNode(transform: PNTransform.scale(factor: 0.5)))
        transformNode.add(child: boardNode)
        nodeUpdate.update(rootNode: transformNode)
        XCTAssertNotNil(boardNode.data.intrinsicBound)
        XCTAssertEqual(boardNode.data.localBound?.min, boardBound.min)
        XCTAssertEqual(boardNode.data.localBound?.max, boardBound.max)
        XCTAssertEqual(boardNode.data.worldBound?.min, [-15, -1, -15])
        XCTAssertEqual(boardNode.data.worldBound?.max, [15, -0.5, 15])
        XCTAssertNil(boardNode.data.childrenMergedBound)
        XCTAssertNil(transformNode.data.intrinsicBound)
        XCTAssertEqual(transformNode.data.worldBound?.min, [-15, -1, -15])
        XCTAssertEqual(transformNode.data.worldBound?.max, [15, -0.5, 15])
        XCTAssertEqual(transformNode.data.localBound?.min, [-15, -1, -15])
        XCTAssertEqual(transformNode.data.localBound?.max, [15, -0.5, 15])
        XCTAssertEqual(transformNode.data.worldBound?.min, boardNode.data.worldBound?.min)
        XCTAssertEqual(transformNode.data.worldBound?.max, boardNode.data.worldBound?.max)
        XCTAssertEqual(transformNode.data.childrenMergedBound?.min, [-30, -2, -30])
        XCTAssertEqual(transformNode.data.childrenMergedBound?.max, [30, -1, 30])
    }
    func testBoundingBoxNestedBoard() throws {
        let boardBound = PNBound(min: [-30, -2, -30], max: [30, -1, 30])
        let boardNode = PNScenePiece.make(data: PNISceneNode(transform: .identity, bound: boardBound))
        let transformNode = PNScenePiece.make(data: PNISceneNode(transform: PNTransform.scale(factor: 0.5)))
        transformNode.add(child: boardNode)
        nodeUpdate.update(rootNode: transformNode)
        XCTAssertEqual(transformNode.data.worldBound?.min, boardNode.data.worldBound?.min)
        XCTAssertEqual(transformNode.data.worldBound?.max, boardNode.data.worldBound?.max)
        let passthroughNode = PNScenePiece.make(data: PNISceneNode(transform: .translation(vector: [1, 0, 0])))
        passthroughNode.add(child: transformNode)
    }
    func testBoundingBoxNestedNoTranslationAfterBoundingBoxUpdate() throws {
        let firstBb = PNBound(min: [-1, -1, -1], max: [5, 5, 5])
        let firstNode = PNScenePiece.make(data: PNISceneNode(transform: .identity,
                                                             bound: firstBb))
        let secondBb = PNBound(min: [-4, -4, -4], max: [2, 2, 2])
        let secondNode = PNScenePiece.make(data: PNISceneNode(transform: .identity,
                                                              bound: secondBb))
        let parentBb = PNBound(min: [-10, -10, -10], max: [4, 4, 4])
        let parentNode = PNScenePiece.make(data: PNISceneNode(transform: .identity,
                                                              bound: parentBb))
        parentNode.add(child: firstNode)
        parentNode.add(child: secondNode)
        secondNode.data.transform = .translation(vector: [20, 20, 20])

        nodeUpdate.update(rootNode: parentNode)
        XCTAssertEqual(firstNode.data.worldBound?.min, [-1, -1, -1])
        XCTAssertEqual(firstNode.data.worldBound?.max, [5, 5, 5])
        XCTAssertEqual(secondNode.data.worldBound?.min, [16, 16, 16])
        XCTAssertEqual(secondNode.data.worldBound?.max, [22, 22, 22])
        XCTAssertEqual(parentNode.data.childrenMergedBound?.min, [-1, -1, -1])
        XCTAssertEqual(parentNode.data.childrenMergedBound?.max, [22, 22, 22])
        XCTAssertEqual(parentNode.data.worldBound?.min, [-10, -10, -10])
        XCTAssertEqual(parentNode.data.worldBound?.max, [22, 22, 22])
    }
}
