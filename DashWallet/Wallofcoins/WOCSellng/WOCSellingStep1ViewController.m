//
//  WOCSellingStep1ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingStep1ViewController.h"
#import "WOCLocationManager.h"
#import "WOCSellingStep2ViewController.h"
#import "WOCSellingStep3ViewController.h"
#import "WOCSellingStep4ViewController.h"
#import "WOCConstants.h"
#import "BRAppDelegate.h"
#import "BRRootViewController.h"
#import "MBProgressHUD.h"
#import "APIManager.h"
#import "WOCAlertController.h"
#import "WOCSellingStep6ViewController.h"
#import "WOCSellingStep7ViewController.h"

@interface WOCSellingStep1ViewController ()

@property (strong, nonatomic) NSString *zipCode;

@end

@implementation WOCSellingStep1ViewController

- (void)viewDidLoad {
    
    self.requiredBackButton = TRUE;
    
    [super viewDidLoad];
    
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_LOCATION_LATITUDE];
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE];
    
    [[NSNotificationCenter defaultCenter] removeObserver:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1];
    [[NSNotificationCenter defaultCenter] removeObserver:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_2];
    [[NSNotificationCenter defaultCenter] removeObserver:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_4];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLogoutButton) name:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep2) name:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_2 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findZipCode) name:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_4 object:nil];
    
    [self.btnSellYourCrypto setTitle:[NSString stringWithFormat:@"SELL YOUR %@",WOC_CURRENTCY_SPECIAL] forState:UIControlStateNormal];
    [self setShadow:self.btnSellYourCrypto];
    [self setShadow:self.btnNoThanks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setLogoutButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.btnLocation setUserInteractionEnabled:YES];
}

-(void)setLogoutButton {
    
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        
        NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
        NSString *loginPhone = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",phoneNo];
        self.lblDescription.text = loginPhone;
        [self.btnSignOut setTitle:@"SIGN OUT" forState:UIControlStateNormal];
        [self.signoutView setHidden:NO];
        [self.orderListBtn setHidden:NO];
    }
    else {
        NSString *loginPhone = [NSString stringWithFormat:@"Do you already have an order?"];
        self.lblDescription.text = loginPhone;
        [self.btnSignOut setTitle:@"SIGN IN HERE" forState:UIControlStateNormal];
        [self.orderListBtn setHidden:YES];
        [self.signoutView setHidden:NO];
    }
    
    [self setShadow:self.btnSignOut];
    [self setShadow:self.orderListBtn];
}

-(void)openBuyDashStep2 {
    [self push:@"WOCSellingStep2ViewController"];
}

-(void)openBuyDashStep3 {
    [self push:@"WOCSellingStep3ViewController"];
}

- (void)openBuyDashStep4 {
    WOCSellingStep4ViewController *myViewController = (WOCSellingStep4ViewController*)[self getViewController:@"WOCSellingStep4ViewController"];
    myViewController.zipCode = self.zipCode;
    [self pushViewController:myViewController animated:YES];
}

- (void)back:(id)sender {
    [self backToRoot];
}

- (void)showAlert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE message:@"Are you in the USA?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self refereshToken];
        [self openBuyDashStep2];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self refereshToken];
        [self openBuyDashStep3];
       
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)findZipCode {
    
    [self.btnLocation setUserInteractionEnabled:YES];
    
    // Your location from latitude and longitude
    NSString *latitude = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LATITUDE];
    NSString *longitude = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE];
    
    if (latitude != nil && longitude != nil) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];

        // Call the method to find the address
        [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *placeDetail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            NSLog(@"address informations : %@", placeDetail);
            NSLog(@"ZIP code : %@", [placeDetail valueForKey:@"ZIP"]);
            
            [self.defaults setObject:[placeDetail valueForKey:API_BODY_COUNTRY_CODE] forKey:API_BODY_COUNTRY_CODE];
            [self.defaults synchronize];
            self.zipCode = [placeDetail valueForKey:@"ZIP"];
            [self openBuyDashStep4];
        }
        failureHandler:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            [self.defaults removeObjectForKey:API_BODY_COUNTRY_CODE];
            NSLog(@"Error : %@", error);
        }];
    }
    else {
        
        [self.defaults removeObjectForKey:API_BODY_COUNTRY_CODE];
        [[WOCLocationManager sharedInstance] startLocationService];
    }
}

- (void)getAddressFromLocation:(CLLocation *)location completionHandler:(void (^)(NSMutableDictionary *placemark))completionHandler failureHandler:(void (^)(NSError *error))failureHandler {
    
    NSMutableDictionary *d = [NSMutableDictionary new];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (failureHandler && (error || placemarks.count == 0)) {
            failureHandler(error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(completionHandler) {
                
                completionHandler([NSMutableDictionary dictionaryWithDictionary:placemark.addressDictionary]);
            }
        }
    }];
}

// MARK: - API
- (void)signOut:(NSString*)phone {
    
    [self signOutWOC];
}
- (IBAction)onOrderListClick:(id)sender {
    
    [self getOrderList];
}

// MARK: - IBAction

- (IBAction)backBtnClicked:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self backToRoot];
       // [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController.navigationBar setHidden:NO];
    });
}

- (IBAction)findLocationClicked:(id)sender {
    
    [self refereshToken];
    [self.defaults removeObjectForKey:API_BODY_COUNTRY_CODE];
    [self.defaults synchronize];
    if ([[WOCLocationManager sharedInstance] locationServiceEnabled]) {
        
        [self findZipCode];
        [self.btnLocation setUserInteractionEnabled:NO];
    }
    else {
        // Enable Location services
        [[WOCLocationManager sharedInstance] startLocationService];
        [self.btnLocation setUserInteractionEnabled:NO];
    }
}

- (IBAction)noThanksClicked:(id)sender {
    
    [self.defaults removeObjectForKey:API_BODY_COUNTRY_CODE];
    [self.defaults synchronize];
    [self showAlert];
}

- (IBAction)signOutClicked:(id)sender {
   
    UIButton * btn = (UIButton*) sender;
    if (btn != nil) {
        if ([btn.titleLabel.text isEqualToString:@"SIGN IN HERE"]) {
            [self push:@"WOCSellingSignInViewController"];
        }
        else {
           [self signOutWOC];
        }
    }
    [self performSelector:@selector(setLogoutButton) withObject:nil afterDelay:1.0];
}

- (IBAction)sellYourCryptoClicked:(id)sender {
    
    NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    
    if (phoneNo == nil || phoneNo.length == 0)
    {
        WOCSellingStep7ViewController *myViewController = [self getViewController:@"WOCSellingStep7ViewController"];
        myViewController.offerId = @"";
        myViewController.emailId = @"";
        [self pushViewController:myViewController animated:YES];
    }
    else {
        WOCSellingStep6ViewController *myViewController = [self getViewController:@"WOCSellingStep6ViewController"];
        [self pushViewController:myViewController animated:YES];
    }
}
@end
