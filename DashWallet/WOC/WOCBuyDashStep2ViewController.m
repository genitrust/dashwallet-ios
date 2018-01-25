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
    // Do any additional setup after loading the view.
    self.title = @"Buy Dash With Cash";
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.btnNext.layer.cornerRadius = 3.0;
    self.btnNext.layer.masksToBounds = YES;
    [self setShadow:self.btnNext];
    
    self.isZipCodeBlank = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)nextClicked:(id)sender {
    
    if (self.isZipCodeBlank) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep3ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep3ViewController"];
        [self.navigationController pushViewController:myViewController animated:YES];
    }
    else{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep4ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep4ViewController"];
        [self.navigationController pushViewController:myViewController animated:YES];
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

@end
