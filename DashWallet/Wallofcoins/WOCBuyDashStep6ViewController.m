//
//  WOCBuyDashStep6ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep6ViewController.h"
#import "WOCBuyDashStep7ViewController.h"
#import "WOCAlertController.h"
#import "WOCConstants.h"

@interface WOCBuyDashStep6ViewController ()

@end

@implementation WOCBuyDashStep6ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadow:self.btnNext];
}

- (BOOL)validateEmailWithString:(NSString*)checkString {
    
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

// MARK: - IBAction

- (IBAction)doNotSendMeEmailClicked:(id)sender {
    
    WOCBuyDashStep7ViewController *myViewController = [self getViewController:@"WOCBuyDashStep7ViewController"];
    myViewController.offerId = self.offerId;
    myViewController.emailId = @"";
    [self pushViewController:myViewController animated:YES];
}

- (IBAction)nextClicked:(id)sender {
    
    NSString *emailStr = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([emailStr length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter email." viewController:self.navigationController.visibleViewController];
    }
    else if (![self validateEmailWithString:emailStr]) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter valid email." viewController:self.navigationController.visibleViewController];
    }
    else {

        WOCBuyDashStep7ViewController *myViewController = [self getViewController:@"WOCBuyDashStep7ViewController"];
        myViewController.offerId = self.offerId;
        myViewController.emailId = emailStr;
        [self pushViewController:myViewController animated:YES];
    }
}

@end

