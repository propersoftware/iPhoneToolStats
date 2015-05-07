//
//GpsViewController.m
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




#import "GpsViewController.h"
#import "EditLocationViewController.h"
@import CoreLocation;

@interface GpsViewController () <EditLocationViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *gpsLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressHeaderLabel;
@property (weak, nonatomic) IBOutlet UITextField *commentsTextField;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBbuttonItem;

@property (retain, nonatomic) NSString *subThoroughfare;
@property (retain, nonatomic) NSString *thoroughfare;
@property (retain, nonatomic) NSString *locality;
@property (retain, nonatomic) NSString *administrativeArea;
@property (retain, nonatomic) NSString *postalCode;
@property (retain, nonatomic) NSString *country;
@property (retain, nonatomic) NSString *isManualInput;
@property (retain, nonatomic) NSString *gpsLatitude;
@property (retain, nonatomic) NSString *gpsLongitude;
@property (strong, nonatomic) NSString *comment;

@property (strong, nonatomic) NSString *address1, *address2;
@property (weak, nonatomic) IBOutlet UILabel *gpsSubmissionResponseLabel;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *bottomMaskView;
@property (weak, nonatomic) IBOutlet UIView *topMaskView;
@property (weak, nonatomic) IBOutlet UILabel *topMaskLabel;
@property (weak, nonatomic) IBOutlet UIButton *topMaskButton;

@end

@implementation GpsViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // here we hide the nested views
    _bottomMaskView.hidden = YES;
    _topMaskView.hidden = YES;
    
    // here we unhide the lower navigation controller
    [self.navigationController setToolbarHidden:NO];
    
    // here we add the toolstats logo to the navbar
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_ios_xsm.png"]];
    
    // here we make the navigation bar clear
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    // here we initialize the CLLocationManager object
    locationManager = [[CLLocationManager alloc] init];
    
    geocoder = [[CLGeocoder alloc] init];
    _addressHeaderLabel.text = @"Current Location:";
    
    // here we hide the edit buttons on load
    self.submitButtonItem.enabled = NO;
    self.editBbuttonItem.enabled = NO;
    
    if ((_subThoroughfare != (id)[NSNull null] && _subThoroughfare.length > 0)
        || (_thoroughfare != (id)[NSNull null] && _thoroughfare.length > 0)
        || (_locality != (id)[NSNull null] && _locality.length > 0)
        || (_administrativeArea != (id)[NSNull null] && _administrativeArea.length > 0)
        || (_postalCode != (id)[NSNull null] && _postalCode.length > 0)
        || (_country != (id)[NSNull null] && _country.length > 0)) {
        _gpsLocationLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@ %@\n%@",
                                  _subThoroughfare, _thoroughfare,
                                  _locality,
                                  _administrativeArea, _postalCode,
                                  _country];
        
        // here we set the lat, long values to zero. web app cannot parse null values
        self.gpsLongitude = @"0";
        self.gpsLatitude = @"0";
        
        
        // here we retain the original comment
        _commentsTextField.text = _comment;
        
        // unhide buttons
        self.editBbuttonItem.enabled = YES;
        self.submitButtonItem.enabled = YES;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editCurrentLocation:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowEditLocationView" sender:self];
}

- (IBAction)getCurrentLocation:(id)sender {
    
    // here we start the network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    ///*
    // here we add for iOS8
    locationManager.delegate = self;
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    //    self.map.showsUserLocation = YES;
    //*/
    [locationManager startUpdatingLocation];
}

