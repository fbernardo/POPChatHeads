//
//  AppDelegate.swift
//  POPChatHeads
//
//  Created by Fábio Bernardo on 09/12/14.
//  Copyright (c) 2014 fbernardo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow!


    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let chatHeadsContainerViewController = ChatHeadsContainerViewController()
        window.rootViewController = chatHeadsContainerViewController
        
        chatHeadsContainerViewController.childViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as?UIViewController
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window.makeKeyAndVisible()
        
        let chatHead = ChatHead(name: "D", image : UIImage(named: "avatar")!)
        window.rootViewController?.chatHeadsContainerViewController()?.addChatHead(chatHead)
        
        return true
    }
    
}

