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
#import "WOCOfferCell.h"
#import "APIManager.h"
#import "BRWalletManager.h"
#import "WOCAlertController.h"

@interface WOCBuyDashStep5ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *offers;

@end

@implementation WOCBuyDashStep5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Buy Dash With Cash";
    
    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
    [self getOffers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)orderClicked:(id)sender{
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kToken];
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        [self getOrders:[sender tag]];
    }
    else
    {
        [self pushToStep6:[sender tag]];
    }
}

- (IBAction)checkLocationClicked:(id)sender{
    
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

- (void)pushToStep6:(NSInteger)sender{

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:0];
    NSDictionary *offerDict = self.offers[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep6ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep6ViewController"];
    myViewController.offerId = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"id"]];
    [self.navigationController pushViewController:myViewController animated:YES];
}

#pragma mark - API

- (void)getOffers {

    if (self.discoveryId != nil && [self.discoveryId length] > 0) {
        
        [[APIManager sharedInstance] discoveryInputs:self.discoveryId response:^(id responseDict, NSError *error) {
            
            if (error == nil) {
                
                NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
                NSArray *offersArray = [[NSArray alloc] initWithArray:(NSArray*)[responseDictionary valueForKey:@"singleDeposit"]];
                self.offers = [[NSArray alloc] initWithArray:offersArray];
                
                [self.tableView reloadData];
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
        }];
    }
}

- (void)getOrders:(NSInteger)sender {
    
    NSDictionary *params = @{
                             @"kPublisherId": @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSArray *orders = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            
            if (orders.count > 0){
                
                NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:kPhone];
                
                NSDictionary *orderDict = (NSDictionary*)[orders objectAtIndex:0];
                
                NSString *status = [NSString stringWithFormat:@"%@",[orderDict valueForKey:@"status"]];
                
                if ([status isEqualToString:@"WD"]) {
                    
                    UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                    WOCBuyingInstructionsViewController *myViewController = [stroyboard instantiateViewControllerWithIdentifier:@"WOCBuyingInstructionsViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.isFromSend = YES;
                    myViewController.orderDict = (NSDictionary*)[orders objectAtIndex:0];
                    [self.navigationController pushViewController:myViewController animated:YES];
                }
                else{
                    //[self pushToStep6:sender];
                    
                    UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                    WOCBuyingInstructionsViewController *myViewController = [stroyboard instantiateViewControllerWithIdentifier:@"WOCBuyingInstructionsViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.offerId = [NSString stringWithFormat:@"%@",[[self.offers objectAtIndex:sender] valueForKey:@"id"]];
                    myViewController.isFromOffer = YES;
                    myViewController.isFromSend = NO;
                    myViewController.orderDict = (NSDictionary*)[orders objectAtIndex:0];
                    [self.navigationController pushViewController:myViewController animated:YES];
                }
            }
            else{
                [self pushToStep6:sender];
            }
        }
        else{
            [self pushToStep6:sender];
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WOCOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offerCell"];
    
    NSDictionary *offerDict = self.offers[indexPath.row];
    
    NSString *dashAmount = [NSString stringWithFormat:@"%@",[[offerDict valueForKey:@"amount"] valueForKey:@"DASH"]];
    NSString *bits = [NSString stringWithFormat:@"(%@)",[[offerDict valueForKey:@"amount"] valueForKey:@"dots"]];
    NSString *bankName = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"bankName"]];
    NSString *bankAddress = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"address"]];
    NSString *bankLocationUrl = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"bankLocationUrl"]];
    NSString *bankLogo = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"bankLogo"]];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t amount;
    amount = [manager amountForDashString:dashAmount];
    
    uint64_t dshAmt = [[[offerDict valueForKey:@"amount"] valueForKey:@"DASH"] longLongValue];
    uint64_t bitsAmt = [[[offerDict valueForKey:@"amount"] valueForKey:@"bits"] longLongValue];

    cell.lblDashTitle.text = dashAmount;
    cell.lblDashSubTitle.text = bits;
    cell.lblBankName.text = bankName;
    cell.lblLocation.text = bankAddress;
    
    if ([offerDict valueForKey:@"bankLocationUrl"] != [NSNull null]) {
        [cell.btnLocation setHidden:NO];
        cell.btnLocation.tag = indexPath.row;
        [cell.btnLocation addTarget:self action:@selector(checkLocationClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //bankLogo - inproper url in development
    /*if ([bankLogo length] > 0) {
     
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bankLogo,bankLogo]]];
        cell.imgView.image = [UIImage imageWithData: imageData];
    }*/
    
    cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
    
    [cell.btnOrder addTarget:self action:@selector(orderClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnOrder.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 125.0;
}
@end