- (IBAction)submitCurrentLocation:(id)sender {
    // todo
    NSString *add1 = [NSString stringWithFormat:@"%@ %@", _subThoroughfare, _thoroughfare];
    NSString *add2 = @"";
    NSString *city = _locality;
    NSString *statProv = _administrativeArea;
    NSString *zipCd = _postalCode;
    NSString *countryCd;
    NSString *lat = _gpsLatitude;
    NSString *lon = _gpsLongitude;
    //NSString *isManualInput = @"1";
    NSString *com = _commentsTextField.text;
    //NSString *pnum = _projectNo;
    
    //-- delete test
    _userName = @"testing"; _companyName = @"testing";
    //--<
    
    // here we parse the country info
    if ([[_country lowercaseString]isEqualToString:@"united states"] || [[_country lowercaseString]isEqualToString:@"usa"]) {
        countryCd = @"USA";
    }
    else if ([[_country lowercaseString]isEqualToString:@"canada"] || [[_country lowercaseString]isEqualToString:@"can"]){
        countryCd = @"CAN";
    }
    else if ([[_country lowercaseString] isEqualToString:@"mexico"] || [[_country lowercaseString] isEqualToString:@"mex"]){
        countryCd = @"MEX";
    }
    else countryCd = @"USA";
    
    
    //NSString *post = [NSString stringWithFormat:@"email=%@", var]; // set the variable to pass into the api
    NSString *post = [NSString stringWithFormat:@"userName=%@&companyName=%@&projectNo=%@&address1=%@&address2=%@&city=%@&stateProv=%@&zipCode=%@&country=%@&lat=%@&longitude=%@&isManualInput=%@&comment=%@&",_userName, _companyName, _projectNo, add1, add2, city, statProv, zipCd, countryCd, lat, lon, _isManualInput, com];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; // make the request to the api
    [request setURL:[NSURL URLWithString:@"http://toolstatsinfo.com/json/PostGpsDataAndroid/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response; // Grab the response from the API and decode it
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    //----todo----> check the variable error from above and post a warning/retry
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    
    
    NSData *data = [theReply dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    //NSLog(@"%@", [json objectForKey:@"Data"]); //--- for testing
    
    // here we hide the bottom bar buttons
    self.submitButtonItem.enabled = NO;
    self.editBbuttonItem.enabled = NO;
    self.scanButtonItem.enabled = NO;
    
    self.navigationItem.hidesBackButton = YES;
    
    // here we build the view to show if data posted to databse
    _bottomMaskView.hidden = NO;
    _topMaskView.hidden = NO;
    _topMaskView.layer.cornerRadius = 10;
    _topMaskButton.layer.cornerRadius = 10;
    _topMaskButton.layer.borderColor = [UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1].CGColor;
    _topMaskButton.layer.borderWidth = 1;
    
    if([[json objectForKey:@"Data"]  isEqual: @"true"])
    {
        _topMaskLabel.text = @"GPS Location Data submitted successfully.";
    } else {
        _topMaskLabel.text = @"GPS Location Data NOT SUBMITTED.";
        [_topMaskLabel setTextColor:[UIColor redColor]];
    }
    
}

- (IBAction)hideKeyBoard:(id)sender {
    [self.commentsTextField resignFirstResponder];
}

// here we hide keyboard on tap gesture - needed for UIScrollView
- (IBAction)hideKeyBoardOnTap:(id)sender {
    [self.commentsTextField endEditing:YES];
}

// here we dismiss the view when we touch outside of text area.
// ** this method does NOT work in a UIScrollView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark = CLLocationMangerDelegate

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //NSLog(@"didFailWithError: %@", error);// for testing ---------------->
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Faliled to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations objectAtIndex:0];
    
    if (currentLocation != nil) {
        // todo
        self.gpsLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.gpsLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        // here we show submit and edit buttons
        self.submitButtonItem.enabled = YES;
        self.editBbuttonItem.enabled = YES;
    }
    else {
        _gpsLongitude = nil;
        _gpsLatitude = nil;
    }
    
    // Stop Location Manger
    [locationManager stopUpdatingLocation];
    
    
    // Reverse Geocoding
    //NSLog(@"Resolving the Address"); // for testing ---------------->
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);// for testing ---------------->
        if(error == nil &&[placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            NSString *subThoroughfareNilChecked;
            // here we initialize location variables
            
            // here if street number is null we write white space instead of (null)
            if (placemark.subThoroughfare == nil) {
                subThoroughfareNilChecked = @"";
            } else {
                subThoroughfareNilChecked = placemark.subThoroughfare;
            }
            
            self.gpsLocationLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@ %@\n%@",
                                          subThoroughfareNilChecked //placemark.subThoroughfare
                                          , placemark.thoroughfare,
                                          placemark.locality,
                                          placemark.administrativeArea, placemark.postalCode,
                                          placemark.country];
            _subThoroughfare = placemark.subThoroughfare;
            _thoroughfare = placemark.thoroughfare;
            _locality = placemark.locality;
            _administrativeArea = placemark.administrativeArea;
            _postalCode = placemark.postalCode;
            _country = placemark.country;
            _isManualInput = @"false";
            //NSLog(@"%@",placemark.subThoroughfare);// for testing ---------------->
        } else {
            //NSLog(@"%@", error.debugDescription);// for testing ---------------->
        }
        
        
        // here we zoom the map to current location
        MKCoordinateRegion mapRegion;
        mapRegion.center.latitude=currentLocation.coordinate.latitude;
        mapRegion.center.longitude=currentLocation.coordinate.longitude;
        mapRegion.span.latitudeDelta=0.1;
        mapRegion.span.longitudeDelta=0.1;
        [_map setRegion:mapRegion animated:YES];
        
        // here we initialize the pin
        MKPlacemark *mapPlacemark = [[MKPlacemark alloc]initWithPlacemark:placemark];
        
        // here we drop previous pin then place the next pin
        [self.map removeAnnotation:self.map.annotations.lastObject];
        [self.map addAnnotation:mapPlacemark];
        
        // here we stop the network activity animation because gps search finished
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowEditLocationView"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        EditLocationViewController *editLocationVC = [navigationController viewControllers][0];
        editLocationVC.delegate = self;
        editLocationVC.streetNumber = self.subThoroughfare;
        editLocationVC.streetName = self.thoroughfare;
        editLocationVC.city = self.locality;
        editLocationVC.state = self.administrativeArea;
        editLocationVC.zipCode = self.postalCode;
        editLocationVC.country = self.country;
        editLocationVC.userName = self.userName;
        editLocationVC.companyName = self.companyName;
        //editLocationVC.projectNo = self.projectNo;
    }
}

