//
//  WOCBuyDashStep7ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep7ViewController.h"
#import "WOCBuyDashStep8ViewController.h"
#import "WOCBuyingInstructionsViewController.h"
#import "WOCBuyingSummaryViewController.h"
#import "WOCPasswordViewController.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCAlertController.h"
#import "MBProgressHUD.h"

@interface WOCBuyDashStep7ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *purchaseCode;
@property (strong, nonatomic) NSString *holdId;

@end

@implementation WOCBuyDashStep7ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnNext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep8:) name:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_8 object:nil];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.txtCountryCode.inputView = self.pickerView;
    
    [self loadJSON];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setShadow:(UIView *)view{
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

- (void)loadJSON{
    
    // Retrieve local JSON file called example.json
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    
    // Load the file into an NSData object called JSONData
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    // Create an Objective-C object from JSON Data
    NSDictionary *countriesDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
    NSArray *countries = [countriesDict valueForKey:@"countries"];
    
    self.countries = countries;
    if (self.countries.count > 0) {
        self.txtCountryCode.text = [NSString stringWithFormat:@"%@ (%@)",self.countries[0][@"name"],self.countries[0][@"code"]];
        self.countryCode = [NSString stringWithFormat:@"%@",self.countries[0][@"code"]];
    }
    
    [self.pickerView reloadAllComponents];
}

- (void)openBuyDashStep8:(NSNotification*)notification {
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@",notification.object];
    [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    
    [self createHoldAfterAuthorize:phoneNo];
    
    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
     WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
     myViewController.phoneNo = phoneNo;
     myViewController.offerId = self.offerId;
     myViewController.deviceCode = deviceCode;
     myViewController.emailId = self.emailId;
     [self.navigationController pushViewController:myViewController animated:YES];*/
}

// MARK: - API

- (void)checkPhone:(NSString*)phone code:(NSString*)countryCode{
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@%@",countryCode,phone];
    
    [[APIManager sharedInstance] authorizeDevice:params phone:phoneNo response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            NSArray *availableAuthSource = (NSArray*)[responseDictionary valueForKey:@"availableAuthSources"];
            
            if (availableAuthSource.count > 0) {
                
                if ([[availableAuthSource objectAtIndex:0] isEqualToString:@"password"]){
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                    WOCPasswordViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCPasswordViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                    [self.navigationController presentViewController:myViewController animated:YES completion:nil];
                }
                else if([[availableAuthSource objectAtIndex:0] isEqualToString:@"device"]){
                    
                    [self login:phoneNo];
                }
            }
        }
        else
        {
            if ([error code] == 404) {
                
                //new number
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self createHold:phoneNo];
                
                /*NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                 WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
                 myViewController.phoneNo = phoneNo;
                 myViewController.offerId = self.offerId;
                 myViewController.deviceCode = deviceCode;
                 myViewController.emailId = self.emailId;
                 [self.navigationController pushViewController:myViewController animated:YES];*/
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.userInfo != nil)
                    {
                        if (error.userInfo[@"detail"] != nil)
                        {
                            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.userInfo[@"detail"]  viewController:self.navigationController.visibleViewController];
                        }
                        else
                        {
                            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
                        }
                    }
                    else
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
                    }
                });
            }
        }
    }];
}

