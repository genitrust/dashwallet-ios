//
//  WOCSellingStep8ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSellingStep8ViewController.h"
#import "WOCSellingInstructionsViewController.h"
#import "WOCSellingSummaryViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCAlertController.h"
#import "BRRootViewController.h"
#import "BRAppDelegate.h"
#import "MBProgressHUD.h"

@interface WOCSellingStep8ViewController () <UITextFieldDelegate>

@end

@implementation WOCSellingStep8ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setShadow:self.btnPurchaseCode];
    
    self.descLable.text = [NSString stringWithFormat:@"The Mobile phone %@ will receive a verification code within 10 seconds.When you receive the code, input it below."];
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

