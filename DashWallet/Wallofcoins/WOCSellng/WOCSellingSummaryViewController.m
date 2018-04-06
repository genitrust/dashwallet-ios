//
//  WOCSellingSummaryViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#define WD @"WD"
#define WDV @"WDV"
#define RERR @"RERR"
#define DERR @"DERR"
#define RSD @"RSD"
#define RMIT @"RMIT"
#define UCRV @"UCRV"
#define PAYP @"PAYP"
#define SENT @"SENT"

#define STATUS_WD @"Waiting Deposit"
#define STATUS_WDV @"Waiting Deposit Verification"
#define STATUS_RERR @"Issue with Receipt"
#define STATUS_DERR @"Issue with Deposit"
#define STATUS_RSD @"Reserved for Deposit"
#define STATUS_RMIT @"Remit Address Missing"
#define STATUS_UCRV @"Under Review"
#define STATUS_PAYP @"Done - Pending Delivery"
#define STATUS_SENT @"Done - Units Delivered"

#import "WOCSellingSummaryViewController.h"
#import "WOCSummaryCell.h"
#import "WOCSignOutCell.h"
#import "WOCSellingStep1ViewController.h"
#import "WOCSellingStep4ViewController.h"
#import "APIManager.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "WOCAlertController.h"
#import "MBProgressHUD.h"
#import "WOCAsyncImageView.h"

@interface WOCSellingSummaryViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *wdOrders;
@property (strong, nonatomic) NSArray *otherOrders;

@end

@implementation WOCSellingSummaryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    [self setShadow:self.btnBuyMoreDash];
    [self setAttributedString];
    
    if (self.orders.count == 0) {
        
        [self reloadOrderTable];

        [self getOrders];
        
        if (self.hideSuccessAlert == FALSE) {
            [self displayAlert];
        }
    }
    else {
        
        NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
        NSArray *wdvArray = [self.orders filteredArrayUsingPredicate:wdvPredicate];
        self.wdOrders = [[NSArray alloc] initWithArray:wdvArray];
        
        NSPredicate *otherPredicate = [NSPredicate predicateWithFormat:@"status == 'WDV' || status == 'RERR' || status == 'DERR' || status == 'RSD' || status == 'RMIT' || status == 'UCRV' || status == 'PAYP' || status == 'SENT' || status == 'ACAN'"];
        NSArray *otherArray = [self.orders filteredArrayUsingPredicate:otherPredicate];
        self.otherOrders = [[NSArray alloc] initWithArray:otherArray];
        
        NSLog(@"wdvArray count: %lu, otherArray count: %lu",(unsigned long)wdvArray.count,(unsigned long)otherArray.count);
        
         [self reloadOrderTable];
    }
}

- (void)setAttributedString {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Wall of Coins will verify your payment. This usually takes up to 10 minutes. To expedite your order, take a picture of your receipt and click here to email your receipt to Wall of Coins." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"support@wallofcoins.com"
                             range:[[attributedString string] rangeOfString:@"click here"]];
    
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                     NSUnderlineColorAttributeName: [UIColor blackColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    self.txtInstruction.linkTextAttributes = linkAttributes;
    self.txtInstruction.attributedText = attributedString;
    self.txtInstruction.delegate = self;
}

- (void)back:(id)sender {
    
    [self backToMainView];
}

- (NSString*)checkStatus:(NSString*)status {
    
    NSString *string = @"";
    
    if ([status isEqualToString:WD]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_WD];
    }
    else if ([status isEqualToString:WDV]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_WDV];
    }
    else if ([status isEqualToString:RERR]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_RERR];
    }
    else if ([status isEqualToString:DERR]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_DERR];
    }
    else if ([status isEqualToString:RMIT]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_RMIT];
    }
    else if ([status isEqualToString:UCRV]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_UCRV];
    }
    else if ([status isEqualToString:PAYP]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_PAYP];
    }
    else if ([status isEqualToString:SENT]) {
        string = [NSString stringWithFormat:@"Status: %@",STATUS_SENT];
    }
    
    return string;
}

- (void)displayAlert {
    
    [[WOCAlertController sharedInstance] alertshowWithTitle:@"" message:[NSString stringWithFormat:@"Thank you for making the payment!\nOnce we verify your payment, we will send the %@ to your wallet!",WOC_CURRENTCY] viewController:self];
}

// MARK: - IBAction

- (IBAction)buyMoreDashClicked:(id)sender {
    [self backToMainView];
}

- (IBAction)signOutClicked:(id)sender {
    [self signOutWOC];
}

- (IBAction)wallOfCoinsClicked:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"https://wallofcoins.com"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"URL opened...");
        }];
    }
}

