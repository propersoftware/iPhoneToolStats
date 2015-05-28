//
//  ProjectMenuViewController.m
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

#import "ProjectMenuViewController.h"
//#import "QrCodeScanViewController.h"
#import "CustomerLoginViewController.h"
#import "ProjectSubMenuViewController.h"
#import "GpsViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#define AS(A,B) [(A) stringByAppendingString:(B)]
#import "BarCodeObjects.h"
#import "AppDelegateProtocol.h"
#import "ScanDatabase.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface ProjectMenuViewController () <CustomerLoginViewDelegate, GpsViewDelegate>
@property (nonatomic, strong) NSString *buttonId; // to keep the id of the pressed button
@property (nonatomic, weak) NSString *customerName;
@property (nonatomic, weak) NSString *companyName;
@property (weak, nonatomic) IBOutlet UIView *bottomMaskView;
@property (weak, nonatomic) IBOutlet UIView *topMaskView;
@property (weak, nonatomic) IBOutlet UIButton *topMaskButton;
@property (weak, nonatomic) IBOutlet UILabel *topMaskLabel;
@end

@implementation ProjectMenuViewController

bool isCopied = FALSE;
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

// here we initialize variables with expected button resotrationId's
NSString *button1Id = @"viewProjectButton";
NSString *button2Id = @"sendGpsInfoButton";
NSString *button3Id = @"copyUrlToClipboardButton";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // here we hide the top and bottom alert mask view
    _bottomMaskView.hidden = YES;
    _topMaskView.hidden = YES;
    
    // Custom initialization
    db = [ScanDatabase database];
    theDataObject = [self theAppDataObject];
    NSString *baseCopyURL =  AS(theDataObject.baseURL, @"CustomerInfo?qstring=");
    NSString *MOBILE_FLAG = @"~0";
    NSString *encryptedCopyValue = [self doCipher: AS(theDataObject.projectNo, MOBILE_FLAG)];
    baseCopyURL = AS(baseCopyURL, [self encode:encryptedCopyValue]);
    NSURL *url = [[NSURL alloc] initWithString:baseCopyURL];
    theDataObject.appURL = url;
    
    theDataObject.chkResStatus = @"";
    theDataObject.pjtStatus = @"";
    
    // here we make sure the lower navigation controller is hidden
    [self.navigationController setToolbarHidden:YES];
    
    // here we make the navigation bar clear
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    _projectNumberLabel.text = [NSString stringWithFormat:@"Toolmaker Project#: %@",_projectNumber];
    
}

- (void)viewDidAppear:(BOOL)animated {
    // here we make sure the lower navigation controller is hidden
    [self.navigationController setToolbarHidden:YES];
    
    // here we hide the top and bottom alert mask view
    _bottomMaskView.hidden = YES;
    _topMaskView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitToHere:(UIStoryboardSegue *)sender {
    // Execute this code upon unwinding
}

- (IBAction)goToCustomerLogin:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.buttonId = button.restorationIdentifier;
    // to do
    
    NSString *messageText = @"";
    
    // here we implement logic to check connectivity and validate the status of the selected job
    bool isConnectivity = [self hasConnectivity];
    
    if(isConnectivity)
    {
        @try
        {
            NSString *response = theDataObject.pjtStatus;
            
            [self checkIOResponse];
            
            response = theDataObject.pjtStatus;
            
            if(response != NULL  && ![response isEqualToString:@""])
            {
                if(![[response uppercaseString] isEqualToString: @"I"])
                {
                    if(![[response uppercaseString] isEqualToString: @"N"])
                    {
                        if([[response uppercaseString] isEqualToString: @"A"])
                        {
                            messageText = @"";
                            
                            [db selectUserDataFromTable];
                            
                            [self performSegueWithIdentifier:@"ShowCustomerLogin" sender:self];
                        }
                        else
                        {
                            //NSLog(@"Unable to connect to the remote server.");// for testing ---------------->
                            messageText = @"Unable to connect to remote server.";
                        }
                    }
                    else
                    {
                        //NSLog(@"Project is either waiting for Approval or Deactivated.");// for testing ---------------->
                        messageText = @"Project is either waiting for Approval or Deactivated.";
                    }
                }
                else
                {
                    //NSLog(@"Invalid Project No.");// for testing ---------------->
                    messageText = @"Invalid Project No.";
                }
            }
            else
            {
                //NSLog(@"Unable to connect to the remote server.");// for testing ---------------->
                messageText = @"Unable to connect to the remote server.";
            }
        } 
        @catch (NSException *exception) 
        {
            //[HUD hide:TRUE];
            // todo
        }
    } 
    else
    {
        //NSLog(@"Unable to connect to the remote server. Please check internet connection.");// for testing ---------------->
        messageText = @"Unable to connect to the remote server. Please check internet connection.";
    }
    
    if (![messageText isEqualToString:@""]) {
        self.navigationItem.hidesBackButton = YES;
        _bottomMaskView.hidden = NO;
        _topMaskView.hidden = NO;
        _topMaskView.layer.cornerRadius = 10;
        _topMaskButton.layer.cornerRadius = 10;
        _topMaskButton.layer.borderColor = [UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1].CGColor;
        _topMaskButton.layer.borderWidth = 1;
        
        _topMaskLabel.text = messageText;
    }
}

