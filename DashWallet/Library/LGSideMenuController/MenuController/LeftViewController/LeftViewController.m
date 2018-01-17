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
    else{
        
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
        WOCSendDashViewController *sendDash = [storyBoard instantiateViewControllerWithIdentifier:@"WOCSendDashViewController"];
        
        UIViewController *viewController = [UIViewController new];
        viewController.view.backgroundColor = [UIColor whiteColor];
        viewController.title = self.section1[indexPath.row];
        
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

@end
