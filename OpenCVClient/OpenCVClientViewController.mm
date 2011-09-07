//
//  OpenCVClientViewController.m
//  OpenCVClient
//
//  Created by Robin Summerhill on 02/09/2011.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//

// UIImage extensions for converting between UIImage and cv::Mat
#import "UIImage+OpenCV.h"

#import "OpenCVClientViewController.h"

// Aperture value to use for the Canny edge detection
const int kCannyAperture = 7;

@interface OpenCVClientViewController ()
- (void)processFrame;
@end

@implementation OpenCVClientViewController

@synthesize imageView = _imageView;
@synthesize elapsedTimeLabel = _elapsedTimeLabel;
@synthesize highSlider = _highSlider;
@synthesize lowSlider= _lowSlider;
@synthesize highLabel = _highLabel;
@synthesize lowLabel = _lowLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialise video capture - only supported on iOS device NOT simulator
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Video capture is not supported in the simulator");
#else
    _videoCapture = new cv::VideoCapture;
    if (!_videoCapture->open(CV_CAP_AVFOUNDATION))
    {
        NSLog(@"Failed to open video camera");
    }
#endif
    
    // Load a test image and demonstrate conversion between UIImage and cv::Mat
    UIImage *testImage = [UIImage imageNamed:@"testimage.jpg"];
    
    double t;
    int times = 10;
    
    //--------------------------------
    // Convert from UIImage to cv::Mat
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    t = (double)cv::getTickCount();
    
    for (int i = 0; i < times; i++)
    {
        cv::Mat tempMat = [testImage CVMat];
    }
        
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency() / times;
    
    [pool release];
    
    NSLog(@"UIImage to cv::Mat: %gms", t);
    
    //------------------------------------------
    // Convert from UIImage to grayscale cv::Mat
    pool = [[NSAutoreleasePool alloc] init];
    
    t = (double)cv::getTickCount();
    
    for (int i = 0; i < times; i++)
    {
        cv::Mat tempMat = [testImage CVGrayscaleMat];
    }
    
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency() / times;
    
    [pool release];
    
    NSLog(@"UIImage to grayscale cv::Mat: %gms", t);
    
    //--------------------------------
    // Convert from cv::Mat to UIImage
    cv::Mat testMat = [testImage CVMat];

    t = (double)cv::getTickCount();
        
    for (int i = 0; i < times; i++)
    {
        UIImage *tempImage = [[UIImage alloc] initWithCVMat:testMat];
        [tempImage release];
    }
    
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency() / times;
    
    NSLog(@"cv::Mat to UIImage: %gms", t);
    
    // Process test image and force update of UI 
    _lastFrame = testMat;
    [self sliderChanged:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.elapsedTimeLabel = nil;
    self.highLabel = nil;
    self.lowLabel = nil;
    self.highSlider = nil;
    self.lowSlider = nil;

    delete _videoCapture;
    _videoCapture = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Called when the user taps the Capture button. Grab a frame and process it
- (IBAction)capture:(id)sender
{
    if (_videoCapture && _videoCapture->grab())
    {
        (*_videoCapture) >> _lastFrame;
        [self processFrame];
    }
    else
    {
        NSLog(@"Failed to grab frame");        
    }
}

// Perform image processing on the last captured frame and display the results
- (void)processFrame
{
    double t = (double)cv::getTickCount();
    
    cv::Mat grayFrame, output;
  
    // Convert captured frame to grayscale
    cv::cvtColor(_lastFrame, grayFrame, cv::COLOR_RGB2GRAY);
    
    // Perform Canny edge detection using slide values for thresholds
    cv::Canny(grayFrame, output,
              _lowSlider.value * kCannyAperture * kCannyAperture,
              _highSlider.value * kCannyAperture * kCannyAperture,
              kCannyAperture);
    
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    
    // Display result 
    self.imageView.image = [UIImage imageWithCVMat:output];
    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%.1fms", t];
}

// Called when the user changes either of the threshold sliders
- (IBAction)sliderChanged:(id)sender
{
    self.highLabel.text = [NSString stringWithFormat:@"%.0f", self.highSlider.value];
    self.lowLabel.text = [NSString stringWithFormat:@"%.0f", self.lowSlider.value];
    
    [self processFrame];
}

@end
