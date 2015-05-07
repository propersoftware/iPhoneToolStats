//
//  ViewController.m
//  TStats2
//
//  Created by anwosu on 4/7/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSURL *webAppHome;

- (IBAction)gotoWebApp:(id)sender;

@end

@implementation ViewController
@synthesize webAppHome;
@synthesize toolStatsBlue;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

//    _scanButton.layer.borderWidth = 1.0f;
//    _scanButton.layer.borderColor = [[UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1]CGColor];
//    
//    recentScansButton.layer.borderWidth = 1.0f;
//    recentScansButton.layer.borderColor = [[UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1]CGColor];
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoWebApp:(id)sender {
    webAppHome = [NSURL URLWithString:@"http://toolstatsinfo.com"];
    
    if (![[UIApplication sharedApplication]openURL:webAppHome]) {
        NSLog(@"%@%@", @"Failed to open url:", [webAppHome description]);
    }
                  
}

@end
