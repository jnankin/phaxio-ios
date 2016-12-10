//
//  PhoneNumber.m
//  Phaxio
//
//  Created by Nick Schulze on 11/5/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import "PhoneNumber.h"

@implementation PhoneNumber

@synthesize phone_number;
@synthesize country_code;
@synthesize area_code;

-(id)initPhoneNumber
{
    self = [super init];
    if (self)
    {
        api = [[PhaxioAPI alloc] init];
        [api setDelegate:self];
    }
    return self;
}

-(void)provisionPhoneNumber;
{
    [self provisionPhoneNumberWithCallbackUrl:nil];
}

-(void)provisionPhoneNumberWithCallbackUrl:(NSString*)callback_url
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    BOOL error = NO;
    
    if (country_code == nil)
    {
        NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
        [response setValue:@"NO" forKey:@"success"];
        [response setValue:@"You need to provide a country code to provision a number." forKey:@"message"];
        [[self delegate] provisionNumber:NO andResponse:response];
        error = YES;
    }
    
    if (area_code == nil)
    {
        NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
        [response setValue:@"NO" forKey:@"success"];
        [response setValue:@"You need to provide an area code to provision a number." forKey:@"message"];
        [[self delegate] provisionNumber:NO andResponse:response];
        error = YES;
    }
    
    [parameters setValue:country_code forKey:@"country_code"];
    [parameters setValue:area_code forKey:@"area_code"];
    
    if (callback_url != nil)
    {
        [parameters setValue:callback_url forKey:@"callback_url"];
    }
    
    if (!error)
    {
        [api provisionPhoneNumberWithPostParameters:parameters];
    }
}

-(void)releasePhoneNumber
{
    [api releasePhoneNumber:phone_number];
}

- (void)provisionNumber:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] provisionNumber:success andResponse:json];
}

- (void)releasePhoneNumber:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] releasePhoneNumber:success andResponse:json];
}

@end
