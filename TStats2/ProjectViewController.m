//
//  ProjectViewController.m
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

#import "ProjectViewController.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#define AS(A,B) [(A) stringByAppendingString:(B)]
#import "BarCodeObjects.h"
#import "AppDelegateProtocol.h"
#import "ScanDatabase.h"

@interface ProjectViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *projectWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stop;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) NSURL *mainURL;

- (void) loadRequestFromString:(NSString *)urlString;
- (void) updateButtons;
@end

@implementation ProjectViewController

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

NSArray *extensionArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.projectWebView.scrollView setContentInset:UIEdgeInsetsMake(-40, 0, 0, 0)];
    // here we unhide the lower navigation controller
    [self.navigationController setToolbarHidden:NO];
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    //UINavigationController *myNavControler = [[UINavigationController alloc]initWithRootViewController: aFeedController];
    
    // Custom initialization
    
    //extensionArr = [[NSArray alloc] initWithObjects:@".pdf", @".jpg", @".jpeg", @".xls",@".xlsx",@".txt",@".doc",@".png", @".gif",@".docx",@".pptx", @".ppt", nil];
    
    // here we scale the contents to fit the webview
    //self.projectWebView.scalesPageToFit = YES;
    
    _mainURL = [NSURL URLWithString:_urlString];

    //[self.projectWebView loadRequest:[NSURLRequest requestWithURL:_mainURL]];
    //self.projectWebView.delegate = self;
    
    [self loadWebView:_mainURL];
}

- (void)loadWebView:(NSURL *)url {
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    //[self.projectWebView loadRequest:[NSURLRequest requestWithURL:_mainURL]];
    self.projectWebView.delegate = self;
    [self.projectWebView loadRequest:requestObj];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType; {

    
    NSURL *url = [request URL];
    
    NSString *contactStr = @"Default/Contact";
    if([url.absoluteString.lowercaseString rangeOfString:contactStr.lowercaseString].location != NSNotFound) {
        
        _projectWebView.dataDetectorTypes=UIDataDetectorTypeLink;
        _projectWebView.dataDetectorTypes=UIDataDetectorTypePhoneNumber;
    } else {
        _projectWebView.dataDetectorTypes=UIDataDetectorTypeNone;
        _projectWebView.dataDetectorTypes=UIDataDetectorTypeLink;
    }
    
    NSString *urlString = [url absoluteString];
    if ([[[request URL] scheme] isEqual:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    NSUInteger count = [extensionArr count];
    for (NSUInteger i = 0; i < count; i++) {
        NSString *name = [extensionArr objectAtIndex: i];
        if([urlString rangeOfString:name].location != NSNotFound){
            isFile = YES;
            break;
        } else {
            isFile = NO;
        }
    }
    
    NSString *projectHome = AS(theDataObject.baseURL,@"CustomerInfo/CustIndex");
    
    NSString *projectHome1 = AS(theDataObject.baseURL,@"/CustomerInfo/CustIndex");
    
    NSString *home = theDataObject.baseURL;
    
    if( [[urlString lowercaseString] isEqualToString: [home lowercaseString]] ) {
        NSLog(@"url ::>> %@",urlString);
        [webView stopLoading];
        [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.0];
        return false;
    } else if([[urlString lowercaseString] isEqualToString: [projectHome lowercaseString]] || [[urlString lowercaseString] isEqualToString: [projectHome1 lowercaseString]] ){
        NSLog(@"url ::>> %@",urlString);
        [webView stopLoading];
        [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.0];
        return false;
    }
    
    return true;
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

// here we implement the UIWebView delegate method
// note: there may be a better fix by manipulating the HTML
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // here we update the navigation buttons
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    
    // here we add code to test site connectivity
    bool isConnectivity = [self hasConnectivity];
    if (!isConnectivity) {
        NSLog(@"Unable to connect to the remote server. Please check internet connection.");
    }
    
    NSString *url = self.projectWebView.request.URL.absoluteString;
    NSString *contactStr = @"Default/Contact";
    
    if([url.lowercaseString rangeOfString:contactStr.lowercaseString].location != NSNotFound) {
        
        _projectWebView.dataDetectorTypes=UIDataDetectorTypeLink;
        _projectWebView.dataDetectorTypes=UIDataDetectorTypePhoneNumber;
    } else {
        _projectWebView.dataDetectorTypes=UIDataDetectorTypeNone;
        _projectWebView.dataDetectorTypes=UIDataDetectorTypeLink;
    }
    
    
    ///*
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = self.view.bounds.size;
    float rw;
    
    if (contentSize.width > viewSize.width) {
        rw = viewSize.width / contentSize.width - .05;
    } else {
        rw = 1.0;
    }
    //float rw = viewSize.width / contentSize.width;
    
    //NSLog(@"%f", rw); // this line is to test -------->
    /*
    _projectWebView.scrollView.minimumZoomScale = rw;
    _projectWebView.scrollView.maximumZoomScale = rw*2;
    _projectWebView.scrollView.zoomScale = rw;
    // the line below is to prevent zoom
    //_projectWebView.scrollView.bouncesZoom = FALSE;
    //*/
    //float zoom = 1+1-rw;
    //NSString *zoomString = [NSString stringWithFormat:@"document.body.style.zoom = %f",zoom];
    //[_projectWebView stringByEvaluatingJavaScriptFromString:zoomString];
    ///*
    NSString* js;
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
    js = [NSString stringWithFormat:@"var meta = document.createElement('meta'); "
          "meta.setAttribute( 'name', 'viewport' ); "
          "meta.setAttribute( 'content', 'width = device-width, initial-scale = 0.50, user-scalable = yes' ); "
          "document.getElementsByTagName('head')[0].appendChild(meta)"];
    //} else {
    [self.projectWebView stringByEvaluatingJavaScriptFromString:js];
    //*/
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

-(void) loadRequestFromString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.projectWebView loadRequest:urlRequest];
}

-(void)updateButtons {
    self.forward.enabled = self.projectWebView.canGoForward;
    self.back.enabled = self.projectWebView.canGoBack;
    self.stop.enabled = self.projectWebView.loading;
}

//-(void)closeWindow {
//    [self.delegate projectViewDidCancel:self];
//}

- (void)dismissViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Connectivity
-(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                return YES;
            }
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                return YES;
            }
        }
    }
    return NO;
}
@end
