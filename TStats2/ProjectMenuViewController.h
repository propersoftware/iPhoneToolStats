//
//  ProjectMenuViewController.h
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