- (void)login:(NSString*)phoneNo{
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_BODY_DEVICE_CODE: deviceCode
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        if (deviceId != nil && [deviceId isEqualToString:@"(null)"] == FALSE) {
            
            params = @{
                       API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                       API_BODY_DEVICE_CODE: deviceCode,
                       API_BODY_DEVICE_ID: deviceId
                       };
        }
    }
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:API_RESPONSE_TOKEN] forKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.offerId = self.offerId;
            myViewController.deviceCode = deviceCode;
            myViewController.emailId = self.emailId;
            [self.navigationController pushViewController:myViewController animated:YES];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self createHold:phoneNo];
            
            /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
             WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
             myViewController.phoneNo = phoneNo;
             myViewController.offerId = self.offerId;
             myViewController.deviceCode = deviceCode;
             myViewController.emailId = self.emailId;
             [self.navigationController pushViewController:myViewController animated:YES];*/
            //[[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)createHold:(NSString*)phoneNo {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params;
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        params =  @{
                    API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                    API_BODY_DEVICE_CODE: deviceCode,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    else
    {
        params =  @{
                    API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    API_BODY_PHONE_NUMBER: phoneNo,
                    API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                    API_BODY_DEVICE_CODE: deviceCode,
                    API_BODY_EMAIL: self.emailId,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    
    [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
        
        [hud hideAnimated:TRUE];
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            if ([responseDictionary valueForKey:API_RESPONSE_TOKEN] != nil && [[responseDictionary valueForKey:API_RESPONSE_TOKEN] isEqualToString:API_RESPONSE_TOKEN] == FALSE)
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_TOKEN]] forKey:USER_DEFAULTS_AUTH_TOKEN];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_BODY_DEVICE_ID]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            self.purchaseCode = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_PURCHASE_CODE]];
            self.holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_ID]];
            
            [self deleteHold:self.holdId count:1];
            [self registerDevice:phoneNo];
        }
        else
        {
            [self getHold];
        }
    }];
}

- (void)getHold {
    
    [[APIManager sharedInstance] getHold:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSLog(@"Hold with Hold Id: %@.",responseDict);
            
            NSArray *holdArray = (NSArray*)responseDict;
            
            if (holdArray.count > 0) {
                
                NSUInteger count = holdArray.count;
                
                for (int i = 0; i < holdArray.count; i++) {
                    
                    count -= count;
                    
                    NSDictionary *holdDict = [holdArray objectAtIndex:i];
                    
                    NSString *holdId = [holdDict valueForKey:API_RESPONSE_ID];
                    [self deleteHold:holdId count:count];
                }
            }
        }
        else{
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)deleteHold:(NSString*)holdId count:(NSUInteger)count{
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] deleteHold:holdId response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSLog(@"Hold deleted.");
            
            NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            
            if (count == 1) {
                [self createHoldAfterAuthorize:phoneNo];
            }
        }
        else{
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)registerDevice:(NSString*)phoneNo {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params =  @{
                              API_BODY_NAME: API_BODY_DEVICE_NAME_IOS,
                              API_BODY_CODE: deviceCode,
                              API_BODY_JSON_PARAMETER:@"YES"
                              };
    
    [[APIManager sharedInstance] registerDevice:params response:^(id responseDict, NSError *error) {
        
        [hud hideAnimated:TRUE];
        
        if (error == nil) {
            
            NSDictionary *response = (NSDictionary*)responseDict;
            
            if (response.count > 0) {
                
                NSString *deviceId = [NSString stringWithFormat:@"%@",[response valueForKey:API_RESPONSE_ID]];
                
                [self authorize:phoneNo deviceId:deviceId];
            }
        }
        else
        {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)authorize:(NSString*)phoneNo deviceId:(NSString*)deviceId{
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_BODY_DEVICE_CODE: deviceCode,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        if (deviceId != nil && [deviceId isEqualToString:@"(null)"] == FALSE) {
            
            params = @{
                       API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                       API_BODY_DEVICE_CODE: deviceCode,
                       API_BODY_DEVICE_ID: deviceId,
                       API_BODY_JSON_PARAMETER: @"YES"
                       };
        }
    }
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:API_RESPONSE_TOKEN] forKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_BODY_DEVICE_ID]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            
            [self createHoldAfterAuthorize:phoneNo];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //[self createHold:phoneNo];
            
            /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
             WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
             myViewController.phoneNo = phoneNo;
             myViewController.offerId = self.offerId;
             myViewController.deviceCode = deviceCode;
             myViewController.emailId = self.emailId;
             [self.navigationController pushViewController:myViewController animated:YES];*/
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)createHoldAfterAuthorize:(NSString*)phoneNo {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params;
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        params =  @{
                    API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                    API_BODY_DEVICE_CODE: deviceCode,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    else
    {
        params =  @{
                    API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    API_BODY_PHONE_NUMBER: phoneNo,
                    API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                    API_BODY_DEVICE_CODE: deviceCode,
                    API_BODY_EMAIL: self.emailId,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    
    [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
        
        [hud hideAnimated:TRUE];
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            if ([responseDictionary valueForKey:API_RESPONSE_TOKEN] != nil && [[responseDictionary valueForKey:API_RESPONSE_TOKEN] isEqualToString:API_RESPONSE_TOKEN] == FALSE)
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_TOKEN]] forKey:USER_DEFAULTS_AUTH_TOKEN];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_BODY_DEVICE_ID]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            self.purchaseCode = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_PURCHASE_CODE]];
            self.holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_ID]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.offerId = self.offerId;
            myViewController.purchaseCode = self.purchaseCode;
            myViewController.deviceCode = deviceCode;
            myViewController.emailId = self.emailId;
            myViewController.holdId = self.holdId;
            [self.navigationController pushViewController:myViewController animated:YES];
        }
        else
        {
            [self getOrders];
        }
    }];
}

