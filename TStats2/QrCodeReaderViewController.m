//
//  QrCodeReaderViewController.m
//  TStats2
//
/*
 Created by toolstatsdev on 4/19/15.
 Copyright (c) 2015 ToolStats All rights reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "QrCodeReaderViewController.h"
@import AVFoundation;
#import "QrOutlineView.h"
#import "ProjectMenuViewController.h"
#import "AppDelegateProtocol.h"
#import "BarCodeObjects.h"
#import "ScanDatabase.h"

@interface QrCodeReaderViewController() <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureVideoPreviewLayer *_previewLayer;
    QrOutlineView *_boundingBox;
    NSTimer *_boxHideTimer;
    UILabel *_decodedMessage;
    UIImageView *_targetImage;
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) NSString *scanResult;
@property (weak, nonatomic) IBOutlet UIView *bottomMaskView;
@property (weak, nonatomic) IBOutlet UIView *topMaskView;
@property (weak, nonatomic) IBOutlet UILabel *topMaskLabel;
@property (weak, nonatomic) IBOutlet UIButton *topMaskButton;


- (void)loadBeepSound;

@end

@implementation QrCodeReaderViewController
@synthesize session;

-(NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationPortrait;
    //return UIInterfaceOrientationUnknown;
    return UIInterfaceOrientationMaskPortrait;
}

BarCodeObjects* theDataObject;
ScanDatabase* db;

/*
 * Returns BarCodeObjects instance.
 */
- (BarCodeObjects *) theAppDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    BarCodeObjects* theDataObject;
    theDataObject = (BarCodeObjects*) theDelegate.theAppDataObject;
    return theDataObject;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // here we hide the top and bottom alert mask view
    _bottomMaskView.hidden = YES;
    _topMaskView.hidden = YES;
    
    // here we unhide the navigationbar from the previous page
    [self.navigationController setNavigationBarHidden:NO];
    // here we make the navigation bar clear
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    //self.navigationController.navigationBar.alpha = 0.5f;
    //self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    // here we unhide the lower navigation controller
    [self.navigationController setToolbarHidden:YES];
    
    [self loadBeepSound];
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm2.png"]];
    
    //[[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];

    if (![self startReading]) {
        [self startReading];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    //to do
    
    // here we hide the top and bottom alert mask view
    _bottomMaskView.hidden = YES;
    _topMaskView.hidden = YES;
}

-(BOOL)startReading {
    // Create a new AVCaptureSession
    //AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session = [[AVCaptureSession alloc]init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // Want the normal device
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) {
        // Add the input to the session
        [session addInput:input];
    } else {
        NSLog(@"error: %@", error);
        return NO;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [session addOutput:output];
    // What different things can we register to recognise?
    NSLog(@"%@", [output availableMetadataObjectTypes]);
    // We're only interested in QR Codes
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // This VC is the delegate. Please call us on the main queue
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Display on screen
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.bounds = self.view.bounds;
    _previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:_previewLayer];
    
    
    // Add the view to draw the bounding box for the UIView
    _boundingBox = [[QrOutlineView alloc] initWithFrame:self.view.bounds];
    _boundingBox.backgroundColor = [UIColor clearColor];
    _boundingBox.hidden = YES;
    [self.view addSubview:_boundingBox];
    
    // Add a label to display the resultant message
    _decodedMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 75, CGRectGetWidth(self.view.bounds), 75)];
    _decodedMessage.numberOfLines = 0;
    _decodedMessage.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];
    _decodedMessage.textColor = [UIColor darkGrayColor];
    _decodedMessage.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:_decodedMessage];
    
    // here we add, center, and auto-fix margins programmatically for "target" image
    //_targetImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lens_target.png"]];
    _targetImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolstats_target1.png"]];
    _targetImage.center = self.view.center;
    _targetImage.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleRightMargin|
                                  UIViewAutoresizingFlexibleTopMargin  |
                                  UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:_targetImage];
    // end test
    
    // Start the AVSession running
    [session startRunning];
    return YES;
}

- (IBAction)start:(id)sender {
    //if (![self startReading]) {
        [self startReading];
    //}
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Transform the meta-data coordinates to screen coords
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:metadata];
            // Update the frame on the _boundingBox view, and show it
            _boundingBox.frame = transformed.bounds;
            _boundingBox.hidden = NO;
            // Now convert the corners array into CGPoints in the coordinate system
            //  of the bounding box itself
            NSArray *translatedCorners = [self translatePoints:transformed.corners
                                                      fromView:self.view
                                                        toView:_boundingBox];
            
            // Set the corners array
            _boundingBox.corners = translatedCorners;
            
            // Update the view with the decoded text
            _decodedMessage.text = [transformed stringValue];
            
            // Start the timer which will hide the overlay
            //[self startOverlayHideTimer];
            [session stopRunning];
            //[self performSegueWithIdentifier:@"ShowTestPageView" sender:self];
            
            
            // Play the beep
            if (_audioPlayer) {
                [_audioPlayer play];
            }
            
            [self parseDecodedMessage:_decodedMessage.text];
        }
    }
}

