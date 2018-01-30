//
//  WOCBuyDashStep7ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep7ViewController.h"
#import "WOCBuyDashStep8ViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCPasswordViewController.h"
#import "WOCBuyDashStep8ViewController.h"

@interface WOCBuyDashStep7ViewController ()

@end

@implementation WOCBuyDashStep7ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnNext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep8:) name:@"openBuyDashStep8" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSString *phone = [[NSUserDefaults standardUserDefaults] valueForKey:kPhone];
    
    if (phone != nil) {
        
        if ([phone hasPrefix:@"+1"]) {
            phone = [phone stringByReplacingOccurrencesOfString:@"+1" withString:@""];
        }
        
        self.txtPhoneNumber.text = phone;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)nextClicked:(id)sender {
    
    NSString *txtPhone = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([txtPhone length] > 0) {
        
        [self checkPhone:txtPhone];
        
        /*NSString *deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@",txtPhone,txtPhone,txtPhone,txtPhone,txtPhone];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
        myViewController.offerId = self.offerId;
        myViewController.phoneNo =
        myViewController.deviceCode = deviceCode;
        [self.navigationController pushViewController:myViewController animated:YES];*/
    }
    else
    {

    }
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

- (void)openBuyDashStep8:(NSNotification*)notification {
    
    NSString *phone = [NSString stringWithFormat:@"%@",notification.object];
    
    NSString *deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@",phone,phone,phone,phone,phone];
    
    if ([phone hasPrefix:@"+1"]) {
        
        NSString *phoneNo = [phone stringByReplacingOccurrencesOfString:@"+1" withString:@""];
        
        deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@",phoneNo,phoneNo,phoneNo,phoneNo,phoneNo];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
    myViewController.phoneNo = phone;
    myViewController.offerId = self.offerId;
    myViewController.deviceCode = deviceCode;
    [self.navigationController pushViewController:myViewController animated:YES];
}

#pragma mark - API
- (void)checkPhone:(NSString*)phone {
    
    NSDictionary *params = @{
                             @"publisherId": @WALLOFCOINS_PUBLISHER_ID
                             };
    
    NSString *phoneNo = [NSString stringWithFormat:@"+1%@",phone];
    
    [[APIManager sharedInstance] authorizeDevice:params phone:phoneNo response:^(id responseDict, NSError *error) {
   
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            NSArray *availableAuthSource = (NSArray*)[responseDictionary valueForKey:@"availableAuthSources"];
            
            if (availableAuthSource.count > 0) {
                
                if ([[availableAuthSource objectAtIndex:0] isEqualToString:@"password"]){
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                    WOCPasswordViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCPasswordViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                    [self.navigationController presentViewController:myViewController animated:YES completion:nil];
                }
                else if([[availableAuthSource objectAtIndex:0] isEqualToString:@"device"]){
                    
                    [self login:phone];
                }
            }
        }
        else{
            
            if ([error code] == 404) {
                
                //new number
                //NSString *deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@",phone,phone,phone,phone,phone];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kToken];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPhone];
                
                NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceCode];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
                myViewController.phoneNo = phoneNo;
                myViewController.offerId = self.offerId;
                myViewController.deviceCode = deviceCode;
                [self.navigationController pushViewController:myViewController animated:YES];
                
                [[NSUserDefaults standardUserDefaults] setValue:phone forKey:kPhone];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)login:(NSString*)phone{
    
    //NSString *deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@",phone,phone,phone,phone,phone];
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceCode];
    
    NSDictionary *params = @{
                             @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
                             @"deviceCode": deviceCode
                             };
    
    NSString *phoneNo = [NSString stringWithFormat:@"+1%@",phone];
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
    
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:kToken] forKey:kToken];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSUserDefaults standardUserDefaults] setValue:phone forKey:@"phone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.offerId = self.offerId;
            myViewController.deviceCode = deviceCode;
            [self.navigationController pushViewController:myViewController animated:YES];
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

@end