- (void)getOrders {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:params response:^(id responseDict, NSError *error) {
        
        [hud hideAnimated:TRUE];
        
        if (error == nil) {
            
            NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            
            if (orders.count > 0){
                
                NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                
                NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
                NSArray *wdArray = [orders filteredArrayUsingPredicate:wdvPredicate];
                
                NSDictionary *orderDict = (NSDictionary*)[orders objectAtIndex:0];
                
                NSString *status = [NSString stringWithFormat:@"%@",[orderDict valueForKey:@"status"]];
                
                if ([status isEqualToString:@"WD"]) {
                    
                    UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                    WOCBuyingInstructionsViewController *myViewController = [stroyboard instantiateViewControllerWithIdentifier:@"WOCBuyingInstructionsViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.holdId = self.holdId;
                    myViewController.isFromSend = YES;
                    myViewController.isFromOffer = NO;
                    myViewController.orderDict = (NSDictionary*)[orders objectAtIndex:0];
                    [self.navigationController pushViewController:myViewController animated:YES];
                }
                else if (wdArray.count > 0){
                    
                    for (int i = 0; i < wdArray.count; i++) {
                        
                        NSDictionary *orderDict = (NSDictionary*)[wdArray objectAtIndex:i];
                        
                        [self deleteHold:[NSString stringWithFormat:@"%@",[orderDict valueForKey:@"id"]] count:1];
                    }
                }
                else if (orders.count > 0){
                    
                    UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                    WOCBuyingSummaryViewController *myViewController = [stroyboard instantiateViewControllerWithIdentifier:@"WOCBuyingSummaryViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.orders = orders;
                    myViewController.isFromSend = YES;
                    [self.navigationController pushViewController:myViewController animated:YES];
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        BRRootViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
                        
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                        [nav.navigationBar setTintColor:[UIColor whiteColor]];
                        
                        UIPageControl.appearance.pageIndicatorTintColor = [UIColor lightGrayColor];
                        UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor blueColor];
                        
                        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
                        appDelegate.window.rootViewController = nav;
                    });
                }
            }
        }
        else
        {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

// MARK: - IBAction
- (IBAction)nextClicked:(id)sender {
    
    NSString *txtPhone = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([self.countryCode length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Select country code." viewController:self.navigationController.visibleViewController];
    }
    else if ([txtPhone length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter phone number." viewController:self.navigationController.visibleViewController];
    }
    else{
        [self checkPhone:txtPhone code:self.countryCode];
    }
}

// MARK: - UIPickerView Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.countries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%@ (%@)",self.countries[row][@"name"],self.countries[row][@"code"]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.txtCountryCode.text = [NSString stringWithFormat:@"%@ (%@)",self.countries[row][@"name"],self.countries[row][@"code"]];
    self.countryCode = [NSString stringWithFormat:@"%@",self.countries[row][@"code"]];
}

@end

