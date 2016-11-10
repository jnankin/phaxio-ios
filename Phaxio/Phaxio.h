//
//  Phaxio.h
//  Phaxio
//
//  Created by Nick Schulze on 11/3/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhaxioAPI.h"

@class Phaxio;
@protocol PhaxioDelegate <NSObject>

@optional
- (void)listOfSupportedCountries:(BOOL)success andResponse:(NSDictionary *)json;
- (void)getAccountStatus:(BOOL)success andResponse:(NSDictionary*)json;
- (void)faxInfo:(BOOL)success andResponse:(NSDictionary*)json;
- (void)listFaxes:(BOOL)success andResponse:(NSDictionary*)json;
- (void)createPhaxio:(BOOL)success andResponse:(NSDictionary*)json;
- (void)retrievePhaxCode:(BOOL)success andResponse:(NSDictionary*)json;
- (void)listNumbers:(BOOL)success andResponse:(NSDictionary*)json;
- (void)listAreaCodes:(BOOL)success andResponse:(NSDictionary*)json;
- (void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json;
- (void)deleteFaxFile:(BOOL)success andResponse:(NSDictionary*)json;

@required
@end

@interface Phaxio : NSObject <PhaxioAPIDelegate>
{
    PhaxioAPI* api;
}

@property (nonatomic, retain) id <PhaxioDelegate> delegate;

-(id)initPhaxio;

-(void)supportedCountries;

-(void)accountStatus;

-(void)getFaxWithID:(NSString*)fax_id;

- (void)listFaxesInDateRangeCreatedBefore:(NSDate*)created_before createdAfter:(NSDate*)created_after direction:(NSString*)direction status:(NSString*)status phoneNumber:(NSString*)phone_number tag:(NSString*)tag;

-(void)createPhaxCode;

-(void)retrievePhaxCode;

-(void)getPhoneNumber:(NSString*)phone_number;

-(void)listPhoneNumbersWithCountryCode:(NSString*)country_code areaCode:(NSString*)area_code;

-(void)listAreaCodesAvailableForPurchasingNumbersWithTollFree:(NSString*)toll_free countryCode:(NSString*)country_code country:(NSString*)country state:(NSString*)state;

@end
