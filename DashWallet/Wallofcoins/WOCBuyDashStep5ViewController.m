//
//  WOCBuyDashStep5ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep5ViewController.h"
#import "WOCBuyDashStep6ViewController.h"
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
@interface WOCBuyDashStep5ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *offers;
@property (assign) BOOL incremented;

@end

@implementation WOCBuyDashStep5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for at least $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
    
    [self getOffers];
}

- (void)pushToStep6:(NSInteger)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:0];
    NSDictionary *offerDict = self.offers[indexPath.row];
    WOCBuyDashStep6ViewController *myViewController = (WOCBuyDashStep6ViewController*)[self getViewController:@"WOCBuyDashStep6ViewController"];
    myViewController.offerId = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"id"]];
    [self pushViewController:myViewController animated:YES];
}

// MARK: - API

- (void)getOffers {
    
    if (self.discoveryId != nil && [self.discoveryId length] > 0) {
        [[APIManager sharedInstance] discoveryInputs:self.discoveryId response:^(id responseDict, NSError *error) {
            if (error == nil) {
                NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
                if ([responseDictionary valueForKey:@"singleDeposit"] != nil) {
                    
                    if ([[responseDictionary valueForKey:@"singleDeposit"] isKindOfClass:[NSArray class]] ) {
                        
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
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                  [self.tableView reloadData];
                });
                
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

- (void)getOrders:(NSInteger)sender {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:nil response:^(id responseDict, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [hud hideAnimated:TRUE];
        });
        
        NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];

        if (error == nil) {
            
            NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            if (orders.count > 0) {
                
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
                        return ;
                    }
                }
            }
            
            WOCBuyingInstructionsViewController *myViewController = [self getViewController:@"WOCBuyingInstructionsViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.isFromSend = NO;
            myViewController.isFromOffer = YES;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:0];
            NSDictionary *offerDict = self.offers[indexPath.row];
            myViewController.offerId = [NSString stringWithFormat:@"%@",[offerDict valueForKey:API_RESPONSE_ID]];
            [self pushViewController:myViewController animated:YES];
        }
        else {
           
            [self refereshToken];
        }
    }];
}


// MARK: - IBAction

- (IBAction)orderClicked:(id)sender
{
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        [self getOrders:[sender tag]];
    }
    else {
        [self pushToStep6:[sender tag]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WOCOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offerCell"];
    
    NSDictionary *offerDict = self.offers[indexPath.row];
    
    if (self.incremented) {
        [cell.lblDollar setHidden:false];
    }
    else{
        [cell.lblDollar setHidden:true];
    }
    
    NSString *dashAmount = [NSString stringWithFormat:@"%@ %@",WOC_CURRENTCY_SYMBOL,setVal([[offerDict valueForKey:@"amount"] valueForKey:CRYPTO_CURRENTCY])];
    NSString *bits = [NSString stringWithFormat:@"(%@ %@)",WOC_CURRENTCY_SYMBOL_MINOR,setVal([[offerDict valueForKey:@"amount"] valueForKey:CRYPTO_CURRENTCY_SMALL])];
    NSString *dollarAmount = [NSString stringWithFormat:@"Pay $%@",setVal([[offerDict valueForKey:@"deposit"] valueForKey:@"amount"])];
    NSString *bankName = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankName"])];
    NSString *bankAddress = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"address"])];
    NSString *bankLocationUrl = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankLocationUrl"])];
    NSString *bankLogo = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankLogo"])];
    NSString *bankIcon = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankIcon"])];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t amount;
    amount = [manager amountForDashString:dashAmount];
    
    uint64_t dshAmt = [[[offerDict valueForKey:@"amount"] valueForKey:CRYPTO_CURRENTCY] longLongValue];
    uint64_t bitsAmt = [[[offerDict valueForKey:@"amount"] valueForKey:@"bits"] longLongValue];
    
    cell.lblDashTitle.text = dashAmount;
    cell.lblDashSubTitle.text = bits;
    cell.lblDollar.text = dollarAmount;
    cell.lblBankName.text = bankName;
    
    cell.lblLocation.text = bankAddress;
    
    if (bankLocationUrl.length > 0) {
        [cell.btnLocation setHidden:NO];
        cell.btnLocation.tag = indexPath.row;
        [cell.btnLocation addTarget:self action:@selector(checkLocationClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //bankLogo
    if ([bankLogo length] > 0) {
        
        cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",bankLogo]];
                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                           
                           //This is your completion handler
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               //If self.image is atomic (not declared with nonatomic)
                               // you could have set it directly above
                               if (imageData != nil) {
                                   cell.imgView.image = [UIImage imageWithData:imageData];
                               }
                               else {
                                   cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
                               }
                               
                           });
                       });
    }
    else if ([bankIcon length] > 0) {
        
        cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",bankIcon]];
                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                           
                           //This is your completion handler
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               //If self.image is atomic (not declared with nonatomic)
                               // you could have set it directly above
                               if (imageData != nil) {
                                   cell.imgView.image = [UIImage imageWithData:imageData];
                               }
                               else {
                                   cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
                               }
                               
                           });
                       });
    }
    else {
        cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
    }
    
    [cell.btnOrder addTarget:self action:@selector(orderClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnOrder.tag = indexPath.row;
    
    return cell;
}

// MARK: - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125.0;
}

@end

