//
//  WOCBuyingSummaryViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyingSummaryViewController.h"
#import "WOCSummaryCell.h"
#import "WOCSignOutCell.h"
#import "WOCBuyDashStep1ViewController.h"
#import "APIManager.h"

@interface WOCBuyingSummaryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *orders;

@end

@implementation WOCBuyingSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setShadow:self.btnBuyMoreDash];
    [self getOrders];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)buyMoreDashClicked:(id)sender {
    
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[WOCBuyDashStep1ViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            
            break;
        }
    }
}

- (IBAction)signOutClicked:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self pushToHome];
}

#pragma mark - Function
- (void)setShadow:(UIView *)view{
    
    //if widthOffset = 1 and heightOffset = 1 then shadow will set to two sides
    //if widthOffset = 0 and heightOffset = 0 then shadow will set to four sides
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);//CGSize(width: widthOffset, height: heightOffset)//0,1
    view.layer.shadowRadius = 1; //1
    view.layer.shadowOpacity = 1;//1
    view.layer.masksToBounds = false;
}

- (void)pushToHome{
    
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[WOCBuyDashStep1ViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            
            break;
        }
    }
}

#pragma mark - API
- (void)getOrders {
    
    [[APIManager sharedInstance] getOrders:^(id responseDict, NSError *error) {
    
        if (error == nil) {
            
            NSArray *response = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            self.orders = response;
            [self.tableView reloadData];
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return self.orders.count;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        WOCSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"summaryCell"];
        
        NSDictionary *orderDict = self.orders[indexPath.row];
        
        NSString *bankLogo = [orderDict valueForKey:@"bankLogo"];
        NSString *bankName = [orderDict valueForKey:@"bankName"];
        NSString *phoneNo = [NSString stringWithFormat:@"%@",[[orderDict valueForKey:@"nearestBranch"] valueForKey:@"phone"]];
        float depositAmount = [[orderDict valueForKey:@"payment"] floatValue];
        NSString *totalDash = [orderDict valueForKey:@"total"];
        
        //bankLogo
        /*if ([bankLogo length] > 0) {
         
         NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bankLogo,bankLogo]]];
         self.imgView.image = [UIImage imageWithData: imageData];
         }*/
        
        cell.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
        cell.lblName.text = bankName;
        cell.lblPhone.text = [NSString stringWithFormat:@"Location's phone #: %@",phoneNo];
        cell.lblCashDeposit.text = [NSString stringWithFormat:@"Cash to Deposit: $%.02f",depositAmount];
        cell.lblTotalDash.text = [NSString stringWithFormat:@"Total Dash: %@",totalDash];
        
        return cell;
    }
    else{
        
        WOCSignOutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"signOutCell"];
        
        cell.lblDescription.text = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",self.phoneNo];
        [cell.btnSignOut addTarget:self action:@selector(signOutClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return 185.0;
    }
    else{
        
        return 110.0;
    }
}
@end
