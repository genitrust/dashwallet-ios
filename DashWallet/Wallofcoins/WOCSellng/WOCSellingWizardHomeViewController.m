//
//  WOCSellingWizardHomeViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingWizardHomeViewController.h"
#import "WOCLocationManager.h"
#import "WOCSellingWizardZipCodeViewController.h"
#import "WOCSellingWizardPaymentCenterViewController.h"
#import "WOCSellingWizardInputAmountViewController.h"
#import "WOCConstants.h"
#import "BRAppDelegate.h"
#import "BRRootViewController.h"
#import "MBProgressHUD.h"
#import "APIManager.h"
#import "WOCAlertController.h"
#import "WOCSellingWizardInputEmailViewController.h"
#import "WOCSellingWizardInputPhoineNumberViewController.h"

@interface WOCSellingWizardHomeViewController ()

@property (strong, nonatomic) NSString *zipCode;

@end

@implementation WOCSellingWizardHomeViewController

- (void)viewDidLoad {
    
    self.requiredBackButton = YES;
    
    [super viewDidLoad];
    
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_LOCATION_LATITUDE];
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE];
    
    [[NSNotificationCenter defaultCenter] removeObserver:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLogoutButton) name:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1 object:nil];
    
    [self.btnSellYourCrypto setTitle:[NSString stringWithFormat:@"SELL YOUR %@",WOC_CURRENTCY_SPECIAL] forState:UIControlStateNormal];
    [self setShadowOnButton:self.btnSellYourCrypto];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self setLogoutButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

-(void)setLogoutButton {
    
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    if (token != nil && (![token isEqualToString:@"(null)"])) {
        NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
        NSString *loginPhone = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",phoneNo];
        self.lblDescription.text = loginPhone;
        [self.btnSignOut setTitle:@"SIGN OUT" forState:UIControlStateNormal];
        self.signoutView.hidden = NO;
        self.orderListBtn.hidden = NO;
    }
    else {
        NSString *loginPhone = [NSString stringWithFormat:@"Do you already have an order?"];
        self.lblDescription.text = loginPhone;
        [self.btnSignOut setTitle:@"SIGN IN HERE" forState:UIControlStateNormal];
        self.signoutView.hidden = NO;
        self.orderListBtn.hidden = YES;
    }
    
    [self setShadowOnButton:self.btnSignOut];
    [self setShadowOnButton:self.orderListBtn];
}

- (void)back:(id)sender {
    
    [self backToRoot];
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
        self.navigationController.navigationBar.hidden = NO;
    });
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
    
    [self refereshToken];
    NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    
    if (phoneNo == nil || phoneNo.length == 0)
    {
        WOCSellingWizardInputPhoineNumberViewController *inputPhoneNumberViewController = [self getViewController:@"WOCSellingWizardInputPhoineNumberViewController"];
        inputPhoneNumberViewController.offerId = @"";
        inputPhoneNumberViewController.emailId = @"";
        [self pushViewController:inputPhoneNumberViewController animated:YES];
    }
    else {
        WOCSellingWizardInputEmailViewController *inputEmailViewController = [self getViewController:@"WOCSellingWizardInputEmailViewController"];
        [self pushViewController:inputEmailViewController animated:YES];
    }
}
@end
