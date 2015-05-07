//
//  ProjectViewController.m
//  TStats2
//
//  Created by anwosu on 4/15/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "ProjectViewController.h"

@interface ProjectViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *projectWebView;
@end

@implementation ProjectViewController

NSString *baseURLstring;
NSURL *baseURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    
    // here we scale the contents to fit the webview
    self.projectWebView.scalesPageToFit = YES;
    
    baseURLstring = [NSString stringWithFormat:@"http://toolstatsinfo.com/"];
    
    baseURL = [NSURL URLWithString:baseURLstring];

    [self.projectWebView loadRequest:[NSURLRequest requestWithURL:baseURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
