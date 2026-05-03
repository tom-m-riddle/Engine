//
//  Copyright © 2025 Mateusz Stompór. All rights reserved.
//

import PNShared

enum PNBoundingBoxCreator {
    private static let interactor = PNIBoundInteractor()
    static func vertices(bounds: [PNBound?]) -> [VertexP] {
        bounds.compactMap { $0 }.map { vertices(bound: $0) }.reduce(+) ?? []
    }
    static private func vertices(bound: PNBound) -> [VertexP] {
        let c = interactor.corners(bound)
        return [
            VertexP(position: c[0]), VertexP(position: c[1]),
            VertexP(position: c[1]), VertexP(position: c[3]),
            VertexP(position: c[1]), VertexP(position: c[2]),
            VertexP(position: c[2]), VertexP(position: c[3]),
            VertexP(position: c[2]), VertexP(position: c[0]),
            VertexP(position: c[3]), VertexP(position: c[0]),
            VertexP(position: c[4]), VertexP(position: c[0]),
            VertexP(position: c[5]), VertexP(position: c[1]),
            VertexP(position: c[6]), VertexP(position: c[2]),
            VertexP(position: c[7]), VertexP(position: c[3]),
            VertexP(position: c[4]), VertexP(position: c[5]),
            VertexP(position: c[5]), VertexP(position: c[7]),
            VertexP(position: c[5]), VertexP(position: c[6]),
            VertexP(position: c[6]), VertexP(position: c[7]),
            VertexP(position: c[6]), VertexP(position: c[4]),
            VertexP(position: c[7]), VertexP(position: c[4])
        ]
    }
}
