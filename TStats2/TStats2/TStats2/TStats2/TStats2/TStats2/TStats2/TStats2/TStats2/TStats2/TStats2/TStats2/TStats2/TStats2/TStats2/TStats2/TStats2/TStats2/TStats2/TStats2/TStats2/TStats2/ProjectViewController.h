//
//  ProjectViewController.h
//  TStats2
//
//  Created by anwosu on 4/15/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import <UIKit/UIKit.h>

// here we forward declare the protocol
@protocol ProjectViewDelegate;

@interface ProjectViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) NSString *urlString;

@property (nonatomic, weak) id <ProjectViewDelegate> delegate;

@end


// here we define the delegate method - if we need to return data to the sender
@protocol ProjectViewDelegate

// todo
//-(void)projectViewDidFinishWithAnswer:(NSString *)answer;

@end