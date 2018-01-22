//
//  WOCAddressBookViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCOpeningScreenViewController.h"
#import "WOCCollapsedCell.h"
#import "WOCExpandedCell.h"
#import "WOCBuyDashViewController.h"
#import "WOCSendDashViewController.h"
#import "WOCSafetyNotesViewController.h"

@interface WOCOpeningScreenViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation WOCOpeningScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setHidden:YES];
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.btnSafetyNotes.titleLabel.text];
    // making text property to underline text-
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(31, 12)];
    // using text on button
    [self.btnSafetyNotes setAttributedTitle:titleString forState:UIControlStateNormal];
    
    UIFont *font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
    
    NSMutableAttributedString *titleString1 = [[NSMutableAttributedString alloc] initWithString:self.btnBackupWallet.titleLabel.text];
    [titleString1 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(12, 19)];
    [titleString1 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [titleString1 length] - 1)];
    [self.btnBackupWallet setAttributedTitle:titleString1 forState:UIControlStateNormal];
    
    NSMutableAttributedString *titleString2 = [[NSMutableAttributedString alloc] initWithString:self.btnloadWallet.titleLabel.text];
    [titleString2 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(26, 25)];
    [titleString2 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [titleString2 length] - 1)];
    [self.btnloadWallet setAttributedTitle:titleString2 forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)backBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)requestCoinClicked:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WOCBuyDashViewController *buyDash = [storyBoard instantiateViewControllerWithIdentifier:@"WOCBuyDashViewController"];
    [self.navigationController pushViewController:buyDash animated:YES];
}

- (IBAction)sendCoinClicked:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WOCSendDashViewController *buyDash = [storyBoard instantiateViewControllerWithIdentifier:@"WOCSendDashViewController"];
    [self.navigationController pushViewController:buyDash animated:YES];
}

- (IBAction)safetyNotesClicked:(id)sender {
    
    [self viewSafetyNotesPopup];
}

- (void)viewSafetyNotesPopup{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Important safety notes:\n" message:@"Dash are stored on the device. If you lose it, you'll lose your Dash.\n\nThis means you need to back up your wallet! Use the in-app backup facility for this, rather than a third party backup app. Keep your backup safe and remember the password. This is an HD wallet. Only one backup is required.\n\nBefore uninstalling  (or clearing app data/wiping your device), transfer your Dash to another wallet. Remaining Dash will be lost.\n\nPayments are irreversible. If you send your Dash into the void, there is almost no way to get them back.\n\nKeep your mobile device safe! Do not root your device. Don only install apps you fully trust. Malicious app could be trying to steal your wallet.\n\nKepp the risk low! Only use with small amounts for day use." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"DISMISS" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:dismissAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath != self.selectedIndexPath) {
        
        WOCCollapsedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collapsedCell"];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
        UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
        UIColor *color = [UIColor colorWithRed:92.0/255.0 green:184.0/255.0 blue:92.0/255.0 alpha:1.0];
        UIColor *color1 = [UIColor colorWithRed:152.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];
        
        NSDictionary *attrsDictionary = @{
                                          NSFontAttributeName : font,
                                          NSForegroundColorAttributeName : color
                                          };
        
        NSDictionary *attrsDictionary1 = @{
                                           NSFontAttributeName : font1,
                                           NSForegroundColorAttributeName : color
                                           };
        
        NSDictionary *attrsDictionary2 = @{
                                          NSFontAttributeName : font,
                                          NSForegroundColorAttributeName : color1
                                          };
        
        NSDictionary *attrsDictionary3 = @{
                                           NSFontAttributeName : font1,
                                           NSForegroundColorAttributeName : color1
                                           };
        
        if (indexPath.row % 2) {
            cell.imgCircle.image = [UIImage imageNamed:@"green_opening_icon"];
            
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"+ 0.22" attributes:attrsDictionary];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"99" attributes:attrsDictionary1];
            [mutableString appendAttributedString:attrString];
            
            cell.lblPoints.attributedText = mutableString;
        }
        else{
            cell.imgCircle.image = [UIImage imageNamed:@"red_opening_icon"];
            
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"- 0.22" attributes:attrsDictionary2];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"99" attributes:attrsDictionary3];
            [mutableString appendAttributedString:attrString];
            
            cell.lblPoints.attributedText = mutableString;
        }
        
        return cell;
    }
    else{
        
        WOCExpandedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expandedCell"];
        cell.imgCircle.image = [UIImage imageNamed:@"red_opening_icon"];
        
        
        
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedIndexPath = indexPath;
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath == self.selectedIndexPath) {
        return 105.0;
    }
    return 45.0;
}

@end

