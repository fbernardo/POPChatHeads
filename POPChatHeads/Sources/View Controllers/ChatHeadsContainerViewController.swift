//
//  ChatHeadsContainerViewController.swift
//  POPChatHeads
//
//  Created by Fábio Bernardo on 08/12/14.
//  Copyright (c) 2014 fbernardo. All rights reserved.
//

import UIKit

var AssociatedViewHandle: UInt8 = 0

struct ChatHead {
    let name : String
    let image : UIImage
}

extension CGPoint {
    var absoluteValue : CGFloat {
        return sqrt(x*x + y*y)
    }
}

class ChatHeadsContainerViewController : UIViewController, POPAnimationDelegate {
    
    //MARK: Properties
    
    private var chatHeads : [ChatHead] = []
    
    var childViewController : UIViewController? {
        didSet {
            oldValue?.willMoveToParentViewController(nil)
            if let newChildViewController = childViewController {
                let newView = newChildViewController.view
                newView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                self.addChildViewController(newChildViewController)
                self.view.addSubview(newView)
                newChildViewController.didMoveToParentViewController(self)
            }
            oldValue?.removeFromParentViewController()
        }
    }
    
    //MARK: UIViewController
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return childViewController
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return childViewController
    }
    
    //MARK: Public Methods
    
    func addChatHead(chatHead : ChatHead) {
        let count = chatHeads.count
        chatHeads.append(chatHead)
        
        self.view.addSubview(self.createChatHeadView(chatHead.image, center: self.view.center))
    }
    
    func removeChatHead(index : Int) {
        chatHeads.removeAtIndex(index)
    }
    
    func removeChatHead(name : String) {
        for (var i = 0; i < chatHeads.count; i++) {
            if chatHeads[i].name == name {
                self.removeChatHead(i)
                break;
            }
        }
    }
    
    //MARK: Actions
    
    dynamic private func touchDown(sender : ChatHeadView) {
        sender.pop_removeAllAnimations()
        
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation.toValue = NSValue(CGSize: CGSizeMake(0.9, 0.9))
        scaleAnimation.springBounciness = 10;
        scaleAnimation.removedOnCompletion = false
        sender.pop_addAnimation(scaleAnimation, forKey: "scaleAnimation")
    }
    
    dynamic private func touchUpInside(sender : ChatHeadView) {
        if let scaleAnimation = sender.pop_animationForKey("scaleAnimation") as? POPPropertyAnimation {
            scaleAnimation.toValue = NSValue(CGSize: CGSizeMake(1, 1))
            scaleAnimation.removedOnCompletion = true
        }
    }
    
    dynamic private func handlePan(sender : UIPanGestureRecognizer) {
        let chatHeadView = sender.view as ChatHeadView
        
        if let scaleAnimation = chatHeadView.pop_animationForKey("scaleAnimation") as? POPPropertyAnimation {
            scaleAnimation.toValue = NSValue(CGSize: CGSizeMake(1, 1))
            scaleAnimation.removedOnCompletion = true
        }
        
        let translation = sender.translationInView(self.view)
        chatHeadView.center = CGPointMake(chatHeadView.center.x + translation.x, chatHeadView.center.y + translation.y)
        sender.setTranslation(CGPointMake(0, 0), inView: self.view)
        
        if sender.state == .Ended {
            var velocity = sender.velocityInView(self.view)
            
            let positionAnimation = POPDecayAnimation(propertyNamed: kPOPViewCenter)
            objc_setAssociatedObject(positionAnimation, &AssociatedViewHandle, chatHeadView, objc_AssociationPolicy(OBJC_ASSOCIATION_ASSIGN))
            positionAnimation.velocity = NSValue(CGPoint: velocity)
            positionAnimation.delegate = self
            
            chatHeadView.pop_addAnimation(positionAnimation, forKey: "layerPositionAnimation")
            
        }
    }
    
    //MARK: POPAnimationDelegate
    
    func pop_animationDidApply(anim: POPAnimation!) {
        let decayAnimation = anim as POPDecayAnimation
        let view = objc_getAssociatedObject(anim, &AssociatedViewHandle) as UIView
        let frame = view.frame
        let halfHeight = frame.height / 2
        let halfWidth = frame.width / 2
        let center = CGPoint(x: frame.midX, y: frame.midY)
        
        let snapRectangle = UIEdgeInsetsInsetRect(
            self.view.bounds, UIEdgeInsets(top: halfHeight, left: halfWidth, bottom: halfHeight, right: halfWidth)
        )
        
        let isOutsideEdges = !CGRectContainsPoint(snapRectangle, center)
        
        let originalVelocity = decayAnimation.originalVelocity.CGPointValue()
        let currentVelocity = decayAnimation.velocity.CGPointValue()
        
        
        if (isOutsideEdges || currentVelocity.absoluteValue < 400 || currentVelocity.absoluteValue < originalVelocity.absoluteValue * 0.8) {
            view.pop_removeAnimationForKey("layerPositionAnimation")
            
            let leftDiff = abs(center.x - snapRectangle.minX)
            let rightDiff = abs(snapRectangle.maxX - center.x)
            
            let springAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            springAnimation.velocity = decayAnimation.velocity
            
            let y = min(max(snapRectangle.minY, center.y), snapRectangle.maxY)
            
            if (leftDiff < rightDiff) {
                springAnimation.toValue = NSValue(CGPoint: CGPointMake(snapRectangle.minX, y))
            } else {
                springAnimation.toValue = NSValue(CGPoint: CGPointMake(snapRectangle.maxX, y))
            }
            
            view.pop_addAnimation(springAnimation, forKey: "springAnimation")
        }
    }
    
    //MARK: Private Methods
    
    private func createChatHeadView(image: UIImage, center: CGPoint) -> ChatHeadView {
        var frame = CGRectMake(center.x - 32, center.y - 32, 64, 64)
        let chatHeadView = ChatHeadView(frame: frame)
        chatHeadView.image = image
        chatHeadView.backgroundColor = UIColor.clearColor()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        
        chatHeadView.addTarget(self, action: "touchDown:", forControlEvents: UIControlEvents.TouchDown);
        chatHeadView.addTarget(self, action: "touchUpInside:", forControlEvents: UIControlEvents.TouchUpInside);
        chatHeadView.addGestureRecognizer(panGestureRecognizer)
        
        return chatHeadView
    }
    
}

extension UIViewController {
    
    func chatHeadsContainerViewController() -> ChatHeadsContainerViewController? {
        if self is ChatHeadsContainerViewController {
            return (self as ChatHeadsContainerViewController)
        }
        return self.parentViewController?.chatHeadsContainerViewController()
    }
    
}