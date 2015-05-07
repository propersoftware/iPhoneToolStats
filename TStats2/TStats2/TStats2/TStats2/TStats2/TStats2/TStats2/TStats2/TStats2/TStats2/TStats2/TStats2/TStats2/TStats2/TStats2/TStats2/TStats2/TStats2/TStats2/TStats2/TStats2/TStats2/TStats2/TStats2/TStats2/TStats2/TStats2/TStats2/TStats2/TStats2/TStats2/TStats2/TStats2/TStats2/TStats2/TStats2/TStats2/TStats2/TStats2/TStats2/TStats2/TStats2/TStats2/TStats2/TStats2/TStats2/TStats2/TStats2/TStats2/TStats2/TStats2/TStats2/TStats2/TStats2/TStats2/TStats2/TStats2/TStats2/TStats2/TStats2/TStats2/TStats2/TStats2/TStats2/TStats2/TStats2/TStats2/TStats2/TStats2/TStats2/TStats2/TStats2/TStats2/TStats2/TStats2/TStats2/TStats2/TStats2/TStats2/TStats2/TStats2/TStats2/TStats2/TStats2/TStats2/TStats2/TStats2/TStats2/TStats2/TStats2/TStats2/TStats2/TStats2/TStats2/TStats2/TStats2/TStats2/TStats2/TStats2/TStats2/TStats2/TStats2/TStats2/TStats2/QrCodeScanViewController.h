//
//  QrCodeScanViewController.h
//  TStats2
//
//  Created by anwosu on 4/8/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ProjectMenuViewController.h"

@interface QrCodeScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate> //, ProjectMenuViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbitemStart;

- (IBAction)startStopReading:(id)sender;
@end

