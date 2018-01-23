//
//  WOCBuyDashStep1ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep1ViewController.h"
#import "WOCLocationManager.h"

@interface WOCBuyDashStep1ViewController ()

@end

@implementation WOCBuyDashStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.navigationController.navigationBar setHidden:YES];
    
    /*UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Buy Dash With Cash"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(backBtnClicked:)];
    [btnBack setImage:[UIImage imageNamed:@"ic_arrow_back_white_24dp"]];*/
    
    self.title = @"Buy Dash With Cash";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep4) name:@"openBuyDashStep4" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)backBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController.navigationBar setHidden:NO];
}

- (IBAction)findLocationClicked:(id)sender {
    
    // Enable Location services
    [[WOCLocationManager sharedInstance] startLocationService];
}

- (IBAction)noThanksClicked:(id)sender {
}

#pragma mark - Function
- (void)openBuyDashStep4 {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep1ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep1ViewController"];
    [self.navigationController pushViewController:myViewController animated:YES];
}
@end
