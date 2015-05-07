//
//  ChecklistItem.h
//  TStats2
//
//  Created by anwosu on 4/24/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChecklistItem : NSObject
@property (nonatomic, copy)NSString *projectNumber;
@property (nonatomic, copy)NSString *dateTimeStamp;
@property (nonatomic, assign)BOOL checked;
@end
