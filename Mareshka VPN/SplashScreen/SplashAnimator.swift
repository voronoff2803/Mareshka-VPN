//
//  SplashAnimator.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 31.08.2022.
//

import UIKit

protocol SplashAnimatorDescription {
    func animateAppearance()
    func animateDisappearance(completion: (() -> ())?)
}


class SplashAnimator: SplashAnimatorDescription {
    private unowned let foregroundSplashWindow: UIWindow
    private unowned let foregroundSplashViewController: SplashViewController
    private unowned let backgroundSplashWindow: UIWindow
    private unowned let backgroundSplashViewController: SplashViewController
    
    init(foregroundSplashWindow: UIWindow, backgroundSplashWindow: UIWindow) {
        self.foregroundSplashWindow = foregroundSplashWindow
        self.backgroundSplashWindow = backgroundSplashWindow
        
        guard let foregroundSplashViewController = foregroundSplashWindow.rootViewController as? SplashViewController else { fatalError("SplashAnimatorDescription") }
        guard let backgroundSplashViewController = backgroundSplashWindow.rootViewController as? SplashViewController else { fatalError("SplashAnimatorDescription") }
        
        self.foregroundSplashViewController = foregroundSplashViewController
        self.backgroundSplashViewController = backgroundSplashViewController
    }
    
    func animateAppearance() {
        foregroundSplashWindow.isHidden = false
        backgroundSplashWindow.isHidden = false
        
        foregroundSplashViewController.textLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.3, delay: 0.15) {
            self.foregroundSplashViewController.textLabel.transform = .identity
        }
        
        foregroundSplashViewController.textLabel.alpha = 0
        UIView.animate(withDuration: 0.15, delay: 0.15) {
            self.foregroundSplashViewController.textLabel.alpha = 1.0
        }
    }
    
    func animateDisappearance(completion: (() -> ())?) {
        guard let window = UIApplication.shared.delegate?.window, let mainWindow = window else { return }
        
        foregroundSplashWindow.alpha = 0
        backgroundSplashWindow.isHidden = false
        
        let mask = CALayer()
        mask.frame = foregroundSplashViewController.logoImageView.frame
        mask.contents = SplashViewController.logoMask.cgImage
        mainWindow.layer.mask = mask
        
        let maskImageView = UIImageView(image: SplashViewController.logoImage)
        maskImageView.frame = mask.frame
        mainWindow.addSubview(maskImageView)
        mainWindow.bringSubviewToFront(maskImageView)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            mainWindow.layer.mask = nil
            completion?()
        }
        
        mainWindow.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        UIView.animate(withDuration: 0.6) {
            mainWindow.transform = .identity
        }
        
        [mask, maskImageView.layer].forEach {
            addScalingAnimation(to: $0, duration: 0.6)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.15, options: []) {
            maskImageView.alpha = 0
        } completion: { _ in
            maskImageView.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundSplashViewController.textLabel.alpha = 0
        }
        
        CATransaction.commit()
    }
    
    
    func addScalingAnimation(to layer: CALayer, duration: TimeInterval) {
        let animation = CAKeyframeAnimation(keyPath: "bounds")
        let width = layer.frame.width
        let height = layer.frame.height
        
        let finalScale = UIScreen.main.bounds.height / 80 + 10
        print(finalScale)
        let scales = [1, 0.85, finalScale]
        
        animation.beginTime = CACurrentMediaTime()
        animation.duration = duration
        animation.values = scales.map { NSValue(cgRect: CGRect(x: 0, y: 0, width: width * $0, height: height * $0))}
        animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut),
                                     CAMediaTimingFunction(name: .easeOut)]
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        layer.add(animation, forKey: "bounds")
                                               
    }
    
    
}
