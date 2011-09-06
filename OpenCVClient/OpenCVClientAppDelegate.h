//
//  OpenCVClientAppDelegate.h
//  OpenCVClient
//
//  Created by Robin Summerhill on 02/09/2011.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenCVClientViewController;

@interface OpenCVClientAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet OpenCVClientViewController *viewController;

@end
