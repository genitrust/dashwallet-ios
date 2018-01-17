//
//  WOCSendDashViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSendDashViewController.h"

@interface WOCSendDashViewController ()

@end

@implementation WOCSendDashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)backBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
