//
//  ViewController.m
//  Phaxio
//
//  Created by Nick Schulze on 11/3/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initial setup with the api key and secret.
    [PhaxioAPI setAPIKey:@"thisisthekey" andSecret:@"thisisthesecret"];
    
    //Phaxio account methods used to retrieve information relevant to the Phaxio account
    Phaxio* phaxio = [[Phaxio alloc] init];
    
    [phaxio supportedCountries];
    
    [phaxio accountStatus];
    
    [phaxio getFaxWithID:@"fax_id"];
    
    [phaxio listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:nil status:nil phoneNumber:nil tag:nil];
    
    [phaxio createPhaxCode];
    
    [phaxio retrievePhaxCode];
    
    [phaxio getPhoneNumber:@"phone_number"];
    
    [phaxio listPhoneNumbersWithCountryCode:@"country_code" areaCode:@"area_code"];
    
    [phaxio listAreaCodesAvailableForPurchasingNumbersWithTollFree:@"toll_free" countryCode:@"country_code" country:@"country" state:@"state"];
    
    //Fax methods, used for creating, sending, deleting faxes
    Fax* fax = [[Fax alloc] initFax];
    [fax setContent_url:@"image/url"];
    [fax setHeader_text:@"this is the header"];
    
    [fax send];
    [fax sendWithBatchDelay:@"" batchCollisionAvoidance:@"" callbackUrl:@"" cancelTimeout:@"" tag:@"" tagValue:@"" callerId:@"" testFail:@""];
    
    [fax cancel];
    
    [fax resend];
    
    [fax deleteFax];
    
    [fax contentFile];
    
    [fax smallThumbnail];
    
    [fax largeThumbnail];
    
    PhoneNumber* phoneNumber = [[PhoneNumber alloc] initPhoneNumber];
    [phoneNumber setCountry_code:@""];
    [phoneNumber setArea_code:@""];
    [phoneNumber setArea_code:@""];
    
    [phoneNumber provisionPhoneNumberWithCallbackUrl];
    [phoneNumber provisionPhoneNumberWithCallbackUrl:@""];
    
    [phoneNumber releasePhoneNumber];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
