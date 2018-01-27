//
//  WOCBuyDashStep1ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep1ViewController.h"
#import "WOCLocationManager.h"
#import "WOCBuyDashStep2ViewController.h"
#import "WOCBuyDashStep3ViewController.h"
#import "WOCBuyDashStep4ViewController.h"

@interface WOCBuyDashStep1ViewController ()

@property (strong, nonatomic) NSString *zipCode;

@end

@implementation WOCBuyDashStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.navigationController.navigationBar setHidden:YES];
    
    /*UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Buy Dash With Cash"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(backBtnClicked:)];
    [btnBack setImage:[UIImage imageNamed:@"ic_arrow_back_white_24dp"]];*/
    
    self.title = @"Buy Dash With Cash";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep4) name:@"openBuyDashStep4" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep2) name:@"openBuyDashStep2" object:nil];
    
    self.btnLocation.layer.cornerRadius = 3.0;
    self.btnLocation.layer.masksToBounds = YES;
    self.btnNoThanks.layer.cornerRadius = 3.0;
    self.btnNoThanks.layer.masksToBounds = YES;
    [self setShadow:self.btnLocation];
    [self setShadow:self.btnNoThanks];
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
    
    if ([[WOCLocationManager sharedInstance] locationServiceEnabled]) {
        [self findZipCode];
    }
    else{
        // Enable Location services
        [[WOCLocationManager sharedInstance] startLocationService];
    }
}

- (IBAction)noThanksClicked:(id)sender {
    
    [self showAlert];
}

#pragma mark - Function
- (void)openBuyDashStep4 {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep4ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep4ViewController"];
    myViewController.zipCode = self.zipCode;
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (void)openBuyDashStep2 {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep2ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep2ViewController"];
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (void)setShadow:(UIView *)view{
    
    //if widthOffset = 1 and heightOffset = 1 then shadow will set to two sides
    //if widthOffset = 0 and heightOffset = 0 then shadow will set to four sides
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);//CGSize(width: widthOffset, height: heightOffset)//0,1
    view.layer.shadowRadius = 1; //1
    view.layer.shadowOpacity = 1;//1
    view.layer.masksToBounds = false;
}

- (void)showAlert{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Dash" message:@"Are you in the USA?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openBuyDashStep2];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep3ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep3ViewController"];
        [self.navigationController pushViewController:myViewController animated:YES];
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
            NSLog(@"ZIP code : %@", [d valueForKey:@"ZIP"]);
            
            self.zipCode = [d valueForKey:@"ZIP"];
            [self openBuyDashStep4];
            
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
@end
