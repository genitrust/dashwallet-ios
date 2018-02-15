//
//  WOCBuyingSummaryViewController.m
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

#import "WOCBuyingSummaryViewController.h"
#import "WOCSummaryCell.h"
#import "WOCSignOutCell.h"
#import "WOCBuyDashStep1ViewController.h"
#import "WOCBuyDashStep4ViewController.h"
#import "APIManager.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "WOCAlertController.h"

@interface WOCBuyingSummaryViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *wdOrders;
@property (strong, nonatomic) NSArray *otherOrders;

@end

@implementation WOCBuyingSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnBuyMoreDash];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    if (self.orders.count == 0) {
        [self getOrders];
    }
    else{
        NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
        NSArray *wdvArray = [self.orders filteredArrayUsingPredicate:wdvPredicate];
        self.wdOrders = [[NSArray alloc] initWithArray:wdvArray];
        
        NSPredicate *otherPredicate = [NSPredicate predicateWithFormat:@"status == 'WDV' || status == 'RERR' || status == 'DERR' || status == 'RSD' || status == 'RMIT' || status == 'UCRV' || status == 'PAYP' || status == 'SENT' || status == 'ACAN'"];
        NSArray *otherArray = [self.orders filteredArrayUsingPredicate:otherPredicate];
        self.otherOrders = [[NSArray alloc] initWithArray:otherArray];
        
        NSLog(@"wdvArray count: %lu, otherArray count: %lu",(unsigned long)wdvArray.count,(unsigned long)otherArray.count);
        
        [self.tableView reloadData];
    }
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setShadow:(UIView *)view{
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

- (void)pushToHome{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BRRootViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIPageControl.appearance.pageIndicatorTintColor = [UIColor lightGrayColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor blueColor];
    
    BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = nav;
}

- (void)back:(id)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BRRootViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIPageControl.appearance.pageIndicatorTintColor = [UIColor lightGrayColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor blueColor];
    
    BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = nav;
}

- (void)pushToStep1{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep1ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];
        vc.isFromSend = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = navigationController;
    });
    return;
    
    BOOL viewFound = NO;
    
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[WOCBuyDashStep1ViewController class]])
        {
            [self.navigationController popToViewController:controller animated:NO];
            viewFound = YES;
            break;
        }
    }
    
    if (viewFound == NO) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep1ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];
            myViewController.isFromSend = YES;
            [self.navigationController pushViewController:myViewController animated:YES];
        });
    }
}

- (NSString*)checkStatus:(NSString*)status {
    
    NSString *string = @"";
    
    if ([status isEqualToString:WD]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_WD];
    }
    else if ([status isEqualToString:WDV]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_WDV];
    }
    else if ([status isEqualToString:RERR]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_RERR];
    }
    else if ([status isEqualToString:DERR]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_DERR];
    }
    else if ([status isEqualToString:RMIT]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_RMIT];
    }
    else if ([status isEqualToString:UCRV]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_UCRV];
    }
    else if ([status isEqualToString:PAYP]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_PAYP];
    }
    else if ([status isEqualToString:SENT]){
        string = [NSString stringWithFormat:@"Status: %@",STATUS_SENT];
    }
    
    return string;
}

// MARK: - IBAction

- (IBAction)buyMoreDashClicked:(id)sender {
    
    [self pushToStep1];
}

