//
//  LeftViewController.m
//  LGSideMenuControllerDemo
//

#import "LeftViewController.h"
#import "LeftViewCell.h"
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"
#import "WOCBuyDashViewController.h"
#import "WOCSendDashViewController.h"
#import "WOCAddressBookViewController.h"
#import "WOCBackupWalletViewController.h"
#import "WOCRestoreWalletViewController.h"
#import "WOCSpendingPINViewController.h"
#import "WOCSettingsViewController.h"
#import "WOCExchangeRatesViewController.h"

@interface LeftViewController ()

@property (strong, nonatomic) NSArray *section1;
@property (strong, nonatomic) NSArray *section2;
@property (strong, nonatomic) NSArray *imgSection1;
@property (strong, nonatomic) NSArray *imgSection2;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // -----
    self.section1 = @[@"Home",
                      @"Disconnect",
                      @"Address book",
                      @"Exchange rates",
                      @"Sweep paper wallet",
                      @"Buy Dash With Cash"];
    
     self.section2 = @[@"Network monitor",
                       @"Safety",
                       @"Settings"];
    
    self.imgSection1 = @[@"Home_temp",
                      @"Disconnect_temp",
                      @"Address_Book_temp",
                      @"Exchange_Rates_temp",
                      @"Sweep_Paper_Wallet_temp",
                      @"Sweep_Paper_Wallet_temp"];
    
    self.imgSection2 = @[@"Network_Monitor",
                         @"Safety_temp",
                         @"Safety_temp"];
    
    // -----
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0){
        return self.section1.count;
    }
    else{
        return self.section2.count;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
        imgView.image = [UIImage imageNamed:@"drawer_header"];
        
        UIImageView *barcodeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90 - 15, 10, 90, 90)];
        barcodeView.image = [UIImage imageNamed:@"barcode_icon"];
        
        [headerView addSubview:imgView];
        [headerView addSubview:barcodeView];
        
        return headerView;
    }
    else
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        headerView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
        
        UIView *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width, 25)];
        label.text = @"Configuration";
        label.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
        label.textColor = [UIColor lightGrayColor];
        
        [headerView addSubview:label];
        [headerView addSubview:line];
        
        return headerView;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == 0) {
        return 160;
    }
    else{
        return 50;
    }
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (indexPath.section == 0) {
        
        cell.titleLabel.text = self.section1[indexPath.row];
        cell.menuImg.image = [UIImage imageNamed:self.imgSection1[indexPath.row]];
    }
    else{
        cell.titleLabel.text = self.section2[indexPath.row];
        cell.menuImg.image = [UIImage imageNamed:self.imgSection2[indexPath.row]];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            if (mainViewController.isLeftViewAlwaysVisibleForCurrentOrientation) {
                [mainViewController showRightViewAnimated:YES completionHandler:nil];
            }
            else {
                [mainViewController hideLeftViewAnimated:YES completionHandler:^(void) {
                    [mainViewController showRightViewAnimated:YES completionHandler:nil];
                }];
            }
        }
        else if (indexPath.row == 2) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            WOCAddressBookViewController *addressBook = [storyBoard instantiateViewControllerWithIdentifier:@"WOCAddressBookViewController"];
            
            UIViewController *viewController = [UIViewController new];
            viewController.view.backgroundColor = [UIColor whiteColor];
            viewController.title = self.section1[indexPath.row];
            
            UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
            [navigationController pushViewController:addressBook animated:YES];
            
            // Rarely you can get some visual bugs when you change view hierarchy and toggle side views in the same iteration
            // You can use delay to avoid this and probably other unexpected visual bugs
            [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
        }
        else if (indexPath.row == 3) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            WOCExchangeRatesViewController *sendDash = [storyBoard instantiateViewControllerWithIdentifier:@"WOCExchangeRatesViewController"];
            
            UIViewController *viewController = [UIViewController new];
            viewController.view.backgroundColor = [UIColor whiteColor];
            
            UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
            [navigationController pushViewController:sendDash animated:YES];
            
            // Rarely you can get some visual bugs when you change view hierarchy and toggle side views in the same iteration
            // You can use delay to avoid this and probably other unexpected visual bugs
            [mainViewController hideLeftViewAnimated:YES delay:0.0 completionHandler:nil];
        }
        else
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            WOCBuyDashViewController *buyDash = [storyBoard instantiateViewControllerWithIdentifier:@"WOCBuyDashViewController"];
            
            UIViewController *viewController = [UIViewController new];
            viewController.view.backgroundColor = [UIColor whiteColor];
            viewController.title = self.section1[indexPath.row];
            
            UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
            [navigationController pushViewController:buyDash animated:YES];
            
            [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        }
    }
    else{
        
        if (indexPath.row == 1){
            
            /*UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            WOCSafetyPopupViewController *popup = [storyBoard instantiateViewControllerWithIdentifier:@"WOCSafetyPopupViewController"];
            popup.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            [self.navigationController presentViewController:popup animated:YES completion:nil];
            
            [mainViewController hideLeftViewAnimated:YES completionHandler:nil];*/
            
            [self openActionSheet];
        }
        else if (indexPath.row == 2){
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            WOCSettingsViewController *settings = [storyBoard instantiateViewControllerWithIdentifier:@"WOCSettingsViewController"];
            
            UIViewController *viewController = [UIViewController new];
            viewController.view.backgroundColor = [UIColor whiteColor];
            
            UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
            [navigationController pushViewController:settings animated:YES];
            
            [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        }
    }
}

