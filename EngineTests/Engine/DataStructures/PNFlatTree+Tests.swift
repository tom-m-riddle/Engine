//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

@testable import Engine
import simd
import XCTest

class PNFlatTreeTests: XCTestCase {
    func testChildrenEmptyTree() throws {
        let tree = PNFlatTree<Int>()
        XCTAssertEqual(tree.children(of: .nil), [])
        XCTAssertEqual(tree.children(of: 0), [])
    }
    func testSingleNodeTree() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 100)
        XCTAssertEqual(tree.children(of: .nil), [0])
        XCTAssertEqual(tree.children(of: 0), [])
    }
    func testMultipleChildren() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 100)
        tree.add(parentIdx: 0, data: 101)
        tree.add(parentIdx: 0, data: 102)
        tree.add(parentIdx: 1, data: 103)
        XCTAssertEqual(tree.children(of: .nil), [0])
        XCTAssertEqual(tree.children(of: 0), [1, 2])
        XCTAssertEqual(tree.children(of: 1), [3])
    }
    func testNonExistingDescendants() throws {
        let tree = PNFlatTree<Int>()
        XCTAssertEqual(tree.children(of: .nil), [])
        XCTAssertEqual(tree.children(of: 10), [])
    }
    func testDifferentAncestors() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 100)
        tree.add(parentIdx: 0, data: 101)
        tree.add(parentIdx: 0, data: 102)
        tree.add(parentIdx: 1, data: 103)
        tree.add(parentIdx: 2, data: 104)
        XCTAssertEqual(tree.descendants(of: 1), [3])
        XCTAssertEqual(tree.descendants(of: 2), [4])
    }
    func testMultipleDescendants() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 100)
        tree.add(parentIdx: 0, data: 101)
        tree.add(parentIdx: 0, data: 102)
        tree.add(parentIdx: 1, data: 103)
        XCTAssertEqual(tree.descendants(of: .nil), [0, 1, 2, 3])
    }
    func testEmptyOnEmpty() throws {
        let tree = PNFlatTree<Int>()
        XCTAssertTrue(tree.isEmpty)
    }
    func testEmptyOnNonEmpty() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 10)
        XCTAssertFalse(tree.isEmpty)
    }
    func testCountOnEmpty() throws {
        let tree = PNFlatTree<Int>()
        XCTAssertEqual(tree.count, 0)
    }
    func testCountOnNonEmpty() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 20)
        XCTAssertEqual(tree.count, 1)
    }
    func testIndicesOnEmpty() throws {
        XCTAssertEqual(PNFlatTree<Int>().indices, 0 ..< 0)
    }
    func testIndicesOnNonEmpty() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 20)
        XCTAssertEqual(tree.indices, 0 ..< 1)
    }
    func testSubscript() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 20)
        // update
        tree[0].data = 100
        XCTAssertEqual(tree[0].data, 100)
        XCTAssertEqual(tree[0].parentIdx, .nil)
    }
    func testMultipleRoots() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 10)
        tree.add(parentIdx: .nil, data: 20)
        tree.add(parentIdx: .nil, data: 30)
        XCTAssertEqual(tree.children(of: .nil), [0, 1, 2])
    }
    func testLeafNodeHasNoChildren() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 10)
        tree.add(parentIdx: 0, data: 20)
        XCTAssertEqual(tree.children(of: 1), [])
        XCTAssertEqual(tree.descendants(of: 1), [])
    }
    func testDescendantsThreeLevelsDeep() throws {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 0)  // 0
        tree.add(parentIdx: 0, data: 1)     // 1
        tree.add(parentIdx: 0, data: 2)     // 2
        tree.add(parentIdx: 1, data: 3)     // 3
        tree.add(parentIdx: 1, data: 4)     // 4
        tree.add(parentIdx: 2, data: 5)     // 5
        // descendants of root: children before their own descendants (BFS-like)
        XCTAssertEqual(tree.descendants(of: .nil), [0, 1, 2, 3, 4, 5])
        // subtree rooted at node 1
        XCTAssertEqual(tree.descendants(of: 1), [3, 4])
        // subtree rooted at node 2
        XCTAssertEqual(tree.descendants(of: 2), [5])
    }
    func testDescendantsPerformance() {
        var tree = PNFlatTree<Int>()
        tree.add(parentIdx: .nil, data: 0)
        for i in 0 ..< 999 {
            tree.add(parentIdx: i, data: i + 1)
        }
        measure {
            _ = tree.descendants(of: .nil)
        }
    }
}
