//
//  WOCSellingCreatePasswordViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingCreatePasswordViewController.h"
#import "WOCSellingInstructionsViewController.h"
#import "WOCSellingSummaryViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCAlertController.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "MBProgressHUD.h"

@interface WOCSellingCreatePasswordViewController () <UITextFieldDelegate>

@end

@implementation WOCSellingCreatePasswordViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setShadow:self.btnPurchaseCode];
    
    NSString *userDeviceName = @"";
    if (self.deviceName != nil) {
        userDeviceName = [NSString stringWithFormat:@"named %@",self.deviceName];
    }
    self.descLable.text = [NSString stringWithFormat:@"You are already signed up with an app %@. Congratulations! Now type a secure password to continue.",userDeviceName];
    if (self.purchaseCode != nil) {
        self.txtPurchaseCode.text = setVal(self.purchaseCode);
    } else {
        self.txtPurchaseCode.text = @"";
    }
    self.txtPurchaseCode.delegate = self;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField.text.length == 4 && string.length == 1)
    {
        [self performSelector:@selector(confirmPurchaseCodeClicked:) withObject:self afterDelay:1.0];
    }
    return TRUE;
}

// MARK: - IBAction
- (IBAction)confirmPurchaseCodeClicked:(id)sender {
    
    NSString *txtCode = [self.txtPurchaseCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([txtCode length] == 5) {

        WOCSellingInstructionsViewController *myViewController = [self getViewController:@"WOCSellingInstructionsViewController"];
        myViewController.purchaseCode = txtCode;
        myViewController.holdId = self.holdId;
        myViewController.phoneNo = self.phoneNo;
        [self pushViewController:myViewController animated:YES];
    }
    else if ([txtCode length] == 0 ) {
        
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:@"Enter Purchase Code" viewController:self.navigationController.visibleViewController];
    }
    else if ([txtCode length] != 5 ) {
        
         [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:@"Enter Valid Purchase Code" viewController:self.navigationController.visibleViewController];
    }
}
@end
/* Resend Code
 Problems receiving your code? Your mobile phone must be able to receive text messages. If you are sure you typed your mobile number correctly, double check that you are in an area with good mobile service signal. Also, try texting the word "Start" to (217) 672-6467. This will "unblock" our service from sending you text messages.
 
 If you still need help, contact us toll-free: 866-841-COIN (866-841-2646).
 */
