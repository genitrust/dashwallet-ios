//
//  WOCBuyDashStep7ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep7ViewController.h"
#import "WOCBuyDashStep8ViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"
#import "WOCPasswordViewController.h"
#import "WOCAlertController.h"

@interface WOCBuyDashStep7ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSString *countryCode;

@end

@implementation WOCBuyDashStep7ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buy Dash With Cash";
    
    [self setShadow:self.btnNext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep8:) name:kNotificationObserverStep8Id object:nil];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.txtCountryCode.inputView = self.pickerView;
    
    [self loadJSON];
}

- (void)viewWillAppear:(BOOL)animated{
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)nextClicked:(id)sender {
    
    NSString *txtPhone = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([self.countryCode length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Select country code." viewController:self.navigationController.visibleViewController];
    }
    else if ([txtPhone length] == 0) {
        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Alert" message:@"Enter phone number." viewController:self.navigationController.visibleViewController];
    }
    else{
        [self checkPhone:txtPhone code:self.countryCode];
    }
}

#pragma mark - Function
- (void)setShadow:(UIView *)view{
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

- (void)loadJSON{

    // Retrieve local JSON file called example.json
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    
    // Load the file into an NSData object called JSONData
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    // Create an Objective-C object from JSON Data
    NSDictionary *countriesDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
    NSArray *countries = [countriesDict valueForKey:@"countries"];
    
    self.countries = countries;
    if (self.countries.count > 0) {
        self.txtCountryCode.text = [NSString stringWithFormat:@"%@ (%@)",self.countries[0][@"name"],self.countries[0][@"code"]];
        self.countryCode = [NSString stringWithFormat:@"%@",self.countries[0][@"code"]];
    }
    
    [self.pickerView reloadAllComponents];
}

- (void)openBuyDashStep8:(NSNotification*)notification {
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@",notification.object];
    [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:kPhone];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceCode];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
    myViewController.phoneNo = phoneNo;
    myViewController.offerId = self.offerId;
    myViewController.deviceCode = deviceCode;
    myViewController.emailId = self.emailId;
    [self.navigationController pushViewController:myViewController animated:YES];
}

#pragma mark - API
- (void)checkPhone:(NSString*)phone code:(NSString*)countryCode{
    
    NSDictionary *params = @{
                             kPublisherId: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@%@",countryCode,phone];
    
    [[APIManager sharedInstance] authorizeDevice:params phone:phoneNo response:^(id responseDict, NSError *error) {
   
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            NSArray *availableAuthSource = (NSArray*)[responseDictionary valueForKey:@"availableAuthSources"];
            
            if (availableAuthSource.count > 0) {
                
                if ([[availableAuthSource objectAtIndex:0] isEqualToString:@"password"]){
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                    WOCPasswordViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCPasswordViewController"];
                    myViewController.phoneNo = phoneNo;
                    myViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                    [self.navigationController presentViewController:myViewController animated:YES completion:nil];
                }
                else if([[availableAuthSource objectAtIndex:0] isEqualToString:@"device"]){
                    
                    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kToken];
                    
                    if (token != nil && [token isEqualToString:@"(null)"] == FALSE){
                        
                       [self getDeviceId:phone code:countryCode];
                    }
                    else{
                        [self login:phone code:countryCode];
                    }
                }
            }
        }
        else
        {
            if ([error code] == 404) {

                //new number
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kToken];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPhone];
                
                NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceCode];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
                WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
                myViewController.phoneNo = phoneNo;
                myViewController.offerId = self.offerId;
                myViewController.deviceCode = deviceCode;
                myViewController.emailId = self.emailId;
                [self.navigationController pushViewController:myViewController animated:YES];
                
                [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:kPhone];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.userInfo != nil)
                    {
                        if (error.userInfo[@"detail"] != nil)
                        {
                            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.userInfo[@"detail"]  viewController:self.navigationController.visibleViewController];
                        }
                        else
                        {
                            [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
                        }
                    }
                    else
                    {
                        [[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
                    }
                });
            }
        }
    }];
}

- (void)getDeviceId:(NSString*)phone code:(NSString*)countryCode{
    
    [[APIManager sharedInstance] getDevice:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSArray *response = (NSArray*)responseDict;
            
            if (response.count > 0) {
                
                NSDictionary *dictionary = [response objectAtIndex:0];
                               
                [[NSUserDefaults standardUserDefaults] setValue:[dictionary valueForKey:@"id"] forKey:kDeviceId];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [self login:phone code:countryCode];
        }
        else{
            [self login:phone code:countryCode];
            //[[WOCAlertController sharedInstance] alertshowWithTitle:@"Error" message:error.localizedDescription viewController:self.navigationController.visibleViewController];
        }
    }];
}

- (void)login:(NSString*)phone code:(NSString*)countryCode{
    
    NSString *deviceCode = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceCode];
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceId];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kToken];
    
    NSDictionary *params = @{
                             kPublisherId: @WALLOFCOINS_PUBLISHER_ID,
                             kDeviceCode: deviceCode
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
        if (deviceId != nil && [deviceId isEqualToString:@"(null)"] == FALSE) {
            
            params = @{
                       kPublisherId: @WALLOFCOINS_PUBLISHER_ID,
                       kDeviceCode: deviceCode,
                       kDeviceId: deviceId
                       };
        }
    }
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@%@",countryCode,phone];
    
    [[APIManager sharedInstance] login:params phone:phoneNo response:^(id responseDict, NSError *error) {
    
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDictionary valueForKey:kToken] forKey:kToken];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:kPhone];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.offerId = self.offerId;
            myViewController.deviceCode = deviceCode;
            myViewController.emailId = self.emailId;
            [self.navigationController pushViewController:myViewController animated:YES];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kToken];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPhone];
            [[NSUserDefaults standardUserDefaults] setValue:phoneNo forKey:kPhone];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
            WOCBuyDashStep8ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep8ViewController"];
            myViewController.phoneNo = phoneNo;
            myViewController.offerId = self.offerId;
            myViewController.deviceCode = deviceCode;
            myViewController.emailId = self.emailId;
            [self.navigationController pushViewController:myViewController animated:YES];
            //[[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

#pragma mark - UIPickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.countries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%@ (%@)",self.countries[row][@"name"],self.countries[row][@"code"]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    self.txtCountryCode.text = [NSString stringWithFormat:@"%@ (%@)",self.countries[row][@"name"],self.countries[row][@"code"]];
    self.countryCode = [NSString stringWithFormat:@"%@",self.countries[row][@"code"]];
}

@end
