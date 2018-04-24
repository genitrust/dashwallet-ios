//
//  WOCSellingVerifyDetailViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingAdsInstructionsViewController.h"
#import "WOCSellingAdvancedOptionsInstructionsViewController.h"
#import "BRAppDelegate.h"
#import "APIManager.h"
#import "WOCConstants.h"


@interface WOCSellingAdsInstructionsViewController ()

@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *purchaseCode;
@property (strong, nonatomic) NSString *holdId;
@property (strong, nonatomic) NSString *deviceName;
@end

@implementation WOCSellingAdsInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadowOnButton:self.btnNext];
    
    if (self.accountInfoStr != nil && self.accountInfoStr.length > 0) {
        self.txtAccountCode.text = self.accountInfoStr;
    }
    
//    if (self.currentPriceStr != nil && self.currentPriceStr.length > 0){
//        self.txtCurrentPrice.text = self.currentPriceStr;
//    }
    
    self.txtAvailableCrypto.text = [NSString stringWithFormat:@"%@ 0.000",WOC_CURRENTCY_SYMBOL];
    
    NSString *emailAddress = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_EMAIL];
    if (emailAddress != nil && emailAddress.length > 0) {
        self.txtEmail.text = emailAddress;
    }
    
    NSString *bankAccountInfo = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_BANK_INFO];
    if (bankAccountInfo != nil && bankAccountInfo.length > 0) {
        self.txtAccountCode.text = bankAccountInfo;
    }
    
    NSString *bankAccount = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_BANK_ACCOUNT_NUMBER];
    if (bankAccount != nil && bankAccount.length > 0) {
        self.txtAccountNumber.text = bankAccount;
    }
    
    NSString *bankName = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_BANK_NAME];
    if (bankName != nil && bankName.length > 0) {
        self.txtAccountName.text = bankName;
    }
    
    NSString *currentPrice = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_PRICE];
    if (currentPrice != nil && currentPrice.length > 0) {
        self.txtCurrentPrice.text = [NSString stringWithFormat:@"$ %@",currentPrice];
    }
    self.txtAccountNumber.userInteractionEnabled = NO;
    self.txtAccountName.userInteractionEnabled = NO;
    self.txtAccountCode.userInteractionEnabled = NO;
    self.txtAvailableCrypto.userInteractionEnabled = NO;
    self.txtCurrentPrice.userInteractionEnabled = NO;
    self.txtEmail.userInteractionEnabled = NO;
    [self loadAdData];
}

- (void)loadAdData
{
    if (self.AdId != nil && self.AdId.length > 0) {
        [[APIManager sharedInstance] getDetailFromADId:self.AdId  response:^(id responseDict, NSError *error) {
            NSLog(@"responseDict = %@",responseDict);
            
            self.txtAccountCode.text = self.accountInfoStr;
            self.txtAvailableCrypto.text = [NSString stringWithFormat:@"%@ 0.000",WOC_CURRENTCY_SYMBOL];
            
            //self.txtEmail.text = REMOVE_NULL_VALUE(responseDict[@""]);
            self.txtAccountCode.text = REMOVE_NULL_VALUE(responseDict[@""]);
            self.txtAccountNumber.text = REMOVE_NULL_VALUE(responseDict[@""]);
            self.txtAccountName.text = REMOVE_NULL_VALUE(responseDict[@""]);
            self.txtCurrentPrice.text = [NSString stringWithFormat:@"$ %@",REMOVE_NULL_VALUE(responseDict[@"currentPrice"])];
           
            /*
             balance = "0.00000000";
             buyCurrency = USD;
             currentPrice = "1.20";
             dynamicPrice = 0;
             fundingAddress = "(Not Available - Needs Verification)";
             id = 90;
             maxPayment = 0;
             minPayment = 0;
             onHold = "0.00000000";
             primaryMarket = "<null>";
             publicBalance = "0.00000000";
             published = 0;
             secondaryMarket = "<null>";
             sellCrypto = DASH;
             sellerFee = "<null>";
             userEnabled = 1;
             verified = 0;
             */
        }];
    }
}

- (IBAction)AdvancedOptionsClicked:(id)sender {
    WOCSellingAdvancedOptionsInstructionsViewController *sellingAdvancedOptionsInstructionsViewController = [self getViewController:@"WOCSellingAdvancedOptionsInstructionsViewController"];
    [self pushViewController:sellingAdvancedOptionsInstructionsViewController animated:YES];
}

- (IBAction)backToHomeScreenAction:(id)sender {
    [self backToMainView];
}
@end

