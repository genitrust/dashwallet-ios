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
#import "WOCAlertController.h"

@interface WOCPasswordViewController () <UITextViewDelegate>

@end

@implementation WOCPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    self.mainView.layer.cornerRadius = 3.0;
    self.mainView.layer.masksToBounds = YES;
    
    [self setShadow:self.btnLogin];
    [self setShadow:self.btnForgotPassword];
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.btnWOCLink.titleLabel.text];
    // making text property to underline text-
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(30, 13)];
    [titleString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(30, 13)];
    // using text on button
    [self.btnWOCLink setAttributedTitle:titleString forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)linkClicked:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"https://wallofcoins.com/"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (IBAction)loginClicked:(id)sender {
    
    NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([password length] > 0) {
        
        [self login:self.phoneNo password:password];
    }
    else{
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter password." viewController:self.navigationController.visibleViewController];
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
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

#pragma mark - API
- (void)login:(NSString*)phone password:(NSString*)password{
    
    NSDictionary *params = @{
                             @"kPublisherId": @WALLOFCOINS_PUBLISHER_ID,
                             @"password": password
                             };
    
    [[APIManager sharedInstance] login:params phone:phone response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:kToken] forKey:kToken];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSUserDefaults standardUserDefaults] setValue:phone forKey:@"phone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openBuyDashStep8" object:phone];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.userInfo != nil)
                {
                    if (error.userInfo[@"detail"] != nil)
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.userInfo[@"detail"]  viewController:self];
                    }
                    else
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                    }
                }
                else
                {
                    [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self];
                }
            });
        }
    }];
}
@end
