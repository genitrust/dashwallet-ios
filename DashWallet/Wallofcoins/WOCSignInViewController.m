//
//  WOCBuyDashStep5ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSignInViewController.h"
#import "WOCBuyDashStep7ViewController.h"
#import "WOCBuyingInstructionsViewController.h"
#import "WOCBuyingSummaryViewController.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "WOCOfferCell.h"
#import "APIManager.h"
#import "BRWalletManager.h"
#import "WOCAlertController.h"
#import "MBProgressHUD.h"
#import "WOCBuyDashStep1ViewController.h"

@interface WOCSignInViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *offers;
@property (assign) BOOL incremented;

@end

@implementation WOCSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for at least $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
     [self setShadow:self.signupBtn];
     [self setShadow:self.sighInBtn];
     [self getLocalDevices];
}

- (void)getLocalDevices {
    
    if ([self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] != nil) {
        
        if ([[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionaryWithDictionary:[self.defaults objectForKey:USER_DEFAULTS_LOCAL_DEVICE_INFO]];
            if (deviceInfoDict != nil) {
                self.offers = deviceInfoDict.allKeys;
                 [self.tableView reloadData];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushToStep7:(NSInteger)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:0];
    NSString *phoneNumber = self.offers[indexPath.row];
    NSLog(@"phoneNumber = %@",phoneNumber);
    
    [self.defaults setObject:phoneNumber forKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    [self.defaults synchronize];
    [self refereshToken];
    [self performSelector:@selector(backToMainView) withObject:nil afterDelay:1.0];
}

// MARK: - API
- (void)getOffers {
    if (self.discoveryId != nil && [self.discoveryId length] > 0) {
        [[APIManager sharedInstance] discoveryInputs:self.discoveryId response:^(id responseDict, NSError *error) {
            if (error == nil) {
                NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
                NSArray *offersArray = [[NSArray alloc] initWithArray:(NSArray*)[responseDictionary valueForKey:@"singleDeposit"]];
                self.offers = [[NSArray alloc] initWithArray:offersArray];
                
                if ([[responseDictionary valueForKey:@"incremented"] boolValue] == true) {
                    self.incremented = true;
                    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for at least $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
                }
                else {
                    self.incremented = false;
                    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
                }
                
                [self.tableView reloadData];
            }
            else {
                
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
        }];
    }
}

- (void)getOrders:(NSInteger)sender {
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:nil response:^(id responseDict, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
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
            else {
                NSString *phoneNo = [self.defaults valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
                WOCBuyingInstructionsViewController *myViewController = [self getViewController:@"WOCBuyingInstructionsViewController"];
                myViewController.phoneNo = phoneNo;
                myViewController.isFromSend = NO;
                myViewController.isFromOffer = YES;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:0];
                NSDictionary *offerDict = self.offers[indexPath.row];
                myViewController.offerId = [NSString stringWithFormat:@"%@",[offerDict valueForKey:API_RESPONSE_ID]];
                [self pushViewController:myViewController animated:YES];
            }
        }
        else {
           // [self pushToStep6:sender];
            [self pushToStep1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Token expired." viewController:self];
            });
        }
    }];
}

- (void)pushToStep1 {
    [self backToMainView];
}

// MARK: - IBAction

- (IBAction)signInPhoneClicked:(id)sender {
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        [self getOrderList];
    }
    else {
        [self pushToStep7:[sender tag]];
    }
}

- (IBAction)existingAccoutClick:(id)sender {
    WOCBuyDashStep7ViewController *myViewController = [self getViewController:@"WOCBuyDashStep7ViewController"];
    myViewController.isForLoginOny = TRUE;
    [self pushViewController:myViewController animated:YES];
}

- (IBAction)signUpClick:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://wallofcoins.com/signup/"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (IBAction)checkLocationClicked:(id)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    NSDictionary *offerDict = self.offers[indexPath.row];
    if (![[offerDict valueForKey:@"bankLocationUrl"] isEqual:[NSNull null]]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[offerDict valueForKey:@"bankLocationUrl"]]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                NSLog(@"URL opened!");
            }];
        }
    }
}

// MARK: - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WOCOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offerCell"];
    cell.backgroundColor = [UIColor clearColor];
    NSString *phoneNumber = self.offers[indexPath.row];
    [cell.btnOrder setTitle:[NSString stringWithFormat:@"SIGN IN: %@",phoneNumber] forState:UIControlStateNormal];
    [cell.btnOrder setTitle:@"" forState:UIControlStateSelected];
    [cell.btnOrder addTarget:self action:@selector(signInPhoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnOrder.tag = indexPath.row;
    
    return cell;
}

// MARK: - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

@end

