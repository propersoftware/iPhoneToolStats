//
//  ScanDatabase.m
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

#import "ScanDatabase.h"
//#import "AppDataObject.h"
#import "BarCodeObjects.h"
#import "AppDelegateProtocol.h"
#import "ChecklistItem.h"

@implementation ScanDatabase

BarCodeObjects* theDataObject;

- (BarCodeObjects*) theAppDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    BarCodeObjects* theDataObject;
    theDataObject = (BarCodeObjects*) theDelegate.theAppDataObject;
    return theDataObject;
}


static ScanDatabase *_toolStatsDB;
bool isOpened = FALSE;

/*
 * Returns instance of ScanDatabase.
 */

+ (ScanDatabase*)database {
    
    if (_toolStatsDB == nil) {
        
        _toolStatsDB = [[ScanDatabase alloc] init1];
    }
    
    return _toolStatsDB;
}


/*
 * Create the DB.
 */

- (id)init1 {
    if ((self = [super init])) {
        
        if (sqlite3_open([self.getDBPath UTF8String], &_toolStatsDB) == SQLITE_OK) {
            isOpened = TRUE;
            
            const char *sqlStatement = "CREATE TABLE IF NOT EXISTS scan_history (_id INTEGER PRIMARY KEY AUTOINCREMENT, customerName TEXT,programName TEXT,partNumber TEXT,partName TEXT,projectNumber TEXT,name TEXT,company TEXT,reason TEXT,url TEXT,date TEXT)";
            sqlite3_stmt *createStmt = nil;
            
            if (sqlite3_prepare_v2(_toolStatsDB, sqlStatement, -1, &createStmt, NULL) == SQLITE_OK) {
                
                char *error;
                if (sqlite3_exec(_toolStatsDB, sqlStatement, NULL, NULL, &error) == SQLITE_OK)
                {
                    
                }
                
            } else  {
                
                isOpened = FALSE;
            }
            
            const char *sqlStatement1 = "CREATE TABLE IF NOT EXISTS user_info (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,company TEXT,user_flag TEXT)";
            sqlite3_stmt *createStmt1 = nil;
            
            if (sqlite3_prepare_v2(_toolStatsDB, sqlStatement1, -1, &createStmt1, NULL) == SQLITE_OK) {
                
                char *error;
                if (sqlite3_exec(_toolStatsDB, sqlStatement1, NULL, NULL, &error) == SQLITE_OK)
                {
                    
                }
                
            } else  {
                
                isOpened = FALSE;
            }
            
            const char *sqlStatement2 = "CREATE TABLE IF NOT EXISTS home_user_info (_id INTEGER PRIMARY KEY AUTOINCREMENT, projectNo TEXT, productionNo TEXT, name TEXT,company TEXT, user_flag TEXT)";
            sqlite3_stmt *createStmt2 = nil;
            
            if (sqlite3_prepare_v2(_toolStatsDB, sqlStatement2, -1, &createStmt2, NULL) == SQLITE_OK) {
                
                char *error;
                if (sqlite3_exec(_toolStatsDB, sqlStatement2, NULL, NULL, &error) == SQLITE_OK)
                {
                    
                }
                
            } else  {
                
                isOpened = FALSE;
            }
            
        }
    }
    
    return self;
}

/*
 * Copying the DB if needs.
 */

- (void) copyDatabaseIfNeeded {
    
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"toolstats_db.sqlite"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

/*
 * Returns NSString format of DB path.
 */

- (NSString *) getDBPath {
    
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"toolstats_db.sqlite"];
}

/*
 * Save the values into scan_history table.
 */

- (bool) saveData
{
    bool isSuccess = TRUE;
    theDataObject = [self theAppDataObject];
    
    NSString *url = theDataObject.appURL.absoluteString;
    if([url isEqualToString:@"null"]) {
        url = @"-";
    }
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO scan_history (customerName, programName, partNumber, partName, projectNumber, name, company, reason, url, date) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", theDataObject.customerName,theDataObject.programName, theDataObject.partNumber, theDataObject.partName, theDataObject.projectNo, theDataObject.name, theDataObject.company, theDataObject.reason, url,theDataObject.date];
    
    
    const char *insert_stmt = [insertSQL UTF8String];
    char *error;
    
    if ( sqlite3_exec(_toolStatsDB, insert_stmt, NULL, NULL, &error) == SQLITE_OK)
        
    {
        isSuccess = TRUE;
    } else {
        isSuccess = FALSE;
    }
    
    return isSuccess;
}

