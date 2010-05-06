//
//  TestAppDelegate.m
//  Test
//
//  Created by Stefan Arentz on 10-05-05.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TestAppDelegate.h"
#import "TestViewController.h"

@implementation TestAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
