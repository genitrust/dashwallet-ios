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
@property (strong, nonatomic) NSMutableDictionary *offersDict;

@property (assign) BOOL incremented;
@property (assign) BOOL isExtendedSearch;
@end

@implementation WOCBuyDashStep5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for at least $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
    [self getOffers];
}

- (void)pushToStep6:(NSInteger)sender {
    
    NSIndexPath *indexPath = [self getIndexPathfromTag:sender];
    NSString *key = self.offersDict.allKeys[indexPath.section];
    NSArray *offerArray = self.offersDict[key];
    NSDictionary *offerDict = offerArray[indexPath.row];
    WOCBuyDashStep6ViewController *myViewController = (WOCBuyDashStep6ViewController*)[self getViewController:@"WOCBuyDashStep6ViewController"];
    myViewController.offerId = [NSString stringWithFormat:@"%@",[offerDict valueForKey:@"id"]];
    [self pushViewController:myViewController animated:YES];
}

// MARK: - API

- (void)getOffers {
    
    self.offersDict = [NSMutableDictionary dictionaryWithCapacity:0];
    if (self.discoveryId != nil && [self.discoveryId length] > 0) {
        
         MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
        
        [[APIManager sharedInstance] discoveryInputs:self.discoveryId response:^(id responseDict, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            if (error == nil) {
                
                NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
                
                if ([[responseDictionary valueForKey:@"incremented"] boolValue] == TRUE) {
                    self.incremented = TRUE;
                    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for at least $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
                }
                else {
                    self.incremented = FALSE;
                    self.lblInstruction.text = [NSString stringWithFormat:@"Below are offers for $%@. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
                }
                
                if ([[responseDictionary valueForKey:@"isExtendedSearch"] boolValue] == TRUE) {
                    self.isExtendedSearch = TRUE;
                    
                    self.lblInstruction.text = [NSString stringWithFormat:@"Most Convenient Options While $%@ is not available, we gathered the closest options. You must click the ORDER button before you receive instructions to pay at the Cash Payment center.",self.amount];
                }
                else {
                    self.isExtendedSearch = FALSE;
                }
                
                if ([responseDictionary valueForKey:@"singleDeposit"] != nil) {
                    
                    if ([[responseDictionary valueForKey:@"singleDeposit"] isKindOfClass:[NSArray class]] ) {
                        
                        NSArray *offersArray = [[NSArray alloc] initWithArray:(NSArray*)[responseDictionary valueForKey:@"singleDeposit"]];
                        self.offers = [[NSArray alloc] initWithArray:offersArray];
                        if (offersArray.count > 0) {
                            self.offersDict[@""] = offersArray;
                        }
                    }
                }
                
                if ([responseDictionary valueForKey:@"doubleDeposit"] != nil) {
                    
                    if ([[responseDictionary valueForKey:@"doubleDeposit"] isKindOfClass:[NSArray class]] ) {
                        
                        NSArray *offersArray = [[NSArray alloc] initWithArray:(NSArray*)[responseDictionary valueForKey:@"doubleDeposit"]];
                        NSArray *doubleOffer = [self getOffersFromDoubleDeposit:offersArray];
                        if (doubleOffer.count > 0) {
                            
                            if (self.isExtendedSearch == TRUE) {
                                NSString *key = [NSString stringWithFormat:@" Best Value options: more %@ for under $%@ cash.",WOC_CURRENTCY,self.amount];
                               self.offersDict[key] = doubleOffer;
                            }
                            else {
                                NSString *key = [NSString stringWithFormat:@" Best Value options: more %@ for $%@ cash.",WOC_CURRENTCY,self.amount];
                                self.offersDict[key] = doubleOffer;
                            }
                        }
                    }
                }
                
                if ([responseDictionary valueForKey:@"multipleBanks"] != nil) {
                    
                    if ([[responseDictionary valueForKey:@"multipleBanks"] isKindOfClass:[NSArray class]] ) {
                        
                        NSArray *offersArray = [[NSArray alloc] initWithArray:(NSArray*)[responseDictionary valueForKey:@"multipleBanks"]];
                        NSArray *multipleBankOffer = [self getOffersFromDoubleDeposit:offersArray]; NSArray *doubleOffer = [self getOffersFromDoubleDeposit:offersArray];
                        if (multipleBankOffer.count > 0) {
                            
                            if (self.isExtendedSearch == TRUE) {
                                NSString *key = [NSString stringWithFormat:@"Best Value options: more %@ for under $%@ cash from multiple banks.",WOC_CURRENTCY,self.amount];
                                self.offersDict[key] = multipleBankOffer;
                            }
                            else {
                                NSString *key = [NSString stringWithFormat:@"Best Value options: more %@ for $%@ cash from multiple banks.",WOC_CURRENTCY,self.amount];
                                self.offersDict[key] = multipleBankOffer;
                            }
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

-(NSArray*)getOffersFromDoubleDeposit:(NSArray*)doubleDepositOffers
{
    NSMutableArray *signleDepositOfferArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *offerDictionary in doubleDepositOffers)
    {
        NSMutableDictionary *reviceOfferDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        reviceOfferDict[@"deposit"] = @{
                                     @"currency": offerDictionary[@"totalDeposit"][@"currency"],
                                     @"amount": offerDictionary[@"totalDeposit"][@"amount"]
                                     };
        reviceOfferDict[@"id"] = offerDictionary[@"id"];

        if (offerDictionary[@"firstOffer"] != nil) {
            NSDictionary *firstOfferDict = offerDictionary[@"firstOffer"];
            
            reviceOfferDict[@"crypto"] = firstOfferDict[@"crypto"];
            reviceOfferDict[@"amount"] = @{
                                        @"DASH" : firstOfferDict[@"amount"][@"DASH"],
                                        @"dots" : firstOfferDict[@"amount"][@"dots"],
                                        @"bits" : firstOfferDict[@"amount"][@"bits"],
                                        @"BTC" : firstOfferDict[@"amount"][@"BTC"]
                                        };
            reviceOfferDict[@"discoveryId"] = firstOfferDict[@"discoveryId"];
            reviceOfferDict[@"distance"] =  firstOfferDict[@"distance"];
            reviceOfferDict[@"address"] =  firstOfferDict[@"address"] ;
            reviceOfferDict[@"state"] = firstOfferDict[@"state"] ;
            reviceOfferDict[@"bankName"] = firstOfferDict[@"bankName"] ;
            reviceOfferDict[@"bankLogo"] =  firstOfferDict[@"bankLogo"] ;
            reviceOfferDict[@"bankIcon"] = firstOfferDict[@"bankIcon"] ;
            reviceOfferDict[@"bankLocationUrl"] =  firstOfferDict[@"bankLocationUrl"];
            reviceOfferDict[@"city"] = firstOfferDict[@"city"];
            
            
            if (offerDictionary[@"secondOffer"] != nil) {
                NSDictionary *secondOffer = offerDictionary[@"secondOffer"];
                if ([firstOfferDict[@"bankName"] isEqualToString:secondOffer[@"bankName"]] == FALSE) {
                    reviceOfferDict[@"isMultipleBank"] = @TRUE;
                    reviceOfferDict[@"otherBankName"] = secondOffer[@"bankName"];
                    reviceOfferDict[@"otherBankLogo"] = secondOffer[@"bankLogo"];
                }
                
                NSDictionary *amountDict = firstOfferDict[@"amount"];
                NSDictionary *secondAmountDict = offerDictionary[@"secondOffer"];
                
                NSNumber *firstOfferMinorNumber = [NSNumber numberWithFloat:[NSString stringWithFormat:@"%@",[firstOfferDict[@"amount"][CRYPTO_CURRENTCY_SMALL] stringByReplacingOccurrencesOfString:@"," withString:@""]].floatValue];
                
                NSNumber *secondOfferMinorNumber = [NSNumber numberWithFloat:[NSString stringWithFormat:@"%@",[secondOffer[@"amount"][CRYPTO_CURRENTCY_SMALL] stringByReplacingOccurrencesOfString:@"," withString:@""]].floatValue];
                
                NSNumber *totoalMinorNumber =  [NSNumber numberWithFloat:(firstOfferMinorNumber.longLongValue + secondOfferMinorNumber.floatValue)] ;
                
                NSString *totalMinorStr = [self getCryptoPrice:totoalMinorNumber];
                NSLog(@"totalMinorStr = %@",totalMinorStr);
                
                NSNumber *firstOfferMajorNumber = [NSNumber numberWithFloat:[NSString stringWithFormat:@"%@",[firstOfferDict[@"amount"][CRYPTO_CURRENTCY] stringByReplacingOccurrencesOfString:@"," withString:@""]].floatValue];
                
                NSNumber *secondOfferMajorNumber = [NSNumber numberWithFloat:[NSString stringWithFormat:@"%@",[secondOffer[@"amount"][CRYPTO_CURRENTCY] stringByReplacingOccurrencesOfString:@"," withString:@""]].floatValue];
                
                NSNumber *totoalMajorNumber =  [NSNumber numberWithFloat:(firstOfferMajorNumber.longLongValue + secondOfferMajorNumber.floatValue)] ;
                
                NSString *totalMajorStr = [self getCryptoPrice:totoalMajorNumber];
                NSLog(@"totalMajorStr = %@",totalMajorStr);

                reviceOfferDict[@"amount"] = @{
                                            CRYPTO_CURRENTCY : totalMajorStr,
                                            CRYPTO_CURRENTCY_SMALL : totalMinorStr,
                                            @"bits" : [NSNumber numberWithFloat:([amountDict[@"bits"] floatValue] + [secondAmountDict[@"bits"] floatValue])],
                                            @"BTC" : [NSNumber numberWithFloat:([amountDict[@"BTC"] floatValue] + [secondAmountDict[@"BTC"] floatValue])]
                                            };
            }
            
            [signleDepositOfferArray addObject:reviceOfferDict];
        }
    }
    return (NSArray*)signleDepositOfferArray;
}

- (void)getOrders:(NSInteger)sender {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                            };
    
    [[APIManager sharedInstance] getOrders:nil response:^(id responseDict, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [hud hideAnimated:TRUE];
        });
        
        NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];

        if (error == nil) {
            
            if ([responseDict isKindOfClass:[NSArray class]]) {
                
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
            }
            
            WOCBuyingInstructionsViewController *myViewController = [self getViewController:@"WOCBuyingInstructionsViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.isFromSend = NO;
            myViewController.isFromOffer = YES;
            
            NSIndexPath *indexPath = [self getIndexPathfromTag:sender];
            NSString *key = self.offersDict.allKeys[indexPath.section];
            NSArray *offerArray = self.offersDict[key];
            NSDictionary *offerDict = offerArray[indexPath.row];
            
            myViewController.offerId = [NSString stringWithFormat:@"%@",[offerDict valueForKey:API_RESPONSE_ID]];
            [self pushViewController:myViewController animated:YES];
        }
        else {
           
            [self refereshToken];
        }
    }];
}

// MARK: - IBAction

- (IBAction)orderClicked:(id)sender {
    
    NSString *token = [self.defaults valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        [self getOrders:[sender tag]];
    }
    else {
        [self pushToStep6:[sender tag]];
    }
}

- (IBAction)checkLocationClicked:(id)sender {
    
    NSIndexPath *indexPath = [self getIndexPathfromTag:[sender tag]];
    NSString *key = self.offersDict.allKeys[indexPath.section];
    NSArray *offerArray = self.offersDict[key];
    NSDictionary *offerDict = offerArray[indexPath.row];
    
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.offersDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    NSString *key = self.offersDict.allKeys[section];
    NSArray *offerArray = self.offersDict[key];
    return offerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WOCOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offerCell"];
    
    NSString *key = self.offersDict.allKeys[indexPath.section];
    NSArray *offerArray = self.offersDict[key];
    
    NSDictionary *offerDict = offerArray[indexPath.row];
    if (self.incremented || self.isExtendedSearch) {
        [cell.lblDollar setHidden:FALSE];
    }
    else {
        [cell.lblDollar setHidden:FALSE];
    }
    
    NSString *dashAmount = [NSString stringWithFormat:@"%@ %@",WOC_CURRENTCY_SYMBOL,setVal([[offerDict valueForKey:@"amount"] valueForKey:CRYPTO_CURRENTCY])];
    NSString *bits = [NSString stringWithFormat:@"(%@ %@)",WOC_CURRENTCY_SYMBOL_MINOR,setVal([[offerDict valueForKey:@"amount"] valueForKey:CRYPTO_CURRENTCY_SMALL])];
    NSString *dollarAmount = [NSString stringWithFormat:@"Pay $%@",setVal([[offerDict valueForKey:@"deposit"] valueForKey:@"amount"])];
    NSString *bankName = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankName"])];
    NSString *bankAddress = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"address"])];
    NSString *bankLocationUrl = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankLocationUrl"])];
    NSString *bankLogo = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankLogo"])];
    NSString *bankIcon = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"bankIcon"])];
    NSString *otherbankLogo = [NSString stringWithFormat:@"%@",setVal([offerDict valueForKey:@"otherBankLogo"])];

    cell.lblLocation.font = [UIFont systemFontOfSize:12];
    cell.otherBankImgView.hidden = TRUE;
    if (offerDict[@"isMultipleBank"] != nil) {
        BOOL isMultipleBank = [offerDict valueForKey:@"isMultipleBank"];
        if (isMultipleBank) {
            bankAddress = [offerDict valueForKey:@"otherBankName"];
            cell.lblLocation.font = cell.lblBankName.font;
        }
        cell.otherBankImgView.hidden = FALSE;
        if ([otherbankLogo length] > 0) {
            
            cell.otherBankImgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^{
                               NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",otherbankLogo]];
                               NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                               
                               //This is your completion handler
                               dispatch_sync(dispatch_get_main_queue(), ^{
                                   //If self.image is atomic (not declared with nonatomic)
                                   // you could have set it directly above
                                   if (imageData != nil) {
                                       cell.otherBankImgView.image = [UIImage imageWithData:imageData];
                                   }
                                   else {
                                       cell.otherBankImgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
                                   }
                               });
                           });
        }
    }
    cell.lblDashTitle.text = dashAmount;
    cell.lblDashSubTitle.text = bits;
    cell.lblDollar.text = dollarAmount;
    cell.lblBankName.text = bankName;
    cell.lblLocation.text = bankAddress;
    
    if (bankLocationUrl.length > 0) {
        [cell.btnLocation setHidden:NO];
        cell.btnLocation.tag = indexPath.section * 100000 + indexPath.row;
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
    
    cell.btnOrder.tag = indexPath.section * 100000 + indexPath.row;
    [cell.btnOrder addTarget:self action:@selector(orderClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

// MARK: - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = self.offersDict.allKeys[indexPath.section];
    NSArray *offerArray = self.offersDict[key];
    NSDictionary *offerDict = offerArray[indexPath.row];
    if (offerDict[@"isMultipleBank"] != nil) {
        BOOL isMultipleBank = [offerDict valueForKey:@"isMultipleBank"];
        if (isMultipleBank) {
            return 150.0;
        }
    }
    return 125.0;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *key = self.offersDict.allKeys[section];
//    return key;
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    NSString *key = self.offersDict.allKeys[section];
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 0.0, tableView.frame.size.width-60.0, 50.0)];
    lblHeader.text = key;
    lblHeader.numberOfLines = 2.0;
    lblHeader.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    return lblHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 0){
        return 50.0;
    }
    return 20.0;
}

-(NSIndexPath*)getIndexPathfromTag:(NSInteger)tag {
    
    int row = tag % 100000;
    int section = tag / 100000;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}
@end

