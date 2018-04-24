//
//  WOCBaseViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/02/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBaseViewController.h"
#import "WOCBuyingInstructionsViewController.h"
#import "WOCBuyingSummaryViewController.h"
#import "WOCBuyingWizardHomeViewController.h"

#import "WOCSellingWizardHomeViewController.h"
#import "WOCSellingInstructionsViewController.h"
#import "WOCSellingSummaryViewController.h"

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
    [self setWocDeviceCode];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString * storyboardName = [self.storyboard valueForKey:@"name"];
    
    if ([storyboardName isEqualToString:STORYBOARD_WOC_BUY]) {
        self.title = [NSString stringWithFormat:@"buy %@ with cash",WOC_CURRENTCY];
    }
    else {
        self.title = [NSString stringWithFormat:@"sell %@ for cash",WOC_CURRENTCY];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (IBAction)signOutClicked:(id)sender {
    [self signOutWOC];
}

-(void)setWocDeviceCode {
    //store deviceCode in userDefault
    int launched = [self.defaults integerForKey:USER_DEFAULTS_LAUNCH_STATUS];
    if (launched == 0) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [self.defaults setValue:uuid forKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
        [self.defaults setInteger:1 forKey:USER_DEFAULTS_LAUNCH_STATUS];
        [self.defaults synchronize];
    }
}

-(NSString *)wocDeviceCode {
    NSString *deviceCode = @"";
    
    if ([self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE] != nil) {
        deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    }
    return deviceCode;
}

-(void)storeDeviceInfoLocally {
    
    if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER] != nil) {
        if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID] != nil) {
            NSString * phoneNumber = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            NSString * deviceID = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            
            NSMutableDictionary *localDeiveDict =  [NSMutableDictionary dictionaryWithCapacity:0];
            if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] != nil) {
                localDeiveDict = [NSMutableDictionary dictionaryWithDictionary:[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]];
            }
            
            localDeiveDict[phoneNumber] = [NSString stringWithFormat:@"%@",deviceID];
            if (localDeiveDict != nil) {
                [self.defaults setObject:localDeiveDict forKey:USER_DEFAULTS_LOCAL_DEVICE_INFO];
                [self.defaults synchronize];
            }
        }
    }
    
    NSLog(@"Device info %@",[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]);
}

-(void)clearLocalStorage
{
    [self.defaults removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
    [self.defaults synchronize];
}

-(NSString*)getDeviceIDFromPhoneNumber:(NSString*)phoneNo {
    
    if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] != nil) {
        if ([[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionaryWithDictionary:[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]];
            if (deviceInfoDict[phoneNo] != nil) {
                NSString *deviceId = deviceInfoDict[phoneNo];
                if (deviceId != nil) {
                    if (deviceId.length > 0) {
                        if (![deviceId isEqualToString:@"(null)"]) {
                            return  deviceId;
                        }
                    }
                }
            }
        }
    }
    return nil;
}

-(void)refereshToken {
    
    if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] != nil) {
        if ([[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionaryWithDictionary:[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]];
            NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            if (phoneNo != nil) {
                if (deviceInfoDict[phoneNo] != nil) {
                    NSString *deviceId = deviceInfoDict[phoneNo];
                    if (deviceId != nil) {
                        if (deviceId.length > 0 && (![deviceId isEqualToString:@"(null)"])) {
                            [self.defaults setObject:deviceId forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                            [self.defaults synchronize];
                            [self.defaults setObject:deviceInfoDict forKey:USER_DEFAULTS_LOCAL_DEVICE_INFO];
                            [self.defaults synchronize];
                            [self loginWOC];
                            return;
                        }
                        else {
                            [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                            [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                            
                            [deviceInfoDict removeObjectForKey:phoneNo];
                            [self.defaults setObject:deviceInfoDict forKey:USER_DEFAULTS_LOCAL_DEVICE_INFO];
                            [self.defaults synchronize];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE message:@"Error while login with phone number. please try to login again." preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    [self loginWOC];
                                }];
                                
                                [alert addAction:okAction];
                                
                                [self presentViewController:alert animated:YES completion:nil];
                            });
                        }
                    }
                }
            }
        }
    }
}

- (void)backToMainView {
    
    [super backToMainView];
    [self storeDeviceInfoLocally];
}
// MARK: - API
// Will call SignOut API then Store phone number with Device ID in Local storage and Backto Main View

- (void)loginWOC {
    
    NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *deviceId = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params = @{
                             API_BODY_DEVICE_CODE: deviceCode
                             };
    
    if (deviceId != nil && (![deviceId isEqualToString:@"(null)"])) {
        
        params = @{
                   API_BODY_DEVICE_CODE: deviceCode,
                   API_BODY_DEVICE_ID: deviceId,
                   API_BODY_JSON_PARAMETER: @"YES"
                   };
        
        [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
            
            if (error == nil) {
                NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
                [self.defaults setValue:[responseDictionary valueForKey:API_RESPONSE_TOKEN] forKey:USER_DEFAULTS_AUTH_TOKEN];
                [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_BODY_DEVICE_ID]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                [self.defaults synchronize];
                [self storeDeviceInfoLocally];
            }
            else {
                [self.defaults removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
                [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                //[self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [self.defaults synchronize];
                
                NSString *title = ALERT_TITLE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"SIGN IN for the device is hidden" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self backToMainView];
                    }];
                    
                    [alert addAction:okAction];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
        }];
    }
}

