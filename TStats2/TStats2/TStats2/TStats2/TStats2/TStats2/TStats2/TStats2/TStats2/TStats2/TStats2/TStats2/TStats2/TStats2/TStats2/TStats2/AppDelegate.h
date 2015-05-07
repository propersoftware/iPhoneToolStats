//
//  AppDelegate.h
//  TStats2
//
//  Created by anwosu on 4/7/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegateProtocol.h"

@class BarCodeObjects;

@interface AppDelegate : UIResponder <UIApplicationDelegate, AppDelegateProtocol> {
    BarCodeObjects *theAppDataObject;
}

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) IBOutlet BarCodeObjects *theAppDataObject;

@end