- (IBAction)signOutClicked:(id)sender {
    
    NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    
    [self signOut:phoneNo];
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
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] getOrders:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSArray *response = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            self.orders = response;
            
            NSPredicate *wdvPredicate = [NSPredicate predicateWithFormat:@"status == 'WD'"];
            NSArray *wdvArray = [self.orders filteredArrayUsingPredicate:wdvPredicate];
            self.wdOrders = [[NSArray alloc] initWithArray:wdvArray];
            
            NSPredicate *otherPredicate = [NSPredicate predicateWithFormat:@"status == 'WDV' || status == 'RERR' || status == 'DERR' || status == 'RSD' || status == 'RMIT' || status == 'UCRV' || status == 'PAYP' || status == 'SENT' || status == 'ACAN'"];
            NSArray *otherArray = [self.orders filteredArrayUsingPredicate:otherPredicate];
            self.otherOrders = [[NSArray alloc] initWithArray:otherArray];
            
            NSLog(@"wdvArray count: %lu, otherArray count: %lu",(unsigned long)wdvArray.count,(unsigned long)otherArray.count);
            
            [self.tableView reloadData];
        }
        else
        {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)signOut:(NSString*)phone {
    
    NSDictionary *params = @{
                             API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] signOut:params phone:phone response:^(id responseDict, NSError *error) {
        
        if (error == nil)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self pushToStep1];
        }
        else
        {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
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
    else{
        
        WOCSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"summaryCell"];
        
        NSDictionary *orderDict = [[NSDictionary alloc] init];
        
        if (indexPath.section == 0) {
            orderDict = self.wdOrders[indexPath.row];
        }
        else{
            orderDict = self.otherOrders[indexPath.row];
        }
        
        if (![[orderDict valueForKey:@"account"] isEqual:[NSNull null]]) {
            
            if ([[orderDict valueForKey:@"account"] length] > 16) {
                
                cell = [tableView dequeueReusableCellWithIdentifier:@"summaryCell1"];
                
                NSArray *accountArray = [NSJSONSerialization JSONObjectWithData:[[orderDict valueForKey:@"account"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                cell.lblPhone.hidden = YES;
                
                cell.lblFirstName.text = [NSString stringWithFormat:@"First Name: %@",[[accountArray objectAtIndex:0] valueForKey:@"value"]];
                cell.lblLastName.text = [NSString stringWithFormat:@"Last Name: %@",[[accountArray objectAtIndex:1] valueForKey:@"value"]];
                cell.lblBirthCountry.text = [NSString stringWithFormat:@"Country of Birth: %@",[[accountArray objectAtIndex:2] valueForKey:@"value"]];
                cell.lblPickupState.text = [NSString stringWithFormat:@"Pick-up State: %@",[[accountArray objectAtIndex:3] valueForKey:@"value"]];
            }
        }
        
        NSString *bankLogo = [orderDict valueForKey:@"bankLogo"];
        NSString *bankIcon = [orderDict valueForKey:@"bankIcon"];
        NSString *bankName = [orderDict valueForKey:@"bankName"];
        NSString *phoneNo = [NSString stringWithFormat:@"%@",[[orderDict valueForKey:@"nearestBranch"] valueForKey:@"phone"]];
        float depositAmount = [[orderDict valueForKey:@"payment"] floatValue];
        NSString *totalDash = [orderDict valueForKey:@"total"];
        NSString *status = [NSString stringWithFormat:@"%@",[orderDict valueForKey:@"status"]];
        
        //bankLogo
        if (![[orderDict valueForKey:@"bankLogo"] isEqual:[NSNull null]] && [bankLogo length] > 0) {
            
            if ([bankLogo hasPrefix:@"https://"]) {
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",bankLogo]]];
                cell.imgView.image = [UIImage imageWithData: imageData];
            }
            else{
                cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
            }
        }
        else if (![[orderDict valueForKey:@"bankIcon"] isEqual:[NSNull null]] && [bankIcon length] > 0) {
            
            if ([bankLogo hasPrefix:@"https://"]) {
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",bankIcon]]];
                cell.imgView.image = [UIImage imageWithData: imageData];
            }
            else{
                cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
            }
        }
        else {
            cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
        }
        
        cell.lblName.text = bankName;
        cell.lblPhone.text = [NSString stringWithFormat:@"Location's phone #: %@",phoneNo];
        cell.lblCashDeposit.text = [NSString stringWithFormat:@"Cash to Deposit: $%.02f",depositAmount];
        
        NSNumber *num = [NSNumber numberWithDouble:([totalDash doubleValue] * 1000000)];
        
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        [numFormatter setUsesGroupingSeparator:YES];
        [numFormatter setGroupingSeparator:@","];
        [numFormatter setGroupingSize:3];
        
        NSString *stringNum = [numFormatter stringFromNumber:num];
        
        cell.lblTotalDash.text = [NSString stringWithFormat:@"Total Dash: %@ (%@ dots)",totalDash,stringNum];
        cell.lblStatus.text = [self checkStatus:status];
        
        return cell;
    }
}

// MARK: - UITableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 3) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        headerView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, headerView.frame.size.width - 30, headerView.frame.size.height - 15)];
        lblTitle.text = @"Order History";
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
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
    else{
        NSDictionary *orderDict = [[NSDictionary alloc] init];
        
        if (indexPath.section == 0) {
            orderDict = self.wdOrders[indexPath.row];
        }
        else{
            orderDict = self.otherOrders[indexPath.row];
        }
        
        if (![[orderDict valueForKey:@"account"] isEqual:[NSNull null]]) {
            if ([[orderDict valueForKey:@"account"] length] > 16) {
                return 250.0;
            }
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

