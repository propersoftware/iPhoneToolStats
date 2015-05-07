//
//  ProjectSubMenuViewController.m
//  TStats2
//
//  Created by anwosu on 4/15/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "ProjectSubMenuViewController.h"

@interface ProjectSubMenuViewController ()

@end

@implementation ProjectSubMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)goToProjectView:(id)sender {
    
    //UIButton *button = (UIButton *)sender;
    
    //self.buttonId = button.restorationIdentifier;
    
    [self performSegueWithIdentifier:@"ShowProjectView" sender:self];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
