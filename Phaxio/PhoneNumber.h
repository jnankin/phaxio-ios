//
//  PhoneNumber.h
//  Phaxio
//
//  Created by Nick Schulze on 11/5/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhaxioAPI.h"

/**
 Phone Number class used for working with phone number objects
 */
@class PhoneNumber;

/**
 Delegate class to handle PhoneNumber responses
 */
@protocol PhoneNumberDelegate <NSObject>

@optional
/**
 provisioned number response
 
 @param success api response result
 
 @param json json response from api
 */
- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json;

/**
 released phone number response
 
 @param success api response result
 
 @param json json response from api
 */
- (void)releasePhoneNumber:(BOOL)success andResponse:(NSDictionary*)json;

@required
@end

@interface PhoneNumber : NSObject <PhaxioAPIDelegate>
{
    /**
     Used to hit the api endpoints
     */
    PhaxioAPI* api;
}

/**
 Phone number provisioned
 */
@property (nonatomic, retain) NSString* phone_number;

/**
 Country code for phone number
 */
@property (nonatomic, retain) NSString* country_code;

/**
 Area code for phone number
 */
@property (nonatomic, retain) NSString* area_code;

/**
 Used to relay the api response
 */
@property (nonatomic, retain) id <PhoneNumberDelegate> delegate;

/**
 Initializes a Fax object
 */
-(id)initPhoneNumber;

/**
 Provisions a phone number `- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)provisionPhoneNumber;

/**
 Provisions a phone number with given callback url `- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json;`
 
 @param callback_url callback url for given phone number
 */
-(void)provisionPhoneNumberWithCallbackUrl:(NSString*)callback_url;

/**
 Releases the given phone number `- (void)releasePhoneNumber:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)releasePhoneNumber;

@end