/*
 * Save the values into user_info table.
 */

- (bool) saveUserData
{
    bool isSuccess = TRUE;
    theDataObject = [self theAppDataObject];
    NSString *name = theDataObject.name;
    NSString *company = theDataObject.company;
    if([theDataObject.userFlag isEqual: @"No"]) {
        name = @"";
        company = @"";
    }
    NSString *url = theDataObject.appURL.absoluteString;
    if([url isEqualToString:@"null"]) {
        url = @"-";
    }
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO user_info (name, company, user_flag) VALUES ('%@', '%@', '%@')", name,company, theDataObject.userFlag];
    
    
    const char *insert_stmt = [insertSQL UTF8String];
    char *error;
    
    if ( sqlite3_exec(_toolStatsDB, insert_stmt, NULL, NULL, &error) == SQLITE_OK)
        
    {
        isSuccess = TRUE;
    } else {
        isSuccess = FALSE;
    }
    
    return isSuccess;
}

/*
 * Save the values into home_user_info table.
 */

- (bool) saveHomeUserData
{
    bool isSuccess = TRUE;
    theDataObject = [self theAppDataObject];
    NSString *pjtNo = theDataObject.hpjtNo;
    NSString *proNo = theDataObject.hproNo;
    NSString *name = theDataObject.hname;
    NSString *company = theDataObject.hcompany;
    if([theDataObject.userFlag isEqual: @"No"]) {
        name = @"";
        company = @"";
    }
    NSString *url = theDataObject.appURL.absoluteString;
    if([url isEqualToString:@"null"]) {
        url = @"-";
    }
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO home_user_info (projectNo, productionNo, name, company, user_flag) VALUES ('%@', '%@','%@', '%@', '%@')", pjtNo, proNo, name, company, theDataObject.huserFlag];
    
    
    const char *insert_stmt = [insertSQL UTF8String];
    char *error;
    
    if ( sqlite3_exec(_toolStatsDB, insert_stmt, NULL, NULL, &error) == SQLITE_OK)
        
    {
        isSuccess = TRUE;
    } else {
        isSuccess = FALSE;
    }
    
    return isSuccess;
}

/*
 * Get maximum row count from scan_history table.
 */

-(int) getRowCount {
    int count = 0;
    
    
    NSString *maxTimeStatement = [NSString stringWithFormat:@"SELECT max(_id) FROM scan_history"];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(_toolStatsDB, [maxTimeStatement UTF8String], -1, &statement, nil) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    
    return  count;
}

/*
 * Get maximum row count from user_info table.
 */

-(int) getUserRowCount {
    int count = 0;
    
    
    NSString *maxTimeStatement = [NSString stringWithFormat:@"SELECT max(_id) FROM user_info"];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(_toolStatsDB, [maxTimeStatement UTF8String], -1, &statement, nil) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    
    return  count;
}


/*
 * Select the values from scan_history table.
 */

-(bool) selectDataFromTable:(int) id {
    theDataObject = [self theAppDataObject];
    bool isSuccess = TRUE;
    
    NSString *query = [NSString stringWithFormat:@"select * from scan_history where _id = %i", id];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_toolStatsDB, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSString *customerName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            theDataObject.customerName = customerName;
            NSString *programName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            theDataObject.programName = programName;
            NSString *partNumber = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            theDataObject.partNumber = partNumber;
            NSString *partName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            theDataObject.partName = partName;
            NSString *projectNumber = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            theDataObject.projectNo = projectNumber;
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            theDataObject.name = name;
            NSString *company = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
            theDataObject.company = company;
            NSString *reason = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
            theDataObject.reason = reason;
            NSString *appURL = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
            theDataObject.appURL =  [[NSURL alloc] initWithString:appURL];
            NSString *date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)];
            theDataObject.date = date;
            
            isSuccess = TRUE;
        }
    } else {
        isSuccess = FALSE;
        
    }
    sqlite3_finalize(statement);
    
    return isSuccess;
}

/*
 * Select the values from user_info table.
 */

