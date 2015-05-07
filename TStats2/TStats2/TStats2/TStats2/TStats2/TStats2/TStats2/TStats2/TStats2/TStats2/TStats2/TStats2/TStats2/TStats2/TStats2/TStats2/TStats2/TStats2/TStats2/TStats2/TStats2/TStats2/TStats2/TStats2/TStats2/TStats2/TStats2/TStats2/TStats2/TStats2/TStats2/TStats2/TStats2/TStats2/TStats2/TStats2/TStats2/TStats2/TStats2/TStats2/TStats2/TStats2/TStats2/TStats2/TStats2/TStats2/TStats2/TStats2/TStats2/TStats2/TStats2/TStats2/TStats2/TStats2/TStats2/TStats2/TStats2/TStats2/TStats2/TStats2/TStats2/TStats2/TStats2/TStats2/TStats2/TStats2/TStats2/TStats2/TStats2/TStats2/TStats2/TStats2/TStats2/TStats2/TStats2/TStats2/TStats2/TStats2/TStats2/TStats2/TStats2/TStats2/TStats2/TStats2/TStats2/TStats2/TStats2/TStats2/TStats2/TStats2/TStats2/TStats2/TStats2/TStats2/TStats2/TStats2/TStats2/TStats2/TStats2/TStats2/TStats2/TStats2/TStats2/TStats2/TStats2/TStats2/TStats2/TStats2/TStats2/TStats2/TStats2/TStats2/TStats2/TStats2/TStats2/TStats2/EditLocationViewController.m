//
//  EditLocationViewController.m
//  TStats2
//
//  Created by anwosu on 4/16/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

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
