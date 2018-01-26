//
//  WOCBuyDashStep4ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep4ViewController.h"
#import "WOCBuyDashStep5ViewController.h"
#import "WOCConstants.h"
#import "APIManager.h"
#import "WOCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "BRWalletManager.h"
#define dashTextField 101
#define dollarTextField 102

@interface WOCBuyDashStep4ViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSString *zipCode;

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
    [self.txtDash setUserInteractionEnabled:NO];
    self.line1Height.constant = 1;
    self.line2Height.constant = 2;
    [self.txtDollar becomeFirstResponder];
    
    [self findZipCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)getOffersClicked:(id)sender {
    
    if (self.zipCode != nil && [self.zipCode length] > 0) {
        
        [self sendUserData:self.zipCode];
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

- (void)findZipCode {
    
    // Your location from latitude and longitude
    NSString *latitude = [[NSUserDefaults standardUserDefaults] valueForKey:@"locationLatitude"];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] valueForKey:@"locationLongitude"];
    
    if (latitude != nil && longitude != nil) {
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        // Call the method to find the address
        [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *d) {
            NSLog(@"address informations : %@", d);
            //NSLog(@"formatted address : %@", [placemark.addressDictionary valueForKey:@"FormattedAddressLines"]);
            NSLog(@"Street : %@", [d valueForKey:@"Street"]);
            NSLog(@"ZIP code : %@", [d valueForKey:@"ZIP"]);
            NSLog(@"City : %@", [d valueForKey:@"City"]);
            
            self.zipCode = [d valueForKey:@"ZIP"];
            
            // etc.
        } failureHandler:^(NSError *error) {
            NSLog(@"Error : %@", error);
        }];
    }
}

- (void)getAddressFromLocation:(CLLocation *)location completionHandler:(void (^)(NSMutableDictionary *placemark))completionHandler failureHandler:(void (^)(NSError *error))failureHandler
{
    NSMutableDictionary *d = [NSMutableDictionary new];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (failureHandler && (error || placemarks.count == 0)) {
            failureHandler(error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(completionHandler) {
                completionHandler(placemark.addressDictionary);
            }
        }
    }];
}

#pragma mark - API
- (void)sendUserData:(NSString*)zipCode {
    
    NSDictionary *params =
    @{
      @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
      //@"cryptoAddress": @"",
      @"usdAmount": self.txtDollar.text,
      @"crypto": @"DASH",
      @"bank": @"",
      @"zipCode": @"34236"//zipCode
      };
    
    [[APIManager sharedInstance] discoverInfo:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *dictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep5ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep5ViewController"];
            myViewController.discoveryId = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]];
            myViewController.amount = self.txtDollar.text;
            [self.navigationController pushViewController:myViewController animated:YES];
        }
        else{
            
            NSLog(@"Error: %@",error.localizedDescription);
        }
    }];
}

#pragma mark - UITextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField.tag == dashTextField) {
        
        self.line1Height.constant = 2;
        self.line2Height.constant = 1;
    }
    else{
        self.line1Height.constant = 1;
        self.line2Height.constant = 2;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag == dollarTextField) {
        
        NSString *dollarString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        uint64_t amount;
        amount = [manager amountForLocalCurrencyString:dollarString];
        NSString *dashString = [manager stringForDashAmount:amount];
        self.txtDash.attributedText = [manager attributedStringForDashAmount:amount];
        
        return true;
    }
    return false;
}

@end
