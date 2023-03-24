//
//  HUD.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/22.
//

import Cocoa

class HUD: IndeterminateAnimation {
    class func show() {
        if let window = appKeyWindow, let superView = window.contentViewController?.view {
            let hud = HUD(frame: superView.bounds)
            superView.addSubview(hud)
            hud.background = .black.withAlphaComponent(0.7)
            hud.foreground = .white
            hud.startAnimation()
            hud.clockwise = false
            
            hud.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    class func dismiss() {
        if let window = appKeyWindow, let superView = window.contentViewController?.view {
            superView.subviews.forEach { subView in
                if let sub = subView as? HUD {
                    sub.stopAnimation()
                    sub.removeFromSuperview()
                }
            }
        }
    }
    
    var basicShape = CAShapeLayer()
    var containerLayer = CAShapeLayer()
    var starList = [CAShapeLayer]()
    
    var animation: CAKeyframeAnimation = {
        var animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.repeatCount = .infinity
        animation.calculationMode = .discrete
        return animation
    }()

    var starSize:CGSize = CGSize(width: 6, height: 15) {
        didSet {
            notifyViewRedesigned()
        }
    }

    var roundedCorners: Bool = true {
        didSet {
            notifyViewRedesigned()
        }
    }

    
    var distance: CGFloat = CGFloat(20) {
        didSet {
            notifyViewRedesigned()
        }
    }

    var starCount: Int = 10 {
        didSet {
            notifyViewRedesigned()
        }
    }

    var duration: Double = 1 {
        didSet {
            animation.duration = duration
        }
    }

    var clockwise: Bool = false {
        didSet {
            notifyViewRedesigned()
        }
    }

    override func configureLayers() {
        super.configureLayers()
        
        containerLayer.frame = bounds
        containerLayer.cornerRadius = frame.width / 2
        layer?.addSublayer(containerLayer)
        
        animation.duration = duration
    }
    
    override func notifyViewRedesigned() {
        super.notifyViewRedesigned()
        starList.removeAll(keepingCapacity: true)
        containerLayer.sublayers = nil
        animation.values = [Double]()
        
        var i = 0.0
        while i < 360 {
            var iRadian = CGFloat(i * Double.pi / 180.0)
            if clockwise { iRadian = -iRadian }

            animation.values?.append(iRadian)
            let starShape = CAShapeLayer()
            starShape.cornerRadius = roundedCorners ? starSize.width / 2 : 0
            
            let centerLocation = CGPoint(x: frame.width / 2 - starSize.width / 2, y: frame.height / 2 - starSize.height / 2)

            starShape.frame = CGRect(origin: centerLocation, size: starSize)

            starShape.backgroundColor = foreground.cgColor
            starShape.anchorPoint = CGPoint(x: 0.5, y: 0)

            var  rotation: CATransform3D = CATransform3DMakeTranslation(0, 0, 0.0);

            rotation = CATransform3DRotate(rotation, -iRadian, 0.0, 0.0, 1.0);
            rotation = CATransform3DTranslate(rotation, 0, distance, 0.0);
            starShape.transform = rotation

            starShape.opacity = Float(360 - i) / 360
            containerLayer.addSublayer(starShape)
            starList.append(starShape)
            i = i + Double(360 / starCount)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        print(#function)
    }

    override func startAnimation() {
        containerLayer.add(animation, forKey: "rotation")
    }
    
    override func stopAnimation() {
        containerLayer.removeAllAnimations()
    }
}

