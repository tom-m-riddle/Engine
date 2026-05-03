//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import simd

public struct PNIRenderMaskGenerator: PNRenderMaskGenerator {
    private let cullingController: PNCullingController
    init(cullingController: PNCullingController) {
        self.cullingController = cullingController
    }
    public func generate(scene: PNSceneDescription) -> PNRenderMask {
        PNRenderMask(cameras: generateCameraRenderMask(scene: scene),
                     spotLights: generateSpotRenderMasks(scene: scene),
                     omniLights: generateOmniRenderMasks(scene: scene))
    }
    private func generateSpotRenderMasks(scene: PNSceneDescription) -> [[Bool]] {
        scene.spotLights.map { light in
            mask(scene: scene, for: light.idx.int)
        }
    }
    private func generateCameraRenderMask(scene: PNSceneDescription) -> [[Bool]] {
        scene.cameraUniforms.map { cameraUniform in
            mask(scene: scene, for: cameraUniform.index.int)
        }
    }
    private func generateOmniRenderMasks(scene: PNSceneDescription) -> [[Bool]] {
        scene.omniLights.map { light in
            mask(scene: scene, for: light.idx.int)
        }
    }
    private func mask(scene: PNSceneDescription, for index: Int) -> [Bool] {
        guard let bound = scene.bounds[index] else {
            return Array(repeating: false, count: scene.bounds.count)
        }
        return cullingController.cullingMask(scene: scene, bound: bound)
    }
}
