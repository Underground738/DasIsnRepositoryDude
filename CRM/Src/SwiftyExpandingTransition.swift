//
//  SwiftyExpandingTransition.swift
//  CRM
//
//  Created by Noel Jander on 15.06.18.
//  Copyright © 2018 Noel Jander. All rights reserved.
//

import Foundation
import UIKit
var selectedCellFrame = CGRect.zero

class SwiftyExpandingTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var operation: UINavigationControllerOperation?
    
    var imageViewTop: UIImageView?
    var imageViewBottom: UIImageView?
    var duration: TimeInterval = 0
//    var selectedCellFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let sourceVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let sourceView = sourceVC.view else { return }
        
        guard let destinationVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        guard let destinationView = destinationVC.view else { return }
        
        let container = transitionContext.containerView
        
        let initialFrame = transitionContext.initialFrame(for: sourceVC)
        let finalFrame = transitionContext.finalFrame(for: destinationVC)
        
        // must set final frame, because it could be (0.0, 64.0, 768.0, 960.0)
        // and the destinationView frame could be (0 0; 768 1024)
        destinationView.frame = finalFrame
        
        
        // deleted Self
        
        selectedCellFrame = CGRect(x: selectedCellFrame.origin.x, y: selectedCellFrame.origin.y + selectedCellFrame.height, width: selectedCellFrame.width, height: selectedCellFrame.height)
        
        let bounds = CGRect(x: 0, y: 0, width: (sourceView.bounds.size.width), height: (sourceView.bounds.size.height))
        
        if self.operation == UINavigationControllerOperation.push {
            UIGraphicsBeginImageContextWithOptions((sourceView.bounds.size), true, 0)
            
            sourceView.drawHierarchy(in: bounds, afterScreenUpdates: false)
            
            guard let snapShot = UIGraphicsGetImageFromCurrentImageContext() else {
                UIGraphicsEndImageContext()
                return
            }
            
            UIGraphicsEndImageContext()
            
            let tempImageRef = snapShot.cgImage!
            let imageSize = snapShot.size
            let imageScale = snapShot.scale
            
            let midPoint = bounds.height / 2
            let selectedFrame = selectedCellFrame.origin.y - (selectedCellFrame.height / 2)
            
            let padding = selectedCellFrame.height * imageScale
            
            var topHeight: CGFloat = 0.0
            var bottomHeight: CGFloat = 0.0
            
            if selectedFrame < midPoint {
                topHeight = selectedCellFrame.origin.y * imageScale
                bottomHeight = (imageSize.height - selectedCellFrame.origin.y) * imageScale
            } else {
                topHeight = (selectedCellFrame.origin.y * imageScale) - padding
                bottomHeight = ((imageSize.height - selectedCellFrame.origin.y) * imageScale) + padding
            }
            
            let topImageRect = CGRect(x: 0, y: 0, width: imageSize.width * imageScale, height: topHeight)
            
            let bottomImageRect = CGRect(x: 0, y: topHeight, width: imageSize.width * imageScale, height: bottomHeight)
            
            let topImageRef = tempImageRef.cropping(to: topImageRect)!
            let bottomImageRef = tempImageRef.cropping(to: bottomImageRect)
            
            self.imageViewTop = UIImageView(image: UIImage(cgImage: topImageRef, scale: snapShot.scale, orientation: UIImageOrientation.up))
            
            if (bottomImageRef != nil) {
                self.imageViewBottom = UIImageView(image: UIImage(cgImage: bottomImageRef!, scale: snapShot.scale, orientation: UIImageOrientation.up))
            }
        }
        
        var startFrameTop = self.imageViewTop!.frame
        var endFrameTop = startFrameTop
        var startFrameBottom = self.imageViewBottom!.frame
        var endFrameBottom = startFrameBottom
        // include any offset if view controllers are not initially at 0 y position
        let yOffset = self.operation == UINavigationControllerOperation.pop ? finalFrame.origin.y : initialFrame.origin.y
        
        if self.operation == UINavigationControllerOperation.pop {
            startFrameTop.origin.y = -startFrameTop.size.height + yOffset
            endFrameTop.origin.y = yOffset
            startFrameBottom.origin.y = startFrameTop.height + startFrameBottom.height + yOffset
            endFrameBottom.origin.y = startFrameTop.height + yOffset
        } else {
            startFrameTop.origin.y = yOffset
            endFrameTop.origin.y = -startFrameTop.size.height + yOffset
            startFrameBottom.origin.y = startFrameTop.size.height + yOffset
            endFrameBottom.origin.y = startFrameTop.height + startFrameBottom.height + yOffset
        }
        
        self.imageViewTop!.frame = startFrameTop
        self.imageViewBottom!.frame = startFrameBottom
        
        destinationView.alpha = 0
        sourceView.alpha = 0
        
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = UIColor.black
        
        if self.operation == UINavigationControllerOperation.pop {
            sourceView.alpha = 1
            
            container.addSubview(backgroundView)
            container.addSubview(sourceView)
            container.addSubview(destinationView)
            container.addSubview(self.imageViewTop!)
            container.addSubview(self.imageViewBottom!)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                self.imageViewTop!.frame = endFrameTop
                self.imageViewBottom!.frame = endFrameBottom
                
                sourceView.alpha = 0
                
            }, completion: { (finish) -> Void in
                self.imageViewTop!.removeFromSuperview()
                self.imageViewBottom!.removeFromSuperview()
                
                destinationView.alpha = 1
                transitionContext.completeTransition(true)
            })
            
        } else {
            container.addSubview(backgroundView)
            container.addSubview(destinationView)
            container.addSubview(self.imageViewTop!)
            container.addSubview(self.imageViewBottom!)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                self.imageViewTop!.frame = endFrameTop
                self.imageViewBottom!.frame = endFrameBottom
                
                destinationView.alpha = 1
                
            }, completion: { (finish) -> Void in
                self.imageViewTop!.removeFromSuperview()
                self.imageViewBottom!.removeFromSuperview()
                
                transitionContext.completeTransition(true)
            })
        }
    }
}
