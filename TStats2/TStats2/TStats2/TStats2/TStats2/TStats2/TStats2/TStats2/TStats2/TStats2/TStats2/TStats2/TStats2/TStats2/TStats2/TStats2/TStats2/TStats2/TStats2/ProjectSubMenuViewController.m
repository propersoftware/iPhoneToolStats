//
//  ProjectSubMenuViewController.m
//  TStats2
//
//  Created by anwosu on 4/15/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "ProjectSubMenuViewController.h"
#import "ProjectViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#define AS(A,B) [(A) stringByAppendingString:(B)]
#import "BarCodeObjects.h"
#import "AppDelegateProtocol.h"
#import "ScanDatabase.h"

@interface ProjectSubMenuViewController () <ProjectViewDelegate>
@property (weak, nonatomic) NSString *encryptedURL;
@property (weak, nonatomic) NSString *sectionTitle;
@end

@implementation ProjectSubMenuViewController {
    
    //for testing we wil implement these variblas here
    //these should be in the database: projectNo, user, company, baseURL, etc
    // so that we can access them from any page without having to redeclare and pass them around with delegates.
    NSString *company;
    NSString *user;
    NSString *projectNo;
    NSString *baseURL;
    NSString *WEBAPP_FLAG;
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
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    
    // Custom initialization
    db = [ScanDatabase database];
    theDataObject = [self theAppDataObject];
    
    theDataObject.chkResStatus = @"";
    theDataObject.pjtStatus = @"";
    
    NSString *baseCopyURL =  AS(theDataObject.baseURL, @"CustomerInfo?qstring=");
    NSString *MOBILE_FLAG = @"~0";
    NSString *encryptedCopyValue = [self doCipher: AS(theDataObject.projectNo, MOBILE_FLAG)];
    baseCopyURL = AS(baseCopyURL, [self encode:encryptedCopyValue]);
    NSURL *url = [[NSURL alloc] initWithString:baseCopyURL];
    theDataObject.appURL = url;
    
    // here we will initialize our test vars
    /*  Note: theDataObject 'acts' like a singleton (actually an app delegate element)
     *  We use this to store and pass around global data
     *  This eliminates the need in some cases to pass forward data between view controllers
     *  Consider a more consistent method of passing data, making best use of singleton object
     *  as well as view controller delegate objects and methods.
     */
    company = theDataObject.company; // @"testCompany";
    user = theDataObject.name; //@"testUser";
    projectNo = theDataObject.projectNo; // @"10000";
    //projectNo = @"14202";
    //baseURL = @"172.31.3.182:51089/";
    //baseURL = @"http://toolstatsinfo.com/";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)goToProjectView:(id)sender {
    
    // here we capture the name of the button clicked
    UIButton *button = (UIButton *)sender;
    self.sectionTitle = button.currentTitle;
    
    [self performSegueWithIdentifier:@"ShowProjectView" sender:self];
}


///*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowProjectView"]) {
        
        ProjectViewController *projectVC = segue.destinationViewController;
        projectVC.delegate = self;
        
        self.encryptedURL = [self getEncryptedUrlFrom:self.sectionTitle];
        
        projectVC.urlString = self.encryptedURL;
    }
}
//*/

-(void)determineNextView:(NSString *)name {
    // todo
}

// here we create and encrytion driver that will return and encrytpted string
- (NSString *) getEncryptedUrlFrom:(NSString *)buttonId {
    
    WEBAPP_FLAG = @"~1";
    //NSString *sectionTitle = buttonId;
    NSString *sectionTitle = [buttonId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString  *encryptedWebAppValue = [self encode:[self doCipher: AS(theDataObject.projectNo, WEBAPP_FLAG)]];
    
    NSString *webappURL = [NSString stringWithFormat:AS(theDataObject.baseURL, @"RegisterCustomer?name=%@&company=%@&reason=%@&qstring=%@"), [self encode:theDataObject.name],[self encode:theDataObject.company], [self encode:sectionTitle], encryptedWebAppValue];
    
    NSLog(@"%@",webappURL);
    
    return webappURL;
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














