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
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kToken];
   
    if (self.deviceCode == nil)
    {
        self.deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceCode];
    }
    
    NSDictionary *params;
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) 
    {
        params =  @{
                    kPublisherId: @WALLOFCOINS_PUBLISHER_ID,
                    kOffer: [NSString stringWithFormat:@"%@==",self.offerId],
                    kDeviceName: @"Dash Wallet (iOS)",
                    kDeviceCode: self.deviceCode,
                    kJSONParameter:@"YES"
                    };
    }
    else
    {
        
        params =  @{
                    kPublisherId: @WALLOFCOINS_PUBLISHER_ID,
                    kOffer: [NSString stringWithFormat:@"%@==",self.offerId],
                    kPhone: self.phoneNo,
                    kDeviceName: kDeviceNameIOS,
                    kDeviceCode: self.deviceCode,
                    kEmail: self.emailId,
                    kJSONParameter:@"YES"
                    };
    }
    
    [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            self.txtPurchaseCode.text = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"__PURCHASE_CODE"]];
            self.holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"id"]];
            
            if ([responseDictionary valueForKey:kToken] != nil && [[responseDictionary valueForKey:kToken] isEqualToString:@"(null)"] == FALSE)
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:kToken]] forKey:kToken];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:kDeviceId]] forKey:kDeviceId];
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
                             kPublisherId: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:params response:^(id responseDict, NSError *error) {
        
        [hud hideAnimated:TRUE];
        
        if (error == nil) {
            
            NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            
            if (orders.count > 0){
                
                NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:kPhone];
                
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
                             kPublisherId: @WALLOFCOINS_PUBLISHER_ID
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
