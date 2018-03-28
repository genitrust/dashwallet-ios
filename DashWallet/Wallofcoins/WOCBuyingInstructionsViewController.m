//
//  WOCBuyingInstructionsViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyingInstructionsViewController.h"
#import "WOCBuyingSummaryViewController.h"
#import "WOCBuyDashStep1ViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "WOCAlertController.h"
#import "WOCLocationManager.h"
#import "MBProgressHUD.h"

@interface WOCBuyingInstructionsViewController () <UITextViewDelegate>

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *dueTime;
@property (assign, nonatomic) int minutes;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *locationUrl;
@end

@implementation WOCBuyingInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadow:self.btnDepositFinished];
    [self setShadow:self.btnCancelOrder];
    [self setShadow:self.btnWallOfCoins];
    [self setShadow:self.btnSignOut];
    
    NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    NSString *loginPhone = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",phoneNo];
    self.lblLoginPhone.text = loginPhone;
    
    if (self.orderDict.count > 0) {
        [self updateData:self.orderDict];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    if (!self.isFromSend && !self.isFromOffer) {
        if ([self.purchaseCode length] > 0 && [self.holdId length] > 0) {
            [self captureHold:self.purchaseCode holdId:self.holdId];
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Please enter purchase code." viewController:self.navigationController.visibleViewController];
        }
    }
    else if (self.isFromOffer) {
        NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
        if (self.offerId != nil && [self.offerId length] > 0) {
            [self createHold:self.offerId phoneNo:phoneNo];
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Please select offer." viewController:self.navigationController.visibleViewController];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"If you have any questions, there is a live chat window at wallofcoins.com or you may call the phone number that sent you a text message." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.5]}];
    
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"https://wallofcoins.com"
                             range:[[attributedString string] rangeOfString:@"wallofcoins.com"]];
    
    
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                     NSUnderlineColorAttributeName: [UIColor blackColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                     };
    
    // assume that textView is a UITextView previously created (either by code or Interface Builder)
    self.txtInstruction.linkTextAttributes = linkAttributes; // customizes the appearance of links
    self.txtInstruction.attributedText = attributedString;
    self.txtInstruction.delegate = self;
}


- (void)pushToHome
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_DASH bundle:nil];
        WOCBuyDashStep1ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];
        vc.isFromSend = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = navigationController;
    });
    return;
    
    BOOL viewFound = NO;
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[WOCBuyDashStep1ViewController class]]) {
            [self.navigationController popToViewController:controller animated:NO];
            viewFound = YES;
            break;
        }
    }
    
    if (viewFound == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WOCBuyDashStep1ViewController *myViewController = [self getViewController:@"WOCBuyDashStep1ViewController"];
            [self pushViewController:myViewController animated:YES];
        });
    }
}

- (void)back:(id)sender {
    [self pushToBuyingSummary];
}

- (void)pushToBuyingSummary {
    dispatch_async(dispatch_get_main_queue(), ^{
        WOCBuyingSummaryViewController *myViewController = [self getViewController:@"WOCBuyingSummaryViewController"];
        myViewController.phoneNo = self.phoneNo;
        myViewController.hideSuccessAlert = TRUE;
        [self pushViewController:myViewController animated:YES];
    });
}

- (void)pushToStep1 {
    [self backToMainView];
}

- (void)openSite:(NSURL*)url {
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"URL opened...");
        }];
    }
}

- (void)stopTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timer invalidate];
    });
}

