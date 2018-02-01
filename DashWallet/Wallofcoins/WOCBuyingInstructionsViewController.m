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

@interface WOCBuyingInstructionsViewController () <UITextViewDelegate>

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *dueTime;
@property (assign, nonatomic) int minutes;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation WOCBuyingInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnDepositFinished];
    [self setShadow:self.btnCancelOrder];
    [self setShadow:self.btnWallOfCoins];
    [self setShadow:self.btnSignOut];
    
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
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"If you have any questions, there is a live chat window at wallofcoins.com or you may call the phone number that sent you a text message." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.5]}];
    
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"https://wallofcoins.com"
                             range:[[attributedString string] rangeOfString:@"wallofcoins.com"]];
    
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                     NSUnderlineColorAttributeName: [UIColor blackColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    // assume that textView is a UITextView previously created (either by code or Interface Builder)
    self.txtInstruction.linkTextAttributes = linkAttributes; // customizes the appearance of links
    self.txtInstruction.attributedText = attributedString;
    self.txtInstruction.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)showMapClicked:(id)sender
{
    // Your location from latitude and longitude
    NSString *latitude = [[NSUserDefaults standardUserDefaults] valueForKey:@"locationLatitude"];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] valueForKey:@"locationLongitude"];
    
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f", 27.6648, 81.5158, 27.6648, 81.5158];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
    }
}

- (IBAction)depositFinishedClicked:(id)sender {
    
    [self showDepositAlert];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
//    WOCBuyingSummaryViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingSummaryViewController"];
//    [self.navigationController pushViewController:myViewController animated:YES];
}

- (IBAction)cancelOrderClicked:(id)sender
{
    [self showCancelOrderAlert];
}

- (IBAction)wallOfCoinsClicked:(id)sender {
    
    [self openSite:[NSURL URLWithString:@"https://wallofcoins.com"]];
}

- (IBAction)signOutClicked:(id)sender {
    
    NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:kPhone];
    if (![phoneNo hasPrefix:@"+1"]) {
        phoneNo = [NSString stringWithFormat:@"+1%@",phoneNo];
    }
    [self signOut:phoneNo];
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

- (void)pushToStep1{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep1ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];// Or any VC with Id
        vc.isFromSend = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = navigationController;
    });
}

- (void)openSite:(NSURL*)url{

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"URL opened...");
        }];
    }
}

- (void)stopTimer{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timer invalidate];
    });
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
    if (![self.phoneNo hasPrefix:@"+1"]) {
        self.phoneNo = [NSString stringWithFormat:@"+1%@",self.phoneNo];
    }
    NSString *loginPhone = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",self.phoneNo];
    
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
    self.lblLoginPhone.text = loginPhone;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    formatter.timeZone = [NSTimeZone localTimeZone];
    NSDate *local = [formatter dateFromString:depositDue];
    NSLog(@"local: %@",local);
    
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    formatter.timeZone = [NSTimeZone localTimeZone];
    NSString *localTime = [formatter stringFromDate:local];
    NSLog(@"localTime: %@",localTime);
    self.dueTime = localTime;
    
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSLog(@"currentTime UTC : %@",currentTime);
    
    NSMutableAttributedString *timeString = [self dateDiffrenceBetweenTwoDates:currentTime endDate:localTime];
    NSMutableAttributedString *dueString = [[NSMutableAttributedString alloc] initWithString:@"Deposit Due: "];
    [dueString appendAttributedString:timeString];
    
    self.lblDepositDue.attributedText = dueString;
    
    self.timer = [[NSTimer alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
    
    if ([[self.orderDict valueForKey:@"account"] length] > 16) {
        
        NSArray *accountArray = [NSJSONSerialization JSONObjectWithData:[[self.orderDict valueForKey:@"account"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        self.lblPhone.text = [NSString stringWithFormat:@"Name: %@ %@",[[accountArray objectAtIndex:0] valueForKey:@"value"], [[accountArray objectAtIndex:1] valueForKey:@"value"]];
        self.lblAccountName.text = [NSString stringWithFormat:@"Country of Birth: %@",[[accountArray objectAtIndex:2] valueForKey:@"value"]];
        self.lblAccountNo.text = [NSString stringWithFormat:@"Pick-up State: %@",[[accountArray objectAtIndex:3] valueForKey:@"value"]];
    }
}

-(void)checkTime{
    
    if (self.minutes > 0) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        NSMutableAttributedString *timeString = [self dateDiffrenceBetweenTwoDates:currentTime endDate:self.dueTime];
        NSMutableAttributedString *dueString = [[NSMutableAttributedString alloc] initWithString:@"Deposit Due: "];
        [dueString appendAttributedString:timeString];
        self.lblDepositDue.attributedText = dueString;
    }
    else{
        
        self.lblDepositDue.text = @"Deposit Due: time expired";
        [self stopTimer];
    }
}

-(NSMutableAttributedString*)dateDiffrenceBetweenTwoDates:(NSString*)startDate endDate:(NSString*)endDate{
    
    NSMutableAttributedString *timeLeft = [[NSMutableAttributedString alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    
    NSDate *startDateT = [formatter dateFromString:startDate];
    NSDate *endDateT = [formatter dateFromString:endDate];
    
    NSDateComponents *components;
    
    NSInteger days;
    NSInteger hours;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:startDateT toDate:endDateT options:0];
    days = [components day];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:startDateT toDate:endDateT options:0];
    hours = [components hour];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:startDateT toDate:endDateT options:0];
    minutes = [components minute];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:startDateT toDate:endDateT options:0];
    seconds = [components second];
    NSString *secondsInString = [NSString stringWithFormat:@"%ld ", (long)minutes];
    
    self.minutes = [secondsInString intValue];
    
    NSInteger daysN = (int) (floor(seconds / (3600 * 24)));
    if(daysN) seconds -= daysN * 3600 * 24;
    
    NSInteger hoursN = (int) (floor(seconds / 3600));
    if(hoursN) seconds -= hoursN * 3600;
    
    NSInteger minutesN = (int) (floor(seconds / 60));
    if(minutesN) seconds -= minutesN * 60;
    
    if(daysN) {
        [timeLeft appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld Days ", (long)daysN*1]]];
    }
    
    if(hoursN) {
        [timeLeft appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%ld Hour ", (long)hoursN*1]]];
    }
    
    if(minutesN) {
        [timeLeft appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%ld Minutes ",(long)minutesN*1]]];
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
                
                [self stopTimer];
                
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
                
                [self stopTimer];
                NSLog(@"responseDict: %@", responseDict);
                [self pushToHome];
            }
            else{
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
}

- (void)signOut:(NSString*)phone
{
    
    NSDictionary *params = @{
                             @"publisherId": @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] signOut:params phone:phone response:^(id responseDict, NSError *error) {
        
        if (error == nil)
        {
            [self stopTimer];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kToken];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPhone];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self pushToStep1];
        }
        else
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if ([[URL scheme] isEqualToString:@"https"]) {
        
        [self openSite:URL];
    
        return NO;
    }
    return YES; // let the system open this URL
}
@end
