//
//  ProjectMenuViewController.m
//  TStats2
//
//  Created by anwosu on 4/8/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "ProjectMenuViewController.h"
#import "QrCodeScanViewController.h"
#import "CustomerLoginViewController.h"
#import "ProjectSubMenuViewController.h"
#import "GpsViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#define AS(A,B) [(A) stringByAppendingString:(B)]
#import "BarCodeObjects.h"
#import "AppDelegateProtocol.h"
#import "ScanDatabase.h"

@interface ProjectMenuViewController () <CustomerLoginViewDelegate, GpsViewDelegate>
@property (nonatomic, strong) NSString *buttonId; // to keep the id of the pressed button
@property (nonatomic, weak) NSString *customerName;
@property (nonatomic, weak) NSString *companyName;
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
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    _projectNumberLabel.text = [NSString stringWithFormat:@"Toolmaker Project#: %@",_projectNumber];
    
}

- (void)viewDidAppear:(BOOL)animated {
    // here we make sure the lower navigation controller is hidden
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitToHere:(UIStoryboardSegue *)sender {
    // Execute this code upon unwinding
}

- (IBAction)goToCustomerLogin:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    self.buttonId = button.restorationIdentifier;
    
    [self performSegueWithIdentifier:@"ShowCustomerLogin" sender:self];
    
}

- (IBAction) urlCopyAction {
    if(!isCopied) {
        isCopied = TRUE;
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
    
    NSLog(@"answer: %@",answer[0]);
    self.customerName = answer[1];
    self.companyName = answer[2];
    
    if ((self.customerName != nil && ![self.customerName  isEqual: @""]) && (self.companyName != nil && ![self.companyName isEqualToString:@""])) {
        [self deterimineNextView:answer];
    }
    else {
        NSLog(@"user must provide company name and customer name");
    }
    
}

- (void)customerLoginViewDidCancel:(CustomerLoginViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//- (void)gpsViewDidFinishWithAnswer:(NSString *)answer {
//    
//}

- (void)deterimineNextView:(NSArray *)answer {
    if ([answer[0] isEqualToString:button1Id]) {
        NSLog(@"button1 pressed");
        
        [self performSegueWithIdentifier:@"ShowProjectSubMenuView" sender:self];
    }
    else
    if ([answer[0] isEqualToString:button2Id]) {
        NSLog(@"button2 pressed");
        
        // here we segue to the GPS View Controller
        [self performSegueWithIdentifier:@"ShowGpsView" sender:self];
    }
    else {
        NSLog(@"Error: No Button Id Returned");
    }
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
    NSLog(@"encode %@", encoded);
    return encoded;
    
}
@end
