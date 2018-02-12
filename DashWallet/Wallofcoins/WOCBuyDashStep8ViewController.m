//
//  WOCBuyDashStep8ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep8ViewController.h"
#import "WOCBuyingInstructionsViewController.h"
#import "WOCBuyingSummaryViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCAlertController.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "MBProgressHUD.h"

@interface WOCBuyDashStep8ViewController ()

@property (strong, nonatomic) NSString *holdId;

@end

@implementation WOCBuyDashStep8ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnPurchaseCode];
    [self createHold];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)confirmPurchaseCodeClicked:(id)sender {
    
    NSString *txtCode = [self.txtPurchaseCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([txtCode length] > 0) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyingInstructionsViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingInstructionsViewController"];
        myViewController.purchaseCode = txtCode;
        myViewController.holdId = self.holdId;
        myViewController.phoneNo = self.phoneNo;
        [self.navigationController pushViewController:myViewController animated:YES];
    }
    else{
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:@"Enter Purchase Code" viewController:self.navigationController.visibleViewController];
    }
}

#pragma mark - Function
- (void)setShadow:(UIView *)view{
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1; //1
    view.layer.shadowOpacity = 1;//1
    view.layer.masksToBounds = false;
}

#pragma mark - API
- (void)createHold {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
   
    if (self.deviceCode == nil)
    {
        self.deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
    }
    
    NSDictionary *params;
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) 
    {
        params =  @{
                    API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    API_BODY_DEVICE_NAME: @"Dash Wallet (iOS)",
                    API_BODY_DEVICE_CODE: self.deviceCode,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    else
    {
        
        params =  @{
                    API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                    API_BODY_OFFER: [NSString stringWithFormat:@"%@==",self.offerId],
                    API_BODY_PHONE_NUMBER: self.phoneNo,
                    API_BODY_DEVICE_NAME: API_BODY_DEVICE_NAME_IOS,
                    API_BODY_DEVICE_CODE: self.deviceCode,
                    API_BODY_EMAIL: self.emailId,
                    API_BODY_JSON_PARAMETER:@"YES"
                    };
    }
    
    [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            self.txtPurchaseCode.text = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"__PURCHASE_CODE"]];
            self.holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"id"]];
            
            if ([responseDictionary valueForKey:@"token"] != nil && [[responseDictionary valueForKey:@"token"] isEqualToString:@"(null)"] == FALSE)
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"token"]] forKey:USER_DEFAULTS_AUTH_TOKEN];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"token"]] forKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
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
                        
                        [self deleteHold:[NSString stringWithFormat:@"%@",[orderDict valueForKey:@"id"]]];
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

- (void)deleteHold:(NSString*)holdId{
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] deleteHold:holdId response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSLog(@"Hold with Hold Id: %@ deleted.",holdId);
        }
        else{
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

@end
