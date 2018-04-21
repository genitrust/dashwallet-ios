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
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(29, 13)];
    [titleString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(29, 13)];
    [self.btnWOCLink setAttributedTitle:titleString forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setShadow:(UIView *)view {
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

// MARK: - API

- (void)login:(NSString*)phoneNo password:(NSString*)password {
    NSDictionary *params = @{
                             API_BODY_PASSWORD: password,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [self.defaults setValue:[responseDictionary valueForKey:API_RESPONSE_TOKEN] forKey:USER_DEFAULTS_AUTH_TOKEN];
            [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self.defaults synchronize];
            [self storeDeviceInfoLocally];

            [self getDeviceId:phoneNo];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.userInfo != nil) {
                    if (error.userInfo[@"detail"] != nil) {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.userInfo[@"detail"]  viewController:self];
                    }
                    else {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                    }
                }
                else {
                    [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                }
            });
        }
    }];
}

- (void)registerDevice:(NSString*)phoneNo {
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params =  @{
                              API_BODY_NAME: API_BODY_DEVICE_NAME_IOS,
                              API_BODY_CODE: deviceCode,
                              API_BODY_JSON_PARAMETER:@"YES"
                              };
    
    [[APIManager sharedInstance] registerDevice:params response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [hud hideAnimated:TRUE];
        });
        
        if (error == nil) {
            NSDictionary *response = (NSDictionary*)responseDict;
            if (response.count > 0) {
                NSString *deviceId = [NSString stringWithFormat:@"%@",[response valueForKey:API_RESPONSE_ID]];
                [self authorize:phoneNo deviceId:deviceId];
            }
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)getDeviceId:(NSString*)phoneNo {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[APIManager sharedInstance] getDevice:^(id responseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [hud hideAnimated:TRUE];
            });
            
            if (error == nil) {
                if ([responseDict isKindOfClass:[NSArray class]]) {
                    NSArray *response = (NSArray*)responseDict;
                    if (response.count > 0) {
                        NSDictionary *dictionary = [response lastObject];
                        NSString *deviceId = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]];
                        
                        if (deviceId.length > 0 && [deviceId isEqualToString:@"(null)"] == FALSE) {
                            [self.defaults setValue:deviceId forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                            [self.defaults synchronize];
                            [self authorize:phoneNo deviceId:deviceId];
                        }
                    }
                    else {
                        [self registerDevice:phoneNo];
                    }
                }
                else {
                    [self registerDevice:phoneNo];
                }
            }
            else {
                [self registerDevice:phoneNo];
                //[[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
            }
        }];
    });
}

- (void)authorize:(NSString*)phoneNo deviceId:(NSString*)deviceId {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    
    NSDictionary *params = @{
                             API_BODY_DEVICE_CODE: deviceCode,
                             API_BODY_DEVICE_ID: deviceId,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [hud hideAnimated:TRUE];
        });
        
        if (error == nil) {
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [self.defaults setValue:[responseDictionary valueForKey:API_RESPONSE_TOKEN] forKey:USER_DEFAULTS_AUTH_TOKEN];
            [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_DEVICE_ID]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [self.defaults synchronize];
            [self storeDeviceInfoLocally];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
                //move to step 8
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_8 object:phoneNo];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 [self registerDevice:phoneNo];
            });
        }
    }];
}
// MARK: - IBAction

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
    else {
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

@end

