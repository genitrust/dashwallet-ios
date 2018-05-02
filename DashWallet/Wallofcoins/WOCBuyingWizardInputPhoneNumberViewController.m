//
//  WOCBuyingWizardInputPhoneNumberViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyingWizardInputPhoneNumberViewController.h"
#import "WOCBuyingWizardInputVarificationCodeViewController.h"
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
#import "WOCBuyingWizardHomeViewController.h"

@interface WOCBuyingWizardInputPhoneNumberViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *purchaseCode;
@property (strong, nonatomic) NSString *holdId;

@end

@implementation WOCBuyingWizardInputPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadowOnButton:self.nextButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep8:) name:WOCNotificationObserverNameBuyDashStep8 object:nil];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.countryCodeTextField.inputView = self.pickerView;
    
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
        self.countryCodeTextField.text = [NSString stringWithFormat:@"%@ (%@)",self.countries[0][@"name"],self.countries[0][@"code"]];
        self.countryCode = [NSString stringWithFormat:@"%@",self.countries[0][@"code"]];
    }
    
    [self.pickerView reloadAllComponents];
}

- (void)openBuyDashStep8:(NSNotification*)notification {
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@",notification.object];
    [self.defaults setValue:phoneNo forKey:WOCUserDefaultsLocalPhoneNumber];
    [self.defaults synchronize];
    
    [self createHoldAfterAuthorize:phoneNo];
}

// MARK: - API

- (void)checkPhone:(NSString*)phone code:(NSString*)countryCode {
    
    NSDictionary *params = @{
                            };
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@%@",countryCode,phone];
    
    [[APIManager sharedInstance] authorizeDevice:nil phone:phoneNo response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            if ([[responseDictionary valueForKey:@"availableAuthSources"] isKindOfClass:[NSArray class]]) {
                NSArray *availableAuthSource = (NSArray*)[responseDictionary valueForKey:@"availableAuthSources"];
                if (availableAuthSource.count > 0) {
                    if ([[availableAuthSource objectAtIndex:0] isEqualToString:@"password"]) {
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:WOCBuyingStoryboard bundle:nil];
                        WOCPasswordViewController *passwordViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCPasswordViewController"];
                        passwordViewController.phoneNo = phoneNo;
                        passwordViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                        [self.navigationController presentViewController:passwordViewController animated:YES completion:nil];
                    }
                    else if ([[availableAuthSource objectAtIndex:0] isEqualToString:@"device"]) {
                        [self createHoldAfterAuthorize:phoneNo];
                    }
                }
            }
        }
        else {
            
            if ([error code] == 404) {
                //new number
                [self.defaults removeObjectForKey:WOCUserDefaultsAuthToken];
                [self.defaults removeObjectForKey:WOCUserDefaultsLocalPhoneNumber];
                [self.defaults setValue:phoneNo forKey:WOCUserDefaultsLocalPhoneNumber];
                [self.defaults synchronize];

                [self createHold:phoneNo];
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
    
    NSString *deviceCode = [self.defaults valueForKey:WOCUserDefaultsLocalDeviceCode];
    NSString *deviceId = [self.defaults valueForKey:WOCUserDefaultsLocalDeviceId];
    NSString *token = [self.defaults valueForKey:WOCUserDefaultsAuthToken];
    
    NSDictionary *params = @{
                             WOCApiBodyDeviceCode: deviceCode
                            };
    
    if (deviceId != nil) {
        
        params = @{
                   WOCApiBodyDeviceCode: deviceCode,
                   WOCApiBodyDeviceId: deviceId,
                   WOCApiBodyJsonParameter: @"YES"
                   };
        
        [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
            
               NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            if (error == nil) {
                if (responseDictionary != nil) {
                    [self.defaults setValue:[responseDictionary valueForKey:WOCApiResponseToken] forKey:WOCUserDefaultsAuthToken];
                    [self.defaults setValue:phoneNo forKey:WOCUserDefaultsLocalPhoneNumber];
                    [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:WOCApiBodyDeviceId]] forKey:WOCUserDefaultsLocalDeviceId];
                    [self.defaults synchronize];
                    [self storeDeviceInfoLocally];
                    [self createHoldAfterAuthorize:phoneNo];
                }
            }
            else {
                [self.defaults removeObjectForKey:WOCUserDefaultsAuthToken];
                [self.defaults removeObjectForKey:WOCUserDefaultsLocalPhoneNumber];
                [self.defaults removeObjectForKey:WOCUserDefaultsLocalDeviceId];
                [self.defaults synchronize];

                BOOL isNewPhone = YES;
                if (error.code == 400) {
                    if (error.userInfo != nil) {
                        NSString *errorDetail = error.userInfo[@"detail"];
                        if (errorDetail != nil) {
                            if ([errorDetail isEqualToString:@"Unable to authorize your phone number. Password may be incorrect."]) {
                                isNewPhone = NO;
                            }
                        }
                    }
                }
                if (isNewPhone) {
                    [self.defaults setValue:phoneNo forKey:WOCUserDefaultsLocalPhoneNumber];
                    [self.defaults synchronize];
                    [self createHoldAfterAuthorize:phoneNo];
                }
                else {
                      [self openHoldIssueVC];
                }
            }
        }];
    }
}

