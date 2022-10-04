//
//  IconButton.swift
//  SMS Virtual
//
//  Created by Alexey Voronov on 16.02.2022.
//

import UIKit


class MButton: UIButton {
    var activityIndicator: UIActivityIndicatorView?
    
    var isLoading: Bool = false {
        didSet {
            isLoading ? showLoading() : hideLoading()
        }
    }
    
    private func showLoading() {
        self.titleLabel?.layer.opacity = 0.0
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }

    private func hideLoading() {
        self.titleLabel?.layer.opacity = 1.0
        activityIndicator?.stopAnimating()
    }

    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        return activityIndicator
    }

    private func showSpinning() {
        if let activity = activityIndicator {
            activity.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(activity)
            centerActivityIndicatorInButton()
            activity.startAnimating()
            activity.color = tintColor
        }
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                UIView.animate(withDuration: 0.1) {
                    self.alpha = 0.5
                }
            }
            else {
                UIView.animate(withDuration: 0.1) {
                    self.alpha = 1.0
                }
            }
            //super.isHighlighted = newValue
        }
    }

}
