### WOC Buy API Setup (Android)

#### Installation

Setup [Retrofit](https://github.com/square/retrofit) for making API call. 
Create Structure (Classes and interface) for make API call with Retrofit
Set Base URL: http://woc.reference.genitrust.com/api/v1

With Wall of Coins, an individual's contact is considered their "Auth"-orized Contact. In short, we call these "Auths".

All authorization endpoints are located under **'/api/v1/auth/'**

### **Authentication methods**

WOC API supports authentication via auth token. Cookies should not be used, as they are deprecated.
### **Auth token:**

In order to be authenticated you should send a token within every API request. Token must be sent in request header called **‘X-Coins-Api-Token’**. Token must not be expired. Token must have a valid signature and all needed authentication data. Token will look like a long **base64** encoded string: **YXV0aDo2OjE0MjE1OTU1ODN8MDk3NTAyYmE1YzM4YWY4MzUxYTg1NDU2ODFjN2U4ODgyZDhkYmY0Yg==** Each token has a limited lifetime (currently 3 hours, but it can be changed). Token expiration time is always returned by API. Your application should care about automatical token renewal before it expires.

## Auth API

**POST /api/v1/auth/<phone>/authorize/**

Use this endpoint to obtain an auth token (and auth cookie) in exchange to a valid authentication data. Currently you can post either your **‘password’** or your **‘deviceCode’**. In case of successful authentication, response will contain current registration info, authentication source name (device or password) and authentication token along with its expiration time.
Example:

**POST /api/v1/auth/15005550006/authorize/**
```
{
“deviceCode”: “aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa”
}
```
Response:
```
{
"phone": "15005550006",
"token": "ZGV2aWNlOjI6MTQyMTU5OTE0MXw0Nzc5NDFlMDdlNWEwMmJjZWFlZWJhNmUxZmZkZTE3ZTE3NmM3NWY4",
"authSource": "device",
"tokenExpiresAt": "2015-01-18T16:39:01.624Z"
}
```
Here we have a token, a time when this token will expire and the name of authentication source we just used.

**GET /api/v1/auth/current/**

This endpoint only available for authenticated users. It will return your current authentication info that looks like
```
{
"phone": "15005550006",
"token": "YXV0aDo2OjE0MjE1OTk3MTF8MDQzNDJjYzM2ODg1NTdmODU5Mjk0ZjM5NDA1ODhhZjY3MGQxNDBjMQ==",
"availableAuthSources": [
"password",
"device"
],
"tokenExpiresAt": "2015-01-18T16:48:31.319Z"
}
```
* **phone** is a phone number you’re authenticated with
* **token** your auth token with REFRESHED expiration time
* **availableAuthSources** a list of auth sources available for this phone number
* **tokenExpiresAt** a new token expiration time
* **authSource** authentication source you’re currently using
* **device** your current device info. Will be returned only if you have “device” **authSource**
You should use this endpoint for a token renewal.

**GET /api/v1/auth/<phone>/**

This endpoint will return HTTP 404 if phone is not registered in our system, otherwise it will return a list of available authentication methods.

**GET /api/v1/auth/15005550001/**
```
{
"phone": "15005550001",
"availableAuthSources": [
"device"
]
}
```
Note: it will work the same as /api/v1/auth/current/ if you put in a phone number you’re currently authenticated with.

**POST /api/v1/auth/**

You can create new auth entry using this endpoint. You should POST following info:

**POST /api/v1/auth/**
```
{
"phone": "+15005550032",
"email": "john@doe.com",
"password": "123123"
}
```
Response:
```
{
"phone": "+15005550032",
"email": "john@doe.com",
"phoneVerified": false,
"lastVerified": null,
"createdOn": "2015-01-18T14:02:08.548Z",
"accessedOn": "2015-01-18T14:02:08.547Z"
}
```
This endpoint will return HTTP 400 if this phone is already registered or you have any other errors in your data. Error description will be provided.

This is a two-step process. In order to be able to sign in using this phone number, you have to complete the process by verifying it. SMS with validation code will be sent to the given phone right after creation auth record.

**POST /api/v1/auth/<phone>/verify/**

Use this endpoint to complete auth record creation.

**POST /api/v1/auth/15005550033/**
```
{
“code”: “NVDNW”
}
```
Response:
```
{
"phone": "+15005550033",
"email": "john@doe.com",
"phoneVerified": true,
"lastVerified": "2015-01-18T14:08:07.530Z",
"createdOn": "2015-01-18T14:07:41.660Z",
"accessedOn": "2015-01-18T14:07:41.659Z"
}
```
Note, that **phoneVerified** field has turned to “true” You can now sign in using your phone number and password.

**POST /api/v1/auth/<phone>/resendCode/**

Will resend a verification code to your phone in case you haven’t received one.

**POST /api/v1/auth/<phone>/resetPassword/**

POSTing to this endpoint will initiate a password reset process. In order to begin a password reset process you should

**POST /api/v1/auth/15005550033/resetPassword/**
```
{
"password1": "123",
"password2": "123"
}
```
Response:
```
{
"status": "confirmationCode send"
}
```
This will send an SMS with confirmation code that you must POST back in order to successfully change a password.

**POST /api/v1/auth/<phone>/verifyResetPassword/**

This is the endpoint to POST back your reset password verification code.

**POST /api/v1/auth/15005550033/verifyResetPassword/**
```
{
"code": "Y4N4T"
}
```
Response:
```
{
"phone": "15005550033",
"token": "YXV0aDo2OjE0MjE2MDIxNDB8NTM1ZGFlNmZhNDIzMjY1ZjBjOGM1NmNjZmVjNGVhMmJjYmU2MTdhMw==",
"authSource": "password",
"tokenExpiresAt": "2015-01-18T17:29:00.744Z"
}
```
This will finish the password reset process and automatically sign you in.

**DELETE /api/v1/auth/<phone>/**

Will clear an authentication cookie. If you’re using tokens you should just forget your current token in order to be deauthorized.

## **Device endpoint**

You should use **/api/v1/devices/** endpoint for managing your devices. Currently this endpoint requires authentication for evety action (you must send auth token).

**GET /api/v1/devices/**

Will give you a list of devices currently registered with the phone number you’re signed in.

Response:
```
{
[
{
"id": 2,
"name": "New device",
"createdOn": "2015-01-18T13:38:42.839Z"
}
]
}
```
**POST /api/v1/devices/**

Will allow you to register a new device.

**POST /api/v1/devices/**
```
{
"name": "New iPhone",
"code": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
```
Response:
```
{
"id": 4,
"name": "New iPhone",
"createdOn": "2015-01-20T17:13:34.154Z"
}
```
Note, that device code is not sent back by API, it’s a **write-only** field.

**PUT /api/v1/devices/<id>/**

Use this endpoint to update any device details. You can also update a device code if needed.

**PUT /api/v1/devices/4/**
```
{
"id": 4,
"name": "Old iPhone",
"code": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
}
```
Response:
```
{
"id": 4,
"name": "Old iPhone",
"createdOn": "2015-01-20T17:13:34.154Z"
}
```
**DELETE /api/v1/devices/<id>/**

If your device has been stolen or you just want to unlink it from the system, use this endpoint.

**DELETE /api/v1/devices/4/**

Response:
```
{
"status": "Device deleted."
}
```
## **Alternative (simplified) Buy Order Creation**

New user or device can sign up rigth at the step of creating his fist Hold. This can be used to avoid asking user to enter confirmation code twice (one time for signup and one for hold capture). You can post new user or device info right to a hold creation endpoint:

**POST /api/v1/holds/**
```
{
"offer": "eyJlYSI6IHRydWUsICJhZCI6IDIsICJkaSI6ICJhMDAwMjI0ZTEwZjk4NTg0OGM3ZmMyYjVmYjY1ZTRkNSJ9fHxTaW5nbGVEZXBvc2l0T2ZmZXJ8fDFmNzQyMzgxMjJmODIxNjFmYTM2ZWU2MTc0MjFiMDU3",
"phone": "+15005550044",
"email": "john@doe.com",
"deviceName": "John's iPhone",
"deviceCode": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
```
Response:
```
{
"id": "7d80b09c618a8c388ff0f6cc35087c61",
“code”: “AF9UK”,
"tokenExpiresAt": "2015-01-18T16:48:31.319Z",
"discoveryInput": "a000224e10f985848c7fc2b5fb65e4d5",
"holds": [
{
"amount": "0.02325581",
"currentPrice": "430.00",
"status": ""
}
],
"token": "ZGV2aWNlOjM6MTQyMTYwMjk0OXxhYzgzYTZiNjQ3NDJmZDZmMTljNDc5ZWJmZGZlMjgyNmMyZWFiNGRl"
}
```
Note, that it returned an auth token and expiration time. You can use this token to sign up for a limited time, but you’ll be able to use your device code only when you ‘capture’ your hold by sending back a confirmation code.
Note, that “code” field will only be returned in sandbox mode.

Instead of **deviceName** and **deviceCode** you can post a **password** if you don’t want to register a device.

Note, that if you’re posting a phone number when creating a hold, you’re asking an API to register this phone. So, if you’re already registered and have an auth data, don’t post a ‘phone’ to /api/v1/holds/ as the API will tell you that this phone is already registered :)

Notable API response status codes when registering a device with ```POST /api/v1/holds/```:

### Status 403: Forbidden

This is an existing Wall of Coins user. You'll need to...

1. Get the user's Wall of Coins password
2. Supply the password in the POST /api/v1/holds property "password".
3. Call the API again.

### Status 400

The user will not be able to create another offer hold because they already have an order waiting for them to make payment. The functionality you should now provide to the end user is:

1. Show them their orders (obtained from the orders API) with the status "WD", which is known as "Waiting Deposit". This means that Wall of Coins is "Waiting [for the customer to finish the] Deposit [payment]." When this is the order status, you can show the user their payment instructions and inform them that the payment instructions have been SMS'd to their cell phone.
2. Give the user the option to Cancel their "WD"-status orders, or give the user the option to mark their "WD"-status orders as paid. You will call the API to confirm their deposit payment.

### Status 200

The request to reserve the hold was sent. The user will receive an SMS text message with their Purchase Code. The Purchase Code is needed for you to send to the API to finally Capture the Hold, which creates the Order on Wall of Coins.

### Status 201

The request to reserve the hold was sent, and all conditions described for Status 200 are true. Additionally, a device was created and the authentication token can be found in the API response.

## **GET AVAILABLE PAYMENT CENTERS (OPTIONAL)**

API for get payment center list using GET method...

```http
GET http://woc.reference.genitrust.com/api/v1/banks/
```

##### Response : 

```json
[{
    "id": 14,
    "name": "Genitrust",
    "url": "http://genitrust.com/",
    "logo": null,
    "logoHq": null,
    "icon": null,
    "iconHq": null,
    "country": "us",
    "payFields": false},...
]
```
This method is optional.



## **SEARCH & DISCOVERY**

An API for discover available option, which will return Discovery ID along with list of information.

```http
POST http://woc.reference.genitrust.com/api/v1/discoveryInputs/
```

##### Request :

```json
{
  "publisherId": "",
  "cryptoAddress": "",
  "usdAmount": "500",
  "crypto": "DASH",
  "bank": "",
  "zipCode": "34236"
}
```

>   Publisher Id: an Unique ID generated for commit transections.
>   cryptoAddress: Cryptographic Address for user, it's optional parameter.
>   usdAmount: Amount in USD (Need to apply conversation from DASH to USD)
>   crypto: crypto type either DASH or BTC for bitcoin.
>   bank: Selected bank ID from bank list. pass empty if selected none.
>   zipCode: zip code of user, need to take input from user.

##### Response :

```json
{
  "id": "935c882fe79e39e1acd98a801d8ce420",
  "usdAmount": "500",
  "cryptoAmount": "0",
  "crypto": "DASH",
  "fiat": "USD",
  "zipCode": "34236",
  "bank": 5,
  "state": null,
  "cryptoAddress": "",
  "createdIp": "182.76.224.130",
  "location": {
    "latitude": 27.3331293,
    "longitude": -82.5456374
  },
  "browserLocation": null,
  "publisher": null
}
```


## **GET OFFERS**

An API for fetch all offers for received Discovery ID. 

```http
GET http://woc.reference.genitrust.com/api/v1/discoveryInputs/<Discovery ID>/offers/
```

##### Response :

```json
{
  "singleDeposit": [{
    "id": "eyJ1c2QiOiAiNTA2LjAw...",
    "deposit": {
        "currency": "USD",
        "amount": "506.00"
    },
    "crypto": "DASH",
    "amount": {
        "DASH": "52.081",
        "dots": "52,081,512.22",
        "bits": "52,081,512.22",
        "BTC": "52.081"
    },
    "discoveryId": "1260e3afa4f03a195ac1e73c965c797",
    "distance": 0,
    "address": "",
    "state": "",
    "bankName": "MoneyGram",
    "bankLogo": "/media/logos/logo_us_MoneyGram.png",
    "bankLogoHq": "/media/logos/logo_us_MoneyGram%402x.png",
    "bankIcon": "/media/logos/icon_us_MoneyGram.png",
    "bankIconHq": "/media/logos/icon_us_MoneyGram%402x.png",
    "bankLocationUrl": "https://secure.moneygram.com/locations",
    "city": ""},
  ],
  "doubleDeposit": [{
    "id": "eyJkaSI6IC...",
    "firstOffer": {
        "deposit": {
            "currency": "USD",
            "amount": "462.00"
        },
        "crypto": "DASH",
        "amount": {
            "DASH": "44.809",
            "dots": "44,809,058.44",
            "bits": "44,809,058.44",
            "BTC": "44.809"
        },
        "discoveryId": "1260e3afa4f03a195ac1e73c965c797",
        "distance": 0.9639473391774286,
        "address": "240 N Washington Blvd, #100",
        "state": "FL",
        "bankName": "Chase",
        "bankLogo": "/media/logos/logo_us_Chase.png",
        "bankLogoHq": "/media/logos/logo_us_Chase%402x.png",
        "bankIcon": "/media/logos/icon_us_Chase.png",
        "bankIconHq": "/media/logos/icon_us_Chase%402x.png",
        "bankLocationUrl": null,
        "city": "Sarasota"
    },
    "secondOffer": {
        "deposit": {
            "currency": "USD",
            "amount": "38.00"
        },
        "crypto": "DASH",
        "amount": {
            "DASH": "0.368",
            "dots": "368,122.62",
            "bits": "368,122.62",
            "BTC": "0.368"
        },
        "discoveryId": "1260e3afa4f03a195ac1e73c965c797",
        "distance": 0.9639473391774286,
        "address": "240 N Washington Blvd, #100",
        "state": "FL",
        "bankName": "Chase",
        "bankLogo": "/media/logos/logo_us_Chase.png",
        "bankLogoHq": "/media/logos/logo_us_Chase%402x.png",
        "bankIcon": "/media/logos/icon_us_Chase.png",
        "bankIconHq": "/media/logos/icon_us_Chase%402x.png",
        "bankLocationUrl": null,
        "city": "Sarasota"
    },
    "totalAmount": {
        "bits": "45,177,181.06",
        "BTC": "45.177"
    },
    "totalDeposit": {
        "currency": "USD",
        "amount": "500.00"
    }
  }],
  "multipleBanks": [],
  "isExtendedSearch": false,
  "incremented": true
}
```


## **CREATE HOLD**

From offer list on offer click we have to create an hold on offer for generate initial request.

```http
HEADER X-Coins-Api-Token: 

POST http://woc.reference.genitrust.com/api/v1/holds/
```

It need X-Coins-Api-Token as a header parameter which will not pass for new Phone number. If Phone number is already registered with application then we need to authorize that Phone number using "auth/{phoneNumber}/authorize" API and if you will get token in the response of API then that will be used as header parameter.

##### Request :

```json
{
  "publisherId": "",
  "offer": "eyJ1c2QiOiAiNTA...",
  "phone": "+12397772701",
  "deviceName": "Dash Wallet (iOS)",
  "deviceCode": "35149595-411D-4D29-9DBD-9DBF7F125037"
}
```

##### Response :

```json
{
  "id": "999fd1b03f78309988a64701cfaaae37",
  "expirationTime": "2017-08-21T10:08:40.592Z",
  "discoveryInput": "1260e3afa4f03a195ac1e73c965c797",
  "holds": [{
    "amount": "53.65853659",
    "currentPrice": "9.43",
    "status": ""
  }],
  "token": "ZGV2aWNlOjQ0N...",
  "tokenExpiresAt": "2017-08-21T13:05:40.535Z",
  "__PURCHASE_CODE": "CK99K"
}
```
  This API will send purchase code to user's device and it will be same as `__PURCHASE_CODE` value.

 When you get 400 bad response, your device code is WRONG. So create a new device with Alternative (simplified) Buy Order Creation /api/v1/holds


## **CAPTURE HOLD**

We have to match user input code with `__PURCHASE_CODE`  and if verify, we have to proceed further.

```http
HEADER X-Coins-Api-Token: ZGV2aWNlOjQ0NT...

POST http://woc.reference.genitrust.com/api/v1/holds/<Hold ID>/capture/
```

#####Request : 

```
{
  "publisherId": "",
  "verificationCode": "CK99K"
}
```

##### Response :


```json
[
  {
    "id": 81,
    "total": "52.08151222",
    "payment": "506.0000000437",
    "paymentDue": "2017-08-21T12:15:49.024Z",
    "bankName": "MoneyGram",
    "nameOnAccount": "",
    "account": "[{\"displaySort\": 2.0, \"name\": \"birthCountry\", \"value\": \"US\", \"label\": \"Country of Birth\"}, {\"displaySort\": 0.5, \"name\": \"pickupState\", \"value\": \"Florida\", \"label\": \"Pick-up State\"}, {\"displaySort\": 1.0, \"name\": \"lastName\", \"value\": \"Genito\", \"label\": \"Last Name\"}, {\"displaySort\": 0.0, \"name\": \"firstName\", \"value\": \"Robert\", \"label\": \"First Name\"}]",
    "status": "WD",
    "nearestBranch": {
        "city": "",
        "state": "",
        "name": "MoneyGram",
        "phone": null,
        "address": ""
    },
    "bankUrl": "https://secure.moneygram.com",
    "bankLogo": "/media/logos/logo_us_MoneyGram.png",
    "bankIcon": "/media/logos/icon_us_MoneyGram.png",
    "bankIconHq": "/media/logos/icon_us_MoneyGram%402x.png",
    "privateId": "c149c6e90e13de979ff12e0aaa2a9c4d9f88d510"
    }
]
```


it will confirm the user authentication with  `__PURCHASE_CODE`  and in next step we have to confirm or cancel request with Order ID received in last response.



## **CONFIRM DEPOSIT**

```http
HEADER X-Coins-Api-Token: 

POST http://woc.reference.genitrust.com/api/v1/orders/<Order ID>/confirmDeposit/
```

##### Response  

```json
{
  "id": 81,
  "total": "52.08151222",
  "payment": "506.00",
  "paymentDue": "2017-08-21T12:15:49.024Z",
  "bankName": "MoneyGram",
  "nameOnAccount": "",
  "account": "[{\"displaySort\": 2.0, \"name\": \"birthCountry\", \"value\": \"US\", \"label\": \"Country of Birth\"}, {\"displaySort\": 0.5, \"name\": \"pickupState\", \"value\": \"Florida\", \"label\": \"Pick-up State\"}, {\"displaySort\": 1.0, \"name\": \"lastName\", \"value\": \"Genito\", \"label\": \"Last Name\"}, {\"displaySort\": 0.0, \"name\": \"firstName\", \"value\": \"Robert\", \"label\": \"First Name\"}]",
  "status": "WDV",
  "nearestBranch": {
    "city": "",
    "state": "",
    "name": "MoneyGram",
    "phone": null,
    "address": ""
  },
  "bankUrl": "https://secure.moneygram.com",
  "bankLogo": "/media/logos/logo_us_MoneyGram.png",
  "bankIcon": "/media/logos/icon_us_MoneyGram.png",
  "bankIconHq": "/media/logos/icon_us_MoneyGram%402x.png",
  "privateId": "c149c6e90e13de979ff12e0aaa2a9c4d9f88d510"
}
```

it will provide transaction details which will be display to user for proceed manually at bank location.
