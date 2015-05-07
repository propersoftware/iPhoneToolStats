//
//  ProjectMenuViewController.h
//  TStats2
//
//  Created by anwosu on 4/8/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward declaring the protocol so we can reference it a couple lines below
//@protocol ProjectMenuViewControllerDelegate;

@interface ProjectMenuViewController : UIViewController
// We need a reference to our delegate so we can call our delegate methods defined in the protocol
// It is weak because we don't want to retain our delegate who is retaining us or we have a leak
//@property (nonatomic, weak) id <ProjectMenuViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *projectNumberLabel;
@property (nonatomic, strong) NSString *projectNumber;

- (IBAction)exitToHere:(UIStoryboardSegue *)sender;
@end

// Here we actually define the protocol that our delegate has to conform to
//@protocol ProjectMenuViewControllerDelegate

//@end
