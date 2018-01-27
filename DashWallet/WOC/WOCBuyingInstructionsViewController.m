//
//  WOCBuyingInstructionsViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyingInstructionsViewController.h"
#import "WOCBuyingSummaryViewController.h"
#import "WOCBuyDashStep1ViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCBuyingSummaryViewController.h"

@interface WOCBuyingInstructionsViewController ()

@property (strong, nonatomic) NSString *orderId;

@end

@implementation WOCBuyingInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnDepositFinished];
    [self setShadow:self.btnCancelOrder];
    [self captureHold];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)showMapClicked:(id)sender {
}
- (IBAction)depositFinishedClicked:(id)sender {
    
    [self showDepositAlert];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyingSummaryViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingSummaryViewController"];
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (IBAction)cancelOrderClicked:(id)sender {
    
    [self showCancelOrderAlert];
    
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

- (void)showDepositAlert
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:@"Are you sure you finished making the payment?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self confirmDeposit];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCancelOrderAlert{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:@"Are you sure you want to cancel order?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self cancelOrder];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateData:(NSDictionary*)dictionary{
    
    NSString *bankLogo = [dictionary valueForKey:@"bankLogo"];
    NSString *bankName = [dictionary valueForKey:@"bankName"];
    NSString *phoneNo = [NSString stringWithFormat:@"%@",[[dictionary valueForKey:@"nearestBranch"] valueForKey:@"phone"]];
    NSString *accountName = [dictionary valueForKey:@"nameOnAccount"];
    NSString *accountNo = [dictionary valueForKey:@"account"];
    float depositAmount = [[dictionary valueForKey:@"payment"] floatValue];
    NSString *depositDue = [dictionary valueForKey:@"paymentDue"];
    NSString *totalDash = [dictionary valueForKey:@"total"];
    self.orderId = [dictionary valueForKey:@"id"];
    //bankLogo
    /*if ([bankLogo length] > 0) {
     
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bankLogo,bankLogo]]];
        self.imgView.image = [UIImage imageWithData: imageData];
    }*/
    
    self.imgView.image = [UIImage imageNamed:@"ic_account_balance_black"];
    
    self.lblBankName.text = bankName;
    self.lblPhone.text = [NSString stringWithFormat:@"Location's phone #: %@",phoneNo];
    self.lblAccountName.text = [NSString stringWithFormat:@"Name on Account: %@",accountName];
    self.lblAccountNo.text = [NSString stringWithFormat:@"Account #: %@",accountNo];
    self.lblCashDeposit.text = [NSString stringWithFormat:@"Cash to Deposit: $%.02f",depositAmount];
    self.lblInstructions.text = [NSString stringWithFormat:@"You are ordering: %@ Dash.",totalDash];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    formatter.timeZone = [NSTimeZone localTimeZone];
    NSDate *local = [formatter dateFromString:depositDue];
    NSLog(@"local: %@",local);
    
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    formatter.timeZone = [NSTimeZone localTimeZone];
    NSString *localTime = [formatter stringFromDate:local];
    NSLog(@"localTime: %@",localTime);
    
    formatter.timeZone = [NSTimeZone localTimeZone];
    NSString *currentLocalTime = [formatter stringFromDate:[NSDate date]];
    NSLog(@"currentTime Local: %@",currentLocalTime);
    
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSLog(@"currentTime UTC : %@",currentTime);
    
    self.lblDepositDue.text = [NSString stringWithFormat:@"Deposit Due: %@",currentTime];
}

#pragma mark - API
- (void)captureHold {
    
    NSDictionary *params =
    @{
      @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
      @"verificationCode": self.purchaseCode,
      };
    
    [[APIManager sharedInstance] captureHold:params holdId:self.holdId response:^(id responseDict, NSError *error) {
    
        if (error == nil) {
            
            NSArray *response = [[NSArray alloc] initWithArray:(NSArray*)responseDict];
            
            if (response.count > 0) {
             
                if ([[response objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                    
                    [self updateData:[response objectAtIndex:0]];
                }
            }
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)confirmDeposit {
    
    [[APIManager sharedInstance] confirmDeposit:self.orderId response:^(id responseDict, NSError *error) {
 
        if (error == nil) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyingSummaryViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingSummaryViewController"];
            myViewController.phoneNo = self.phoneNo;
            [self.navigationController pushViewController:myViewController animated:YES];
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)cancelOrder {
    
    [[APIManager sharedInstance] cancelOrder:self.orderId response:^(id responseDict, NSError *error) {
   
        if (error == nil) {
            
            NSLog(@"responseDict: %@", responseDict);
            
            [self pushToHome];
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
@end