#pragma mark - Utility Methods
- (void)startOverlayHideTimer
{
    // Cancel it if we're already running
    if(_boxHideTimer) {
        [_boxHideTimer invalidate];
    }
    
    // Restart it to hide the overlay when it fires
    _boxHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                     target:self
                                                   selector:@selector(removeBoundingBox:)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)removeBoundingBox:(id)sender
{
    // Hide the box and remove the decoded text
    _boundingBox.hidden = YES;
    _decodedMessage.text = @"";
}

- (NSArray *)translatePoints:(NSArray *)points fromView:(UIView *)fromView toView:(UIView *)toView
{
    NSMutableArray *translatedPoints = [NSMutableArray new];
    
    // The points are provided in a dictionary with keys X and Y
    for (NSDictionary *point in points) {
        // Let's turn them into CGPoints
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        // Now translate from one view to the other
        CGPoint translatedPoint = [fromView convertPoint:pointValue toView:toView];
        // Box them up and add to the array
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    
    return [translatedPoints copy];
}

#pragma mark - Handle Page Orientation for AV Capture
- (void)viewWillLayoutSubviews {
    _previewLayer.frame = self.view.bounds;
    if (_previewLayer.connection.supportsVideoOrientation) {
        _previewLayer.connection.videoOrientation = [self interfaceOrientationToVideoOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
}

- (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            break;
    }
    NSLog(@"Warning - Didn't recognise interface orientation (%d)",orientation);
    return AVCaptureVideoOrientationPortrait;
}


// here we implement method to stop scanning
- (void) stopReading {
    //[self.indicator startAnimating];
    [session stopRunning];
    session = nil;
    
    //[_previewLayer removeFromSuperlayer];
}

// here we get relevent information form the QR code
- (void)parseDecodedMessage:(NSString *)message {
    
    NSLog(@"%@",message); // for testing
    
    // here we look for "projectno" (case insensitive) in the scanned string
    if ([[message lowercaseString] rangeOfString:@"projectno="].location == NSNotFound)
    {
        
        // todo if project number not found
        NSLog(@"Toolmaker Project information not available");
        
        self.navigationItem.hidesBackButton = YES;
        
        // here we build the view to show if data posted to databse
        // Hide the box and remove the decoded text
        _boundingBox.hidden = YES;
        [_previewLayer removeFromSuperlayer];
        [_targetImage removeFromSuperview]; // here we remove the lens_target view from the display
        _bottomMaskView.hidden = NO;
        _topMaskView.hidden = NO;
        _topMaskView.layer.cornerRadius = 10;
        _topMaskButton.layer.cornerRadius = 10;
        _topMaskButton.layer.borderColor = [UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1].CGColor;
        _topMaskButton.layer.borderWidth = 1;
        
        _topMaskLabel.text = @"Toolmaker Project information is not available";
        [self.view addSubview:_decodedMessage];
    }
    else
    {
        
        // todo if "projectno" found"
        NSScanner *scanner = [NSScanner scannerWithString:message];
        NSString *prefix = @"projectno=";
        NSString *numbers;
        [scanner scanUpToString:prefix intoString:NULL];
        [scanner scanString:prefix intoString:NULL];
        [scanner scanUpToCharactersFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet] intoString:&numbers];
        
        NSLog(@"numbers: %@",numbers); // for testing
        self.scanResult = numbers;
        
        // here we set the project number in the database
        theDataObject.projectNo = self.scanResult;
        
        // here we set the date
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
        
        NSDate *now = [[NSDate alloc]init];
        NSString *theDate = [dateFormat stringFromDate:now];
        
        theDataObject.date   = theDate;
        
        // here we set values similarly to the orig app
        theDataObject.isHistory = FALSE;
        theDataObject.isReason = FALSE;
        
        bool isSuccess = [db saveData];
        
        if (isSuccess) {
            
            /*
            // here we add a delay method - this has been replaced by the goToNextView method below
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(),^(void){
                // here we move to next view since we found the project number
                [self performSegueWithIdentifier:@"ShowProjectMenuView" sender:self];
            });
             */
            [self performSelector:@selector(goToNextView) withObject:nil afterDelay:0.5];
        }
    }
}

- (void)goToNextView {
    [self performSegueWithIdentifier:@"ShowProjectMenuView" sender:self];
}

// here we implement sound
- (void) loadBeepSound {
    //NSString *beepFilePath = [[NSBundle mainBundle]pathForResource:@"beep" ofType:@"mp3"];
    NSString * beepFilePath = [[NSBundle mainBundle]pathForResource:@"BeepV6" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        [_audioPlayer prepareToPlay];
    }
    
}


///*
#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowProjectMenuView"]) {
        
        ProjectMenuViewController *projectMenuVC = (ProjectMenuViewController *)[segue destinationViewController];
        projectMenuVC.projectNumber = self.scanResult;
    }
}
//*/

- (IBAction)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
