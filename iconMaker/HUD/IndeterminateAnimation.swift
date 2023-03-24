//
//  IndeterminateAnimation.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/22.
//

import Cocoa

protocol AnimationStatusDelegate {
    func startAnimation()
    func stopAnimation()
}

class IndeterminateAnimation: BaseView, AnimationStatusDelegate {

    /// View is hidden when *animate* property is false
    var displayAfterAnimationEnds: Bool = false

    /**
    Control point for all Indeterminate animation
    True invokes `startAnimation()` on subclass of IndeterminateAnimation
    False invokes `stopAnimation()` on subclass of IndeterminateAnimation
    */
    var animate: Bool = false {
        didSet {
            guard animate != oldValue else { return }
            if animate {
                isHidden = false
                startAnimation()
            } else {
                if !displayAfterAnimationEnds {
                    isHidden = true
                }
                stopAnimation()
            }
        }
    }

    /**
    Every function that extends Indeterminate animation must define startAnimation().
    `animate` property of Indeterminate animation will indynamically invoke the subclass method
    */
    func startAnimation() {
        fatalError("This is an abstract function")
    }

    /**
    Every function that extends Indeterminate animation must define **stopAnimation()**.

    *animate* property of Indeterminate animation will dynamically invoke the subclass method
    */
    func stopAnimation() {
        fatalError("This is an abstract function")
    }
}
