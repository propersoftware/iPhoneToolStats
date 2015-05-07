//
//  EditLocationViewController.h
//  TStats2
//
//  Created by anwosu on 4/16/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

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