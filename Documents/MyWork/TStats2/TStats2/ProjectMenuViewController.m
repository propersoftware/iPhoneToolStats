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

@interface ProjectMenuViewController () <CustomerLoginViewDelegate>
@property (nonatomic, strong) NSString *buttonId; // to keep the id of the pressed button
@property (nonatomic, weak) NSString *customerName;
@property (nonatomic, weak) NSString *companyName;
@end

@implementation ProjectMenuViewController

// here we initialize variables with expected button resotrationId's
NSString *button1Id = @"viewProjectButton";
NSString *button2Id = @"sendGpsInfoButton";
NSString *button3Id = @"copyUrlToClipboardButton";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    _projectNumberLabel.text = _projectNumber;
    
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


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ShowCustomerLogin"]) {
        CustomerLoginViewController *customerLoginVC = segue.destinationViewController;
        customerLoginVC.delegate = self;
        customerLoginVC.sendingButtonId = self.buttonId; // we pass button id so we know what to do when we come back
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

- (void)deterimineNextView:(NSArray *)answer {
    if ([answer[0] isEqualToString:button1Id]) {
        NSLog(@"button1 pressed");
        
        [self performSegueWithIdentifier:@"ShowProjectSubMenuView" sender:self];
    }
    else
    if ([answer[0] isEqualToString:button2Id]) {
        NSLog(@"button2 pressed");
        
        [self performSegueWithIdentifier:@"ShowGpsView" sender:self];
    }
    else {
        NSLog(@"Error: No Button Id Returned");
    }
}

@end
