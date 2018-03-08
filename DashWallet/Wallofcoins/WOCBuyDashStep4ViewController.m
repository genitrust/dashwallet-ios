//
//  WOCBuyDashStep4ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep4ViewController.h"
#import "WOCBuyDashStep5ViewController.h"
#import "WOCConstants.h"
#import "APIManager.h"
#import "WOCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "BRWalletManager.h"
#import "WOCAlertController.h"
#import "BRAppDelegate.h"

#define dashTextField 101
#define dollarTextField 102

@interface WOCBuyDashStep4ViewController () <UITextFieldDelegate>

@end

@implementation WOCBuyDashStep4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadow:self.btnGetOffers];
    
    self.txtDash.text = @"to acquire Dash (Đ) (1,000,000 đots = 1 ĐASH)";
    self.txtDash.delegate = self;
    self.txtDollar.delegate = self;
    [self.txtDash setUserInteractionEnabled:NO];
    self.line1Height.constant = 1;
    self.line2Height.constant = 2;
    [self.txtDollar becomeFirstResponder];
}

// MARK: - IBAction

- (IBAction)getOffersClicked:(id)sender {
    
    NSString *dollarString = [self.txtDollar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([dollarString length] > 0 && [dollarString intValue] != 0) {
        if ([dollarString intValue] >= 5) {
            
            if ([dollarString intValue] <100000) {
                if ((self.zipCode != nil && [self.zipCode length] > 0) || (self.bankId != nil && [self.bankId length] > 0)) {
                    if ([self.zipCode length] > 0) {
                        [self sendUserData:dollarString zipCode:self.zipCode bankId:@""];
                    }
                    else if ([self.bankId length] > 0) {
                        [self sendUserData:dollarString zipCode:@"" bankId:self.bankId];
                    }
                }
                else {
                    [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"zipCode or bankId is empty." viewController:self.navigationController.visibleViewController];
                }
            }
            else {
                [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"Amount must be less than $100000." viewController:self.navigationController.visibleViewController];
            }
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"Amount must be more than $5." viewController:self.navigationController.visibleViewController];
        }
    }
    else {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"Enter amount." viewController:self.navigationController.visibleViewController];
    }
}

// MARK: - API

- (void)sendUserData:(NSString*)amount zipCode:(NSString*)zipCode bankId:(NSString*)bankId {
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *cryptoAddress = manager.wallet.receiveAddress;
    NSLog(@"cryptoAddress = %@",cryptoAddress);
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_BODY_CRYPTO_AMOUNT: @"0",
                             API_BODY_USD_AMOUNT: amount,
                             API_BODY_CRYPTO: @"DASH",
                             API_BODY_CRYPTO_ADDRESS:cryptoAddress,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    //Receive Dash Address...
    NSString *latitude = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LATITUDE];
    NSString *longitude = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE];
    
    if (latitude == nil && longitude == nil) {
        latitude = @"";
        longitude = @"";
    }
   
    if (latitude.length > 0 && longitude.length > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
        [dict setObject:@{API_BODY_LATITUDE:latitude ,
                          API_BODY_LONGITUDE:longitude } forKey:API_BODY_BROWSERLOCATION];
        params = (NSDictionary*)dict;
    }
    
    if (zipCode != nil && zipCode.length > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
        [dict setObject:zipCode forKey:API_BODY_ZIP_CODE];
        params = (NSDictionary*)dict;
    }
    
    if (bankId != nil && bankId.length > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
        [dict setObject:bankId forKey:API_BODY_BANK];
        params = (NSDictionary*)dict;
    }
   
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    NSString *countryCodeFromLatLong = [self.defaults objectForKey:API_BODY_COUNTRY_CODE];
    
    if (countryCodeFromLatLong == nil) {
        NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
        [dict setObject:countryCode.lowercaseString forKey:API_BODY_COUNTRY];
    }
    else {
        [dict setObject:countryCodeFromLatLong.lowercaseString forKey:API_BODY_COUNTRY];
    }
    
    //[dict setObject:@"us" forKey:API_BODY_COUNTRY];

    params = (NSDictionary*)dict;
    
    [[APIManager sharedInstance] discoverInfo:params response:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSDictionary *dictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            WOCBuyDashStep5ViewController *myViewController = (WOCBuyDashStep5ViewController*)[self getViewController:@"WOCBuyDashStep5ViewController"];;
            myViewController.discoveryId = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]];
            myViewController.amount = self.txtDollar.text;
            [self pushViewController:myViewController animated:YES];
        }
        else {
            
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

// MARK: - UITextField Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == dashTextField) {
        self.line1Height.constant = 2;
        self.line2Height.constant = 1;
    }
    else {
        self.line1Height.constant = 1;
        self.line2Height.constant = 2;
    }
}

@end

