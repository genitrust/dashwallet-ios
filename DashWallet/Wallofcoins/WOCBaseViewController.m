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
#import "WOCBuyDashStep1ViewController.h"

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

-(NSString*)getDeviceIDFromPhoneNumber:(NSString*)phoneNo
{
    if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] != nil) {
        
        if ([[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionaryWithDictionary:[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]];
            if (deviceInfoDict[phoneNo] != nil) {
                
                NSString *deviceId = deviceInfoDict[phoneNo];
                if (deviceId != nil) {
                    
                    if (deviceId.length > 0) {
                        return  deviceId;
                    }
                }
            }
        }
    }
    return nil;
}

-(void)refereshToken
{
    if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] != nil) {
        
        if ([[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionaryWithDictionary:[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]];
            
            NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            if (phoneNo != nil)
            {
                if (deviceInfoDict[phoneNo] != nil) {
                    
                    NSString *deviceId = deviceInfoDict[phoneNo];
                    if (deviceId != nil) {
                        
                        if (deviceId.length > 0) {
                            [self.defaults setObject:deviceId forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                            [self.defaults setObject:deviceInfoDict forKey:USER_DEFAULTS_LOCAL_DEVICE_INFO];
                            [self.defaults synchronize];
                            [self loginWOC];
                            return;
                        }
                    }
                }
            }
        }
    }
}

// MARK: - API
// Will call SignOut API then Store phone number with Device ID in Local storage and Backto Main View

- (void)loginWOC {
    
    NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *deviceId = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_BODY_DEVICE_CODE: deviceCode
                             };
    
    if (deviceId != nil && [deviceId isEqualToString:@"(null)"] == FALSE) {
        
        params = @{
                   //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_BODY_DEVICE_CODE: deviceCode,
                   API_BODY_DEVICE_ID: deviceId,
                   API_BODY_JSON_PARAMETER: @"YES"
                   };
    }
    
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
            [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self.defaults synchronize];
            
            [self backToMainView];
            
        }
    }];
}

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

- (void)pushToWOCRoot {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
        UINavigationController *navController = (UINavigationController*) [storyboard instantiateViewControllerWithIdentifier:@"wocNavigationController"];
        
        WOCBuyDashStep1ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];// Or any VC with Id
        vc.isFromSend = YES;
        [navController.navigationBar setTintColor:[UIColor whiteColor]];
        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = navController;
        
       
    });
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
//    UINavigationController *navController = (UINavigationController*) [storyboard instantiateViewControllerWithIdentifier:@"wocNavigationController"];
//    BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
//    appDelegate.window.rootViewController = navController;
//    [self backToMainView];

}

// MARK: - WallofCoins API

- (void)getOrderList {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             //@"publisherId": @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:nil response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                
                NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
                if (orders.count > 0) {
                    
                    NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                    NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
                    NSArray *wdArray = [orders filteredArrayUsingPredicate:wdvPredicate];
                   
                    if (wdArray.count > 0) {
                        NSDictionary *orderDict = (NSDictionary*)[wdArray objectAtIndex:0];
                        NSString *status = [NSString stringWithFormat:@"%@",[orderDict valueForKey:@"status"]];
                        if ([status isEqualToString:@"WD"]) {
                            WOCBuyingInstructionsViewController *myViewController = [self getViewController:@"WOCBuyingInstructionsViewController"];
                            myViewController.phoneNo = phoneNo;
                            myViewController.isFromSend = YES;
                            myViewController.isFromOffer = NO;
                            myViewController.orderDict = orderDict;
                            [self pushViewController:myViewController animated:YES];
                        }
                    }
                    else {
                        WOCBuyingSummaryViewController *myViewController = [self getViewController:@"WOCBuyingSummaryViewController"];
                        myViewController.phoneNo = phoneNo;
                        myViewController.orders = orders;
                        myViewController.isFromSend = YES;
                        [self pushViewController:myViewController animated:YES];
                    }
                }
            }
        });
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