- (void)showDepositAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:@"Are you sure you finished making the payment?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self confirmDeposit];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCancelOrderAlert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:@"Are you sure you want to cancel order?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cancelOrder];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateData:(NSDictionary*)dictionary {
    NSString *bankLogo = setVal([dictionary valueForKey:@"bankLogo"]);
    NSString *bankName = setVal([dictionary valueForKey:@"bankName"]);
    NSString *phoneNo = [NSString stringWithFormat:@"%@",setVal([[dictionary valueForKey:@"nearestBranch"] valueForKey:@"phone"])];
    NSString *accountName = setVal([dictionary valueForKey:@"nameOnAccount"]);
    NSString *accountNo = setVal([dictionary valueForKey:@"account"]);
    float depositAmount = [[dictionary valueForKey:@"payment"] floatValue];
    NSString *depositDue = setVal([dictionary valueForKey:@"paymentDue"]);
    NSString *totalDash = setVal([dictionary valueForKey:@"total"]);
    self.orderId = setVal([dictionary valueForKey:@"id"]);
    
    //bankLogo
    if (![[dictionary valueForKey:@"bankLogo"] isEqual:[NSNull null]] && [bankLogo length] > 0) {
        self.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",bankLogo]];
                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                           
                           //This is your completion handler
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               //If self.image is atomic (not declared with nonatomic)
                               // you could have set it directly above
                               if (imageData != nil) {
                                   self.imgView.image = [UIImage imageWithData:imageData];
                               }
                               else {
                                   self.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
                               }
                           });
                       });
    }
    else {
        self.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
    }
    
    //bankLocationUrl
    if ([dictionary valueForKey:@"bankUrl"] != [NSNull null]) {
        [self.btnCheckLocation setTitle:@"Check locations" forState:UIControlStateNormal];
        self.locationUrl = [dictionary valueForKey:@"bankUrl"];
        if ([[dictionary valueForKey:@"nearestBranch"] class] != [NSNull class]) {
            if([dictionary valueForKey:@"nearestBranch"][@"address"] != nil) {
                if ([[[dictionary valueForKey:@"nearestBranch"] valueForKey:@"address"] length] > 0) {
                    [self.btnCheckLocation setHidden:YES];
                }}
        }
    }
    
    self.lblBankName.text = bankName;
    self.lblPhone.text = [NSString stringWithFormat:@"Location's phone #: %@",phoneNo];
    self.lblAccountName.text = [NSString stringWithFormat:@"Name on Account: %@",accountName];
    self.lblAccountNo.text = [NSString stringWithFormat:@"Account #: %@",accountNo];
    self.lblCashDeposit.text = [NSString stringWithFormat:@"Cash to Deposit: $%.02f",depositAmount];
    
    NSNumber *num = [NSNumber numberWithDouble:([totalDash doubleValue] * 1000000)];
    self.lblInstructions.text = [NSString stringWithFormat:@"You are ordering: %@ %@ (%@ %@)",totalDash,WOC_CURRENTCY_SPECIAL, [self getCryptoPrice:num],WOC_CURRENTCY_SYMBOL_MINOR];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = API_DATE_FORMAT;
    NSDate *local = [formatter dateFromString:depositDue];
    NSLog(@"local: %@",local);
    
    formatter.dateFormat = LOCAL_DATE_FORMAT;
    NSString *localTime = [formatter stringFromDate:local];
    NSLog(@"localTime: %@",localTime);
    self.dueTime = localTime;
    
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSLog(@"currentTime UTC : %@",currentTime);
    
    NSMutableAttributedString *timeString = [self dateDiffrenceBetweenTwoDates:currentTime endDate:localTime];
    NSMutableAttributedString *dueString = [[NSMutableAttributedString alloc] initWithString:@"Deposit Due: "];
    [dueString appendAttributedString:timeString];
    
    self.lblDepositDue.attributedText = dueString;
    
    self.timer = [[NSTimer alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
    
    if ([[dictionary valueForKey:@"account"] length] > 16) {
        NSArray *accountArr = [NSJSONSerialization JSONObjectWithData:[[dictionary valueForKey:@"account"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displaySort" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
            float aObj1 = [(NSString *)obj1 floatValue];
            float aObj2 = [(NSString *)obj2 floatValue];
            return aObj1 > aObj2;
        }];
        
        NSArray *accountArray = [accountArr sortedArrayUsingDescriptors:@[sort]];
        if (accountArray.count > 2) {
            self.lblPhone.text = [NSString stringWithFormat:@"Name: %@ %@",[[accountArray objectAtIndex:0] valueForKey:@"value"], [[accountArray objectAtIndex:2] valueForKey:@"value"]];
        }
        
        if (accountArray.count > 3) {
        self.lblAccountName.text = [NSString stringWithFormat:@"Country of Birth: %@",[[accountArray objectAtIndex:3] valueForKey:@"value"]];
        }
        
        if (accountArray.count > 1) {
        self.lblAccountNo.text = [NSString stringWithFormat:@"Pick-up State: %@",[[accountArray objectAtIndex:1] valueForKey:@"value"]];
        }
    }
}

- (void)checkTime {
    
    if (self.minutes > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = LOCAL_DATE_FORMAT;
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        NSMutableAttributedString *timeString = [self dateDiffrenceBetweenTwoDates:currentTime endDate:self.dueTime];
        NSMutableAttributedString *dueString = [[NSMutableAttributedString alloc] initWithString:@"Deposit Due: "];
        [dueString appendAttributedString:timeString];
        self.lblDepositDue.attributedText = dueString;
    }
    else {
        self.lblDepositDue.text = @"Deposit Due: time expired";
        [self stopTimer];
    }
}

- (NSMutableAttributedString*)dateDiffrenceBetweenTwoDates:(NSString*)startDate endDate:(NSString*)endDate {
    NSMutableAttributedString *timeLeft = [[NSMutableAttributedString alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = LOCAL_DATE_FORMAT;
    
    NSDate *startDateT = [formatter dateFromString:startDate];
    NSDate *endDateT = [formatter dateFromString:endDate];
    
    NSDateComponents *components;
    
    NSInteger days;
    NSInteger hours;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:startDateT toDate:endDateT options:0];
    days = [components day];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:startDateT toDate:endDateT options:0];
    hours = [components hour];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:startDateT toDate:endDateT options:0];
    minutes = [components minute];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:startDateT toDate:endDateT options:0];
    seconds = [components second];
    NSString *secondsInString = [NSString stringWithFormat:@"%ld ", (long)minutes];
    
    self.minutes = [secondsInString intValue];
    
    NSInteger daysN = (int) (floor(seconds / (3600 * 24)));
    if(daysN) seconds -= daysN * 3600 * 24;
    
    NSInteger hoursN = (int) (floor(seconds / 3600));
    if(hoursN) seconds -= hoursN * 3600;
    
    NSInteger minutesN = (int) (floor(seconds / 60));
    if(minutesN) seconds -= minutesN * 60;
    
    if(daysN) {
        [timeLeft appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld Days ", (long)daysN*1]]];
    }
    
    if(hoursN) {
        [timeLeft appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%ld Hour ", (long)hoursN*1]]];
    }
    
    if(minutesN) {
        [timeLeft appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%ld Minutes ",(long)minutesN*1]]];
    }
    
    return timeLeft;
}

// MARK: - API

- (void)createHold:(NSString*)offerId phoneNo:(NSString*)phone {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
        
        NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
        NSString *deviceCode = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
        NSDictionary *params ;
        
        if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
            params = @{
                       API_BODY_OFFER: [NSString stringWithFormat:@"%@==",offerId],
                       API_BODY_JSON_PARAMETER:@"YES"
                       };
        }
        else {
            params = @{
                       API_BODY_OFFER: [NSString stringWithFormat:@"%@==",offerId],
                       API_BODY_PHONE_NUMBER: phone,
                       API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                       API_BODY_DEVICE_CODE: deviceCode,
                       API_BODY_JSON_PARAMETER:@"YES"
                       };
        }
        
        [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            if (error == nil) {
                NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
                if ([responseDictionary valueForKey:API_RESPONSE_TOKEN] != nil && [[responseDictionary valueForKey:API_RESPONSE_TOKEN] isEqualToString:@"(null)"] == FALSE)
                {
                    [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_TOKEN]] forKey:USER_DEFAULTS_AUTH_TOKEN];
                    [self.defaults setValue:phone forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                    [self.defaults setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_BODY_DEVICE_ID]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                    [self.defaults synchronize];
                }
                
                NSString *holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_ID]];
                self.holdId = holdId;
                
                NSString *purchaseCode = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:API_RESPONSE_PURCHASE_CODE]];
                self.purchaseCode = purchaseCode;
                
                [self captureHold:purchaseCode holdId:holdId];
            }
            else if (error.code == 403 ) {
                [self getHold];
            }
            else if (error.code == 500 ) {
                [self pushToBuyingSummary];
            }
        }];
    });
}

