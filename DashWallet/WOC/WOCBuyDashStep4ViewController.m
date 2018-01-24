//
//  WOCBuyDashStep4ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep4ViewController.h"
#import "WOCBuyDashStep5ViewController.h"

@interface WOCBuyDashStep4ViewController () <UITextFieldDelegate>

@end

@implementation WOCBuyDashStep4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Buy Dash With Cash";
    self.btnGetOffers.layer.cornerRadius = 3.0;
    self.btnGetOffers.layer.masksToBounds = YES;
    [self setShadow:self.btnGetOffers];
    self.txtDash.delegate = self;
    self.txtDollar.delegate = self;
    [self.txtDash becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)getOffersClicked:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep5ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep5ViewController"];
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

#pragma mark - UITextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField.tag == 101) {
        
        self.line1Height.constant = 2;
        self.line2Height.constant = 1;
    }
    else{
        self.line1Height.constant = 1;
        self.line2Height.constant = 2;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if ([textField.text length] == 0) {
        return true;
    }
    return false;
}

@end
