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
#import "WOCHoldIssueViewController.h"
#import "WOCBuyDashStep1ViewController.h"

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

- (void)loadJSON {
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
    [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    [self.defaults synchronize];
    
    [self createHoldAfterAuthorize:phoneNo];
}

// MARK: - API

- (void)checkPhone:(NSString*)phone code:(NSString*)countryCode {
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@%@",countryCode,phone];
    
    [[APIManager sharedInstance] authorizeDevice:nil phone:phoneNo response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            NSArray *availableAuthSource = (NSArray*)[responseDictionary valueForKey:@"availableAuthSources"];
            if (availableAuthSource.count > 0) {
                if ([[availableAuthSource objectAtIndex:0] isEqualToString:@"password"]) {
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
                    WOCPasswordViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCPasswordViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                    [self.navigationController presentViewController:myViewController animated:YES completion:nil];
                }
                else if ([[availableAuthSource objectAtIndex:0] isEqualToString:@"device"]) {
                    //[self login:phoneNo];
                    [self createHoldAfterAuthorize:phoneNo];
                }
            }
        }
        else {
            
            if ([error code] == 404) {
                //new number
                [self.defaults removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
                [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [self.defaults synchronize];

                [self createHold:phoneNo];
                
                /*NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
                 WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
                 myViewController.phoneNo = phoneNo;
                 myViewController.offerId = self.offerId;
                 myViewController.deviceCode = deviceCode;
                 myViewController.emailId = self.emailId;
                 [self pushViewController:myViewController animated:YES];*/
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.userInfo != nil) {
                        if (error.userInfo[@"detail"] != nil) {
                            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.userInfo[@"detail"]  viewController:self.navigationController.visibleViewController];
                        }
                        else {
                            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
                        }
                    }
                    else {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
                    }
                });
            }
        }
    }];
}

- (void)login:(NSString*)phoneNo {
    
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
            [self createHoldAfterAuthorize:phoneNo];
        }
        else {
            [self.defaults removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
            [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self.defaults synchronize];
            
            [self createHoldAfterAuthorize:phoneNo];

            //[self createHold:phoneNo];
        }
    }];
}

- (void)createHold:(NSString*)phoneNo {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params;
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        params =  @{
                    //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    //API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                    //API_BODY_DEVICE_CODE: deviceCode,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    else {
        params =  @{
                    //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    API_BODY_PHONE_NUMBER: phoneNo,
                    API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                    API_BODY_DEVICE_CODE: deviceCode,
                    API_BODY_EMAIL: self.emailId,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    
    [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [hud hideAnimated:TRUE];
        });
        
        if (error == nil) {
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            if ([responseDictionary valueForKey:API_RESPONSE_TOKEN] != nil && [[responseDictionary valueForKey:API_RESPONSE_TOKEN] isEqualToString:@"(null)"] == FALSE) {
                [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_TOKEN]] forKey:USER_DEFAULTS_AUTH_TOKEN];
                [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_BODY_DEVICE_ID]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                [self.defaults synchronize];
            }
        
            NSString *holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_ID]];
            self.holdId = holdId;
            
            NSString *purchaseCode = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_PURCHASE_CODE]];
            self.purchaseCode = purchaseCode;
            
            WOCBuyDashStep8ViewController *myViewController = [self getViewController:@"WOCBuyDashStep8ViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.offerId = self.offerId;
            myViewController.purchaseCode = self.purchaseCode;
            myViewController.deviceCode = deviceCode;
            myViewController.emailId = self.emailId;
            myViewController.holdId = self.holdId;
            [self pushViewController:myViewController animated:YES];
        }
        else if (error.code == 403 ) {
            [self resolveActiveHoldIssue:phoneNo];
        }
        else if (error.code == 401 ) {
            [self registerDevice:phoneNo];
        }
    }];
}

