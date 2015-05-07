//
//  CustomerLoginViewController.m
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

#import "CustomerLoginViewController.h"
#import "BarCodeObjects.h"
#import "AppDelegateProtocol.h"
#import "ScanDatabase.h"

@interface CustomerLoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rememberMeSegment;

- (IBAction)closeWindow:(id)sender;
@end

@implementation CustomerLoginViewController

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
    
    // here we make the navigation bar clear
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    [self.rememberMeSegment setTitle:@"Yes" forSegmentAtIndex:0];
    [self.rememberMeSegment setTitle:@"No" forSegmentAtIndex:1];
    
    [self.rememberMeSegment setSelectedSegmentIndex:1];
    BOOL isOpen = [db selectUserDataFromTable];
    
    if (isOpen == YES)
    {
        if ([theDataObject.userFlag isEqualToString:@"Yes"])
        {
            [self.rememberMeSegment setSelectedSegmentIndex:0];
        
            if (theDataObject.name == nil || [theDataObject.name isEqualToString:@"(null)"]) { //here we handle bad entries
                self.userNameTextField.text = @"";
            } else {
                self.userNameTextField.text = theDataObject.name;
            }
            
            if (theDataObject.company == nil || [theDataObject.company isEqualToString:@"(null)"]) { //here we handle bad entries
                self.companyNameTextField.text = @"";
            } else {
                self.companyNameTextField.text = theDataObject.company ?: @"";
            }
        }
//    } else {
//        [self.rememberMeSegment setSelectedSegmentIndex:1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hideKeyboard:(id)sender {
    [self.userNameTextField resignFirstResponder];
    [self.companyNameTextField resignFirstResponder];
}

// here we dismiss the view when we touch outside of text area.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Navigation Controller Methods
- (IBAction)cancel:(id)sender {
    [self.delegate customerLoginViewDidCancel:self];
}

- (IBAction)closeWindow:(id)sender {
    

    // here, if the textfields are not empty we set the userFlag
    if (!([self.userNameTextField.text isEqualToString:@""] || self.userNameTextField == nil) && !([self.companyNameTextField.text isEqualToString:@""] || self.companyNameTextField == nil)) {
        theDataObject.name = self.userNameTextField.text;
        theDataObject.company = self.companyNameTextField.text;
        
        if ([self.rememberMeSegment selectedSegmentIndex] == 0) {
            theDataObject.userFlag = @"Yes";
        } else {
            theDataObject.userFlag = @"No";
        }
        
        /*  Note: we do database activity here
         *  We delete previous user data and replace it with the new inputs from this page
         *  This section could 'technically' be handled by the previous view controller using the delegates
         */
        [db deleteUserTable];
        bool isSuccess = [db saveUserData];
        if(!isSuccess) {
        }

        
        // here, we close the window
        /* Note: we only dismiss this view if the user elects to save login info
         * We will implement a 'cancel button' to go back to the previos page without logging.
         */
        NSArray *answer;
        
        answer = [NSArray arrayWithObjects:self.sendingButtonId, self.userNameTextField.text, self.companyNameTextField.text, [self.rememberMeSegment titleForSegmentAtIndex:self.rememberMeSegment.selectedSegmentIndex], nil];
        [self.delegate customerLoginViewDidFinishWithAnswer:answer];
        
        
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    
}
/*
- (void)closeWindowDo {
    
    NSArray *answer;
    
    answer = [NSArray arrayWithObjects:self.sendingButtonId, theDataObject.name, theDataObject.company, [self.rememberMeSegment selectedSegmentIndex], nil];
    [self.delegate customerLoginViewDidFinishWithAnswer:answer];
    
    //[db saveUserData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/
@end