-(bool) selectUserDataFromTable {
    theDataObject = [self theAppDataObject];
    bool isSuccess = TRUE;
    
    NSString *query = [NSString stringWithFormat:@"select * from user_info"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_toolStatsDB, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            theDataObject.name = name;
            NSString *company = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            theDataObject.company = company;
            
            NSString *userFlag = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            theDataObject.userFlag = userFlag;
            
            isSuccess = TRUE;
        }
    } else {
        isSuccess = FALSE;
        
    }
    sqlite3_finalize(statement);
    
    return isSuccess;
}

/*
 * Select the values from home_user_info table.
 */

-(bool) selectHomeUserDataFromTable {
    theDataObject = [self theAppDataObject];
    bool isSuccess = TRUE;
    
    NSString *query = [NSString stringWithFormat:@"select * from home_user_info"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_toolStatsDB, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSString *prjNo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            theDataObject.hpjtNo = prjNo;
            
            NSString *proNo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            theDataObject.hproNo = proNo;
            
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            theDataObject.hname = name;
            
            NSString *company = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            theDataObject.hcompany = company;
            
            NSString *userFlag = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            theDataObject.huserFlag = userFlag;
            isSuccess = TRUE;
        }
    } else {
        isSuccess = FALSE;
        
    }
    sqlite3_finalize(statement);
    
    return isSuccess;
}

/*
 * delete element from scan_history table.
 */
-(BOOL)deleteFromScanHistoryTable:(NSString *) projectNum and:(NSString *) date {
    
    NSString *sqlStatement;
    BOOL retValue = YES;
    
    if (projectNum == nil && date == nil)
    {
        sqlStatement = [NSString stringWithFormat:@"DELETE FROM scan_history WHERE projectNum = NULL and data = NULL"];
    }
    else
    {
        sqlStatement = [NSString stringWithFormat:@"DELETE FROM scan_history WHERE projectNumber = \"%@\" and date = \"%@\"", projectNum, date];
    }
    sqlite3_stmt *compiledStatement;
    retValue = sqlite3_prepare_v2(_toolStatsDB, [sqlStatement UTF8String], -1, &compiledStatement, NULL);
    if (SQLITE_DONE != sqlite3_step(compiledStatement))
    {
        NSLog(@"Error while deleting data. '%s'", sqlite3_errmsg(_toolStatsDB));
        return NO;
    }
    sqlite3_finalize(compiledStatement);
    
    return retValue;
}

/*
 * delete the user_info table.
 */

-(BOOL)deleteUserTable {
    
    BOOL retValue = YES;
    
    const char *sqlStatement = "Delete from user_info";
    sqlite3_stmt *compiledStatement;
    retValue = sqlite3_prepare_v2(_toolStatsDB, sqlStatement, -1, &compiledStatement, NULL);
    if(SQLITE_DONE != sqlite3_step(compiledStatement))
    {
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(_toolStatsDB));
        return NO;
    }
    sqlite3_finalize(compiledStatement);
    
    return retValue;
}

/*
 * delete the home_user_info table.
 */

-(BOOL)deleteHomeUserTable {
    
    BOOL retValue = YES;
    
    const char *sqlStatement = "Delete from home_user_info";
    sqlite3_stmt *compiledStatement;
    retValue = sqlite3_prepare_v2(_toolStatsDB, sqlStatement, -1, &compiledStatement, NULL);
    if(SQLITE_DONE != sqlite3_step(compiledStatement))
    {
        NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(_toolStatsDB));
        return NO;
    }
    sqlite3_finalize(compiledStatement);
    
    return retValue;
}

- (NSMutableArray *)getScannedData
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSString *query = [NSString stringWithFormat:@"SELECT projectNumber, date FROM scan_history"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_toolStatsDB, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            // here we use the checklistitem class to populate MutableArray
            ChecklistItem *item = [[ChecklistItem alloc]init];
            item.projectNumber = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            item.dateTimeStamp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            item.checked = NO;
            [array addObject:item];
            item = nil;
        }
    }
    else
    {
        NSLog(@"No Data Found");
    }
    // Release the compiled statement from memory
    sqlite3_finalize(statement);
    return  array;
}


/*
 * close the database.
 */

- (void) closeDatabase {
    sqlite3_close(_toolStatsDB);
    _toolStatsDB = nil;
}
- (void)dealloc {
    sqlite3_close(_toolStatsDB);
}

@end
