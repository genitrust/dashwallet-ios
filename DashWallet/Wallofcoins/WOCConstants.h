//
//  WOCConstants.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#ifndef WOCConstants_h
#define WOCConstants_h

#ifdef SHOW_LOGS
#define APILog(x, ...) NSLog(@"\n\n%s %d: \n" x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define APILog(x, ...)
#endif
#define Str(str) (str != [NSNull null])?str:@""

#define WALLOFCOINS_PUBLISHER_ID "52"

//#define IS_PRODUCTION TRUE // IF MAINNET SET DASH_TESTNET = 0
#define IS_PRODUCTION FALSE  //  IF TESTNET SET DASH_TESTNET = 1

#define BASE_URL_DEVELOPMENT @"https://woc.reference.genitrust.com"
#define BASE_URL_PRODUCTION @"https://wallofcoins.com"

#define API_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ" //@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
#define LOCAL_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"

#pragma mark - USER DEFAULT KEYS

#define USER_DEFAULTS_LOCAL_LOCATION_LATITUDE @"USER_DEFAULTS_LOCAL_LOCATION_LATITUDE"
#define USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE @"USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE"
#define USER_DEFAULTS_LOCAL_DEVICE_CODE @"USER_DEFAULTS_LOCAL_DEVICE_CODE"
#define USER_DEFAULTS_LOCAL_DEVICE_ID @"USER_DEFAULTS_LOCAL_DEVICE_ID"
#define USER_DEFAULTS_AUTH_TOKEN @"USER_DEFAULTS_AUTH_TOKEN"
#define USER_DEFAULTS_LOCAL_PHONE_NUMBER @"USER_DEFAULTS_PHONE_NUMBER"
#define USER_DEFAULTS_LOCAL_COUNTRY_CODE @"USER_DEFAULTS_LOCAL_COUNTRY_CODE"
#define USER_DEFAULTS_LAUNCH_STATUS @"USER_DEFAULTS_LAUNCH_STATUS"
#define USER_DEFAULTS_LOCAL_DEVICE_INFO @"USER_DEFAULTS_LOCAL_DEVICE_INFO"

#pragma mark - NOTIFICATION OBSERVER NAME
#define NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1 @"NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_1"
#define NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_2 @"NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_2"
#define NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_4 @"NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_4"
#define NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_8 @"NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_8"

#pragma mark - API PARAMETERS KEYS

#define API_HEADER_CONTENT_TYPE @"Content-Type"
#define API_HEADER_PUBLISHER_ID @"X-Coins-Publisher"
#define API_HEADER_TOKEN @"X-Coins-Api-Token"
#define API_BODY_PUBLISHER_ID @"publisherId"
#define API_BODY_CRYPTO_AMOUNT @"cryptoAmount"
#define API_BODY_USD_AMOUNT @"usdAmount"
#define API_BODY_CRYPTO @"crypto"
#define API_BODY_CRYPTO_ADDRESS @"cryptoAddress"
#define API_BODY_BANK @"bank"
#define API_BODY_ZIP_CODE @"zipCode"
#define API_BODY_OFFER @"offer"
#define API_BODY_DEVICE_NAME @"deviceName"
#define API_BODY_DEVICE_CODE @"deviceCode"
#define API_BODY_DEVICE_ID @"deviceId"
#define API_BODY_CODE @"code"
#define API_BODY_NAME @"name"
#define API_BODY_PHONE_NUMBER @"phone"
#define API_BODY_DEVICE_NAME_IOS [NSString stringWithFormat:@"%@ Wallet (iOS)",WOC_CURRENTCY]
#define API_BODY_EMAIL @"email"
#define API_BODY_JSON_PARAMETER @"JSONPara"
#define API_BODY_VERIFICATION_CODE @"verificationCode"
#define API_BODY_PASSWORD @"password"
#define API_BODY_LATITUDE @"latitude"
#define API_BODY_LONGITUDE @"longitude"
#define API_BODY_BROWSERLOCATION @"browserLocation"
#define API_BODY_COUNTRY @"country"
#define API_BODY_COUNTRY_CODE @"CountryCode"

#pragma mark - API PARAMETERS KEYS

#define API_RESPONSE_TOKEN @"token"
#define API_RESPONSE_ID @"id"
#define API_RESPONSE_DEVICE_ID @"deviceId"
#define API_RESPONSE_PURCHASE_CODE @"__PURCHASE_CODE"
#define API_RESPONSE_Holds @"holds"
#define API_RESPONSE_Holds_Status @"status"

#pragma mark - OTHER
#define STORYBOARD_DASH @"buyDash"
#define WOC_CURRENTCY @"DASH"
#define WOC_CURRENTCY_SPECIAL @"ĐASH"
#define WOC_CURRENTCY_MINOR_SPECIAL @"đots"
#define WOC_CURRENTCY_SYMBOL @"Đ"
#define WOC_CURRENTCY_SYMBOL_MINOR @"đ"
#define CRYPTO_CURRENTCY_SMALL @"dots"

#define CRYPTO_CURRENTCY WOC_CURRENTCY

#define ALERT_TITLE [NSString stringWithFormat:@"%@ Wallet",WOC_CURRENTCY]

#define setVal(value) (value == nil)?@"":(![value isEqual:[NSNull null]])?value:@""

#endif /* WOCUserDefaultsConstants_h */
