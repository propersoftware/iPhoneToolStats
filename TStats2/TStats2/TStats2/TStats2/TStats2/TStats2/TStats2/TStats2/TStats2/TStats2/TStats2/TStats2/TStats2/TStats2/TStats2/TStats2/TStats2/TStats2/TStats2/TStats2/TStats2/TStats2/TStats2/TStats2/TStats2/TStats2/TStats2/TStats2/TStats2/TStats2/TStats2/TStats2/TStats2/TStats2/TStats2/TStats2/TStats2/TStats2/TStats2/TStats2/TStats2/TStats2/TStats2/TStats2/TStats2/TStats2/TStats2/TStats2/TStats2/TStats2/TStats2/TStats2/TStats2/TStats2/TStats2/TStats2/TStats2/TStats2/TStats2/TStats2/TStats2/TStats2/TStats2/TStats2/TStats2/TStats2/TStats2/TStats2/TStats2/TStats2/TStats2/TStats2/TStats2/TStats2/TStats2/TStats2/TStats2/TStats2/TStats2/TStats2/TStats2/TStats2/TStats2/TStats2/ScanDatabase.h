//
//  ScanDatabase.h
//  TStats2
//
//  Created by anwosu on 4/27/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

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
