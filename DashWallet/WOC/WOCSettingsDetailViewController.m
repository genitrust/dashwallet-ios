//
//  WOCSettingsDetailViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSettingsDetailViewController.h"
#import "WOCAboutCell.h"
#import "WOCReportIssueViewController.h"
#import "WOCBlockChainViewController.h"
#import "WOCShowXPubViewController.h"
#import "WOCDenominationViewController.h"
#import "WOCOwnNameViewController.h"
#import "WOCTrustedPeerViewController.h"
#import "WOCBlockExplorerViewController.h"

@interface WOCSettingsDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *aboutTitles;
@property (strong, nonatomic) NSArray *aboutSubtitles;

@property (strong, nonatomic) NSArray *diagnosticsTitles;
@property (strong, nonatomic) NSArray *diagnosticsSubtitles;

@property (strong, nonatomic) NSArray *settingsDetailTitles1;
@property (strong, nonatomic) NSArray *settingsDetailSubtitles1;

@property (strong, nonatomic) NSArray *settingsDetailTitles2;
@property (strong, nonatomic) NSArray *settingsDetailSubtitles2;

@end

@implementation WOCSettingsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.estimatedRowHeight = 70.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"checkCell"];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"alertCell"];
    
    if (self.index == 0) {
        [self.backBtn setTitle:@"Settings" forState:UIControlStateNormal];
    }
    else if (self.index == 1) {
        [self.backBtn setTitle:@"Diagnostics" forState:UIControlStateNormal];
    }
    else {
        [self.backBtn setTitle:@"About" forState:UIControlStateNormal];
    }
    
    self.aboutTitles = @[@"Version",
                      @"Copyright",
                      @"License",
                      @"Source code",
                      @"Google Play page",
                      @"Google+ community",
                      @"This app is using dashj 0.14.3-12.1",
                      @"This app is using 'xzing'"
                      ];
    
    self.aboutSubtitles = @[@"4.65.12.1U",
                            @"© 2011-2017, the Bitcoin Wallet developers\n© 2014-2017, the Dash Wallet developers",
                            @"https://www.gnu.org/licenses.gpl-3.0.txt",
                            @"https://github.com/HashEngineering/dash-wallet",
                            @"Review or rate the app",
                            @"Discussions about the app",
                            @"https://github/HashEngineering/darkcoinj",
                            @"https://github.com/zxing/zxing"
                            ];
    
    self.diagnosticsTitles = @[@"Report issue",
                               @"Reset block chain",
                               @"Show xpub"
                               ];
    
    self.diagnosticsSubtitles = @[@"Collect information about your issue and email your report to the developers.",
                                  @"Reset block chain, transactions and wallet balance. Replay will take a while.",
                                  @"View the extended public key of your wallet, so it can be imported into other apps and services. Be careful: doing so will disclose your monetary privacy to that app."
                                  ];
    
    self.settingsDetailTitles1 = @[@"Denomination and Precision",
                                  @"Own name",
                                  @"Auto-close send coins dialog",
                                  @"Connectivity indicator",
                                  @"Trusted peer",
                                  @"Skip regular peer discovery",
                                  @"Block explorer",
                                  @"Data usage",
                                  @"Balance reminder"
                                  ];
    
    self.settingsDetailSubtitles1 = @[@"Unit to show amounts in. This does not effect computations.",
                                     @"Name of yourself, to be added to payment requests. Try to keep it short.",
                                     @"When the payment is made, the send dialog will close automatically.",
                                     @"Show current nuber of connected peers in the notification area.",
                                     @"IP or hostname of single peer to connect to",
                                     @"Prevents connecting to any peers besides the trusted peer.",
                                     @"External block explorer to use for browsing transactions, addresses and blocks.",
                                     @"Show optons to restrict data usage on mobile networks.",
                                     @"After a couple of weeks of not being used, the app will notify if there are still coins in the wallet."
                                     ];
    
    self.settingsDetailTitles2 = @[@"Warning",
                                   @"Enable InstantSend",
                                   @"Show disclaimer",
                                   @"BIP70 for scan-to-pay",
                                   @"Look up wallet names"
                                   ];
    
    self.settingsDetailSubtitles2 = @[@"This is all unfinished stuff. Use at your own risk!",
                                      @"Allow Instant send to be used to send and receive coins.",
                                      @"Have you really read the safety nots? Did you already back up your wallet to a safe place?",
                                      @"Use payment protocol for QR-code initiated payments",
                                      @"When sending coins, use DNSSEC to look up wallet names from the domain name system.",
                                      ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)backBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    if (self.index == 0) {
        return 2;
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.index == 0) {
        if (section == 0) {
            return self.settingsDetailTitles1.count;
        }
        else{
            return self.settingsDetailTitles2.count;
        }
    }
    else if (self.index == 1){
        return self.diagnosticsTitles.count;
    }
    else{
        return self.aboutTitles.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if (section == 1) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, self.view.frame.size.width, 25)];
        label.text = @"Labs";
        label.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
        label.textColor = [UIColor darkGrayColor];
        
        [headerView addSubview:label];
        
        return headerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == 1) {
        return 50;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WOCAboutCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"aboutCell"];
    
    if (self.index == 0) {
        if (indexPath.section == 0) {
            cell.lblTitle.text = self.settingsDetailTitles1[indexPath.row];
            cell.lblSubtitle.text = self.settingsDetailSubtitles1[indexPath.row];
        }
        else{
            cell.lblTitle.text = self.settingsDetailTitles2[indexPath.row];
            cell.lblSubtitle.text = self.settingsDetailSubtitles2[indexPath.row];
        }
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 8) {
                cell.checkTrailingConstant.constant = 15;
                cell.checkWidthConstant.constant = 20;
            }
            else{
                cell.checkTrailingConstant.constant = 0;
                cell.checkWidthConstant.constant = 0;
            }
            
            cell.alertLeadingConstant.constant = 0;
            cell.alertWidthConstant.constant = 0;
        }
        else if (indexPath.section == 1){
            if (indexPath.row == 0) {
                cell.alertLeadingConstant.constant = 15;
                cell.alertWidthConstant.constant = 20;
                cell.checkTrailingConstant.constant = 0;
                cell.checkWidthConstant.constant = 0;
            }
            else{
                cell.checkTrailingConstant.constant = 15;
                cell.checkWidthConstant.constant = 20;
                cell.alertLeadingConstant.constant = 0;
                cell.alertWidthConstant.constant = 0;
            }
        }
    }
    else if (self.index == 1){
        cell.lblTitle.text = self.diagnosticsTitles[indexPath.row];
        cell.lblSubtitle.text = self.diagnosticsSubtitles[indexPath.row];
    }
    else{
        cell.lblTitle.text = self.aboutTitles[indexPath.row];
        cell.lblSubtitle.text = self.aboutSubtitles[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (self.index == 0) {
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                
                WOCDenominationViewController *denomination = [storyboard instantiateViewControllerWithIdentifier:@"WOCDenominationViewController"];
                denomination.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                [self presentViewController:denomination animated:YES completion:nil];
            }
            else if (indexPath.row == 1) {
                
                WOCOwnNameViewController *ownName = [storyboard instantiateViewControllerWithIdentifier:@"WOCOwnNameViewController"];
                ownName.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                [self presentViewController:ownName animated:YES completion:nil];
            }
            else if (indexPath.row == 4) {
                
                WOCTrustedPeerViewController *trustedPeer = [storyboard instantiateViewControllerWithIdentifier:@"WOCTrustedPeerViewController"];
                trustedPeer.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                [self presentViewController:trustedPeer animated:YES completion:nil];
            }
            else if (indexPath.row == 6) {
                
                WOCBlockExplorerViewController *blockExplorer = [storyboard instantiateViewControllerWithIdentifier:@"WOCBlockExplorerViewController"];
                blockExplorer.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                [self presentViewController:blockExplorer animated:YES completion:nil];
            }
        }
    }
    else if (self.index == 1){
        
        if (indexPath.row == 0) {
            
            WOCReportIssueViewController *reportIssue = [storyboard instantiateViewControllerWithIdentifier:@"WOCReportIssueViewController"];
            reportIssue.modalTransitionStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:reportIssue animated:YES completion:nil];
        }
        else if (indexPath.row == 1){
            
            WOCBlockChainViewController *blockChain = [storyboard instantiateViewControllerWithIdentifier:@"WOCBlockChainViewController"];
            blockChain.modalTransitionStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:blockChain animated:YES completion:nil];
        }
        else{
            
            WOCShowXPubViewController *showXPub = [storyboard instantiateViewControllerWithIdentifier:@"WOCShowXPubViewController"];
            showXPub.modalTransitionStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:showXPub animated:YES completion:nil];
        }
    }
    else{
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
