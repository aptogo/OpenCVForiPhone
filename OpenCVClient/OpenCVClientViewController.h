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
    cv::Mat _lastFrame;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *elapsedTimeLabel;
@property (nonatomic, retain) IBOutlet UISlider *highSlider;
@property (nonatomic, retain) IBOutlet UISlider *lowSlider;
@property (nonatomic, retain) IBOutlet UILabel *highLabel;
@property (nonatomic, retain) IBOutlet UILabel *lowLabel;

- (IBAction)capture:(id)sender;
- (IBAction)sliderChanged:(id)sender;

@end
