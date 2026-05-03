//
//  Copyright © 2022 Mateusz Stompór. All rights reserved.
//

public struct PNIThreadedWorkloadManagerFactory: PNWorkloadManagerFactory {
    public init() {}
    public func new(bufferStoreFactory: PNBufferStoreFactory,
                    renderingCoordinator: PNRenderingCoordinator,
                    renderMaskGenerator: PNRenderMaskGenerator) -> PNWorkloadManager? {
        guard let bufferStoreA = bufferStoreFactory.new(),
              let bufferStoreB = bufferStoreFactory.new(),
              let bufferStoreC = bufferStoreFactory.new() else {
                  return nil
        }
        return PNIThreadedWorkloadManager(bufferStores: [bufferStoreA,
                                                         bufferStoreB,
                                                         bufferStoreC],
                                          renderingCoordinator: renderingCoordinator,
                                          renderMaskGenerator: renderMaskGenerator,
                                          transcriber: PNITranscriber.default)
    }
}
