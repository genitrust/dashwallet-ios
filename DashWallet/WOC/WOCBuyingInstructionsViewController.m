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
#import "BRRootViewController.h"
#import "BRAppDelegate.h"

@interface WOCBuyingInstructionsViewController ()

@property (strong, nonatomic) NSString *orderId;

@end

@implementation WOCBuyingInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnDepositFinished];
    [self setShadow:self.btnCancelOrder];
    
    if (self.orderDict.count > 0) {
        [self updateData:self.orderDict];
    }
    
    if (self.isFromSend) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
        
    }
    else if (self.isFromOffer){
        
        NSString *phone = [[NSUserDefaults standardUserDefaults] valueForKey:kPhone];
        
        if (![phone hasPrefix:@"+1"]) {
            phone = [NSString stringWithFormat:@"+1%@",phone];
        }
        
        if (self.offerId != nil && [self.offerId length] > 0) {
            [self createHold:self.offerId phoneNo:phone];
        }
        else{
            NSLog(@"Alert: Please select offer.");
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        if ([self.purchaseCode length] > 0 && [self.holdId length] > 0) {
            
            [self captureHold:self.purchaseCode holdId:self.holdId];
        }
        else{
            NSLog(@"Alert: Please enter purchase code.");
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)showMapClicked:(id)sender
{
    
}

- (IBAction)depositFinishedClicked:(id)sender {
    
    [self showDepositAlert];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
//    WOCBuyingSummaryViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingSummaryViewController"];
//    [self.navigationController pushViewController:myViewController animated:YES];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep1ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];// Or any VC with Id
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
            [self.navigationController pushViewController:myViewController animated:YES];
        });
    }
    
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

-(NSMutableString*) timeLeftSinceDate: (NSDate *) dateT {
    
    NSMutableString *timeLeft = [[NSMutableString alloc]init];
    
    NSDate *today10am =[NSDate date];
    
    NSInteger seconds = [today10am timeIntervalSinceDate:dateT];
    
    NSInteger days = (int) (floor(seconds / (3600 * 24)));
    if(days) seconds -= days * 3600 * 24;
    
    NSInteger hours = (int) (floor(seconds / 3600));
    if(hours) seconds -= hours * 3600;
    
    NSInteger minutes = (int) (floor(seconds / 60));
    if(minutes) seconds -= minutes * 60;
    
    if(days) {
        [timeLeft appendString:[NSString stringWithFormat:@"%ld Days", (long)days*-1]];
    }
    
    if(hours) {
        [timeLeft appendString:[NSString stringWithFormat: @"%ld H", (long)hours*-1]];
    }
    
    if(minutes) {
        [timeLeft appendString: [NSString stringWithFormat: @"%ld M",(long)minutes*-1]];
    }
    
    if(seconds) {
        [timeLeft appendString:[NSString stringWithFormat: @"%lds", (long)seconds*-1]];
    }
    
    return timeLeft;
}

#pragma mark - API

- (void)createHold:(NSString*)offerId phoneNo:(NSString*)phone {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kToken];
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceCode];
    NSDictionary *params ;
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) 
    {
        params = @{
                   @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
                   @"offer": [NSString stringWithFormat:@"%@==",offerId],
                   @"deviceName": @"Dash Wallet (iOS)",
                   @"deviceCode": deviceCode,
                   @"JSONPara":@"YES"
                   };
    }
    else
    {
        params = @{
                   @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
                   @"offer": [NSString stringWithFormat:@"%@==",offerId],
                   @"phone": phone,
                   @"deviceName": @"Dash Wallet (iOS)",
                   @"deviceCode": deviceCode,
                   @"JSONPara":@"YES"
                   };
    }
   
    [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            
            NSString *holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"id"]];
            self.holdId = holdId;
            NSString *purchaseCode = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"__PURCHASE_CODE"]];
            
            if ([responseDictionary valueForKey:kToken] != nil && [[responseDictionary valueForKey:kToken] isEqualToString:@"(null)"] == FALSE)
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:kToken]] forKey:kToken];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            [self captureHold:purchaseCode holdId:holdId];
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)captureHold:(NSString*)purchaseCode holdId:(NSString*)holdId{
    
    NSDictionary *params =
    @{
      @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
      @"verificationCode": purchaseCode,
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
    
    if (self.orderId != nil)
    {
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
}

- (void)cancelOrder {
    
    if (self.orderId != nil)
    {
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
}
@end
