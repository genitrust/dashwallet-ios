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
    else {
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:zipCode completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if(error != nil)
            {
                NSLog(@"error from geocoder is %@", [error localizedDescription]);
            } else {
                for(CLPlacemark *placemark in placemarks){
                    NSString *city1 = [placemark locality];
                    NSLog(@"city is %@",city1);
                    NSLog(@"country code is %@",[placemark ISOcountryCode]);
                    NSLog(@"country is %@",[placemark country]);
                    // you'll see a whole lotta stuff is available
                    // in the placemark object here...
                    
                    [self.defaults setObject:[placemark ISOcountryCode].lowercaseString forKey:API_BODY_COUNTRY_CODE];
                    [self.defaults synchronize];
                    NSLog(@"%@",[placemark description]);
                }
            }
        }];
        
        WOCBuyDashStep4ViewController *myViewController = (WOCBuyDashStep4ViewController*)[self getViewController:@"WOCBuyDashStep4ViewController"];;
        myViewController.zipCode = zipCode;
        [self pushViewController:myViewController animated:YES];
    }
}
@end

