//
//  WOCBuyDashStep2ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep2ViewController.h"
#import "WOCBuyDashStep3ViewController.h"
#import "WOCBuyDashStep4ViewController.h"
#import "APIManager.h"

@interface WOCBuyDashStep2ViewController ()

@end

@implementation WOCBuyDashStep2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Buy Dash With Cash";
    [self.navigationItem.backBarButtonItem setTitle:@""];
    
    [self setShadow:self.btnNext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setShadow:(UIView *)view
{
    view.layer.cornerRadius = 3.0;
    view.layer.masksToBounds = YES;
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

// MARK: - IBAction

- (IBAction)nextClicked:(id)sender {
    
    NSString *zipCode = [self.txtZipCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([zipCode length] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep3ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep3ViewController"];
        [self.navigationController pushViewController:myViewController animated:YES];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep4ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep4ViewController"];
        myViewController.zipCode = zipCode;
        [self.navigationController pushViewController:myViewController animated:YES];
    }
}

@end

