//
//  WOCHoldIssueViewController.m
//  dashwallet
//
//  Created by Parth on 21/02/18.
//  Copyright © 2018 Aaron Voisine. All rights reserved.
//

#import "WOCHoldIssueViewController.h"

@interface WOCHoldIssueViewController ()

@end

@implementation WOCHoldIssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)signInBtnClicked:(id)sender {
    
    if (self.phoneNo != nil)
    {
        [self openSite:[NSURL URLWithString:[NSString stringWithFormat:@"https://wallofcoins.com/signin/%@/",self.phoneNo]]];
    }
}

- (void)openSite:(NSURL*)url{
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"URL opened...");
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
