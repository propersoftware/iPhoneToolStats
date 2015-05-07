//
//  EditLocationViewController.m
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

#import "EditLocationViewController.h"

@interface EditLocationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *streetNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;
@property (strong, nonatomic) NSArray *countryArray;


@end

@implementation EditLocationViewController

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
    
    // here we initialize the country picker view
    _countryArray = [[NSArray alloc] initWithObjects:@"USA", @"CAN", @"MEX", nil];
    
    // here we initialize the text fields with values passed in from gpsView
    _streetNumberTextField.text = self.streetNumber;
    _streetNameTextField.text = self.streetName;
    _cityTextField.text = self.city;
    _stateTextField.text = self.state;
    _zipCodeTextField.text = self.zipCode;
    
    if ([_country isEqual:@"USA"] || [_country isEqual:@"United States"]) {
        [_countryPicker selectRow:0 inComponent:0 animated:YES];
    }
    else if ([_country isEqual:@"CAN"] || [_country isEqual:@"Canada"]) {
        [_countryPicker selectRow:1 inComponent:0 animated:YES];
    }
    else if ([_countryPicker isEqual:@"MEX"] || [_country isEqual:@"Mexico"]) {
        [_countryPicker selectRow:2 inComponent:0 animated:YES];
    }
    else {
        // todo - this coude defaults to USA - a little redundant
        [_countryPicker selectRow:0 inComponent:0 animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// here we hide the keyboard when user hits the 'Return' key
- (IBAction)hideKeyboard:(id)sender {
    [self.streetNumberTextField resignFirstResponder];
    [self.streetNameTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.stateTextField resignFirstResponder];
    [self.zipCodeTextField resignFirstResponder];
}

// here we hide the keyboard with tap gesture in UIScrollview
- (IBAction)hideKeyboardOnTap:(id)sender {
    [self.streetNumberTextField endEditing:YES];
    [self.streetNameTextField endEditing:YES];
    [self.cityTextField endEditing:YES];
    [self.stateTextField endEditing:YES];
    [self.zipCodeTextField endEditing:YES];
}

// here we dismiss the view when we touch outside of text area.
// ** this method does NOT work in a UIScrollView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Navigation Controller Methods
- (IBAction)cancel:(id)sender {
    [self.delegate editLocationViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    NSArray *answer;
    
    self.streetNumber = self.streetNumberTextField.text;
    self.streetName = self.streetNameTextField.text;
    self.city = self.cityTextField.text;
    self.state = self.stateTextField.text;
    self.zipCode = self.zipCodeTextField.text;
    self.country = [NSString stringWithFormat:@"%@", [_countryArray objectAtIndex:[_countryPicker selectedRowInComponent:0]]];
    
    answer = [NSArray arrayWithObjects:_streetNumber, _streetName, _city, _state, _zipCode, _country, nil];
    
    [self.delegate editLocationViewController:self didCommit:answer];
}


#pragma mark - Picker View Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _countryArray.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_countryArray objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _country = [NSString stringWithFormat:@"%@",[_countryArray objectAtIndex:[_countryPicker selectedRowInComponent:0]]];
}


@end
