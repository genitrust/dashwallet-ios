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
#import "WOCAlertController.h"

@interface WOCBuyDashStep3ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSArray *paymentCenters;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSString *bankId;

@end

@implementation WOCBuyDashStep3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadow:self.btnNext];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.txtPaymentCenter.inputView = self.pickerView;
    
    [self getPaymentCenters];
}

// MARK: - API

- (void)getPaymentCenters {
    
    [[APIManager sharedInstance] getAvailablePaymentCenters:^(id responseDict, NSError *error) {
        if (error == nil) {
            NSArray *responseArray = [[NSArray alloc] initWithArray:(NSArray *)responseDict];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            self.paymentCenters = [responseArray sortedArrayUsingDescriptors:@[sort]];
            [self.pickerView reloadAllComponents];
        }
    }];
}

// MARK: - IBAction

- (IBAction)nextStepClicked:(id)sender {
    
    if ([self.bankId length] > 0) {
        WOCBuyDashStep4ViewController *myViewController = (WOCBuyDashStep4ViewController*)[self getViewController:@"WOCBuyDashStep4ViewController"];;
        myViewController.bankId = self.bankId;
        [self pushViewController:myViewController animated:YES];
        return;
    }
    else {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Dash" message:@"Select payment center." viewController:self.navigationController.visibleViewController];
    }
}

// MARK: UIPickerView Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.paymentCenters.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.paymentCenters[row][@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.txtPaymentCenter.text = self.paymentCenters[row][@"name"];
    self.bankId = [NSString stringWithFormat:@"%@",self.paymentCenters[row][@"id"]];
}

@end

