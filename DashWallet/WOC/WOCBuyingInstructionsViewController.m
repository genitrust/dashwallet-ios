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

@interface WOCBuyingInstructionsViewController ()

@end

@implementation WOCBuyingInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setShadow:self.btnDepositFinished];
    [self setShadow:self.btnCancelOrder];
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

- (void)showDepositAlert{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:@"Are you sure you finished making the payment?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyingSummaryViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingSummaryViewController"];
        [self.navigationController pushViewController:myViewController animated:YES];
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
        
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[WOCBuyDashStep1ViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
                
                break;
            }
        }
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