- (IBAction) urlCopyAction {
    if(!isCopied) {
        isCopied = TRUE;
        [[UIPasteboard generalPasteboard] setString:theDataObject.appURL.absoluteString];
    } else {
        [[UIPasteboard generalPasteboard] setString:@""];
        [[UIPasteboard generalPasteboard] setString:theDataObject.appURL.absoluteString];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ShowCustomerLogin"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CustomerLoginViewController *customerLoginVC = [navigationController viewControllers][0];
        customerLoginVC.delegate = self;
        customerLoginVC.sendingButtonId = self.buttonId; // we pass button id so we know what to do when we come back
    }
    
    if ([segue.identifier isEqualToString:@"ShowProjectSubMenuView"]) {
        //ProjectSubMenuViewController *projectSubMenuVC = segue.destinationViewController;
        //projectSubMenuVC.projectNumber = self.projectNumber;
        theDataObject.projectNo = self.projectNumber;
    }
    
    if ([segue.identifier isEqualToString:@"ShowGpsView"]) {
        GpsViewController *gpsVC = segue.destinationViewController;
        gpsVC.deldgate = self;
        gpsVC.projectNo = self.projectNumber;
    }
}

- (void)customerLoginViewDidFinishWithAnswer:(NSArray *)answer {
    
    //NSLog(@"answer: %@",answer[0]);// for testing ---------------->
    self.customerName = answer[1];
    self.companyName = answer[2];
    
    if ((self.customerName != nil && ![self.customerName  isEqual: @""]) && (self.companyName != nil && ![self.companyName isEqualToString:@""])) {
        [self deterimineNextView:answer];
    }
    else {
        //NSLog(@"user must provide company name and customer name");// for testing ---------------->
    }
    
}

- (void)customerLoginViewDidCancel:(CustomerLoginViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deterimineNextView:(NSArray *)answer {
    if ([answer[0] isEqualToString:button1Id]) {
        //NSLog(@"button1 pressed");// for testing ---------------->
        
        [self performSegueWithIdentifier:@"ShowProjectSubMenuView" sender:self];
    }
    else
    if ([answer[0] isEqualToString:button2Id]) {
        //NSLog(@"button2 pressed");// for testing ---------------->
        
        // here we segue to the GPS View Controller
        [self performSegueWithIdentifier:@"ShowGpsView" sender:self];
    }
    else {
        //NSLog(@"Error: No Button Id Returned");// for testing ---------------->
    }
}

- (IBAction)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Encryption
// here we have the encryption code
- (NSString*) doCipher:(NSString*)plainText {
    
    const void *vplainText;
    size_t plainTextBufferSize = [plainText length];
    vplainText = (const void *) [plainText UTF8String];
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    Byte iv [] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xab, 0xcd, 0xef};
    
    NSString *key = @"Tool2012";
    const void *vkey = (const void *) [key UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       vkey,  //key
                       kCCKeySizeDES,
                       iv, //iv,
                       vplainText, //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    if (ccStatus == kCCParamError) return @"PARAM ERROR";
    else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    NSString *result;
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    result = [self base64forData: myData];
    
    return result;
}

// here - another encryption method
- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

// * Encode and return the encodeText.
-(NSString*) encode:(NSString*)encodeText {
    
    NSString *encoded = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                              NULL,
                                                                                              (CFStringRef)encodeText,NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    //NSLog(@"encode %@", encoded);// for testing ---------------->
    return encoded;
    
}

#pragma mark - Connectivity
-(BOOL) hasConnectivity {
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

-(void) checkIOResponse
{
    NSStringEncoding *encoding;
    NSError *error;
    
    @try {
        NSURL *URL=[[NSURL alloc] initWithString:AS(@"http://toolstatsinfo.com/TSwcfService/ToolStatsSvc.svc/getTMProjectStatus?prjNo=", [self encode:theDataObject.projectNo])];
        
        // here we must ignore warning otherwise code does not work
        NSString *results = [[NSString alloc] initWithContentsOfURL :URL usedEncoding:&encoding error:&error];
        
        if(results == nil || results.length == 0 ) {
//            
//            //if(toast !=NULL) {
//            //    [toast hideToast:nil];
//            //}
//            
//            //[HUD hide:TRUE];
            NSLog(@"No result returned");
           return;
        }
      
        // we rewrote original code to parse the JSON objec without using JSONKIT
        NSData *val = [results dataUsingEncoding:NSUTF8StringEncoding];

        NSMutableDictionary *searchResults = [NSJSONSerialization JSONObjectWithData:val options:0 error:nil];
        NSString *response = [searchResults valueForKey:@"getTMProjectStatusResult"];
        //NSLog(@"The URL JSON Object response is %@",response);// for testing ---------------->
        //----
        
        theDataObject.pjtStatus = response;
        
        //NSLog(@"response %@", response);// for testing ---------------->
    } @catch (NSException *exception) {
        //[HUD hide:TRUE];
    }
    
}
@end
