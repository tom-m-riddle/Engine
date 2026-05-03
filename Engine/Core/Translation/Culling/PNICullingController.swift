//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

import PNShared

struct PNICullingController: PNCullingController {
    private let interactor: PNBoundInteractor
    init(interactor: PNBoundInteractor) {
        self.interactor = interactor
    }
    func cullingMask(scene: PNSceneDescription, bound: PNBound) -> [Bool] {
        scene.bounds.indices.map {
            if let box = scene.bounds[$0] {
                return interactor.overlap(box, bound)
            } else {
                return true
            }
        }
    }
}
