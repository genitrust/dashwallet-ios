//
//  WOCBuyDashStep7ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep7ViewController.h"
#import "WOCBuyDashStep8ViewController.h"

@interface WOCBuyDashStep7ViewController ()

@end

@implementation WOCBuyDashStep7ViewController

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
- (IBAction)nextClicked:(id)sender {
    
    NSString *txtPhone = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([txtPhone length] > 0) {
        
        NSString *deviceCode = [NSString stringWithFormat:@"%@%@%@%@%@",txtPhone,txtPhone,txtPhone,txtPhone,txtPhone];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
        myViewController.offerId = self.offerId;
        myViewController.phoneNo = [NSString stringWithFormat:@"+1%@",txtPhone];
        myViewController.deviceCode = deviceCode;
        [self.navigationController pushViewController:myViewController animated:YES];
    }
    else{

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
