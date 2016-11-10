# ios-phaxio

Send faxes with [Phaxio](http://www.phaxio.com).

## Installation

`Cocoa-Pods`
`Carthage`
`Framework`
`Framework`

## Setup

Sets the key and secret for Phaxio.
```objective-c

[PhaxioAPI setAPIKey:@"thisisthekey" andSecret:@"thisisthesecret"];

```

## Phaxio

### -(id)initPhaxio

returns a phaxio object.
```objective-c
Phaxio* phaxio = [[phaxio alloc] initPhaxio];
```

## Methods

### -(void)supportedCountries;

returns a list of supported countries
```objective-c
[phaxio supportedCountries];
```
response is returned in the delegate method
```objective-c
- (void)listOfSupportedCountries:(BOOL)success andResponse:(NSDictionary *)json;
```

### -(void)accountStatus;

returns the status of the account
```objective-c
[phaxio accountStatus];
```
response is returned in the delegate method
```objective-c
- (void)getAccountStatus:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)getFaxWithID:(NSString*)fax_id

returns a fax object with the given id
```objective-c
[phaxio getFaxWithID:@"fax_id"];
```
response is returned in the delegate method
```objective-c
- (void)faxInfo:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)listFaxesInDateRangeCreatedBefore:(NSDate*)created_before createdAfter:(NSDate*)created_after direction:(NSString*)direction status:(NSString*)status phoneNumber:(NSString*)phone_number tag:(NSString*)tag;

returns a list of faxes with the given criteria
```objective-c
[phaxio listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:@"sent" status:nil phoneNumber:nil tag:nil];
```
response is returned in the delegate method
```objective-c
- (void)listFaxes:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)createPhaxCode;

creates and returns a phax code
```objective-c
[phaxio createPhaxCode];
```
response is returned in the delegate method
```objective-c
- (void)createPhaxio:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)retrievePhaxCode;

retrieves phax code
```objective-c
[phaxio retrievePhaxCode];
```
response is returned in the delegate method
```objective-c
- (void)retrievePhaxCode:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)getPhoneNumber:(NSString*)phone_number;

returns a phone number object with the given number
```objective-c
[phaxio getPhoneNumber:@"123-456-7890"];
```
response is returned in the delegate method
```objective-c
- (void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)listPhoneNumbersWithCountryCode:(NSString*)country_code areaCode:(NSString*)area_code;

returns a list of phone number objects with the given criteria
```objective-c
[phaxio listPhoneNumbersWithCountryCode:@"" areaCode:@"515"];
```
response is returned in the delegate method
```objective-c
- (void)listNumbers:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)listAreaCodesAvailableForPurchasingNumbersWithTollFree:(NSString*)toll_free countryCode:(NSString*)country_code country:(NSString*)country state:(NSString*)state;

returns a list of area codes available for purchasing numbers
```objective-c
[phaxio listAreaCodesAvailableForPurchasingNumbersWithTollFree:@"" countryCode:@"" country:@"US" state:@""];
```
response is returned in the delegate method
```objective-c
- (void)listAreaCodes:(BOOL)success andResponse:(NSDictionary*)json;
```

## Fax

### -(id)initFax

returns a fax object with content url and header.
```objective-c
Fax* fax = [[Fax alloc] initFax];
[fax setContent_url:@"image/url"];
[fax setHeader_text:@"this is the header"];
```

## Methods

### -(void)sendWithBatchDelay:(NSString*)batch_delay batchCollisionAvoidance:(NSString*) batch_collision_avoidance callbackUrl:(NSString*)callback_url cancelTimeout:(NSString*)cancel_timeout tag:(NSString*)tag tagValue:(NSString*)tag_value callerId:(NSString*)caller_id testFail:(NSString*)test_fail;

creates a fax with the given criteria
```objective-c
[fax sendWithBatchDelay:@"" batchCollisionAvoidance:@"" callbackUrl:@"callback_url" cancelTimeout:@"" tag:@"" tagValue:@"" callerId:@"" testFail:@""];
```
response is returned in the delegate method
```objective-c
- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)send;

creates a fax with the given criteria
```objective-c
[fax send];
```
response is returned in the delegate method
```objective-c
- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)cancel;

cancels the fax
```objective-c
[fax cancel];
```
response is returned in the delegate method
```objective-c
- (void)cancelledFax:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)resend;

resends the fax
```objective-c
[fax resend];
```
response is returned in the delegate method
```objective-c
- (void)resentFax:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)deleteFax;

deletes the fax
```objective-c
[fax delete];
```
response is returned in the delegate method
```objective-c
- (void)deletedFax:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(UIImage*)contentFile;

returns the content file of the fax, returns nil if image hasn't been loaded previously
```objective-c
[fax contentFile];
```
response is returned in the delegate method
```objective-c
- (void)contentFile:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(UIImage*)smallThumbnail;

returns a small thumbnail image, returns nil if image hasn't been loaded previously
```objective-c
[fax smallThumbnail];
```
response is returned in the delegate method
```objective-c
- (void)smallThumbnail:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(UIImage*)largeThumbnail;

returns a large thumbnail image, returns nil if image hasn't been loaded previously
```objective-c
[fax largeThumbnail];
```
response is returned in the delegate method
```objective-c
- (void)largeThumbnail:(BOOL)success andResponse:(NSDictionary*)json;
```

## Phone Number

### -(id)initPhoneNumber

returns a phone number object with country code and area code.
```objective-c
PhoneNumber* phoneNumber = [[PhoneNumber alloc] initPhoneNumber];
[phoneNumber setCountry_code:@""];
[phoneNumber setArea_code:@""];
```

## Methods

### -(void)provisionPhoneNumber;

provisions a phone number
```objective-c
[phoneNumber provisionPhoneNumber];
```
response is returned in the delegate method
```objective-c
- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)provisionPhoneNumberWithCallbackUrl:(NSString*)callback_url;

provisions a phone number with the callback url
```objective-c
[phoneNumber provisionPhoneNumberWithCallbackUrl:@"callback_url"];

```
response is returned in the delegate method
```objective-c
- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json;
```

### -(void)releasePhoneNumber;

releases the phone number
```objective-c
[phoneNumber releasePhoneNumber];
```
response is returned in the delegate method
```objective-c
- (void)releasePhoneNumber:(BOOL)success andResponse:(NSDictionary*)json;
```

## Author

[Nick Schulze](http://twitter.com/nickschulze) ([nschulze16@gmail.com](mailto:nschulze16@gmail.com)).

## License

This project is [UNLICENSED](http://unlicense.org/) and not endorsed by or affiliated with [Phaxio](http://www.phaxio.com).

