//
//  OpenCVClientViewController.h
//  OpenCVClient
//
//  Created by Robin Summerhill on 02/09/2011.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCVClientViewController : UIViewController
{
    cv::VideoCapture *_videoCapture;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;


- (IBAction)capture:(id)sender;

@end
