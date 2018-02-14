//
//  WOCPasswordViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCPasswordViewController.h"
#import "WOCBuyDashStep8ViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCAlertController.h"
#import "MBProgressHUD.h"

@interface WOCPasswordViewController () <UITextViewDelegate>

@end

@implementation WOCPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    self.mainView.layer.cornerRadius = 3.0;
    self.mainView.layer.masksToBounds = YES;
    
    [self setShadow:self.btnLogin];
    [self setShadow:self.btnForgotPassword];
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.btnWOCLink.titleLabel.text];
    // making text property to underline text-
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(29, 13)];
    [titleString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(29, 13)];
    // using text on button
    [self.btnWOCLink setAttributedTitle:titleString forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)linkClicked:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"https://wallofcoins.com/"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (IBAction)loginClicked:(id)sender {
    
    NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([password length] > 0) {
        
        [self login:self.phoneNo password:password];
    }
    else{
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter password." viewController:self.navigationController.visibleViewController];
    }
}

- (IBAction)forgotPasswordClicked:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"https://wallofcoins.com/en/forgotPassword/"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Function
- (void)setShadow:(UIView *)view{
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

#pragma mark - API
- (void)login:(NSString*)phoneNo password:(NSString*)password{
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_BODY_PASSWORD: password,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:API_RESPONSE_TOKEN] forKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_8 object:phoneNo];
            
            [self getDeviceId:phoneNo];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.userInfo != nil)
                {
                    if (error.userInfo[@"detail"] != nil)
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.userInfo[@"detail"]  viewController:self];
                    }
                    else
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                    }
                }
                else
                {
                    [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                }
            });
        }
    }];
}

- (void)getDeviceId:(NSString*)phoneNo{
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APIManager sharedInstance] getDevice:^(id responseDict, NSError *error) {
        
        [hud hideAnimated:TRUE];
        
        if (error == nil) {
            
            NSArray *response = (NSArray*)responseDict;
            
            if (response.count > 0) {
                
                NSDictionary *dictionary = [response lastObject];
                NSString *deviceId = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]];
                
                [[NSUserDefaults standardUserDefaults] setValue:deviceId forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self authorize:phoneNo deviceId:deviceId];
            }
        }
        else{
            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)authorize:(NSString*)phoneNo deviceId:(NSString*)deviceId{
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];

    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_BODY_DEVICE_CODE: deviceCode,
                             API_BODY_DEVICE_ID: deviceId,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
        
        [hud hideAnimated:TRUE];
        
        if (error == nil) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:API_RESPONSE_TOKEN] forKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",API_RESPONSE_DEVICE_ID] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //move to step 8
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_8 object:phoneNo];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.userInfo != nil)
                {
                    if (error.userInfo[@"detail"] != nil)
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.userInfo[@"detail"]  viewController:self];
                    }
                    else
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                    }
                }
                else
                {
                    [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                }
            });
        }
    }];
}

@end
