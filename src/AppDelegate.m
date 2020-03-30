//
//  AppDelegate.m
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window setBackgroundColor: [UIColor blackColor]];
    
   
    /*main view controller contains both of these views, and query the orientation:*/
    theMainViewController = [[mainViewController alloc] init];
    UIDeviceOrientation initOrientation = [theMainViewController interfaceOrientation];
    
    /*the base view, 'touchCatcherView's the meat of the app - this view handles and controls everything*/
    baseView = [[touchCatcherView alloc] initWithFrame: CGRectMake(-256, 0, 1024, 1004) andInitialOrientation: initOrientation];
    
    
    /*basic, empty view is the window's top level view: (this is necessary for correct handling of device orientation)*/
    topLevelView = [[UIView alloc] initWithFrame: CGRectMake(0, 20, 768, 1004)];
    [topLevelView setBackgroundColor: [UIColor blackColor]];
    [topLevelView setAutoresizesSubviews: YES];
    [topLevelView addSubview: baseView];
    
    
    
    /*view controller contains both of these views:*/
    [theMainViewController setView: topLevelView];
    [theMainViewController setMainView: baseView];
    [baseView setMyViewController: theMainViewController];
    
    
    [self.window setRootViewController: theMainViewController];
    [self.window addSubview: [theMainViewController view]];
    
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    /*notify the base view that the app with resign active:*/
    [baseView appWillResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [baseView removeFromSuperview];
    [theMainViewController release];
    
    [baseView preDealloc];
    [baseView release];
    
    [topLevelView removeFromSuperview];
    [topLevelView release];
    
    
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (void)dealloc
{  
}

@end
