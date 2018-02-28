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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem.backBarButtonItem setTitle:@""];
    [self setShadow:self.btnNext];
}

// MARK: - IBAction

- (IBAction)nextClicked:(id)sender {
    
    NSString *zipCode = [self.txtZipCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([zipCode length] == 0) {
         [self push:@"WOCBuyDashStep3ViewController"];
    }
    else {
        WOCBuyDashStep4ViewController *myViewController = (WOCBuyDashStep4ViewController*)[self getViewController:@"WOCBuyDashStep4ViewController"];;
        myViewController.zipCode = zipCode;
        [self pushViewController:myViewController animated:YES];
    }
}
@end

