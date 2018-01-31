//
//  WOCLocationManager.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCLocationManager.h"

@implementation WOCLocationManager

+ (WOCLocationManager *)sharedInstance {

    static dispatch_once_t onceToken;
    static WOCLocationManager *locationManager;

    dispatch_once(&onceToken, ^{
        locationManager = [[WOCLocationManager alloc] init];
    });

    return locationManager;
}

- (void)startLocationService {
    self.manager = [[CLLocationManager alloc] init];
    self.manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.manager.delegate = self;
    [self.manager requestWhenInUseAuthorization];
    [self.manager startUpdatingLocation];
}

- (BOOL)locationServiceEnabled {

    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedWhenInUse :
                return YES;
                break;
            default:
                return NO;
                break;
        }
    } else {
        return NO;
    }
}

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    if ([locations count]) {
        self.lastLocation = [locations lastObject];
        
        if ([NSString stringWithFormat:@"%f",self.lastLocation.coordinate.latitude] != nil)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",self.lastLocation.coordinate.latitude] forKey:@"locationLatitude"];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",self.lastLocation.coordinate.longitude] forKey:@"locationLongitude"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    if (status == kCLAuthorizationStatusDenied) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openBuyDashStep2" object:nil];
        
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openBuyDashStep4" object:nil];
    }
}

- (void)showLocationAlertPopup {
    
    UIAlertController *alert = [UIAlertController
                               alertControllerWithTitle:@"Allow \"Dash\" to Access Your Location While You Use the App?" message:@"Your current location will be used to show you birds nearby."preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:@"Don't Allow"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                }];
    
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:@"Allow"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                   
                                   if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                                       [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
                                   }
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
}

@end
