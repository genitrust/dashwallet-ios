//
//  WOCSellingAdvancedOptionsInstructionsViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingAdvancedOptionsInstructionsViewController.h"
#import "WOCSellingStep8ViewController.h"
#import "WOCSellingInstructionsViewController.h"
#import "WOCSellingSummaryViewController.h"
#import "WOCPasswordViewController.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCAlertController.h"
#import "MBProgressHUD.h"
#import "WOCHoldIssueViewController.h"
#import "WOCSellingStep1ViewController.h"
#import "WOCSellingCreatePasswordViewController.h"
#import "WOCSellingVerifyDetailViewController.h"
#import "WOCSellingAdsInstructionsViewController.h"

@interface WOCSellingAdvancedOptionsInstructionsViewController ()

@end

@implementation WOCSellingAdvancedOptionsInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadow:self.btnNext];
    
    
    NSString *minDeposit = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_MIN_DEPOSIT];
    if (minDeposit != nil && minDeposit.length > 0){
        self.txtMinLimit.text = minDeposit;
    }
    
    NSString *maxDeposit = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_MAX_DEPOSIT];
    if (maxDeposit != nil && maxDeposit.length > 0){
        self.txtMaxLimit.text = maxDeposit;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setupUI];
}

-(void)setupUI {
    
    self.beforeCreateAd = [self.defaults boolForKey:@"beforeCreateAd"];
    if(self.beforeCreateAd == YES) {
        [self.btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
    }
    else {
        [self.btnNext setTitle:@"Save" forState:UIControlStateNormal];
    }
}

// MARK: - IBAction
- (IBAction)nextClicked:(id)sender {
    
    if ([self.txtMinLimit.text length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter minimum deposit limit." viewController:self.navigationController.visibleViewController];
    }
    else if ([self.txtMaxLimit.text length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter maximum deposit limit." viewController:self.navigationController.visibleViewController];
    }
    else {
        
        [self.defaults setObject:self.txtMinLimit.text forKey:USER_DEFAULTS_LOCAL_MIN_DEPOSIT];
        [self.defaults synchronize];
        
        [self.defaults setObject:self.txtMaxLimit.text forKey:USER_DEFAULTS_LOCAL_MAX_DEPOSIT];
        [self.defaults synchronize];
        
        if(self.beforeCreateAd == YES) {
            [self loadVarificationScreen];
        }
        else {
            WOCSellingAdsInstructionsViewController *myViewController = [self getViewController:@"WOCSellingAdsInstructionsViewController"];
            [self pushViewController:myViewController animated:YES];
        }
    }
}

-(void)loadVarificationScreen {
    WOCSellingVerifyDetailViewController *myViewController = (WOCSellingVerifyDetailViewController*)[self getViewController:@"WOCSellingVerifyDetailViewController"];
    [self pushViewController:myViewController animated:YES];
}
@end
