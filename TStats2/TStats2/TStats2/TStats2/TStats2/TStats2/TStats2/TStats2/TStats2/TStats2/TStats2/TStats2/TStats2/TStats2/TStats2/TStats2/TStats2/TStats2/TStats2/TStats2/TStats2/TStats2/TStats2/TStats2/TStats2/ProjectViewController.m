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
@property (strong, nonatomic) NSURL *mainURL;
@end

@implementation ProjectViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    //UINavigationController *myNavControler = [[UINavigationController alloc]initWithRootViewController: aFeedController];
    
    
    // here we scale the contents to fit the webview
    //self.projectWebView.scalesPageToFit = YES;
    
    _mainURL = [NSURL URLWithString:_urlString];

    [self.projectWebView loadRequest:[NSURLRequest requestWithURL:_mainURL]];
    self.projectWebView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// here we implement the UIWebView delegate method
// note: there may be a better fix by manipulating the HTML
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = self.view.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    webView.scrollView.minimumZoomScale = rw;
    webView.scrollView.maximumZoomScale = rw;
    webView.scrollView.zoomScale = rw;
}


@end
