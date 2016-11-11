//
//  Phaxio.m
//  Phaxio
//
//  Created by Nick Schulze on 11/3/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import "Phaxio.h"

@implementation Phaxio

@synthesize delegate;

-(id)initPhaxio
{
    self = [super init];
    if (self)
    {
        api = [[PhaxioAPI alloc] init];
        [api setDelegate:self];
    }
    return self;
}

-(void)supportedCountries
{
    [api getAListOfSupportedCountries];
}

-(void)accountStatus
{
    [api getAccountStatus];
}

-(void)getFaxWithID:(NSString*)fax_id
{
    [api getFaxInfoWithID:fax_id];
}

- (void)listFaxesInDateRangeCreatedBefore:(NSDate*)created_before createdAfter:(NSDate*)created_after direction:(NSString*)direction status:(NSString*)status phoneNumber:(NSString*)phone_number tag:(NSString*)tag
{
    [api listFaxesInDateRangeCreatedBefore:created_before createdAfter:created_after direction:direction status:status phoneNumber:phone_number tag:tag];
}

-(void)createPhaxCodeWithMetadata:(NSString*)metadata;
{
    [api createPhaxCodeWithMetadata:metadata];
}

-(void)retrievePhaxCode
{
    [api retrievePhaxCode];
}

-(void)retrievePhaxCodeWithID:(NSString*)phax_id
{
    [api retrievePhaxCodeWithID:phax_id];
}

-(void)getPhoneNumber:(NSString*)phone_number
{
    [api getNumberInfoForNumber:phone_number];
}

-(void)listPhoneNumbersWithCountryCode:(NSString*)country_code areaCode:(NSString*)area_code
{
    [api listNumbersWithCountryCode:country_code areaCode:area_code];
}

-(void)listAreaCodesAvailableForPurchasingNumbersWithTollFree:(NSString*)toll_free countryCode:(NSString*)country_code country:(NSString*)country state:(NSString*)state
{
    [api listAreaCodesAvailableForPurchasingNumbersWithTollFree:toll_free countryCode:country_code country:country state:state];
}

- (void)deleteFaxFile:(NSString*)fax_id
{
    [api deleteFaxFileWithID:fax_id];
}

- (void)listOfSupportedCountries:(BOOL)success andResponse:(NSDictionary *)json
{
    [[self delegate] listOfSupportedCountries:success andResponse:json];
}

- (void)getAccountStatus:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] getAccountStatus:success andResponse:json];
}

- (void)faxInfo:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] faxInfo:success andResponse:json];
    //return fax
}

- (void)listFaxes:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] listFaxes:success andResponse:json];
    //return faxes
}

- (void)createPhaxio:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] createPhaxio:success andResponse:json];
}

- (void)retrievePhaxCode:(BOOL)success andResponse:(NSDictionary*)json;
{
    [[self delegate] retrievePhaxCode:success andResponse:json];
}

- (void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] getNumberInfo:success andResponse:json];
    //return number
}

- (void)deleteFaxFile:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] deleteFaxFile:success andResponse:json];
}

- (void)listNumbers:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] listNumbers:success andResponse:json];
    //return numbers
}

- (void)listAreaCodes:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] listAreaCodes:success andResponse:json];
}

@end
