//
//  WOCBuyDashStep6ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep6ViewController.h"
#import "WOCBuyDashStep7ViewController.h"

@interface WOCBuyDashStep6ViewController ()

@end

@implementation WOCBuyDashStep6ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setShadow:self.btnNext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)doNotSendMeEmailClicked:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep7ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep7ViewController"];
    [self.navigationController pushViewController:myViewController animated:YES];
}
- (IBAction)nextClicked:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep7ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep7ViewController"];
    [self.navigationController pushViewController:myViewController animated:YES];
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
