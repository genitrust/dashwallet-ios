//
//  WOCSellingWizardConfirmCodeViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingWizardConfirmCodeViewController.h"
#import "WOCSellingAdsInstructionsViewController.h"
#import "WOCSellingSummaryViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCAlertController.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "MBProgressHUD.h"

@interface WOCSellingWizardConfirmCodeViewController () <UITextFieldDelegate>

@end

@implementation WOCSellingWizardConfirmCodeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setShadowOnButton:self.btnPurchaseCode];
    
    NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    
    self.descLable.text = [NSString stringWithFormat:@"The Mobile phone %@ will receive a verification code within 10 seconds.When you receive the code, input it below.",phoneNo];
    if (self.purchaseCode != nil) {
        self.txtPurchaseCode.text = REMOVE_NULL_VALUE(self.purchaseCode);
    } else {
        self.txtPurchaseCode.text = @"";
    }
    self.txtPurchaseCode.delegate = self;
    [self.txtPurchaseCode becomeFirstResponder] ;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField.text.length == 4 && string.length == 1)
    {
        [self performSelector:@selector(confirmPurchaseCodeClicked:) withObject:self afterDelay:1.0];
    }
    return YES;
}

// MARK: - IBAction

- (IBAction)confirmPurchaseCodeClicked:(id)sender {
    
    NSString *txtCode = [self.txtPurchaseCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([txtCode length] == 5) {
    
        NSString *emailAddress = REMOVE_NULL_VALUE([self.defaults objectForKey:USER_DEFAULTS_LOCAL_EMAIL]);
        NSString *bankAccountInfo = REMOVE_NULL_VALUE([self.defaults objectForKey:USER_DEFAULTS_LOCAL_BANK_INFO]);
        NSString *bankAccountID = REMOVE_NULL_VALUE([self.defaults objectForKey:USER_DEFAULTS_LOCAL_BANK_ACCOUNT]);
        NSString *bankAccount = REMOVE_NULL_VALUE([self.defaults objectForKey:USER_DEFAULTS_LOCAL_BANK_ACCOUNT_NUMBER]);
        NSString *bankName = REMOVE_NULL_VALUE([self.defaults objectForKey:USER_DEFAULTS_LOCAL_BANK_NAME]);
        NSString *currentPrice = REMOVE_NULL_VALUE([self.defaults objectForKey:USER_DEFAULTS_LOCAL_PRICE]);
        NSString *deviceCode = REMOVE_NULL_VALUE([self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE]);
        NSString *deviceId = REMOVE_NULL_VALUE([self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_ID]);
        NSString *token = REMOVE_NULL_VALUE([self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN]);
        NSString *phoneNumber = REMOVE_NULL_VALUE([self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER]);
        NSString *phoneCode = REMOVE_NULL_VALUE([self.defaults valueForKey:USER_DEFAULTS_LOCAL_COUNTRY_CODE]);
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",phoneCode] withString:@""];
        phoneCode = [phoneCode stringByReplacingOccurrencesOfString:@"+" withString:@""];

        NSDictionary *params = @{
                                 API_BODY_DEVICE_CODE: deviceCode
                                 };
        
        if (deviceId != nil) {
            
            params = @{
                       API_BODY_PHONE_NUMBER:phoneNumber,
                       API_BODY_EMAIL:emailAddress,
                       @"phoneCode": phoneCode,
                       @"bankBusiness": bankAccountID,
                       @"sellCrypto": CRYPTO_CURRENTCY,
                       @"userEnabled": @"true",
                       @"dynamicPrice": @"false",
                       @"currentPrice": currentPrice,
                       @"name": bankName,
                       @"number":  bankAccount,
                       @"number2": bankAccount,
                       API_BODY_DEVICE_CODE: deviceCode,
                       API_BODY_DEVICE_ID: deviceId,
                       API_BODY_JSON_PARAMETER: @"YES"
                       };
            [[APIManager sharedInstance] createAd:params response:^(id responseDict, NSError *error) {
                
                if (error == nil) {
                   
                }
                
                WOCSellingAdsInstructionsViewController *adsInstructionsViewController = [self getViewController:@"WOCSellingAdsInstructionsViewController"];
                adsInstructionsViewController.AdId = @"90";
                [self pushViewController:adsInstructionsViewController animated:YES];
            }];
        }
    }
    else if ([txtCode length] == 0 ) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:@"Enter Purchase Code" viewController:self.navigationController.visibleViewController];
    }
    else if ([txtCode length] != 5 ) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:@"Enter Valid Purchase Code" viewController:self.navigationController.visibleViewController];
    }
}

@end