#pragma mark - Safety Popups
- (void)openActionSheet {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *safetyNotesAction = [UIAlertAction actionWithTitle:@"Safety notes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self viewSafetyNotesPopup];
    }];
    
    UIAlertAction *backupWalletAction = [UIAlertAction actionWithTitle:@"Backup wallet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self viewBackupWallet];
    }];
    
    UIAlertAction *restoreWalletAction = [UIAlertAction actionWithTitle:@"Restore wallet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self viewRestoreWallet];
    }];
    
    UIAlertAction *setSpendingAction = [UIAlertAction actionWithTitle:@"Set spending PIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self viewSpendingPIN];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [actionSheet addAction:safetyNotesAction];
    [actionSheet addAction:backupWalletAction];
    [actionSheet addAction:restoreWalletAction];
    [actionSheet addAction:setSpendingAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
}

- (void)viewSafetyNotesPopup{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Important safety notes:\n" message:@"Dash are stored on the device. If you lose it, you'll lose your Dash.\n\nThis means you need to back up your wallet! Use the in-app backup facility for this, rather than a third party backup app. Keep your backup safe and remember the password. This is an HD wallet. Only one backup is required.\n\nBefore uninstalling  (or clearing app data/wiping your device), transfer your Dash to another wallet. Remaining Dash will be lost.\n\nPayments are irreversible. If you send your Dash into the void, there is almost no way to get them back.\n\nKeep your mobile device safe! Do not root your device. Do only install apps you fully trust. Malicious app could be trying to steal your wallet.\n\nKepp the risk low! Only use with small amounts for day use." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"DISMISS" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:dismissAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewBackupWallet{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WOCBackupWalletViewController *wallet = [storyboard instantiateViewControllerWithIdentifier:@"WOCBackupWalletViewController"];
    wallet.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:wallet animated:YES completion:nil];
}

- (void)viewRestoreWallet{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WOCRestoreWalletViewController *wallet = [storyboard instantiateViewControllerWithIdentifier:@"WOCRestoreWalletViewController"];
    wallet.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:wallet animated:YES completion:nil];
}

- (void)viewSpendingPIN{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WOCSpendingPINViewController *wallet = [storyboard instantiateViewControllerWithIdentifier:@"WOCSpendingPINViewController"];
    wallet.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:wallet animated:YES completion:nil];
}

@end
