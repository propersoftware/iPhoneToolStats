//
//  QrCodeScanViewController.m
//  TStats2
//
//  Created by anwosu on 4/8/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "QrCodeScanViewController.h"
#import "ProjectMenuViewController.h"
#import "AppDelegateProtocol.h"
#import "BarCodeObjects.h"
#import "ScanDatabase.h"

@interface QrCodeScanViewController ()

@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSString *scanResult;
@property (weak, nonatomic) IBOutlet UILabel *targetLabel;

-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;

@end

@implementation QrCodeScanViewController {
    // fix for multiple segue
    int counter;
}

BarCodeObjects* theDataObject;
ScanDatabase*  db;

/*
 * Returns BarcodeObjects instance.
 */
- (BarCodeObjects*) theAppDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    BarCodeObjects* theDataObject;
    theDataObject = (BarCodeObjects*) theDelegate.theAppDataObject;
    return theDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // here we unhide the navigationbar from the previous page
    [self.navigationController setNavigationBarHidden:NO];
    
    counter = 0;
    // here we unhide the lower navigation controller
    [self.navigationController setToolbarHidden:NO];
    
    _isReading = NO;
    _captureSession = nil;
    
    [self loadBeepSound];
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm2.png"]];
    
//    _targetLabel.layer.borderColor = [UIColor colorWithRed: 0.0 green: 1.0 blue: 0.0 alpha: 1].CGColor;
//    _targetLabel.layer.borderWidth = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    // here we make sure the lower navigation controller is hidden
    [self.navigationController setToolbarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startStopReading:(id)sender {
    if(!_isReading) {
        if([self startReading]) {
            [_bbitemStart setTitle:@"Stop"];
            [_lblStatus setText:@"Scanning for QR Code..."];
        }
    }
    else {
        [self stopReading];
        [_bbitemStart setTitle:@"Start!"];
        //[_lblStatus setText:@"Scan stopped..."];
    }
    
    _isReading = !_isReading;
}

- (BOOL) startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    ///*
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    //*/
    
    
    [_captureSession startRunning];
    
    return YES;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //
    self.bbitemStart.enabled = NO;
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        
        //NSLog(@"what is going on?");
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type]isEqualToString:AVMetadataObjectTypeQRCode])
        {
            //[_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
            //NSLog(@"%@",[metadataObj stringValue]); //for testing
            
            //--
            NSString *myString = [metadataObj stringValue];
            
            NSLog(@"%@",myString); // for testing
            
            // here we look for "projectno" (case insensitive) in the scanned string
            if ([[myString lowercaseString] rangeOfString:@"projectno="].location == NSNotFound)
            {
                
                // todo if project number not found
                NSLog(@"Toolmaker Project information not available");
            }
            else
            {

                // todo if "projectno" found"
                NSScanner *scanner = [NSScanner scannerWithString:myString];
                NSString *prefix = @"projectno=";
                NSString *numbers;
                [scanner scanUpToString:prefix intoString:NULL];
                [scanner scanString:prefix intoString:NULL];
                [scanner scanUpToCharactersFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet] intoString:&numbers];
                
                NSLog(@"numbers: %@",numbers); // for testing
                self.scanResult = numbers;
                
                // here we stop scanning
                [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
                [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
                _isReading = NO;
                
                if (_audioPlayer)
                {
                    [_audioPlayer play];
                }
                // here we assign the project number to the scan result - then call segue
                //[self performSegueWithIdentifier:@"ShowProjectMenuView" sender:self];
                counter++;
                NSLog(@"Counter is:%d",counter);
                
                // temp fix to multiple segue
                if (counter == 1)
                {
                    [self gotoNextView];
                    //[self performSegueWithIdentifier:@"ShowProjectMenuView" sender:self];
                }
                
            }
        }
    }
}


- (void) gotoNextView {
    //[self.indicator stopAnimating];
    [self performSegueWithIdentifier:@"ShowProjectMenuView" sender:self];
    //ProjectMenuViewController *projectMenuVC = [[ProjectMenuViewController alloc]init];
    //[self.navigationController pushViewController:projectMenuVC animated:YES];
}

- (void) stopReading {
    //[self.indicator startAnimating];
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void) loadBeepSound {
    NSString *beepFilePath = [[NSBundle mainBundle]pathForResource:@"beep" ofType:@"mp3"];
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


// here we employ the two methods below to handle the page orientation problem when scanning QR code
- (void)viewWillLayoutSubviews {
    _videoPreviewLayer.frame = self.view.bounds;
    if (_videoPreviewLayer.connection.supportsVideoOrientation) {
        _videoPreviewLayer.connection.videoOrientation = [self interfaceOrientationToVideoOrientation:[UIApplication sharedApplication].statusBarOrientation];
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

///*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    bool isSuccess = [db saveData];
    
    if (isSuccess) {
        
        if ([segue.identifier isEqualToString:@"ShowProjectMenuView"])
        {
            
            // here we set the project number in the database
            theDataObject.projectNo = self.scanResult;
            
            // here we set the date
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
            
            NSDate *now = [[NSDate alloc] init];
            
            NSString *theDate = [dateFormat stringFromDate:now];
            
            theDataObject.date = theDate;
            
            // here we set values similarly to the orig app
            theDataObject.isHistory = FALSE;
            theDataObject.isReason = FALSE;
            
            // here we can pass data forward to the next view contorller by using the "destinationViewController" property of UIViewController.
            ProjectMenuViewController *projectMenuVC = (ProjectMenuViewController *)[segue destinationViewController];
            projectMenuVC.projectNumber = self.scanResult;
        }
    }
}
//*/


#pragma mark - Utility Methods

@end