// MARK: - API
- (void)getOrders {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                            };
    
    [[APIManager sharedInstance] getIncomingOrders:nil response:^(id responseDict, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [hud hideAnimated:YES];
        });
        
        if (error == nil) {
            if ([responseDict isKindOfClass:[NSArray class]]) {
                NSArray *response = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
                self.orders = response;
                
                NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
                NSArray *wdvArray = [self.orders filteredArrayUsingPredicate:wdvPredicate];
                self.wdOrders = [[NSArray alloc] initWithArray:wdvArray];
                
                NSPredicate *otherPredicate = [NSPredicate predicateWithFormat:@"status == 'WDV' || status == 'RERR' || status == 'DERR' || status == 'RSD' || status == 'RMIT' || status == 'UCRV' || status == 'PAYP' || status == 'SENT' || status == 'ACAN'"];
                NSArray *otherArray = [self.orders filteredArrayUsingPredicate:otherPredicate];
                self.otherOrders = [[NSArray alloc] initWithArray:otherArray];
                
                NSLog(@"wdvArray count: %lu, otherArray count: %lu",(unsigned long)wdvArray.count,(unsigned long)otherArray.count);
            }
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
        
        [self reloadOrderTable];

    }];
}

-(void)reloadOrderTable{
    if (self.orders.count > 0) {
        self.txtInstruction.text = @"Wall of Coins will verify your payment. This usually takes up to 10 minutes. To expedite your order, take a picture of your receipt and click here to email your receipt to Wall of Coins.";
    }
    else {
        self.txtInstruction.text = [NSString stringWithFormat:@"You have no order history with %@ for iOS. To see your full order history across all devices, visit %@",CRYPTO_CURRENTCY,BASE_URL_PRODUCTION];
    }
    self.lblInstruction.hidden  = TRUE;
    self.txtInstruction.hidden  = FALSE;
    [self.tableView reloadData];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.wdOrders.count;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2){
        return 1;
    }
    else {
        return self.otherOrders.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        WOCSignOutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"linkCell"];
        [cell.btnSignOut addTarget:self action:@selector(wallOfCoinsClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if (indexPath.section == 2) {
        WOCSignOutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"signOutCell"];
        cell.lblDescription.text = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",self.phoneNo];
        [cell.btnSignOut addTarget:self action:@selector(signOutClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else {
        
        static const NSInteger IMAGE_VIEW_TAG = 98;
        NSString *cellIdentifier = @"offerCell";
        
        WOCSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"summaryCell"];
        
        NSDictionary *orderDict = [[NSDictionary alloc] init];
        /*
         {
             bankAccount =
             {
                bankBusiness =
                    {
                        country = us;
                        icon = "https://woc-staging-static.s3.amazonaws.com/logos/icon_us_Genitrust2x.png";
                        id = 14;
                        logo = "https://woc-staging-static.s3.amazonaws.com/logos/logo_us_Genitrust2x.png";
                        name = Genitrust;
                        payFields = 0;
                        url = "http://genitrust.com/";
                    };
                id = 78;
                name = "Sujal Bandhara";
                number = ABC1234567890;
             };
             gross = "6.70454545";
             id = 397;
             payment = "2.95";
             paymentDue = "2018-03-26T12:55:33.093147+05:30";
             status = DERR;
         }
         */
        NSMutableDictionary *sellingOrderDict =  [NSMutableDictionary dictionaryWithCapacity:0];
        
        
        if (indexPath.section == 0) {
            orderDict = self.wdOrders[indexPath.row];
            if (orderDict[@"bankAccount"] != nil) {
                if (orderDict[@"bankAccount"][@"bankBusiness"] != nil) {
                    sellingOrderDict = orderDict[@"bankAccount"][@"bankBusiness"];
                }
            }

        }
        else {
            
            orderDict = self.otherOrders[indexPath.row];
            if (orderDict[@"bankAccount"] != nil) {
                if (orderDict[@"bankAccount"][@"bankBusiness"] != nil) {
                    sellingOrderDict = orderDict[@"bankAccount"][@"bankBusiness"];
                }
            }
        }
        
        if (![[sellingOrderDict valueForKey:@"number"] isEqual:[NSNull null]]) {
            if ([[sellingOrderDict valueForKey:@"number"] length] > 16) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"summaryCell1"];
                
                NSArray *accountArr = [NSJSONSerialization JSONObjectWithData:[[sellingOrderDict valueForKey:@"number"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displaySort" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
                    float aObj1 = [(NSString *)obj1 floatValue];
                    float aObj2 = [(NSString *)obj2 floatValue];
                    return aObj1 > aObj2;
                }];
                NSArray *accountArray = [accountArr sortedArrayUsingDescriptors:@[sort]];
                cell.lblPhone.hidden = YES;
                if (accountArray.count > 0) {
                    cell.lblFirstName.text = [NSString stringWithFormat:@"First Name: %@",setVal([[accountArray objectAtIndex:0] valueForKey:@"value"])];
                }
                if (accountArray.count > 2) {
                    cell.lblLastName.text = [NSString stringWithFormat:@"Last Name: %@",setVal([[accountArray objectAtIndex:2] valueForKey:@"value"])];
                }
                if (accountArray.count > 3) {
                    cell.lblBirthCountry.text = [NSString stringWithFormat:@"Country of Birth: %@",setVal([[accountArray objectAtIndex:3] valueForKey:@"value"])];
                }
                if (accountArray.count > 1) {
                    cell.lblPickupState.text = [NSString stringWithFormat:@"Pick-up State: %@",setVal([[accountArray objectAtIndex:1] valueForKey:@"value"])];
                }
            }
        }
        else {
             NSString *phoneNo = [NSString stringWithFormat:@"%@",setVal([[orderDict valueForKey:@"bankAccount"] valueForKey:@"number"])];
            cell.lblPhone.text = [NSString stringWithFormat:@"Acct: -%@",phoneNo];

        }
        NSString *bankLogo = setVal([sellingOrderDict valueForKey:@"logo"]);
        NSString *bankIcon = setVal([sellingOrderDict valueForKey:@"icon"]);
        NSString *bankName = setVal([sellingOrderDict valueForKey:@"name"]);
       
        float depositAmount = [[orderDict valueForKey:@"payment"] floatValue];
        NSString *totalDash = setVal([orderDict valueForKey:@"gross"]);
        NSString *status = [NSString stringWithFormat:@"%@",setVal([orderDict valueForKey:@"status"])];
        
        UIView *cellView = cell.imgView.superview;
        
        WOCAsyncImageView *imageView = (WOCAsyncImageView *)[cellView viewWithTag:IMAGE_VIEW_TAG];
        
        if (imageView == nil) {
            imageView = [[WOCAsyncImageView alloc] initWithFrame:cell.imgView.frame];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.image = [UIImage imageNamed:@"ic_account_balance_black"];
            imageView.tag = IMAGE_VIEW_TAG;
            [cellView addSubview:imageView];
        }
        
        cell.imgView.hidden = TRUE;
        imageView.hidden = FALSE;
        
        //get image view
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView];
        //bankLogo
        if ([bankLogo length] > 0) {
            
            imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",bankLogo]];
        }
        else if ([bankIcon length] > 0) {
            
            imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",bankIcon]];
            //cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
        }
        
        cell.lblName.text = bankName;
        if ([[[orderDict valueForKey:@"nearestBranch"] valueForKey:@"phone"] isEqual:[NSNull null]]) {
            [cell.lblPhone setHidden:YES];
        }
        cell.lblCashDeposit.text = [NSString stringWithFormat:@"Verified Deposits: $%.02f",depositAmount];
        
        NSNumber *num = [NSNumber numberWithDouble:([totalDash doubleValue] * 1000000)];
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        [numFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //[numFormatter setAllowsFloats:YES];
        [numFormatter setAlwaysShowsDecimalSeparator:YES];
        //[numFormatter setDecimalSeparator:@"."];
        [numFormatter setUsesGroupingSeparator:YES];
        [numFormatter setGroupingSeparator:@","];
        [numFormatter setGroupingSize:3];
        NSString *stringNum = [numFormatter stringFromNumber:num];
        cell.lblTotalDash.text = [NSString stringWithFormat:@"Available %@: %@ (%@ %@)",WOC_CURRENTCY_SPECIAL,totalDash,stringNum,WOC_CURRENTCY_SYMBOL_MINOR];
        cell.lblStatus.text = [self checkStatus:status];
        
        return cell;
    }
}

// MARK: - UITableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 3) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        headerView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, headerView.frame.size.width - 30, headerView.frame.size.height - 15)];
        lblTitle.text = @"Incoming Order History";
        lblTitle.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.backgroundColor = [UIColor whiteColor];
        lblTitle.layer.cornerRadius = 10.0;
        lblTitle.layer.masksToBounds = YES;
        
        [self setShadow:lblTitle];
        [headerView addSubview:lblTitle];
        return headerView;
    }
    return  nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 3) {
        if (self.otherOrders.count > 0) {
            return 50;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 || indexPath.section == 2) {
        return 110.0;
    }
    else {
        NSDictionary *orderDict = [[NSDictionary alloc] init];
        if (indexPath.section == 0) {
            orderDict = self.wdOrders[indexPath.row];
            if (![[orderDict valueForKey:@"account"] isEqual:[NSNull null]]) {
                if ([[orderDict valueForKey:@"account"] length] > 16) {
                    return 250.0;
                }
            }
        }
        else {
            orderDict = self.otherOrders[indexPath.row];
        }
        return 185.0;
    }
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
  
    if ([[URL absoluteString] hasPrefix:@"support"]) {
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            mailController.mailComposeDelegate = self;
            
            NSDictionary *orderDict = [self.orders objectAtIndex:0];
            [mailController setSubject:[NSString stringWithFormat:@"Order #{%@} - {%@}",[orderDict valueForKey:@"id"],self.phoneNo]];
            [mailController setToRecipients:[NSArray arrayWithObject:@"support@wallofcoins.com"]];
            [mailController setMessageBody:@"" isHTML:NO];
            [self presentViewController:mailController animated:YES completion:nil];
        }
        return NO;
    }
    return YES;
}

#pragma mark - MFMailComposer Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

