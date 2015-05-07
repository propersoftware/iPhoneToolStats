//
//  EditLocationViewController.h
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

#import <UIKit/UIKit.h>

// here we forward declare the EditLocationView delegate
@protocol EditLocationViewDelegate;

@interface EditLocationViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

// here we instantiate the delegate
@property (weak, nonatomic) id <EditLocationViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (strong, nonatomic) NSString *streetNumber;
@property (strong, nonatomic) NSString *streetName;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *projectNo;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end


@protocol EditLocationViewDelegate

- (void)editLocationViewControllerDidCancel:(EditLocationViewController *)controller;
- (void)editLocationViewController:(EditLocationViewController *)controller didCommit:(NSArray *)answer;

@end