- (void)signOutWOC {
    
    NSString * phoneNumber = [self.defaults objectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    
    if (phoneNumber != nil) {
        MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
        
        NSDictionary *params = @{
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

- (void)pushToWOCRoot {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString * storyboardName = [self.storyboard valueForKey:@"name"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        UINavigationController *navController = (UINavigationController*) [storyboard instantiateViewControllerWithIdentifier:@"wocNavigationController"];
        
        if ([storyboardName isEqualToString:STORYBOARD_WOC_BUY]) {
            WOCBuyingWizardHomeViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingWizardHomeViewController"];// Or any VC with Id
            vc.isFromSend = YES;
            [navController.navigationBar setTintColor:[UIColor whiteColor]];
            BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
            appDelegate.window.rootViewController = navController;
        }
        else {
            WOCSellingWizardHomeViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCSellingWizardHomeViewController"];// Or any VC with Id
            vc.isFromSend = YES;
            [navController.navigationBar setTintColor:[UIColor whiteColor]];
            BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
            appDelegate.window.rootViewController = navController;
        }
    });
}

// MARK: - WallofCoins API

- (void)getOrderList {
    
    NSString * storyboardName = [self.storyboard valueForKey:@"name"];
    
    if ([storyboardName isEqualToString:STORYBOARD_WOC_BUY]) {
        [[APIManager sharedInstance] getOrders:nil response:^(id responseDict, NSError *error) {
            [self loadOrdersWithResponse:responseDict withError:error];
        }];
    }
    else {
        [self getIncomingList];
    }
}

- (void)getIncomingList {
    
    [[APIManager sharedInstance] getIncomingOrders:nil response:^(id responseDict, NSError *error) {
        
        [self loadOrdersWithResponse:responseDict withError:error];
    }];
}

-(void)loadOrdersWithResponse:(id)responseDict withError: (NSError *)error
{
    NSString * storyboardName = [self.storyboard valueForKey:@"name"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == nil) {
            if ([responseDict isKindOfClass:[NSArray class]]) {
                NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                
                NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
                if (orders.count > 0) {
                    NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
                    NSArray *wdArray = [orders filteredArrayUsingPredicate:wdvPredicate];
                    if (wdArray.count > 0) {
                        NSDictionary *orderDict = (NSDictionary*)[wdArray objectAtIndex:0];
                        NSString *status = [NSString stringWithFormat:@"%@",[orderDict valueForKey:@"status"]];
                        if ([status isEqualToString:@"WD"]) {
                            if ([storyboardName isEqualToString:STORYBOARD_WOC_BUY]) {
                                WOCBuyingInstructionsViewController *buyingInstructionsViewController = [self getViewController:@"WOCBuyingInstructionsViewController"];
                                buyingInstructionsViewController.phoneNo = phoneNo;
                                buyingInstructionsViewController.isFromSend = YES;
                                buyingInstructionsViewController.isFromOffer = NO;
                                buyingInstructionsViewController.orderDict = orderDict;
                                [self pushViewController:buyingInstructionsViewController animated:YES];
                            }
                            else {
                                WOCSellingInstructionsViewController *sellingInstructionsViewController = [self getViewController:@"WOCSellingInstructionsViewController"];
                                sellingInstructionsViewController.phoneNo = phoneNo;
                                sellingInstructionsViewController.isFromSend = YES;
                                sellingInstructionsViewController.isFromOffer = NO;
                                sellingInstructionsViewController.orderDict = orderDict;
                                [self pushViewController:sellingInstructionsViewController animated:YES];
                            }
                        }
                    }
                    else {
                        
                        if ([storyboardName isEqualToString:STORYBOARD_WOC_BUY]) {
                            WOCBuyingSummaryViewController *buyingInstructionsViewController = [self getViewController:@"WOCBuyingSummaryViewController"];
                            buyingInstructionsViewController.phoneNo = phoneNo;
                            buyingInstructionsViewController.orders = orders;
                            buyingInstructionsViewController.isFromSend = YES;
                            [self pushViewController:buyingInstructionsViewController animated:YES];
                        }
                        else {
                            WOCSellingSummaryViewController *sellingSummaryViewController = [self getViewController:@"WOCSellingSummaryViewController"];
                            sellingSummaryViewController.phoneNo = phoneNo;
                            sellingSummaryViewController.orders = orders;
                            sellingSummaryViewController.isFromSend = YES;
                            [self pushViewController:sellingSummaryViewController animated:YES];
                        }
                    }
                }
                else {
                    if ([storyboardName isEqualToString:STORYBOARD_WOC_BUY]) {
                        WOCBuyingSummaryViewController *buyingSummaryViewController = [self getViewController:@"WOCBuyingSummaryViewController"];
                        buyingSummaryViewController.phoneNo = phoneNo;
                        buyingSummaryViewController.orders = orders;
                        buyingSummaryViewController.isFromSend = YES;
                        buyingSummaryViewController.hideSuccessAlert = YES;
                        [self pushViewController:buyingSummaryViewController animated:YES];
                    }
                    else {
                        WOCSellingSummaryViewController *sellingSummaryViewController = [self getViewController:@"WOCSellingSummaryViewController"];
                        sellingSummaryViewController.phoneNo = phoneNo;
                        sellingSummaryViewController.orders = orders;
                        sellingSummaryViewController.isFromSend = YES;
                        sellingSummaryViewController.hideSuccessAlert = YES;
                        [self pushViewController:sellingSummaryViewController animated:YES];
                    }
                }
            }
            else {
                [self backToMainView];
            }
        }
        else {
            [self refereshToken];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