- (void)createHold:(NSString*)phoneNo {
    
    if (!self.isForLoginOny) {
        MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
        
        NSString *deviceCode = [self.defaults valueForKey:WOCUserDefaultsLocalDeviceCode];
        NSString *token = [self.defaults valueForKey:WOCUserDefaultsAuthToken];
        
        NSDictionary *params;
    
        if (token != nil && (![token isEqualToString:@"(null)"])) {
            params =  @{
                        WOCApiBodyOffer: [NSString stringWithFormat:@"%@==",self.offerId],
                        WOCApiBodyJsonParameter:@"YES"
                        };
        }
        else {
            params =  @{
                        WOCApiBodyOffer: [NSString stringWithFormat:@"%@==",self.offerId],
                        WOCApiBodyPhoneNumber: phoneNo,
                        WOCApiBodyDeviceName: WOCApiBodyDeviceName_IOS,
                        WOCApiBodyDeviceCode: deviceCode,
                        WOCApiBodyJsonParameter:@"YES"
                        };
            
            if (self.emailId != nil && self.emailId.length > 0) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
                [dict setObject:self.emailId forKey:WOCApiBodyEmail];
                params = (NSDictionary*)dict;
            }
        }
        
        [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [hud hideAnimated:YES];
            });
            
            if (error == nil) {
                NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
                if ([responseDictionary valueForKey:WOCApiResponseToken] != nil && (![[responseDictionary valueForKey:WOCApiResponseToken] isEqualToString:@"(null)"])) {
                    [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:WOCApiResponseToken]] forKey:WOCUserDefaultsAuthToken];
                    [self.defaults setValue:phoneNo forKey:WOCUserDefaultsLocalPhoneNumber];
                    [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:WOCApiBodyDeviceId]] forKey:WOCUserDefaultsLocalDeviceId];
                    [self.defaults synchronize];
                    [self storeDeviceInfoLocally];
                }
                
                NSString *holdId = [NSString stringWithFormat:@"%@",REMOVE_NULL_VALUE([responseDictionary valueForKey:WOCApiResponseId])];
                self.holdId = holdId;
                
                NSString *purchaseCode = [NSString stringWithFormat:@"%@",REMOVE_NULL_VALUE([responseDictionary valueForKey:WOCApiResponsePurchaseCde])];
                if (![purchaseCode isKindOfClass:[NSNull class]]) {
                    self.purchaseCode = purchaseCode;
                }
                else {
                    self.purchaseCode = @"";
                }
                
                WOCBuyingWizardInputVarificationCodeViewController *inputVarificationCodeViewController = [self getViewController:@"WOCBuyingWizardInputVarificationCodeViewController"];
                inputVarificationCodeViewController.phoneNo = phoneNo;
                inputVarificationCodeViewController.offerId = self.offerId;
                inputVarificationCodeViewController.purchaseCode = self.purchaseCode;
                inputVarificationCodeViewController.deviceCode = deviceCode;
                inputVarificationCodeViewController.emailId = self.emailId;
                inputVarificationCodeViewController.holdId = self.holdId;
                [self pushViewController:inputVarificationCodeViewController animated:YES];
            }
            else if (error.code == 403 ) {
                [self resolveActiveHoldIssue:phoneNo];
            }
            else if (error.code == 401 ) {
                [self registerDevice:phoneNo];
            }
        }];
    }
    else {
        
        NSString *token = [self.defaults valueForKey:WOCUserDefaultsAuthToken];
        if (token != nil && (![token isEqualToString:@"(null)"])) {
            [self getOrderList];
        }
        else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please select an offer and then try to register/login with app." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 [self backToMainView];
            }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];

        }
    }
}