- (void)editLocationViewControllerDidCancel:(EditLocationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editLocationViewController:(EditLocationViewController *)controller didCommit:(NSArray *)answer {
    // here we initialize address variables with new values
    self.subThoroughfare = answer[0];
    self.thoroughfare = answer[1];
    self.locality = answer[2];
    self.administrativeArea = answer[3];
    self.postalCode = answer[4];
    self.country = answer[5];
    
    _gpsLocationLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@ %@\n%@",
                              _subThoroughfare, _thoroughfare,
                              _locality,_administrativeArea, _postalCode,
                              _country];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    // here we update the apple map to show the new address
    [geocoder geocodeAddressString:_gpsLocationLabel.text completionHandler:^(NSArray *placemarks, NSError *error){
        //--
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            CLPlacemark *firstPlacemark = [placemarks lastObject];
            MKPlacemark *mapPlacemark = [[MKPlacemark alloc]initWithPlacemark:firstPlacemark];
            
            // here we remove previous pin
            [self.map removeAnnotation:self.map.annotations.lastObject];
            
            MKCoordinateRegion mapRegion;
            mapRegion.center.latitude = firstPlacemark.location.coordinate.latitude;
            mapRegion.center.longitude = firstPlacemark.location.coordinate.longitude;
            mapRegion.span.latitudeDelta = 0.00725;
            mapRegion.span.longitudeDelta = 0.00725;
            
            // here we move to the location
            [self.map setRegion:mapRegion animated:YES];
            
            // here we drop pin on location
            [self.map addAnnotation:mapPlacemark];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// for iOS 8
- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

@end
