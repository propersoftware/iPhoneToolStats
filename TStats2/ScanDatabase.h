//
//  ScanDatabase.h
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

#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#import "BarCodeObjects.h"
//#import "AppDataObject.h"

@interface ScanDatabase : NSObject {
    sqlite3 *_toolStatsDB;
}

-(bool) selectDataFromTable:(int) id;
- (bool) saveData;
- (bool) saveUserData;
- (bool) saveHomeUserData;
-(bool) selectUserDataFromTable;
- (BOOL) deleteUserTable;
-(bool) selectHomeUserDataFromTable;
- (BOOL) deleteHomeUserTable;
- (void) closeDatabase;
+ (ScanDatabase*)database;
-(int) getRowCount;
-(NSMutableArray *)getScannedData;
-(BOOL)deleteFromScanHistoryTable:(NSString *) projectNum and:(NSString *) date;
@end
