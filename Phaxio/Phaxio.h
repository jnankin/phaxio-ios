//
//  Phaxio.h
//  Phaxio
//
//  Created by Nick Schulze on 11/3/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhaxioAPI.h"
#import "Fax.h"
#import "PhoneNumber.h"

/**
 Main Phaxio class used for general Phaxio operations
 */
@class Phaxio;

/**
Delegate class to handle Phaxio responses
 */
@protocol PhaxioDelegate <NSObject>

@optional
/**
 a list of supported countries
 
 @param success api response result

 @param json json response from api
 */
-(void)listOfSupportedCountries:(BOOL)success andResponse:(NSDictionary *)json;

/**
 account status
 
 @param success api response result
 
 @param json json response from api
 */
-(void)getAccountStatus:(BOOL)success andResponse:(NSDictionary*)json;

/**
 fax info
 
 @param success api response result
 
 @param json json response from api
 */
-(void)faxInfo:(BOOL)success andResponse:(NSDictionary*)json;

/**
 a list of faxes
 
 @param success api response result
 
 @param json json response from api
 */
-(void)listFaxes:(BOOL)success andResponse:(NSDictionary*)json;

/**
 created phax code
 
 @param success api response result
 
 @param json json response from api
 */
-(void)createPhaxio:(BOOL)success andResponse:(NSDictionary*)json;

/**
 phax code
 
 @param success api response result
 
 @param json json response from api
 */
-(void)retrievePhaxCode:(BOOL)success andResponse:(NSDictionary*)json;

/**
 a list of available phone numbers
 
 @param success api response result
 
 @param json json response from api
 */
-(void)listNumbers:(BOOL)success andResponse:(NSDictionary*)json;

/**
 a list of available area codes
 
 @param success api response result
 
 @param json json response from api
 */
-(void)listAreaCodes:(BOOL)success andResponse:(NSDictionary*)json;

/**
 number info
 
 @param success api response result
 
 @param json json response from api
 */
-(void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json;

/**
 deleted fax result
 
 @param success api response result
 
 @param json json response from api
 */
-(void)deleteFaxFile:(BOOL)success andResponse:(NSDictionary*)json;

@required
@end

@interface Phaxio : NSObject <PhaxioAPIDelegate>
{
    /**
     Used to hit the api endpoints
     */
    PhaxioAPI* api;
}

/**
 Used to relay the api response
 */
@property (nonatomic, retain) id <PhaxioDelegate> delegate;

/**
Initializes a Phaxio object
 */
-(id)initPhaxio;

/**
Returns a list of supported countries to the delegate method `-(void)listOfSupportedCountries:(BOOL)success andResponse:(NSDictionary *)json;`
 */
-(void)supportedCountries;

/**
 Returns the account status to the delegate method `-(void)getAccountStatus:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)accountStatus;

/**
 Returns the account status to the delegate method `-(void)getAccountStatus:(BOOL)success andResponse:(NSDictionary*)json;`
 
 @param fax_id id for the fax
 */
-(void)getFaxWithID:(NSString*)fax_id;

/**
 Returns a list of faxes info for the given parameters to the delegate method `-(void)listFaxes:(BOOL)success andResponse:(NSDictionary*)json;`

 @param created_before date faxes were created before *optional*

 @param created_after faxes were created after *optional*

 @param direction direction of faxes (`sent` or `recieved`) *optional*

 @param status status of faxes *optional*
 
 @param phone_number phone number of faxes *optional*
 
 @param tag tag for faxes *optional*
 */
-(void)listFaxesInDateRangeCreatedBefore:(NSDate*)created_before createdAfter:(NSDate*)created_after direction:(NSString*)direction status:(NSString*)status phoneNumber:(NSString*)phone_number tag:(NSString*)tag;

/**
 Returns a phax code id to the delegate method `-(void)createPhaxio:(BOOL)success andResponse:(NSDictionary*)json;`

 @param metadata metadata associated with the phax code
 */
-(void)createPhaxCodeWithMetadata:(NSString*)metadata;

/**
 Returns the phax code to the delegate method -(void)retrievePhaxCode:(BOOL)success andResponse:(NSDictionary*)json;

 @param phax_id id for the phax code
 */
-(void)retrievePhaxCodeWithID:(NSString*)phax_id;

/**
 Returns the default phax code to the delegate method `-(void)retrievePhaxCode:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)retrievePhaxCode;

/**
 Returns the phone number info to the delegate method `-(void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json;`
 
 @param phone_number phone number to retrieve
 */
-(void)getPhoneNumber:(NSString*)phone_number;

/**
 Returns the phone number info to the delegate method `-(void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json;`
 
 @param country_code country code for listed phone numbers

 @param area_code area code for listed phone numbers
 */
-(void)listPhoneNumbersWithCountryCode:(NSString*)country_code areaCode:(NSString*)area_code;

/**
 Returns the phone number info to the delegate method `-(void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json;`
 
 @param toll_free toll free for the listed area codes
 
 @param country_code for the listed area codes

 @param country country for the listed area codes

 @param state state for the listed area codes
 */
-(void)listAreaCodesAvailableForPurchasingNumbersWithTollFree:(NSString*)toll_free countryCode:(NSString*)country_code country:(NSString*)country state:(NSString*)state;

/**
 Deletes the fax for the given id and returns the result to the delegate method `-(void)deleteFaxFile:(BOOL)success andResponse:(NSDictionary*)json;`
 
 @param fax_id fax id
 */
-(void)deleteFaxFile:(NSString*)fax_id;

@end
