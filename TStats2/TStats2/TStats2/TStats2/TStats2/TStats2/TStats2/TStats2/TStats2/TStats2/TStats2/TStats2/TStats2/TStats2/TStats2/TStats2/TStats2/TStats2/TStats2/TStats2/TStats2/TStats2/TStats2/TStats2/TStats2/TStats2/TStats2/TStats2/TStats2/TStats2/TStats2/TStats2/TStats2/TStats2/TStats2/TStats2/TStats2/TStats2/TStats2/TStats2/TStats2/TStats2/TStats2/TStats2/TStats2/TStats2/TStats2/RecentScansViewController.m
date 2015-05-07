//
//  RecentScansViewController.m
//  TStats2
//
//  Created by anwosu on 4/24/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

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
    
    // here we reverse the oreder of objects in the collected list of scanned items (most recent first)
    _items = [self getReversed:[db getScannedData]];

    /*
     // here we use MOCK data to test the functionality of the table view items
    _items = [[NSMutableArray alloc]initWithCapacity:10];
    ChecklistItem *item;
    
    
    item = [[ChecklistItem alloc]init];
    item.projectNumber = @"20000";
    item.checked = NO;
    item.dateTimeStamp = @"2015-04-24 14:29:00.805";
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.projectNumber = @"10000";
    item.dateTimeStamp = @"2015-04-24 14:10:00.805";
    item.checked = NO;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.projectNumber = @"10000";
    item.dateTimeStamp = @"2015-04-24 10:00:00.805";
    item.checked = NO;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.projectNumber = @"40000";
    item.dateTimeStamp = @"2015-04-23 09:20:00.805";
    item.checked = NO;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.projectNumber = @"10000";
    item.dateTimeStamp = @"2015-04-22 16:50:00.805";
    item.checked = NO;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.projectNumber = @"10000";
    item.dateTimeStamp = @"2015-04-20 12:15:00.805";
    item.checked = NO;
    [_items addObject:item];
    */

    
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
    
    //UILabel *label = (UILabel *)[cell viewWithTag:1000];
    //label.text = item.projectNumber;
    
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
    
    // this was for testing
//    if (isDeleted) {
//        NSLog(@"Hooray");
//    }
    
    
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
        // here we can pass data forward to the next view contorller by using the "destinationViewController" property of UIViewController.
        ProjectMenuViewController *projectMenuVC = (ProjectMenuViewController *)[segue destinationViewController];
        projectMenuVC.projectNumber = _selectedProjectNo;
    }
}

@end
