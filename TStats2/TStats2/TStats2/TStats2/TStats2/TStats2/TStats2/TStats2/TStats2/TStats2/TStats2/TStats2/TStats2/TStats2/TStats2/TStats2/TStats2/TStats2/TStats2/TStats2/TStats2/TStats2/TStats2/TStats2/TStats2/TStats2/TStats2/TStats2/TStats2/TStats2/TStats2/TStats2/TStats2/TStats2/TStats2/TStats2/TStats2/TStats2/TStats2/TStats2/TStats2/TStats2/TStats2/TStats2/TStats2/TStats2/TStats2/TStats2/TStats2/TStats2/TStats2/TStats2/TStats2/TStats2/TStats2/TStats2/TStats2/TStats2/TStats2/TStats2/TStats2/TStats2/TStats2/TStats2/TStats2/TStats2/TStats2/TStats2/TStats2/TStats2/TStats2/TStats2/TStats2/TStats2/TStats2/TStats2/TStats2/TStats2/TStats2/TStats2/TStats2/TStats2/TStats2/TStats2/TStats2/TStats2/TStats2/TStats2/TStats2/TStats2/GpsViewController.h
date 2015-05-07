//
//  GpsViewController.h
//  TStats2
//
//  Created by anwosu on 4/15/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

// here we forward declare the delegate
@protocol GpsViewDelegate;


@interface GpsViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *projectNo;

// here we create delegeat
@property (nonatomic, weak) id <GpsViewDelegate> deldgate;

@end

// here we define the delegate method
@protocol GpsViewDelegate

//-(void)gpsViewDidFinishWithAnswer:(NSString *)answer;

@end