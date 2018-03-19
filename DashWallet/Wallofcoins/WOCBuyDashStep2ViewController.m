//
//  WOCBuyDashStep2ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep2ViewController.h"
#import "WOCBuyDashStep3ViewController.h"
#import "WOCBuyDashStep4ViewController.h"
#import "APIManager.h"
#import "WOCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
@interface WOCBuyDashStep2ViewController ()

@end

@implementation WOCBuyDashStep2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem.backBarButtonItem setTitle:@""];
    [self setShadow:self.btnNext];
}

// MARK: - IBAction

- (IBAction)nextClicked:(id)sender {
    
    [self.defaults removeObjectForKey:API_BODY_COUNTRY_CODE];
   
    [self.defaults synchronize];
    
    NSString *zipCode = [self.txtZipCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([zipCode length] == 0) {
        [self push:@"WOCBuyDashStep3ViewController"];
    }
    else if ([zipCode length] > 6 ) {
         [[WOCAlertController sharedInstance] alertshowWithTitle:ALERT_TITLE message:@"Enter valid zipcode" viewController:self.navigationController.visibleViewController];
    }
    else {
        
        [self setCountryWithZipCode:zipCode];
        
        WOCBuyDashStep4ViewController *myViewController = (WOCBuyDashStep4ViewController*)[self getViewController:@"WOCBuyDashStep4ViewController"];;
        myViewController.zipCode = zipCode;
        [self pushViewController:myViewController animated:YES];
    }
}

-(void)setCountryWithZipCode:(NSString*)zipCode {
    
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    postalAddress.postalCode = zipCode;
    postalAddress.country = @"us";
    postalAddress.state = @"";
    if (@available(iOS 11.0, *)) {
        [geoCoder geocodePostalAddress:postalAddress completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0) {
                CLPlacemark* placemark = [placemarks objectAtIndex:0];
                [self.defaults setObject:[placemark ISOcountryCode].lowercaseString forKey:API_BODY_COUNTRY_CODE];
                [self.defaults synchronize];
                NSLog(@"%@",[placemark description]);
                NSLog(@"======> country code is %@",[placemark ISOcountryCode]);
            }
            else {
                NSLog(@"Error in featching Country =");
            }
        }];
    }
    else {
        // Fallback on earlier versions
        [geoCoder geocodeAddressDictionary:@{(NSString*)kABPersonAddressZIPKey : zipCode,(NSString*)kABPersonAddressCountryCodeKey : @"us"}
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             if ([placemarks count] > 0) {
                                 CLPlacemark* placemark = [placemarks objectAtIndex:0];
                                 
                                 NSString* city = placemark.addressDictionary[(NSString*)kABPersonAddressCityKey];
                                 NSString* state = placemark.addressDictionary[(NSString*)kABPersonAddressStateKey];
                                 NSString* country = placemark.addressDictionary[(NSString*)kABPersonAddressCountryCodeKey];
                                 
                                 [self.defaults setObject:country.lowercaseString forKey:API_BODY_COUNTRY_CODE];
                                 [self.defaults synchronize];
                                 NSLog(@"%@",[placemark description]);
                                 NSLog(@"======> country code is city [%@] state [%@] country [%@]",city,state,country);
                                 
                             } else {
                                 // Lookup Failed
                                 NSLog(@"Error in featching Country =");
                             }
                         }];
    }
    
    //    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //    [geocoder geocodeAddressString:zipCode completionHandler:^(NSArray *placemarks, NSError *error) {
    //
    //        if(error != nil)
    //        {
    //            NSLog(@"error from geocoder is %@", [error localizedDescription]);
    //        } else {
    //            for(CLPlacemark *placemark in placemarks){
    //                NSString *city1 = [placemark locality];
    //                NSLog(@"city is %@",city1);
    //                NSLog(@"======> country code is %@",[placemark ISOcountryCode]);
    //                NSLog(@"country is %@",[placemark country]);
    //                // you'll see a whole lotta stuff is available
    //                // in the placemark object here...
    //
    //                [self.defaults setObject:[placemark ISOcountryCode].lowercaseString forKey:API_BODY_COUNTRY_CODE];
    //                [self.defaults synchronize];
    //                NSLog(@"%@",[placemark description]);
    //            }
    //        }
    //    }];
}

@end

