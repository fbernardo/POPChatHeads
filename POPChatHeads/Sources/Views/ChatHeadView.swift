//
//  ChatHeadView.swift
//  POPChatHeads
//
//  Created by Fábio Bernardo on 08/12/14.
//  Copyright (c) 2014 fbernardo. All rights reserved.
//

import UIKit

class ChatHeadView : UIControl {
    
    var image : UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.7
    }
    
    convenience init(image : UIImage) {
        var rect = CGRectZero
        rect.size = image.size
        self.init(frame: rect)
        self.image = image
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.7
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        let bounds = self.bounds
        let ctx = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(ctx);
        
        let circlePath = CGPathCreateWithEllipseInRect(bounds, nil);
        let inverseCirclePath = CGPathCreateMutableCopy(circlePath)
        CGPathAddRect(inverseCirclePath, nil, CGRectInfinite);
        
        CGContextSaveGState(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddPath(ctx, circlePath);
        CGContextClip(ctx);
        image?.drawInRect(bounds)
        
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddPath(ctx, circlePath);
        CGContextClip(ctx);
        
        let shadowColor = UIColor(red: 0.994, green: 0.989, blue: 1, alpha: 1).CGColor
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3.0, shadowColor);
        
        CGContextBeginPath(ctx);
        CGContextAddPath(ctx, inverseCirclePath);
        CGContextEOFillPath(ctx);
        
        CGContextRestoreGState(ctx);
        
        CGContextRestoreGState(ctx);
    }
    
}
