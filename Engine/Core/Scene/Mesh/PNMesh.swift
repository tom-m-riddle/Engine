//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

/// Mesh is a 3D object representation consisting of a collection of vertices and polygons.
public final class PNMesh {
    /// The spatial bounds that encapsulate the mesh.
    public let bound: PNBound
    /// Buffer containing the vertex data used to render the mesh.
    public let vertexBuffer: PNDataBuffer
    /// Descriptions of the individual segments of the mesh.
    public var pieceDescriptions: [PNPieceDescription]
    /// Initializes a mesh with bounds, vertex buffer, and piece descriptions.
    public init(bound: PNBound,
                vertexBuffer: PNDataBuffer,
                pieceDescriptions: [PNPieceDescription]) {
        self.bound = bound
        self.vertexBuffer = vertexBuffer
        self.pieceDescriptions = pieceDescriptions
    }
}
