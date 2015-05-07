//
//  CustomerLoginViewController.h
//  TStats2
//
//  Created by anwosu on 4/13/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import <UIKit/UIKit.h>

// here were forward declare the delegate
@protocol CustomerLoginViewDelegate;

@interface CustomerLoginViewController : UIViewController

@property (nonatomic, strong) NSString *sendingButtonId;
// here we create delegate property
@property (nonatomic, weak) id <CustomerLoginViewDelegate> delegate;

@end

// here we define delegate method
@protocol CustomerLoginViewDelegate

-(void)customerLoginViewDidFinishWithAnswer:(NSArray *)answer;
-(void)customerLoginViewDidCancel:(CustomerLoginViewController *)controller;

@end
