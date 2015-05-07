//
//  BarCodeObjects.h
//  TStats2
//
//  Created by anwosu on 4/28/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "AppDataObject.h"

@interface BarCodeObjects : AppDataObject

{
    NSString *projectNo;
    NSString *customerName;
    NSString *programName;
    NSString *partName;
    NSString *partNumber;
    NSString *name;
    NSString *company;
    NSString *userFlag;
    NSString *date;
    NSString *reason;
    //NSString *hpjtNo;
    //NSString *hproNo;
    //NSString *hname;
    //NSString *hcompany;
    //NSString *huserFlag;
    bool isReason;
    bool isHistory;
    NSURL *webAppURL;
    NSURL *appURL;
    bool isLandscape;
    NSString *baseURL;
    NSString *coutDate;
    NSString *proToolNo;
    NSString *chkResStatus;
    NSString *shopName;
    NSString *pjtStatus;
    NSString *comments;
}

@property (nonatomic, copy) NSString *projectNo;
@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, copy) NSString *programName;
@property (nonatomic, copy) NSString *partName;
@property (nonatomic, copy) NSString *partNumber;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSString *userFlag;
@property (nonatomic, copy) NSString *hpjtNo;
@property (nonatomic, copy) NSString *hproNo;
@property (nonatomic, copy) NSString *hname;
@property (nonatomic, copy) NSString *hcompany;
@property (nonatomic, copy) NSString *huserFlag;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *cinDate;
@property (nonatomic, copy) NSString *proToolNo;
@property (nonatomic, copy) NSString *chkResStatus;
@property (nonatomic, copy) NSString *shopName;
@property (nonatomic, copy) NSString *pjtStatus;
@property (nonatomic, copy) NSString *comments;

@property  bool isReason;
@property  bool isLandscape;
@property  bool isHistory;
@property (nonatomic, copy) NSURL *webAppURL;
@property (nonatomic, copy) NSURL *appURL;

@end
