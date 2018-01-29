//
//  WOCPasswordViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 27/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCPasswordViewController.h"
#import "WOCBuyDashStep8ViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"

@interface WOCPasswordViewController ()

@end

@implementation WOCPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mainView.layer.cornerRadius = 3.0;
    self.mainView.layer.masksToBounds = YES;
    
    [self setShadow:self.btnLogin];
    [self setShadow:self.btnForgotPassword];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)loginClicked:(id)sender {
    
    NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([password length] > 0) {
        
        [self login:self.phoneNo password:password];
    }
    else{
        
        NSLog(@"Alert: Enter password.");
    }
}

- (IBAction)forgotPasswordClicked:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"https://wallofcoins.com/en/forgotPassword/"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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

#pragma mark - API
- (void)login:(NSString*)phone password:(NSString*)password{
    
    NSDictionary *params = @{
                             @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
                             @"password": password
                             };
    
    [[APIManager sharedInstance] login:params phone:phone response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setValue:phone forKey:@"phone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openBuyDashStep8" object:phone];
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
@end
