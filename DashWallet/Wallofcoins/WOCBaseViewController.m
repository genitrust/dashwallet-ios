//
//  WOCBaseViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/02/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBaseViewController.h"
#import "WOCBuyingInstructionsViewController.h"

@interface WOCBaseViewController ()

@end

@implementation WOCBaseViewController

+ (instancetype) sharedInstance {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (IBAction)signOutClicked:(id)sender {
    [self signOutWOC];
}

// MARK: - API
// Will call SignOut API then Store phone number with Device ID in Local storage and Backto Main View
- (void)signOutWOC {
    
    NSString * phoneNumber = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    
    if (phoneNumber != nil) {
        MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
        
        NSDictionary *params = @{
                                 //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                                 };
        
        [[APIManager sharedInstance] signOut:nil phone:phoneNumber response:^(id responseDict, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            if (error != nil) {
                [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
            }
            
            [self backToMainView];
            [self clearLocalStorage];
            
        }];
    }
    else {
        
        [self backToMainView];
        [self clearLocalStorage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

