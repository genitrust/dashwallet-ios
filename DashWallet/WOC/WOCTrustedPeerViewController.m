//
//  WOCTrustedPeerViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCTrustedPeerViewController.h"

@interface WOCTrustedPeerViewController ()

@end

@implementation WOCTrustedPeerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)okClicked:(id)sender {
}

- (IBAction)cancelClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
