//
//  WOCBuyDashStep5ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep5ViewController.h"
#import "WOCOfferCell.h"
#import "WOCBuyDashStep6ViewController.h"
#import "APIManager.h"
#import "BRWalletManager.h"

@interface WOCBuyDashStep5ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *offers;

@end

@implementation WOCBuyDashStep5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
    [self getOffers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)orderClicked:(id)sender{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    
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
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WOCOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offerCell"];
    
    NSDictionary *offerDict = self.offers[indexPath.row];
    
    NSString *dashAmount = [NSString stringWithFormat:@"%@",[[offerDict valueForKey:@"amount"] valueForKey:@"DASH"]];
    NSString *bits = [NSString stringWithFormat:@"%@",[[offerDict valueForKey:@"amount"] valueForKey:@"bits"]];
    NSString *bankName = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"bankName"]];
    NSString *bankAddress = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"address"]];
    NSString *bankLocationUrl = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"bankLocationUrl"]];
    NSString *bankLogo = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"bankLogo"]];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t amount;
    amount = [manager amountForDashString:dashAmount];
    
    uint64_t dshAmt = [[[offerDict valueForKey:@"amount"] valueForKey:@"DASH"] longLongValue];
    uint64_t bitsAmt = [[[offerDict valueForKey:@"amount"] valueForKey:@"bits"] longLongValue];
    //[manager attributedStringForDashAmount:dshAmt]
    //[manager bitcoinCurrencyStringForAmount:bitsAmt]
    cell.lblDashTitle.text = dashAmount;
    cell.lblDashSubTitle.text = bits;
    cell.lblBankName.text = bankName;
    cell.lblLocation.text = bankAddress;
    
    if ([offerDict valueForKey:@"bankLocationUrl"] != [NSNull null]) {
        [cell.btnLocation setHidden:NO];
    }
    
    /*if ([bankLogo length] > 0) {
     
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bankLogo,bankLogo]]];
        cell.imgView.image = [UIImage imageWithData: imageData];
    }*/
    
    cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
    
    [cell.btnOrder addTarget:self action:@selector(orderClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnOrder.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 125.0;
}
@end