- (void)resolveActiveHoldIssue:(NSString*)phoneNo {
    
    if (!self.isActiveHoldChecked) {
        NSString *token = [self.defaults valueForKey:WOCUserDefaultsAuthToken];
        if (token != nil && (![token isEqualToString:@"(null)"])) {
            /*you receive Status 403 from POST /api/v1/holds/
            IF YOU HAVE a token or the deviceId/deviceCode, login with that device -- you will use the token to get a list of holds so that you can cancel the holds. IF THERE ARE NO HOLDS, then you will bring the user to the Buy Summary, where they will see their latest WD orders.
             */
            self.isActiveHoldChecked = YES;
            [self getHold];
        }
        else {
            NSString *deviceID = [self getDeviceIDFromPhoneNumber:phoneNo];
            if (deviceID.length > 0 && (![deviceID isEqualToString:@"(null)"])) {
                [self.defaults setObject:deviceID forKey:WOCUserDefaultsLocalDeviceId];
                [self.defaults synchronize];
                [self login:phoneNo];
            }
            else {
                [self openHoldIssueVC];
            }
        }
    }
}

- (void)openHoldIssueVC {
    /*
     IF YOU DO NOT HAVE the token or deviceId/deviceCode in local storage, then you will need to show a new view that says, "You already have an open hold or a pending order with Wall of Coins. Before you can create a new order, you must finish these orders." and then show a yellow button w/ blue text (just like the "BUY MORE {Crypto Currency} WITH CASH" button), and when they press that button, you will bring them to this website link:
     https://wallofcoins.com/signin/1-2397776832/
     https://wallofcoins.com/signin/{phone_country_code}-{local_phone_number}/
     */
    NSString *txtPhone = [self.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *txtcountryCode = [self.countryCode stringByReplacingOccurrencesOfString:@"+" withString:@""];
    WOCHoldIssueViewController *aViewController = [self getViewController:@"WOCHoldIssueViewController"];
    aViewController.phoneNo = [NSString stringWithFormat:@"%@-%@",txtcountryCode,txtPhone];
    [self pushViewController:aViewController animated:YES];
}

- (void)resolvePandingOrderIssue {
    
    [self getOrderList];
}

- (void)getHold {
    
    [[APIManager sharedInstance] getHold:^(id responseDict, NSError *error) {
        if (error == nil) {
            APILog(@"Hold with Hold Id: %@.",responseDict);
            if ([responseDict isKindOfClass:[NSArray class]]) {
                NSArray *holdArray = (NSArray*)responseDict;
                if (holdArray.count > 0) {
                    NSUInteger count = holdArray.count;
                    NSUInteger activeHodCount = 0;
                    
                    for (int i = 0; i < holdArray.count; i++) {
                        count -= count;
                        
                        NSDictionary *holdDict = [holdArray objectAtIndex:i];
                        NSString *holdId = [holdDict valueForKey:WOCApiResponseId];
                        NSString *holdStatus = [holdDict valueForKey:WOCApiResponseHoldsStatus];
                        
                        if (holdStatus != nil) {
                            if ([holdStatus isEqualToString:@"AC"]) {
                                if (holdId) {
                                    activeHodCount = activeHodCount + 1;
                                    [self deleteHold:holdId count:count];
                                }
                            }
                        }
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
                            };
    
    [[APIManager sharedInstance] deleteHold:holdId response:^(id responseDict, NSError *error) {
        if (error == nil) {
            APILog(@"Hold deleted.");
            
            NSString *phoneNo = [self.defaults valueForKey:WOCUserDefaultsLocalPhoneNumber];
            [self createHoldAfterAuthorize:phoneNo];
        }
    }];
}

- (void)registerDevice:(NSString*)phoneNo {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSString *deviceCode = [self.defaults valueForKey:WOCUserDefaultsLocalDeviceCode];
    NSString *token = [self.defaults valueForKey:WOCUserDefaultsAuthToken];
    
    NSDictionary *params =  @{
                              WOCApiBodyName: WOCApiBodyDeviceName_IOS,
                              WOCApiBodyCode: deviceCode,
                              WOCApiBodyJsonParameter:@"YES"
                              };
    
    [[APIManager sharedInstance] registerDevice:params response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [hud hideAnimated:YES];
        });
        
        if (error == nil) {
            NSDictionary *response = (NSDictionary*)responseDict;
            if (response.count > 0) {
                NSString *deviceId = [NSString stringWithFormat:@"%@",[response valueForKey:WOCApiResponseId]];
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
    
    NSString *deviceCode = [self.defaults valueForKey:WOCUserDefaultsLocalDeviceCode];
    NSString *token = [self.defaults valueForKey:WOCUserDefaultsAuthToken];
    
    NSDictionary *params = @{
                             WOCApiBodyDeviceCode: deviceCode,
                             WOCApiBodyJsonParameter: @"YES"
                             };
    
    if (deviceId != nil && (![deviceId isEqualToString:@"(null)"])) {
        params = @{
                   WOCApiBodyDeviceCode: deviceCode,
                   WOCApiBodyDeviceId: deviceId,
                   WOCApiBodyJsonParameter: @"YES"
                   };
    }
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [self.defaults setValue:[responseDictionary valueForKey:WOCApiResponseToken] forKey:WOCUserDefaultsAuthToken];
            [self.defaults setValue:phoneNo forKey:WOCUserDefaultsLocalPhoneNumber];
            [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:WOCApiBodyDeviceId]] forKey:WOCUserDefaultsLocalDeviceId];
            [self.defaults synchronize];
            [self storeDeviceInfoLocally];
            [self createHoldAfterAuthorize:phoneNo];
        }
        else {
            [self.defaults removeObjectForKey:WOCUserDefaultsAuthToken];
            [self.defaults removeObjectForKey:WOCUserDefaultsLocalPhoneNumber];
            [self.defaults removeObjectForKey:WOCUserDefaultsLocalDeviceId];
            [self.defaults setValue:phoneNo forKey:WOCUserDefaultsLocalPhoneNumber];
            [self.defaults synchronize];
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)createHoldAfterAuthorize:(NSString*)phoneNo {
    NSString *token = [self.defaults valueForKey:WOCUserDefaultsAuthToken];
    
    if (token != nil && (![token isEqualToString:@"(null)"])) {
   
        [self createHold:phoneNo];
    }
    else {
        NSString *deviceID = [self getDeviceIDFromPhoneNumber:phoneNo];
        if (deviceID != nil) {
            [self.defaults setObject:deviceID forKey:WOCUserDefaultsLocalDeviceId];
            [self.defaults synchronize];
            [self login:phoneNo];
        }
        else {
             [self createHold:phoneNo];
        }
    }
}

// MARK: - IBAction
- (IBAction)onNextButtonClicked:(id)sender {
    
    NSString *txtPhone = [self.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([self.countryCode length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Select country code." viewController:self.navigationController.visibleViewController];
    }
    else if ([txtPhone length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter phone number." viewController:self.navigationController.visibleViewController];
    }
    else if ([txtPhone length] == 10) {
        self.isActiveHoldChecked = NO;
        [self checkPhone:txtPhone code:self.countryCode];
    }
    else {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter valid phone number." viewController:self.navigationController.visibleViewController];
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.countryCodeTextField.text = [NSString stringWithFormat:@"%@ (%@)",self.countries[row][@"name"],self.countries[row][@"code"]];
    self.countryCode = [NSString stringWithFormat:@"%@",self.countries[row][@"code"]];
}

- (void)pushToStep1 {
    [self storeDeviceInfoLocally];
    [self backToMainView];
}

@end
