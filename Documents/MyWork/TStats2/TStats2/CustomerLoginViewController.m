//
//  CustomerLoginViewController.m
//  TStats2
//
//  Created by anwosu on 4/13/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "CustomerLoginViewController.h"

@interface CustomerLoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rememberMeSegment;

- (IBAction)closeWindow:(id)sender;
@end

@implementation CustomerLoginViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeWindow:(id)sender {
    
    NSArray *answer;
    
    answer = [NSArray arrayWithObjects:self.sendingButtonId, self.userNameTextField.text, self.companyNameTextField.text, nil];
    [self.delegate customerLoginViewDidFinishWithAnswer:answer];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
