//
//  WOCBuyDashStep3ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep3ViewController.h"
#import "WOCBuyDashStep4ViewController.h"
#import "APIManager.h"

@interface WOCBuyDashStep3ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSArray *paymentCenters;
@property (strong, nonatomic) UIPickerView *pickerView;

@end

@implementation WOCBuyDashStep3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Buy Dash With Cash";
    self.btnNext.layer.cornerRadius = 3.0;
    self.btnNext.layer.masksToBounds = YES;
    [self setShadow:self.btnNext];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;   
    self.pickerView.dataSource = self;
    self.txtPaymentCenter.inputView = self.pickerView;
    
    [self getPaymentCenters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)nextClicked:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep4ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep4ViewController"];
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

#pragma mark - API
- (void)getPaymentCenters{
    
    [[APIManager sharedInstance] getAvailablePaymentCenters:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            self.paymentCenters = [[NSArray alloc] initWithArray:(NSArray *)responseDict];
            [self.pickerView reloadAllComponents];
        }
    }];
}

#pragma mark - UIPickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.paymentCenters.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.paymentCenters[row][@"name"];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
   
    self.txtPaymentCenter.text = self.paymentCenters[row][@"name"];
    
}
@end