-(void)resolveActiveHoldIssue:(NSString*)phoneNo {
    
    if (!self.isActiveHoldChecked) {
        
        
        NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
        
        if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
            /*you receive Status 403 from POST /api/v1/holds/
            IF YOU HAVE a token or the deviceId/deviceCode, login with that device -- you will use the token to get a list of holds so that you can cancel the holds. IF THERE ARE NO HOLDS, then you will bring the user to the Buy Summary, where they will see their latest WD orders.
             */
            self.isActiveHoldChecked = TRUE;
            [self getHold];
        }
        else {
            
      
            NSString *deviceID = [self getDeviceIDFromPhoneNumber:phoneNo];
            if (deviceID != nil)
            {
                [self.defaults setObject:deviceID forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                [self.defaults synchronize];
                [self login:phoneNo];
            }
            else
            {
                /*
                 IF YOU DO NOT HAVE the token or deviceId/deviceCode in local storage, then you will need to show a new view that says, "You already have an open hold or a pending order with Wall of Coins. Before you can create a new order, you must finish these orders." and then show a yellow button w/ blue text (just like the "BUY MORE DASH WITH CASH" button), and when they press that button, you will bring them to this website link:
                 https://wallofcoins.com/signin/1-2397776832/
                 https://wallofcoins.com/signin/{phone_country_code}-{local_phone_number}/
                 */
                NSString *txtPhone = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *txtcountryCode = [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
                WOCHoldIssueViewController *aViewController = [self getViewController:@"WOCHoldIssueViewController"];
                aViewController.phoneNo = [NSString stringWithFormat:@"%@-%@",txtcountryCode,txtPhone];
                [self pushViewController:aViewController animated:YES];
            }
        }
    }
}

-(void)resolvePandingOrderIssue {
    
    [self getOrders];
}

- (void)getHold {
    
    [[APIManager sharedInstance] getHold:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSLog(@"Hold with Hold Id: %@.",responseDict);
            
            NSArray *holdArray = (NSArray*)responseDict;
            if (holdArray.count > 0) {
                NSUInteger count = holdArray.count;
                NSUInteger activeHodCount = 0;
                
                for (int i = 0; i < holdArray.count; i++) {
                    count -= count;
                    
                    NSDictionary *holdDict = [holdArray objectAtIndex:i];
                    NSString *holdId = [holdDict valueForKey:API_RESPONSE_ID];
                    NSString *holdStatus = [holdDict valueForKey:API_RESPONSE_Holds_Status];
                   
                    if (holdStatus != nil) {
                        if ([holdStatus isEqualToString:@"AC"]) {
                            if (holdId) {
                                activeHodCount = activeHodCount + 1;
                                [self deleteHold:holdId count:count];
                            }
                        }
                    }// Handle as per Old Response
//                    else if ([holdDict valueForKey:API_RESPONSE_Holds] != nil) {
//
//                        if ([[holdDict valueForKey:API_RESPONSE_Holds] isKindOfClass:[NSArray class]]) {
//                            NSArray *holdDetailArray = (NSArray *) [holdDict valueForKey:API_RESPONSE_Holds];
//
//                            if (holdDetailArray.count > 0) {
//                                NSDictionary *holdSubDict = [holdDetailArray objectAtIndex:0];
//                                NSString *holdStatus = [holdSubDict valueForKey:API_RESPONSE_Holds_Status];
//
//                                if ([holdStatus isEqualToString:@"AC"])  {
//
//                                    if (holdId) {
//                                        [self deleteHold:holdId count:count];
//                                    }
//                                }
//                            }
//                        }
//                    }
                    else {
                        if (holdId) {
                            activeHodCount = activeHodCount + 1;
                            [self deleteHold:holdId count:count];
                        }
                    }
                }

                if (activeHodCount == 0 ) {
                     [self resolvePandingOrderIssue];
                }
            }
            else {
                [self resolvePandingOrderIssue];
            }
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)deleteHold:(NSString*)holdId count:(NSUInteger)count {
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] deleteHold:holdId response:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSLog(@"Hold deleted.");
            
            NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self createHoldAfterAuthorize:phoneNo];
        }
        else {
           //[[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)registerDevice:(NSString*)phoneNo {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
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
            
            [self pushToStep1];
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)authorize:(NSString*)phoneNo deviceId:(NSString*)deviceId {
    
    NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_BODY_DEVICE_CODE: deviceCode,
                             API_BODY_JSON_PARAMETER: @"YES"
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
            [self createHoldAfterAuthorize:phoneNo];
        }
        else {
            
            [self.defaults removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
            [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self.defaults removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [self.defaults setValue:phoneNo forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self.defaults synchronize];
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];

            //[self createHold:phoneNo];
        }
    }];
}

- (void)createHoldAfterAuthorize:(NSString*)phoneNo
{
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
   
        [self createHold:phoneNo];
    }
    else {
        
        NSString *deviceID = [self getDeviceIDFromPhoneNumber:phoneNo];
        if (deviceID != nil)
        {
            [self.defaults setObject:deviceID forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [self.defaults synchronize];
            [self login:phoneNo];
        }
        else
        {
             [self createHold:phoneNo];
        }
    }
}

- (void)getOrders
{
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:nil response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [hud hideAnimated:TRUE];
        });
        
        if (error == nil) {
            NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            if (orders.count > 0) {
                NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
                NSArray *wdArray = [orders filteredArrayUsingPredicate:wdvPredicate];
                NSDictionary *orderDict = (NSDictionary*)[orders objectAtIndex:0];
                NSString *status = [NSString stringWithFormat:@"%@",[orderDict valueForKey:@"status"]];
                
                if ([status isEqualToString:@"WD"]) {

                    WOCBuyingInstructionsViewController *myViewController = [self getViewController:@"WOCBuyingInstructionsViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.holdId = self.holdId;
                    myViewController.isFromSend = YES;
                    myViewController.isFromOffer = NO;
                    myViewController.orderDict = (NSDictionary*)[orders objectAtIndex:0];
                    [self pushViewController:myViewController animated:YES];
                }
                else if (orders.count > 0) {
                    
                    WOCBuyingSummaryViewController *myViewController = [self getViewController:@"WOCBuyingSummaryViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.orders = orders;
                    myViewController.isFromSend = YES;
                    [self pushViewController:myViewController animated:YES];
                }
                else {
                    
                    [self backToMainView];
                }
            }
        }
        else {
            
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
    else if ([txtPhone length] == 10) {
        self.isActiveHoldChecked = FALSE;
        [self checkPhone:txtPhone code:self.countryCode];
    }
    else {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter valid phone number." viewController:self.navigationController.visibleViewController];
    }
}

// MARK: - UIPickerView Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.countries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@ (%@)",self.countries[row][@"name"],self.countries[row][@"code"]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.txtCountryCode.text = [NSString stringWithFormat:@"%@ (%@)",self.countries[row][@"name"],self.countries[row][@"code"]];
    self.countryCode = [NSString stringWithFormat:@"%@",self.countries[row][@"code"]];
}

- (void)pushToStep1
{
    [self storeDeviceInfoLocally];
    [self backToMainView];
}

@end

