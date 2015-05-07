//
//  GpsViewController.h
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
//#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
@import CoreLocation;

// here we forward declare the delegate
@protocol GpsViewDelegate;


@interface GpsViewController : UIViewController <CLLocationManagerDelegate> {
    //CLLocationManager *locationManager;
}

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *projectNo;
//@property (strong, nonatomic) CLLocationManager *locationManager;

// here we create delegeat
@property (nonatomic, weak) id <GpsViewDelegate> deldgate;

@end

// here we define the delegate method
@protocol GpsViewDelegate

//-(void)gpsViewDidFinishWithAnswer:(NSString *)answer;

@end