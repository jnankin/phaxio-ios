//
//  PhoneNumber.h
//  Phaxio
//
//  Created by Nick Schulze on 11/5/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhaxioAPI.h"

@class PhoneNumber;
@protocol PhoneNumberDelegate <NSObject>

@optional
- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json;
- (void)releasePhoneNumber:(BOOL)success andResponse:(NSDictionary*)json;

@required
@end

@interface PhoneNumber : NSObject <PhaxioAPIDelegate>
{
    PhaxioAPI* api;
}

@property (nonatomic, retain) NSString* phone_number;
@property (nonatomic, retain) NSString* country_code;
@property (nonatomic, retain) NSString* area_code;
@property (nonatomic, retain) id <PhoneNumberDelegate> delegate;

-(id)initPhoneNumber;

-(void)provisionPhoneNumberWithCallbackUrl;

-(void)provisionPhoneNumberWithCallbackUrl:(NSString*)callback_url;

-(void)releasePhoneNumber;

@end
