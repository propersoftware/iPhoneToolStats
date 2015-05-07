//
//  RecentScansViewController.m
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

#import "RecentScansViewController.h"
#import "ChecklistItem.h"
#import "ProjectMenuViewController.h"
#import "ScanDatabase.h"
#import "AppDelegateProtocol.h"
#import "BarCodeObjects.h"

@interface RecentScansViewController ()
@property (strong, nonatomic)NSString* selectedProjectNo;
@end

@implementation RecentScansViewController{
    NSMutableArray *_items;
    //- (NSMutableArray *)getReversed:(NSMutableArray *)array;
}

BarCodeObjects* theDataObject;
ScanDatabase*  db;

/*
 * Returns BarcodeObjects instance.
 */
- (BarCodeObjects*) theAppDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    BarCodeObjects* theDataObject;
    theDataObject = (BarCodeObjects*) theDelegate.theAppDataObject;
    return theDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // here we add the toolstats logo to the navbar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    
    // here we make the navigation bar clear
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    // here we reverse the oreder of objects in the collected list of scanned items (most recent first)
    _items = [self getReversed:[db getScannedData]];

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScanListItem"];
    
    ChecklistItem *item = _items[indexPath.row];
    
    cell.textLabel.text = item.projectNumber;
    cell.detailTextLabel.text = item.dateTimeStamp;
    
    [self configureCheckmarkForCell:cell altIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ChecklistItem *item = _items[indexPath.row];
    item.checked = !item.checked;
    
    // here we capture the selected project number
    self.selectedProjectNo = cell.textLabel.text;
    
    [self configureCheckmarkForCell:cell altIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowProjectMenuView2" sender:self];
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell altIndexPath:(NSIndexPath *)indexPath
{
    ChecklistItem *item = _items[indexPath.row];
    
    if (item.checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // here we keep a placeholder for the item to be removed
    ChecklistItem *item = _items[indexPath.row];
    
    [_items removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = @[indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    BOOL isDeleted = NO;
    isDeleted = [db deleteFromScanHistoryTable:item.projectNumber and:item.dateTimeStamp];

}

// here we implement a method to reverse order of Mutable Array
- (NSMutableArray *)getReversed:(NSMutableArray *)array {
    if ([array count] == 0)
        return array;
    NSUInteger start = 0;
    NSUInteger end = [array count] -1;
    
    while (start < end) {
        [array exchangeObjectAtIndex:start withObjectAtIndex:end];
        start++;
        end--;
    }
    return array;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowProjectMenuView2"]) {
        // to do - pass data
        theDataObject.projectNo = _selectedProjectNo;
        // here we can pass data forward to the next view contorller by using the "destinationViewController" property of UIViewController.
        ProjectMenuViewController *projectMenuVC = (ProjectMenuViewController *)[segue destinationViewController];
        projectMenuVC.projectNumber = _selectedProjectNo;
    }
}

@end
