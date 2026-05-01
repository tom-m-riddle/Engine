//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders
import os.signpost
import simd

struct PNIRenderingCoordinator: PNRenderingCoordinator {
    private let commandQueue: MTLCommandQueue
    private var pipeline: PNPipeline
    init?(view metalView: MTKView, renderingSize: CGSize) {
        guard let device = metalView.device,
              let commandQueue = device.makeCommandQueue(),
              let pipeline = PNPipeline(device: device,
                                        renderingSize: renderingSize,
                                        view: metalView) else {
            return nil
        }
        self.pipeline = pipeline
        self.commandQueue = commandQueue
    }
    mutating func draw(frameSupply: PNFrameSupply, onComplete: @escaping () -> Void) {
        guard frameSupply.scene.activeCameraIdx != .nil else {
            onComplete()
            return
        }
        let encodingInterval = psignposter.beginInterval("Frame encoding")
        pipeline.draw(commandQueue: commandQueue, supply: frameSupply, onComplete: onComplete)
        psignposter.endInterval("Frame encoding", encodingInterval)
    }
}
