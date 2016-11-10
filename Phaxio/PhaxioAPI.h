//
//  PhaxioAPI.h
//  Phaxio
//
//  Created by Nick Schulze on 11/3/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PhaxioAPI;
@protocol PhaxioAPIDelegate <NSObject>

@optional
- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)cancelledFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)resentFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)contentFile:(BOOL)success andResponse:(NSDictionary*)json;
- (void)smallThumbnail:(BOOL)success andResponse:(NSDictionary*)json;
- (void)largeThumbnail:(BOOL)success andResponse:(NSDictionary*)json;
- (void)testReceive:(BOOL)success andResponse:(NSDictionary*)json;
- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json;
- (void)createPhaxio:(BOOL)success andResponse:(NSDictionary*)json;
- (void)faxInfo:(BOOL)success andResponse:(NSDictionary*)json;
- (void)listFaxes:(BOOL)success andResponse:(NSDictionary*)json;
- (void)listOfSupportedCountries:(BOOL)success andResponse:(NSDictionary*)json;
- (void)getNumberInfo:(BOOL)success andResponse:(NSDictionary*)json;
- (void)listNumbers:(BOOL)success andResponse:(NSDictionary*)json;
- (void)listAreaCodes:(BOOL)success andResponse:(NSDictionary*)json;
- (void)retrievePhaxCode:(BOOL)success andResponse:(NSDictionary*)json;
- (void)getAccountStatus:(BOOL)success andResponse:(NSDictionary*)json;
- (void)deleteFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)deleteFaxFile:(BOOL)success andResponse:(NSDictionary*)json;
- (void)releasePhoneNumber:(BOOL)success andResponse:(NSDictionary*)json;

@required
@end

@interface PhaxioAPI : NSObject

@property (nonatomic, retain) id <PhaxioAPIDelegate> delegate;

- (void)createAndSendFaxWithParameters:(NSMutableDictionary*)parameters;

- (void)cancelFax:(NSString*)fax_id;

- (void)resendFax:(NSString*)fax_id;

- (void)testReceive;

- (void)getFaxInfoWithID:(NSString*)fax_id;

- (void)getFaxContentFileWithID:(NSString*)fax_id;

- (void)getFaxContentThumbnailSmallWithID:(NSString*)fax_id;

- (void)getFaxContentThumbnailLargeWithID:(NSString*)fax_id;

- (void)deleteFaxWithID:(NSString*)fax_id;

- (void)deleteFaxFileWithID:(NSString*)fax_id;

- (void)listFaxesInDateRangeCreatedBefore:(NSDate*)created_before createdAfter:(NSDate*)created_after direction:(NSString*)direction status:(NSString*)status phoneNumber:(NSString*)phone_number tag:(NSString*)tag;

- (void)listSentFaxes;

- (void)listReceivedFaxes;

- (void)listFaxesWithStatus:(NSString*)status;

- (void)listFaxesForPhoneNumber:(NSString*)phone_number;

- (void)listFaxesForTag:(NSString*)tag;

- (void)getAListOfSupportedCountries;

- (void)provisionPhoneNumberWithPostParameters:(NSMutableDictionary*)parameters;

- (void)getNumberInfoForNumber:(NSString*)number;

- (void)listNumbersWithCountryCode:(NSString*)country_code areaCode:(NSString*)area_code;

- (void)releasePhoneNumber:(NSString*)number;

- (void)listAreaCodesAvailableForPurchasingNumbersWithTollFree:(NSString*)toll_free countryCode:(NSString*)country_code country:(NSString*)country state:(NSString*)state;

- (void)createPhaxCode;

- (void)retrievePhaxCode;

- (void)retrievePhaxCodeWithID:(NSString*)phax_id;

- (void)getAccountStatus;

+ (void)setAPIKey:(NSString*)_api_key andSecret:(NSString*)_api_secret;

@end
