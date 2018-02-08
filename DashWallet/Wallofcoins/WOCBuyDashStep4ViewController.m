//
//  WOCBuyDashStep4ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep4ViewController.h"
#import "WOCBuyDashStep5ViewController.h"
#import "WOCConstants.h"
#import "APIManager.h"
#import "WOCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "BRWalletManager.h"
#import "WOCAlertController.h"

#define dashTextField 101
#define dollarTextField 102

@interface WOCBuyDashStep4ViewController () <UITextFieldDelegate>

@end

@implementation WOCBuyDashStep4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Buy Dash With Cash";
    self.txtDash.text = @"to acquire Dash (Đ) (1,000,000 đots = 1 ĐASH)";
    self.btnGetOffers.layer.cornerRadius = 3.0;
    self.btnGetOffers.layer.masksToBounds = YES;
    [self setShadow:self.btnGetOffers];
    self.txtDash.delegate = self;
    self.txtDollar.delegate = self;
    [self.txtDash setUserInteractionEnabled:NO];
    self.line1Height.constant = 1;
    self.line2Height.constant = 2;
    [self.txtDollar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)getOffersClicked:(id)sender {
    
    NSString *dollarString = [self.txtDollar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([dollarString length] > 0 && [dollarString intValue] != 0) {
        
        if ([dollarString intValue] >= 5) {
            
            if ((self.zipCode != nil && [self.zipCode length] > 0) || (self.bankId != nil && [self.bankId length] > 0)) {
                
                if ([self.zipCode length] > 0) {
                    
                    [self sendUserData:dollarString zipCode:self.zipCode bankId:@""];
                }
                else if ([self.bankId length] > 0){
                    
                    [self sendUserData:dollarString zipCode:@"" bankId:self.bankId];
                }
            }
            else{
                [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"zipCode or bankId is empty." viewController:self.navigationController.visibleViewController];
            }
        }
        else{
            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"Amount must be more than $5." viewController:self.navigationController.visibleViewController];
        }
    }
    else{
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"Enter amount." viewController:self.navigationController.visibleViewController];
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
- (void)sendUserData:(NSString*)amount zipCode:(NSString*)zipCode bankId:(NSString*)bankId {
    
    NSDictionary *params =
    @{
      @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
      @"cryptoAmount": @"0",
      @"usdAmount": amount,
      @"crypto": @"DASH",
      @"bank": bankId,
      @"zipCode": zipCode
      };
    
    [[APIManager sharedInstance] discoverInfo:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *dictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep5ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep5ViewController"];
            myViewController.discoveryId = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]];
            myViewController.amount = self.txtDollar.text;
            [self.navigationController pushViewController:myViewController animated:YES];
        }
        else{
            
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

#pragma mark - UITextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField.tag == dashTextField) {
        
        self.line1Height.constant = 2;
        self.line2Height.constant = 1;
    }
    else{
        self.line1Height.constant = 1;
        self.line2Height.constant = 2;
    }
}
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag == dollarTextField) {
        
        NSString *dollarString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        uint64_t amount;
        amount = [manager amountForLocalCurrencyString:dollarString];
        NSString *dashString = [manager stringForDashAmount:amount];
        self.txtDash.attributedText = [manager attributedStringForDashAmount:amount];
        
        return true;
    }
    return false;
}
*/
@end