- (void)getHold {
    [[APIManager sharedInstance] getHold:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSLog(@"Hold with Hold Id: %@.",responseDict);
            
            if ([responseDict isKindOfClass:[NSArray class]]) {
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
                        }
                        else {
                            if (holdId) {
                                activeHodCount = activeHodCount + 1;
                                [self deleteHold:holdId count:count];
                            }
                        }
                    }
                    
                    if (activeHodCount == 0 ) {
                        [self getOrderList];
                    }
                }
                else {
                    [self getOrderList];
                }
            }
            else {
                [self getOrderList];
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
            NSLog(@"Hold deleted.");
            
            NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [self createHold:self.offerId phoneNo:phoneNo];
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)captureHold:(NSString*)purchaseCode holdId:(NSString*)holdId {
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             API_BODY_VERIFICATION_CODE: purchaseCode,
                             API_BODY_JSON_PARAMETER: @"YES"
                             };
    
    [[APIManager sharedInstance] captureHold:params holdId:self.holdId response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
        if (error == nil) {
            if ([responseDict isKindOfClass:[NSArray class]])
            {
                NSArray *response = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
                if (response.count > 0) {
                    if ([[response objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                        [self updateData:[response objectAtIndex:0]];
                    }
                }
            }
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }];
}

- (void)confirmDeposit {
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    if (self.orderId != nil) {
        
        [[APIManager sharedInstance] confirmDeposit:self.orderId response:^(id responseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            if (error == nil) {
                [self stopTimer];
                [self pushToBuyingSummary];
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
        }];
    }
}

- (void)cancelOrder {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    if (self.orderId != nil) {
        
        [[APIManager sharedInstance] cancelOrder:self.orderId response:^(id responseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            if (error == nil) {
                [self stopTimer];
                [self backToMainView];
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
        }];
    }
}

// MARK: - IBAction

- (IBAction)showMapClicked:(id)sender {
    if (self.locationUrl != nil) {
        if (![self.locationUrl hasPrefix:@"http"]) {
            self.locationUrl = [NSString stringWithFormat:@"https://%@",self.locationUrl];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.locationUrl]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.locationUrl] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"URL opened.");
            }];
        }
    }
    else {
        // Your location from latitude and longitude
        double latitude = [[self.defaults valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LATITUDE] doubleValue];
        double longitude = [[self.defaults valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE] doubleValue];
        
        NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f", latitude, longitude, latitude, longitude];
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
        }
    }
}

- (IBAction)depositFinishedClicked:(id)sender {
    [self showDepositAlert];
}

- (IBAction)cancelOrderClicked:(id)sender {
    [self showCancelOrderAlert];
}

- (IBAction)wallOfCoinsClicked:(id)sender {
    [self openSite:[NSURL URLWithString:@"https://wallofcoins.com"]];
}

- (IBAction)signOutClicked:(id)sender {
    [self signOutWOC];
}

// MARK: - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"https"]) {
        [self openSite:URL];
        return NO;
    }
    return YES;
}

@end
