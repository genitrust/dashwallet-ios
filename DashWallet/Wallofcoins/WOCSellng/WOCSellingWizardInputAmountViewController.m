//
//  WOCSellingWizardInputAmountViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingWizardInputAmountViewController.h"
#import "WOCSellingWizardOfferListViewController.h"
#import "WOCConstants.h"
#import "APIManager.h"
#import "WOCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "BRWalletManager.h"
#import "WOCAlertController.h"
#import "BRAppDelegate.h"
#import "WOCSellingVerifyDetailViewController.h"
#import "WOCSellingAdvancedOptionsInstructionsViewController.h"

#define dashTextField 101
#define dollarTextField 102

@interface WOCSellingWizardInputAmountViewController () <UITextFieldDelegate>

@end

@implementation WOCSellingWizardInputAmountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadowOnButton:self.btnGetOffers];
    self.titleLable.text = [NSString stringWithFormat:@"How much do you want per %@?",WOC_CURRENTCY];
    self.txtDash.text = @"Price Per Coin";
    self.txtDash.delegate = self;
    self.txtDollar.delegate = self;
    self.txtDash.userInteractionEnabled = NO;
    self.line1Height.constant = 1;
    self.line2Height.constant = 2;
    [self.txtDollar becomeFirstResponder];
}

// MARK: - IBAction

- (IBAction)getOffersClicked:(id)sender {
    
    NSString *dollarString = [self.txtDollar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([dollarString length] > 0 && [dollarString intValue] != 0) {
        
        if ([dollarString intValue] <10000000) {
            
            [self loadVarificationScreen];
            
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithTitle:ALERT_TITLE message:@"Amount must be less than $100000." viewController:self.navigationController.visibleViewController];
        }
    }
    else {
        [[WOCAlertController sharedInstance] alertshowWithTitle:ALERT_TITLE message:@"Enter amount." viewController:self.navigationController.visibleViewController];
    }
}

// MARK: - API
- (void)sendUserData:(NSString*)amount zipCode:(NSString*)zipCode bankId:(NSString*)bankId {
    
    if (self.txtDash != nil) {
        [self.txtDash resignFirstResponder];
    }
    
    if (self.txtDollar != nil) {
        [self.txtDollar resignFirstResponder];
    }
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *cryptoAddress = manager.wallet.receiveAddress;
    NSLog(@"cryptoAddress = %@",cryptoAddress);
    
    NSDictionary *params = @{
                             API_BODY_CRYPTO_AMOUNT: @"0",
                             API_BODY_USD_AMOUNT: amount,
                             API_BODY_CRYPTO: CRYPTO_CURRENTCY,
                             API_BODY_CRYPTO_ADDRESS:cryptoAddress,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    //Receive Crypto Currency Address...
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
    
    if (bankId == nil || bankId.length == 0) {
        NSString *countryCodeFromLatLong = [self.defaults objectForKey:API_BODY_COUNTRY_CODE];
        
        if (countryCodeFromLatLong == nil) {
            NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
            [dict setObject:countryCode.lowercaseString forKey:API_BODY_COUNTRY];
        }
        else {
            [dict setObject:countryCodeFromLatLong.lowercaseString forKey:API_BODY_COUNTRY];
        }
    }
    //[dict setObject:@"us" forKey:API_BODY_COUNTRY];

    params = (NSDictionary*)dict;
    
    [[APIManager sharedInstance] discoverInfo:params response:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSDictionary *dictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            if ([dictionary valueForKey:@"id"] != nil) {
                WOCSellingWizardOfferListViewController *offerListViewController = (WOCSellingWizardOfferListViewController*)[self getViewController:@"WOCSellingWizardOfferListViewController"];;
                offerListViewController.discoveryId = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]];
                offerListViewController.amount = self.txtDollar.text;
                [self pushViewController:offerListViewController animated:YES];
            }
            else {
                [[WOCAlertController sharedInstance] alertshowWithTitle:ALERT_TITLE message:@"Error in getting offers. Please try after some time." viewController:self.navigationController.visibleViewController];
            }
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}


-(void)loadVarificationScreen {
    
    [self.defaults setObject:self.txtDollar.text forKey:USER_DEFAULTS_LOCAL_PRICE];
    [self.defaults synchronize];
    
    [self.defaults setBool:YES forKey:@"beforeCreateAd"];
    [self.defaults synchronize];
    
    WOCSellingAdvancedOptionsInstructionsViewController *sellingAdvancedOptionsInstructionsViewController = [self getViewController:@"WOCSellingAdvancedOptionsInstructionsViewController"];
    [self pushViewController:sellingAdvancedOptionsInstructionsViewController animated:YES];
    [sellingAdvancedOptionsInstructionsViewController setupUI];
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

