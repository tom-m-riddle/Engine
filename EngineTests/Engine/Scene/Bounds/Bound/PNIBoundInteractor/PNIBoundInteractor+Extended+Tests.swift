//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

@testable import Engine
import simd
import XCTest

class PNIBoundInteractorExtendedTests: XCTestCase {
    let interactor = PNIBoundInteractor()
    let bounds = PNBound(min: [-1, -2, -3], max: [4, 5, 6])
    func testTransformations() throws {
        let result = interactor.multiply(simd_float4x4.scale([2, 3, 4]), bounds)
        let corners = interactor.corners(result)
        XCTAssertEqual(corners[0], [-2, -6, -12])
        XCTAssertEqual(corners[1], [8, -6, -12])
        XCTAssertEqual(corners[2], [-2, -6, 24])
        XCTAssertEqual(corners[3], [8, -6, 24])
        XCTAssertEqual(corners[4], [-2, 15, -12])
        XCTAssertEqual(corners[5], [8, 15, -12])
        XCTAssertEqual(corners[6], [-2, 15, 24])
        XCTAssertEqual(corners[7], [8, 15, 24])
    }
    func testCorners() throws {
        let corners = interactor.corners(bounds)
        XCTAssertEqual(corners[0], [-1, -2, -3])
        XCTAssertEqual(corners[1], [4, -2, -3])
        XCTAssertEqual(corners[2], [-1, -2, 6])
        XCTAssertEqual(corners[3], [4, -2, 6])
        XCTAssertEqual(corners[4], [-1, 5, -3])
        XCTAssertEqual(corners[5], [4, 5, -3])
        XCTAssertEqual(corners[6], [-1, 5, 6])
        XCTAssertEqual(corners[7], [4, 5, 6])
    }
    func testFromCorners() throws {
        let corners: [simd_float3] = [[0, 0, 0], [2, 0, 0], [0, 1, 3], [2, 1, 3],
                                       [0, 3, 0], [2, 3, 0], [0, 4, 3], [2, 4, 3]]
        let result = interactor.from(corners)
        XCTAssertEqual(result.min, [0, 0, 0])
        XCTAssertEqual(result.max, [2, 4, 3])
    }
    func testMergeTheSameBox() throws {
        let zero = PNBound(min: .zero, max: .zero)
        let merged = interactor.merge(zero, rhs: zero)
        XCTAssertEqual(merged.min, .zero)
        XCTAssertEqual(merged.max, .zero)
    }
    func testMergeDisjointBoxes() throws {
        let boundA = PNBound(min: [0, 0, 0], max: [2, 2, 2])
        let boundB = PNBound(min: [-4, -4, -4], max: [-2, -2, -2])
        let merged = interactor.merge(boundA, rhs: boundB)
        XCTAssertEqual(merged.min, [-4, -4, -4])
        XCTAssertEqual(merged.max, [2, 2, 2])
    }
    func testMultiplication() throws {
        let b = PNBound(min: .zero, max: [2, 2, 2])
        let translated = interactor.multiply(simd_float4x4.translation(vector: [1, 2, 3]), b)
        XCTAssertEqual(translated.min, [1, 2, 3])
        XCTAssertEqual(translated.max, [3, 4, 5])
    }
    func testOverlapping() throws {
        let boxA = PNBound(min: [0, 0, 0], max: [2, 2, 2])
        let boxB = PNBound(min: [-2, -2, -2], max: [0.1, 0.1, 0.1])
        XCTAssertTrue(interactor.overlap(boxA, boxB))
    }
    func testNotOverlapping() throws {
        let boxA = PNBound(min: [0, 0, 0], max: [2, 2, 2])
        let boxB = PNBound(min: [-2, -2, -2], max: [-0.1, -0.1, -0.1])
        XCTAssertFalse(interactor.overlap(boxA, boxB))
    }
    func testIsEqualSameValues() throws {
        let a = PNBound(min: .zero, max: .zero)
        let b = PNBound(min: .zero, max: .zero)
        XCTAssertTrue(interactor.isEqual(a, b))
    }
    func testNotEqual() throws {
        let a = PNBound(min: .zero, max: .zero)
        let b = PNBound(min: [1, 1, 1], max: [3, 3, 3])
        XCTAssertFalse(interactor.isEqual(a, b))
    }
    func testCornersCount() throws {
        XCTAssertEqual(interactor.corners(bounds).count, 8)
    }
    func testCornersRoundTrip() throws {
        let result = interactor.from(interactor.corners(bounds))
        XCTAssertEqual(result.min, bounds.min)
        XCTAssertEqual(result.max, bounds.max)
    }
    func testFromCornersUnordered() throws {
        let points: [simd_float3] = [[3, 0, -1], [-2, 5, 4], [1, -3, 0], [0, 2, -5]]
        let result = interactor.from(points)
        XCTAssertEqual(result.min, [-2, -3, -5])
        XCTAssertEqual(result.max, [3, 5, 4])
    }
    func testMultiplyIdentity() throws {
        let result = interactor.multiply(.identity, bounds)
        XCTAssertEqual(result.min, bounds.min)
        XCTAssertEqual(result.max, bounds.max)
    }
    func testMultiplyRotation() throws {
        // 90° rotation around Y: (x,y,z) → (z, y, -x)
        // Bound min=[0,0,0] max=[2,1,3] becomes min=[0,0,-2] max=[3,1,0]
        let b = PNBound(min: [0, 0, 0], max: [2, 1, 3])
        let rotation = simd_float4x4(simd_quatf(angle: .pi / 2, axis: [0, 1, 0]))
        let result = interactor.multiply(rotation, b)
        XCTAssertEqual(result.min.x,  0, accuracy: 1e-5)
        XCTAssertEqual(result.min.y,  0, accuracy: 1e-5)
        XCTAssertEqual(result.min.z, -2, accuracy: 1e-5)
        XCTAssertEqual(result.max.x,  3, accuracy: 1e-5)
        XCTAssertEqual(result.max.y,  1, accuracy: 1e-5)
        XCTAssertEqual(result.max.z,  0, accuracy: 1e-5)
    }
    func testFromInverseProjectionOrthographic() throws {
        let original = PNBound(min: [-5, -3, 0], max: [5, 3, 10])
        let proj = simd_float4x4.orthographicProjection(bound: original)
        let result = interactor.from(inverseProjection: proj.inverse)
        XCTAssertEqual(result.min.x, original.min.x, accuracy: 1e-4)
        XCTAssertEqual(result.min.y, original.min.y, accuracy: 1e-4)
        XCTAssertEqual(result.max.x, original.max.x, accuracy: 1e-4)
        XCTAssertEqual(result.max.y, original.max.y, accuracy: 1e-4)
    }
    func testFromInverseProjectionPerspectiveIsNonDegenerate() throws {
        let proj = simd_float4x4.perspectiveProjectionRightHand(fovyRadians: Float(60).radians,
                                                                 aspect: 16.0 / 9.0,
                                                                 nearZ: 0.1,
                                                                 farZ: 100)
        let result = interactor.from(inverseProjection: proj.inverse)
        XCTAssertLessThan(result.min.x, result.max.x)
        XCTAssertLessThan(result.min.y, result.max.y)
        XCTAssertLessThan(result.min.z, result.max.z)
    }
}
