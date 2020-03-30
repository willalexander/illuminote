//
//  AppDelegate.h
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "mainViewController.h"
#import "touchCatcherView.h"


@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    mainViewController *theMainViewController;
    UIView *topLevelView;
    touchCatcherView *baseView;
}


@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
