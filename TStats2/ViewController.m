//
//  ViewController.m
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

#import "ViewController.h"
#import "BarCodeObjects.h"
#import "AppDelegateProtocol.h"
#import "ScanDatabase.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *recentScanButton;
@property (weak, nonatomic) IBOutlet UIButton *gotoWebAppButton;
@property (strong, nonatomic) NSURL *webAppHome;

- (IBAction)gotoWebApp:(id)sender;

@end

@implementation ViewController
@synthesize webAppHome;
@synthesize toolStatsBlue;

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
    // Do any additional setup after loading the view, typically from a nib.

//    _scanButton.layer.borderWidth = 1.0f;
//    _scanButton.layer.borderColor = [[UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1]CGColor];
//    
//    recentScansButton.layer.borderWidth = 1.0f;
//    recentScansButton.layer.borderColor = [[UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1]CGColor];
    
    // here we add the toolstats logo to the navbar
    //self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    
    // here we hide the navigation controller so that we can show an image instead
    [self.navigationController setNavigationBarHidden:YES];
    

    // Custom initialization
    db = [ScanDatabase database];
    theDataObject = [self theAppDataObject];
    
    theDataObject.projectNo = @"";
    theDataObject.programName = @"";
    theDataObject.partName = @"";
    theDataObject.customerName = @"";
    theDataObject.partNumber = @"";
    theDataObject.name = @"";
    theDataObject.company = @"";
    theDataObject.name = @"";
    theDataObject.date = @"";
    theDataObject.isReason = @"";
    theDataObject.isHistory = @"";
    theDataObject.hpjtNo = nil;
    theDataObject.hproNo = nil;
    theDataObject.huserFlag = nil;
    theDataObject.hcompany = nil;
    theDataObject.webAppURL = nil;
    theDataObject.appURL = nil;
    theDataObject.isLandscape = YES;
    theDataObject.baseURL = @"http://toolstatsinfo.com/"; //@"http://172.31.3.95:51089/";//@"http://172.31.3.182:51089/";//
    
    NSLog(@"%@",db.description);
    NSLog(@"%@", theDataObject.description);
}

- (void)viewDidAppear:(BOOL)animated {
    // here we hide the navigation bars
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
}


// here we hide the navigation bar immediately - withought fading up
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (IBAction)gotoSelectView:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    if (button.titleLabel == self.scanButton.titleLabel) {
        [self performSegueWithIdentifier:@"ShowQrScanView" sender:self];
    }
    if (button.titleLabel == self.recentScanButton.titleLabel) {
        [self performSegueWithIdentifier:@"ShowRecentScansView" sender:self];
    }
    
}
 */

- (IBAction)gotoWebApp:(id)sender {
    webAppHome = [NSURL URLWithString:theDataObject.baseURL]; //@"http://toolstatsinfo.com"];
    
    if (![[UIApplication sharedApplication]openURL:webAppHome]) {
        NSLog(@"%@%@", @"Failed to open url:", [webAppHome description]);
    }
                  
}

@end
