//
//  Copyright © 2022 Mateusz Stompór. All rights reserved.
//

import PNShared

/// A multi-threaded rendering process coordinator.
public class PNIThreadedWorkloadManager: PNWorkloadManager {
    private var renderingCoordinator: PNRenderingCoordinator
    private let transcriber: PNTranscriber
    private let renderMaskGenerator: PNRenderMaskGenerator
    private let dispatchQueue = DispatchQueue.global()
    private let dispatchGroup = DispatchGroup()
    private let nodeUpdate = PNNodeUpdater()
    private var supplies: [PNFrameSupply]
    private var writeIndex = 0
    private let semaphore = DispatchSemaphore(value: 3)
    private var previousFrameScene: PNSceneDescription?
    public init(bufferStores: (PNBufferStore, PNBufferStore, PNBufferStore),
                renderingCoordinator: PNRenderingCoordinator,
                renderMaskGenerator: PNRenderMaskGenerator,
                transcriber: PNTranscriber) {
        self.renderingCoordinator = renderingCoordinator
        self.transcriber = transcriber
        self.renderMaskGenerator = renderMaskGenerator
        supplies = [
            PNFrameSupply(scene: PNSceneDescription(), bufferStore: bufferStores.0, mask: .empty),
            PNFrameSupply(scene: PNSceneDescription(), bufferStore: bufferStores.1, mask: .empty),
            PNFrameSupply(scene: PNSceneDescription(), bufferStore: bufferStores.2, mask: .empty)
        ]
    }
    public func draw(sceneGraph: PNScene, taskQueue: PNRepeatableTaskQueue) {
        semaphore.wait()
        let slotIdx = writeIndex % 3
        let slot = supplies[slotIdx]
        dispatchGroup.enter()
        dispatchQueue.async { [unowned self] in
            let backgroundUpdateInterval = psignposter.beginInterval("Background update")
            taskQueue.execute()
            nodeUpdate.update(rootNode: sceneGraph.rootNode)
            let scene = transcriber.transcribe(scene: sceneGraph)
            if PNDefaults.shared.debug.boundingBoxes {
                let geometry = PNBoundingBoxCreator.vertices(bounds: scene.bounds)
                slot.bufferStore.boundingBoxes.upload(data: geometry)
            }
            slot.bufferStore.matrixPalettes.upload(data: scene.palettes)
            slot.bufferStore.ambientLights.upload(data: scene.ambientLights)
            slot.bufferStore.omniLights.upload(data: scene.omniLights)
            slot.bufferStore.directionalLights.upload(data: scene.directionalLights)
            slot.bufferStore.spotLights.upload(data: scene.spotLights)
            slot.bufferStore.cameras.upload(data: scene.cameraUniforms)
            slot.bufferStore.modelCoordinateSystems.upload(data: scene.uniforms)
            let previous = previousFrameScene ?? scene
            slot.bufferStore.previousMatrixPalettes.upload(data: previous.palettes)
            slot.bufferStore.previousModelCoordinateSystems.upload(data: previous.uniforms)
            supplies[slotIdx] = PNFrameSupply(scene: scene,
                                              bufferStore: slot.bufferStore,
                                              mask: renderMaskGenerator.generate(scene: scene))
            previousFrameScene = scene
            psignposter.endInterval("Background update", backgroundUpdateInterval)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        renderingCoordinator.draw(frameSupply: supplies[slotIdx], onComplete: { [weak self] in self?.semaphore.signal() })
        writeIndex += 1
    }
}
