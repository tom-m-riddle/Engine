//
//  Copyright © 2021 Mateusz Stompór. All rights reserved.
//

protocol PNCullingController {
    func cullingMask(scene: PNSceneDescription, bound: PNBound) -> [Bool]
}
