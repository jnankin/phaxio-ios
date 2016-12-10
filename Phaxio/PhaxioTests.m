//
//  PhaxioTests.m
//  Phaxio
//
//  Created by Nick Schulze on 12/4/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>
#import "Fax.h"
#import "PhoneNumber.h"
#import "Phaxio.h"

NSString* api_url = @"https://api.phaxio.com/v2/";
NSString* api_secret = @"secret";
NSString* api_key = @"key";

@interface PhaxioTests : XCTestCase <FaxDelegate, PhoneNumberDelegate, PhaxioDelegate>
{
    XCTestExpectation *serverRespondExpectation;
    BOOL passingTest;
    Fax* fax;
    PhoneNumber* phone;
    Phaxio* phaxio;
}
@end

@implementation PhaxioTests

- (void)setUp
{
    [super setUp];
    [PhaxioAPI setAPIKey:@"key" andSecret:@"secret"];
    
    fax = [[Fax alloc] initFax];
    fax.delegate = self;
    
    [fax setContent_url:@"www.contenturl.com"];
    [fax setHeader_text:@"text"];
    [fax setFax_id:@"1234"];
    [fax setTo_phone_numbers:[NSMutableArray arrayWithObjects:@"1234567890", @"9876543210", nil]];
    UIImage* test_image = [UIImage imageNamed:@"apple.png" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
    NSData* fileData = UIImagePNGRepresentation(test_image);
    
    [fax setFile:fileData];
    
    phone = [[PhoneNumber alloc] initPhoneNumber];
    phone.delegate = self;
    [phone setPhone_number:@"1234567890"];
    [phone setCountry_code:@"1"];
    [phone setArea_code:@"515"];
    
    phaxio = [[Phaxio alloc] initPhaxio];
    phaxio.delegate = self;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFaxSend500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax Sent"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [fax send];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testFaxSendSuccess
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:api_secret forKey:@"api_secret"];
    [parameters setValue:api_key forKey:@"api_key"];
    [parameters setValue:@"text" forKey:@"header_text"];
    [parameters setValue:@"true" forKey:@"batch_collision_avoidance"];
    [parameters setValue:@"www.callbackurl.com" forKey:@"callback_url"];
    [parameters setValue:@"1234567890" forKey:@"caller_id"];
    [parameters setValue:@"fail" forKey:@"test_fail"];
    
    serverRespondExpectation = [self expectationWithDescription:@"Fax Sent"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes", api_url];
        
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"1234" forKey:@"id"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Fax queued for sending" forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        
        NSDictionary* bodyDictionary = [dictionary copy];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:&err];

        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [fax sendWithBatchDelay:0 batchCollisionAvoidance:YES callbackUrl:@"www.callbackurl.com" cancelTimeout:0 tag:@"" tagValue:@"" callerId:@"1234567890" testFail:@"fail"];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) sentFax:(BOOL)success andResponse:(NSDictionary *)json
{
    [serverRespondExpectation fulfill];
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Fax queued for sending"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"id"] isEqualToString:@"1234"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
}

- (void)testFaxResend500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax Resend"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [fax resend];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testFaxResendSuccess
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:api_secret forKey:@"api_secret"];
    [parameters setValue:api_key forKey:@"api_key"];
    serverRespondExpectation = [self expectationWithDescription:@"Fax Resent"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234/resend", api_url];
        NSString* request_body = [[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding];
        
        XCTAssertTrue([self verifyParameters:parameters forRequestBody:request_body]);
        
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"1234" forKey:@"id"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Fax queued for resending." forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        
        NSDictionary* bodyDictionary = [dictionary copy];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:&err];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [fax resend];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) resentFax:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Fax queued for resending."]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"id"] isEqualToString:@"1234"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testFaxCancel500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax Cancelled 500"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [fax cancel];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testFaxCancelSuccess
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:api_secret forKey:@"api_secret"];
    [parameters setValue:api_key forKey:@"api_key"];
    serverRespondExpectation = [self expectationWithDescription:@"Fax Cancelled"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234/cancel", api_url];
        NSString* request_body = [[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding];
        
        XCTAssertTrue([self verifyParameters:parameters forRequestBody:request_body]);
        
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"1234" forKey:@"id"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Fax cancellation scheduled successfully." forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        
        NSDictionary* bodyDictionary = [dictionary copy];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:&err];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [fax cancel];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) cancelledFax:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Fax cancellation scheduled successfully."]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"id"] isEqualToString:@"1234"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testFaxDelete500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax Deleted"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [fax deleteFax];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testFaxDeleteSuccess
{

    serverRespondExpectation = [self expectationWithDescription:@"Fax Deleted"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url] && [request.HTTPMethod isEqualToString:@"DELETE"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"1234" forKey:@"id"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Fax cancellation scheduled successfully." forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        
        NSDictionary* bodyDictionary = [dictionary copy];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:&err];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [fax deleteFax];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) deletedFax:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Fax cancellation scheduled successfully."]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"id"] isEqualToString:@"1234"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testFaxContentFile500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax ContentFile"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];

    [fax contentFile];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testFaxContentFileSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax ContentFile"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234/file", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:@"image" forKey:@"image_data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];

    [fax contentFile];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) contentFile:(BOOL)success andResponse:(NSData *)data
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue(data != nil);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testFaxSmallThumbnail500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax SmallThumbnail"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];

    [fax smallThumbnail];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testFaxSmallThumbnailSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax SmallThumbnail"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234/file?thumbnail=s", api_url];
        return [request.URL.absoluteString isEqualToString:url];    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:@"image" forKey:@"image_data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];

    [fax smallThumbnail];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) smallThumbnail:(BOOL)success andResponse:(UIImage *)img
{
    if (passingTest)
    {
        XCTAssertTrue(success);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testFaxLargeThumbnail500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax LargeThumbnail"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];

    [fax largeThumbnail];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testFaxLargeThumbnailSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax LargeThumbnail"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234/file?thumbnail=l", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:@"image" forKey:@"image_data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];

    [fax largeThumbnail];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) largeThumbnail:(BOOL)success andResponse:(UIImage *)img
{
    if (passingTest)
    {
        XCTAssertTrue(success);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhoneNumberProvisionPhoneNumber500
{
    serverRespondExpectation = [self expectationWithDescription:@"Provision Phone Number"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phone provisionPhoneNumber];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhoneNumberProvisionPhoneNumberSuccess
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:api_secret forKey:@"api_secret"];
    [parameters setValue:api_key forKey:@"api_key"];
    [parameters setValue:@"1" forKey:@"country_code"];
    [parameters setValue:@"515" forKey:@"area_code"];
    
    serverRespondExpectation = [self expectationWithDescription:@"Provision Phone Number"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@phone_numbers", api_url];
        NSString* request_body = [[NSString alloc] initWithData:request.OHHTTPStubs_HTTPBody encoding:NSUTF8StringEncoding];
        
        XCTAssertTrue([self verifyParameters:parameters forRequestBody:request_body]);
        
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"+18475551234" forKey:@"phone_number"];
        [dataDictionary setObject:@"Northbrook" forKey:@"city"];
        [dataDictionary setObject:@"Illinois" forKey:@"state"];
        [dataDictionary setObject:@"United States" forKey:@"country"];
        [dataDictionary setObject:@"200" forKey:@"cost"];
        [dataDictionary setObject:@"2016-06-16T15:45:32.000-06:00" forKey:@"last_billed_at"];
        [dataDictionary setObject:@"2016-06-16T15:45:32.000-06:00" forKey:@"provisioned_at"];
        [dataDictionary setObject:@"www.callback.com" forKey:@"callback_url"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Number provisioned successfully!" forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];

        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phone provisionPhoneNumber];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}


-(void) provisionNumber:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Number provisioned successfully!"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"phone_number"] isEqualToString:@"+18475551234"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"city"] isEqualToString:@"Northbrook"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"state"] isEqualToString:@"Illinois"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"country"] isEqualToString:@"United States"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"cost"] isEqualToString:@"200"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"last_billed_at"] isEqualToString:@"2016-06-16T15:45:32.000-06:00"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"provisioned_at"] isEqualToString:@"2016-06-16T15:45:32.000-06:00"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"callback_url"] isEqualToString:@"www.callback.com"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhoneNumberReleasePhoneNumber500
{
    serverRespondExpectation = [self expectationWithDescription:@"Release Phone Number"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phone releasePhoneNumber];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhoneNumberReleasePhoneNumberSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Release Phone Number"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@phone_numbers/1234567890?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url] && [request.HTTPMethod isEqualToString:@"DELETE"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Number released successfully!" forKey:@"message"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phone releasePhoneNumber];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) releasePhoneNumber:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Number released successfully!"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioSupportedCountries500
{
    serverRespondExpectation = [self expectationWithDescription:@"Supported Countries"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phaxio supportedCountries];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioSupportedCountriesSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Supported Countries"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
      NSString* url = [NSString stringWithFormat:@"%@public/countries?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* pagingDictionary = [[NSMutableDictionary alloc] init];
        [pagingDictionary setObject:@"47" forKey:@"total"];
        [pagingDictionary setObject:@"3" forKey:@"per_page"];
        [pagingDictionary setObject:@"1" forKey:@"page"];
 
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"United States" forKey:@"name"];
        [dataDictionary setObject:@"US" forKey:@"alpha2"];
        [dataDictionary setObject:@"1" forKey:@"country_code"];
        [dataDictionary setObject:@"7" forKey:@"price_per_page"];
        [dataDictionary setObject:@"full" forKey:@"send_support"];
        [dataDictionary setObject:@"full" forKey:@"receive_support"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Data contains countries info" forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        [dictionary setObject:pagingDictionary forKey:@"paging"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio supportedCountries];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) listOfSupportedCountries:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Data contains countries info"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"name"] isEqualToString:@"United States"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"alpha2"] isEqualToString:@"US"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"country_code"] isEqualToString:@"1"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"price_per_page"] isEqualToString:@"7"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"send_support"] isEqualToString:@"full"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"receive_support"] isEqualToString:@"full"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"total"] isEqualToString:@"47"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"per_page"] isEqualToString:@"3"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"page"] isEqualToString:@"1"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioAccountStatus500
{
    serverRespondExpectation = [self expectationWithDescription:@"Account Status"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];

    [phaxio accountStatus];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioAccountStatusSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Account Status"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@account/status?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* faxesTodayDictionary = [[NSMutableDictionary alloc] init];
        [faxesTodayDictionary setValue:@"1" forKey:@"sent"];
        [faxesTodayDictionary setValue:@"1" forKey:@"received"];

        NSMutableDictionary* faxesMonthlyDictionary = [[NSMutableDictionary alloc] init];
        [faxesMonthlyDictionary setValue:@"15" forKey:@"sent"];
        [faxesMonthlyDictionary setValue:@"7" forKey:@"received"];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setValue:@"5050" forKey:@"balance"];
        [dataDictionary setObject:faxesTodayDictionary forKey:@"faxes_today"];
        [dataDictionary setObject:faxesMonthlyDictionary forKey:@"faxes_this_month"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Account status retrieved successfully" forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio accountStatus];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}


-(void) getAccountStatus:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Account status retrieved successfully"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"balance"] isEqualToString:@"5050"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"faxes_today"] valueForKey:@"sent"] isEqualToString:@"1"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"faxes_today"] valueForKey:@"received"] isEqualToString:@"1"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"faxes_this_month"] valueForKey:@"sent"] isEqualToString:@"15"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"faxes_this_month"] valueForKey:@"received"] isEqualToString:@"7"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioGetFaxWithID500
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax With ID"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phaxio getFaxWithID:@"1234"];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioGetFaxWithIDSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Fax With ID"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* recipientsDictionary = [[NSMutableDictionary alloc] init];
        [recipientsDictionary setValue:@"+14141234567" forKey:@"phone_number"];
        [recipientsDictionary setValue:@"success" forKey:@"status"];
        [recipientsDictionary setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [recipientsDictionary setValue:@"null" forKey:@"error_type"];
        [recipientsDictionary setValue:@"null" forKey:@"error_id"];
        [recipientsDictionary setValue:@"null" forKey:@"error_message"];
        
        NSMutableDictionary* tagsDictionary = [[NSMutableDictionary alloc] init];
        [tagsDictionary setValue:@"1234" forKey:@"order_id"];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setValue:@"1234" forKey:@"id"];
        [dataDictionary setValue:@"sent" forKey:@"direction"];
        [dataDictionary setValue:@"3" forKey:@"num_pages"];
        [dataDictionary setValue:@"success" forKey:@"status"];
        [dataDictionary setValue:@"true" forKey:@"is_test"];
        [dataDictionary setValue:@"2015-09-02T11:28:02.000-05:00" forKey:@"created_at"];
        [dataDictionary setValue:@"null" forKey:@"from_number"];
        [dataDictionary setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [dataDictionary setValue:@"21" forKey:@"cost"];
        [dataDictionary setValue:@"null" forKey:@"to_number"];
        [dataDictionary setValue:@"null" forKey:@"error_id"];
        [dataDictionary setValue:@"null" forKey:@"error_type"];
        [dataDictionary setValue:@"null" forKey:@"error_message"];
        [dataDictionary setObject:recipientsDictionary forKey:@"recipients"];
        [dataDictionary setObject:tagsDictionary forKey:@"tags"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Metadata for fax" forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];

    [phaxio getFaxWithID:@"1234"];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) faxInfo:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Metadata for fax"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"id"] isEqualToString:@"1234"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"direction"] isEqualToString:@"sent"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"num_pages"] isEqualToString:@"3"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"is_test"] isEqualToString:@"true"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"created_at"] isEqualToString:@"2015-09-02T11:28:02.000-05:00"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"from_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"cost"] isEqualToString:@"21"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"to_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"error_message"] isEqualToString:@"null"]);

        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"recipients"] valueForKey:@"phone_number"] isEqualToString:@"+14141234567"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"recipients"] valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"recipients"] valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"recipients"] valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"recipients"] valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"recipients"] valueForKey:@"error_message"] isEqualToString:@"null"]);

        XCTAssertTrue([[[[json valueForKey:@"data"] valueForKey:@"tags"] valueForKey:@"order_id"] isEqualToString:@"1234"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioListFaxes500
{
    serverRespondExpectation = [self expectationWithDescription:@"List Faxes"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];

    [phaxio listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:nil status:nil phoneNumber:nil tag:nil];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioListFaxesSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"List Faxes"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* pagingDictionary = [[NSMutableDictionary alloc] init];
        [pagingDictionary setObject:@"47" forKey:@"total"];
        [pagingDictionary setObject:@"3" forKey:@"per_page"];
        [pagingDictionary setObject:@"1" forKey:@"page"];
        
        NSMutableDictionary* tagsDictionary = [[NSMutableDictionary alloc] init];
        [tagsDictionary setValue:@"1234" forKey:@"order_id"];
        
        NSMutableDictionary* recipientsDictionary = [[NSMutableDictionary alloc] init];
        [recipientsDictionary setValue:@"+14141234567" forKey:@"phone_number"];
        [recipientsDictionary setValue:@"success" forKey:@"status"];
        [recipientsDictionary setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [recipientsDictionary setValue:@"null" forKey:@"error_type"];
        [recipientsDictionary setValue:@"null" forKey:@"error_id"];
        [recipientsDictionary setValue:@"null" forKey:@"error_message"];
        
        NSMutableDictionary* faxDictionary = [[NSMutableDictionary alloc] init];
        [faxDictionary setValue:@"1234" forKey:@"id"];
        [faxDictionary setValue:@"sent" forKey:@"direction"];
        [faxDictionary setValue:@"3" forKey:@"num_pages"];
        [faxDictionary setValue:@"success" forKey:@"status"];
        [faxDictionary setValue:@"true" forKey:@"is_test"];
        [faxDictionary setValue:@"2015-09-02T11:28:02.000-05:00" forKey:@"created_at"];
        [faxDictionary setValue:@"null" forKey:@"from_number"];
        [faxDictionary setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [faxDictionary setValue:@"21" forKey:@"cost"];
        [faxDictionary setValue:@"null" forKey:@"to_number"];
        [faxDictionary setValue:@"null" forKey:@"error_id"];
        [faxDictionary setValue:@"null" forKey:@"error_type"];
        [faxDictionary setValue:@"null" forKey:@"error_message"];
        [faxDictionary setObject:tagsDictionary forKey:@"tags"];
        [faxDictionary setObject:recipientsDictionary forKey:@"recipients"];
        
        NSMutableDictionary* tagsDictionary2 = [[NSMutableDictionary alloc] init];
        [tagsDictionary2 setValue:@"5678" forKey:@"order_id"];
        
        NSMutableDictionary* recipientsDictionary2 = [[NSMutableDictionary alloc] init];
        [recipientsDictionary2 setValue:@"+14141234567" forKey:@"phone_number"];
        [recipientsDictionary2 setValue:@"success" forKey:@"status"];
        [recipientsDictionary2 setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [recipientsDictionary2 setValue:@"null" forKey:@"error_type"];
        [recipientsDictionary2 setValue:@"null" forKey:@"error_id"];
        [recipientsDictionary2 setValue:@"null" forKey:@"error_message"];
        
        NSMutableDictionary* faxDictionary2 = [[NSMutableDictionary alloc] init];
        [faxDictionary2 setValue:@"1234" forKey:@"id"];
        [faxDictionary2 setValue:@"sent" forKey:@"direction"];
        [faxDictionary2 setValue:@"3" forKey:@"num_pages"];
        [faxDictionary2 setValue:@"success" forKey:@"status"];
        [faxDictionary2 setValue:@"true" forKey:@"is_test"];
        [faxDictionary2 setValue:@"2015-09-02T11:28:02.000-05:00" forKey:@"created_at"];
        [faxDictionary2 setValue:@"null" forKey:@"from_number"];
        [faxDictionary2 setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [faxDictionary2 setValue:@"21" forKey:@"cost"];
        [faxDictionary2 setValue:@"null" forKey:@"to_number"];
        [faxDictionary2 setValue:@"null" forKey:@"error_id"];
        [faxDictionary2 setValue:@"null" forKey:@"error_type"];
        [faxDictionary2 setValue:@"null" forKey:@"error_message"];
        [faxDictionary2 setObject:tagsDictionary2 forKey:@"tags"];
        [faxDictionary2 setObject:recipientsDictionary2 forKey:@"recipients"];
        
        NSMutableDictionary* tagsDictionary3 = [[NSMutableDictionary alloc] init];
        [tagsDictionary3 setValue:@"9012" forKey:@"order_id"];
        
        NSMutableDictionary* recipientsDictionary3 = [[NSMutableDictionary alloc] init];
        [recipientsDictionary3 setValue:@"+14141234567" forKey:@"phone_number"];
        [recipientsDictionary3 setValue:@"success" forKey:@"status"];
        [recipientsDictionary3 setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [recipientsDictionary3 setValue:@"null" forKey:@"error_type"];
        [recipientsDictionary3 setValue:@"null" forKey:@"error_id"];
        [recipientsDictionary3 setValue:@"null" forKey:@"error_message"];
        
        NSMutableDictionary* faxDictionary3 = [[NSMutableDictionary alloc] init];
        [faxDictionary3 setValue:@"1234" forKey:@"id"];
        [faxDictionary3 setValue:@"sent" forKey:@"direction"];
        [faxDictionary3 setValue:@"3" forKey:@"num_pages"];
        [faxDictionary3 setValue:@"success" forKey:@"status"];
        [faxDictionary3 setValue:@"true" forKey:@"is_test"];
        [faxDictionary3 setValue:@"2015-09-02T11:28:02.000-05:00" forKey:@"created_at"];
        [faxDictionary3 setValue:@"null" forKey:@"from_number"];
        [faxDictionary3 setValue:@"2015-09-02T11:28:54.000-05:00" forKey:@"completed_at"];
        [faxDictionary3 setValue:@"21" forKey:@"cost"];
        [faxDictionary3 setValue:@"null" forKey:@"to_number"];
        [faxDictionary3 setValue:@"null" forKey:@"error_id"];
        [faxDictionary3 setValue:@"null" forKey:@"error_type"];
        [faxDictionary3 setValue:@"null" forKey:@"error_message"];
        [faxDictionary3 setObject:tagsDictionary3 forKey:@"tags"];
        [faxDictionary3 setObject:recipientsDictionary3 forKey:@"recipients"];
        
        NSMutableArray* faxArray = [[NSMutableArray alloc] initWithCapacity:3];
        [faxArray addObject:faxDictionary];
        [faxArray addObject:faxDictionary2];
        [faxArray addObject:faxDictionary3];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Retrieved faxes successfully" forKey:@"message"];
        [dictionary setObject:pagingDictionary forKey:@"paging"];
        [dictionary setObject:faxArray forKey:@"data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio listFaxesInDateRangeCreatedBefore:nil createdAfter:nil direction:nil status:nil phoneNumber:nil tag:nil];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) listFaxes:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Retrieved faxes successfully"]);
        NSMutableDictionary* pagingDictionary = [[NSMutableDictionary alloc] init];
        [pagingDictionary setObject:@"47" forKey:@"total"];
        [pagingDictionary setObject:@"3" forKey:@"per_page"];
        [pagingDictionary setObject:@"1" forKey:@"page"];
        
        NSArray* faxes = [json valueForKey:@"data"];
        
        XCTAssertTrue([faxes count] == 3);
        
        NSDictionary* fax_one = [faxes objectAtIndex:0];
        
        XCTAssertTrue([[fax_one valueForKey:@"id"] isEqualToString:@"1234"]);
        XCTAssertTrue([[fax_one valueForKey:@"direction"] isEqualToString:@"sent"]);
        XCTAssertTrue([[fax_one valueForKey:@"num_pages"] isEqualToString:@"3"]);
        XCTAssertTrue([[fax_one valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[fax_one valueForKey:@"is_test"] isEqualToString:@"true"]);
        XCTAssertTrue([[fax_one valueForKey:@"created_at"] isEqualToString:@"2015-09-02T11:28:02.000-05:00"]);
        XCTAssertTrue([[fax_one valueForKey:@"from_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_one valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[fax_one valueForKey:@"cost"] isEqualToString:@"21"]);
        XCTAssertTrue([[fax_one valueForKey:@"to_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_one valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_one valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_one valueForKey:@"error_message"] isEqualToString:@"null"]);
        
        XCTAssertTrue([[[fax_one valueForKey:@"recipients"] valueForKey:@"phone_number"] isEqualToString:@"+14141234567"]);
        XCTAssertTrue([[[fax_one valueForKey:@"recipients"] valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[[fax_one valueForKey:@"recipients"] valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[[fax_one valueForKey:@"recipients"] valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[[fax_one valueForKey:@"recipients"] valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[[fax_one valueForKey:@"recipients"] valueForKey:@"error_message"] isEqualToString:@"null"]);
        
        XCTAssertTrue([[[fax_one valueForKey:@"tags"] valueForKey:@"order_id"] isEqualToString:@"1234"]);
        
        NSDictionary* fax_two = [faxes objectAtIndex:0];
        
        XCTAssertTrue([[fax_two valueForKey:@"id"] isEqualToString:@"1234"]);
        XCTAssertTrue([[fax_two valueForKey:@"direction"] isEqualToString:@"sent"]);
        XCTAssertTrue([[fax_two valueForKey:@"num_pages"] isEqualToString:@"3"]);
        XCTAssertTrue([[fax_two valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[fax_two valueForKey:@"is_test"] isEqualToString:@"true"]);
        XCTAssertTrue([[fax_two valueForKey:@"created_at"] isEqualToString:@"2015-09-02T11:28:02.000-05:00"]);
        XCTAssertTrue([[fax_two valueForKey:@"from_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_two valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[fax_two valueForKey:@"cost"] isEqualToString:@"21"]);
        XCTAssertTrue([[fax_two valueForKey:@"to_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_two valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_two valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_two valueForKey:@"error_message"] isEqualToString:@"null"]);
        
        XCTAssertTrue([[[fax_two valueForKey:@"recipients"] valueForKey:@"phone_number"] isEqualToString:@"+14141234567"]);
        XCTAssertTrue([[[fax_two valueForKey:@"recipients"] valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[[fax_two valueForKey:@"recipients"] valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[[fax_two valueForKey:@"recipients"] valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[[fax_two valueForKey:@"recipients"] valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[[fax_two valueForKey:@"recipients"] valueForKey:@"error_message"] isEqualToString:@"null"]);
        
        XCTAssertTrue([[[fax_two valueForKey:@"tags"] valueForKey:@"order_id"] isEqualToString:@"1234"]);
        
        NSDictionary* fax_three = [faxes objectAtIndex:0];
        
        XCTAssertTrue([[fax_three valueForKey:@"id"] isEqualToString:@"1234"]);
        XCTAssertTrue([[fax_three valueForKey:@"direction"] isEqualToString:@"sent"]);
        XCTAssertTrue([[fax_three valueForKey:@"num_pages"] isEqualToString:@"3"]);
        XCTAssertTrue([[fax_three valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[fax_three valueForKey:@"is_test"] isEqualToString:@"true"]);
        XCTAssertTrue([[fax_three valueForKey:@"created_at"] isEqualToString:@"2015-09-02T11:28:02.000-05:00"]);
        XCTAssertTrue([[fax_three valueForKey:@"from_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_three valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[fax_three valueForKey:@"cost"] isEqualToString:@"21"]);
        XCTAssertTrue([[fax_three valueForKey:@"to_number"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_three valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_three valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[fax_three valueForKey:@"error_message"] isEqualToString:@"null"]);
        
        XCTAssertTrue([[[fax_three valueForKey:@"recipients"] valueForKey:@"phone_number"] isEqualToString:@"+14141234567"]);
        XCTAssertTrue([[[fax_three valueForKey:@"recipients"] valueForKey:@"status"] isEqualToString:@"success"]);
        XCTAssertTrue([[[fax_three valueForKey:@"recipients"] valueForKey:@"completed_at"] isEqualToString:@"2015-09-02T11:28:54.000-05:00"]);
        XCTAssertTrue([[[fax_three valueForKey:@"recipients"] valueForKey:@"error_id"] isEqualToString:@"null"]);
        XCTAssertTrue([[[fax_three valueForKey:@"recipients"] valueForKey:@"error_type"] isEqualToString:@"null"]);
        XCTAssertTrue([[[fax_three valueForKey:@"recipients"] valueForKey:@"error_message"] isEqualToString:@"null"]);
        
        XCTAssertTrue([[[fax_three valueForKey:@"tags"] valueForKey:@"order_id"] isEqualToString:@"1234"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testCreatePhaxCode500
{
    serverRespondExpectation = [self expectationWithDescription:@"Create Phax Code"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phaxio createPhaxCodeWithMetadata:@""];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testCreatePhaxCodeSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Create Phax Code"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@phax_codes", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Phax code successfully created" forKey:@"message"];
        [dictionary setValue:@"image" forKey:@"data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio createPhaxCodeWithMetadata:@""];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) createPhaxio:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Phax code successfully created"]);
        XCTAssertTrue([[json valueForKey:@"data"] isEqualToString:@"image"]);

    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testRetrievePhaxCode500
{
    serverRespondExpectation = [self expectationWithDescription:@"Retrieve Phax Code"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phaxio retrievePhaxCodeWithID:@""];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testRetrievePhaxCodeSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Retrieve Phax Code"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@phax_code/1234?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Phax code successfully retrieved" forKey:@"message"];
        [dictionary setValue:@"image" forKey:@"data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio retrievePhaxCodeWithID:@"1234"];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) retrievePhaxCode:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Phax code successfully retrieved"]);
        XCTAssertTrue([[json valueForKey:@"data"] isEqualToString:@"image"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioPhoneNumber500
{
    serverRespondExpectation = [self expectationWithDescription:@"Get Phone Number"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phaxio getPhoneNumber:@"123-456-7890"];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioPhoneNumberSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Get Phone Number"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@phone_numbers/1234567890?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setValue:@"+18475551234" forKey:@"phone_number"];
        [dataDictionary setValue:@"Northbrook" forKey:@"city"];
        [dataDictionary setValue:@"Illinois" forKey:@"state"];
        [dataDictionary setValue:@"United States" forKey:@"country"];
        [dataDictionary setValue:@"200" forKey:@"cost"];
        [dataDictionary setValue:@"2016-05-10T11:38:15.000-05:00" forKey:@"last_billed_at"];
        [dataDictionary setValue:@"2016-03-10T11:38:15.000-06:00" forKey:@"provisioned_at"];
        [dataDictionary setValue:@"www.callbackurl.com" forKey:@"callback_url"];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Retrieved user phone numbers successfully" forKey:@"message"];
        [dictionary setObject:dataDictionary forKey:@"data"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio getPhoneNumber:@"1234567890"];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) getNumberInfo:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"phone_number"] isEqualToString:@"+18475551234"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"city"] isEqualToString:@"Northbrook"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"state"] isEqualToString:@"Illinois"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"country"] isEqualToString:@"United States"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"last_billed_at"] isEqualToString:@"2016-05-10T11:38:15.000-05:00"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"provisioned_at"] isEqualToString:@"2016-03-10T11:38:15.000-06:00"]);
        XCTAssertTrue([[[json valueForKey:@"data"] valueForKey:@"callback_url"] isEqualToString:@"www.callbackurl.com"]);

    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioListPhoneNumbers500
{
    serverRespondExpectation = [self expectationWithDescription:@"List Phone Numbers"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phaxio listPhoneNumbersWithCountryCode:@"1" areaCode:@"515"];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioListPhoneNumbersSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"List Phone Numbers"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@phone_numbers?country_code=1&area_code=515&api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* pagingDictionary = [[NSMutableDictionary alloc] init];
        [pagingDictionary setObject:@"47" forKey:@"total"];
        [pagingDictionary setObject:@"3" forKey:@"per_page"];
        [pagingDictionary setObject:@"1" forKey:@"page"];
        
        NSMutableDictionary* numberDictionary = [[NSMutableDictionary alloc] init];
        [numberDictionary setValue:@"+18475551234" forKey:@"phone_number"];
        [numberDictionary setValue:@"Northbrook" forKey:@"city"];
        [numberDictionary setValue:@"Illinois" forKey:@"state"];
        [numberDictionary setValue:@"United States" forKey:@"country"];
        [numberDictionary setValue:@"200" forKey:@"cost"];
        [numberDictionary setValue:@"2016-05-10T11:38:15.000-05:00" forKey:@"last_billed_at"];
        [numberDictionary setValue:@"2016-03-10T11:38:15.000-06:00" forKey:@"provisioned_at"];
        [numberDictionary setValue:@"www.callbackurl.com" forKey:@"callback_url"];
        
        NSMutableDictionary* numberDictionary2 = [[NSMutableDictionary alloc] init];
        [numberDictionary2 setValue:@"+18475555678" forKey:@"phone_number"];
        [numberDictionary2 setValue:@"Ames" forKey:@"city"];
        [numberDictionary2 setValue:@"Iowa" forKey:@"state"];
        [numberDictionary2 setValue:@"United States" forKey:@"country"];
        [numberDictionary2 setValue:@"200" forKey:@"cost"];
        [numberDictionary2 setValue:@"2016-05-10T11:38:15.000-07:00" forKey:@"last_billed_at"];
        [numberDictionary2 setValue:@"2016-03-10T11:38:15.000-08:00" forKey:@"provisioned_at"];
        [numberDictionary2 setValue:@"www.callbackurl2.com" forKey:@"callback_url"];
        
        NSMutableArray* numberArray = [[NSMutableArray alloc] init];
        [numberArray addObject:numberDictionary];
        [numberArray addObject:numberDictionary2];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Retrieved user phone numbers successfully" forKey:@"message"];
        [dictionary setObject:numberArray forKey:@"data"];
        [dictionary setObject:pagingDictionary forKey:@"paging"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio listPhoneNumbersWithCountryCode:@"1" areaCode:@"515"];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}


-(void) listNumbers:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Retrieved user phone numbers successfully"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"total"] isEqualToString:@"47"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"per_page"] isEqualToString:@"3"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"page"] isEqualToString:@"1"]);
        
        NSArray* numbers = [json valueForKey:@"data"];
        
        XCTAssertTrue([numbers count] == 2);
        
        NSDictionary* phone_number_one = [numbers objectAtIndex:0];
        
        XCTAssertTrue([[phone_number_one valueForKey:@"phone_number"] isEqualToString:@"+18475551234"]);
        XCTAssertTrue([[phone_number_one valueForKey:@"city"] isEqualToString:@"Northbrook"]);
        XCTAssertTrue([[phone_number_one valueForKey:@"state"] isEqualToString:@"Illinois"]);
        XCTAssertTrue([[phone_number_one valueForKey:@"country"] isEqualToString:@"United States"]);
        XCTAssertTrue([[phone_number_one valueForKey:@"last_billed_at"] isEqualToString:@"2016-05-10T11:38:15.000-05:00"]);
        XCTAssertTrue([[phone_number_one valueForKey:@"provisioned_at"] isEqualToString:@"2016-03-10T11:38:15.000-06:00"]);
        XCTAssertTrue([[phone_number_one valueForKey:@"callback_url"] isEqualToString:@"www.callbackurl.com"]);
        
        NSDictionary* phone_number_two = [numbers objectAtIndex:1];
        
        XCTAssertTrue([[phone_number_two valueForKey:@"phone_number"] isEqualToString:@"+18475555678"]);
        XCTAssertTrue([[phone_number_two valueForKey:@"city"] isEqualToString:@"Ames"]);
        XCTAssertTrue([[phone_number_two valueForKey:@"state"] isEqualToString:@"Iowa"]);
        XCTAssertTrue([[phone_number_two valueForKey:@"country"] isEqualToString:@"United States"]);
        XCTAssertTrue([[phone_number_two valueForKey:@"last_billed_at"] isEqualToString:@"2016-05-10T11:38:15.000-07:00"]);
        XCTAssertTrue([[phone_number_two valueForKey:@"provisioned_at"] isEqualToString:@"2016-03-10T11:38:15.000-08:00"]);
        XCTAssertTrue([[phone_number_two valueForKey:@"callback_url"] isEqualToString:@"www.callbackurl2.com"]);
        
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioListAreaCodes500
{
    serverRespondExpectation = [self expectationWithDescription:@"List Area Codes"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];

    [phaxio listAreaCodesAvailableForPurchasingNumbersWithTollFree:@"" countryCode:@"" country:@"" state:@""];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioListAreaCodesSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"List Area Codes"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@public/area_codes?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary* pagingDictionary = [[NSMutableDictionary alloc] init];
        [pagingDictionary setObject:@"47" forKey:@"total"];
        [pagingDictionary setObject:@"3" forKey:@"per_page"];
        [pagingDictionary setObject:@"1" forKey:@"page"];
        
        NSMutableDictionary* areaCodeDictionary = [[NSMutableDictionary alloc] init];
        [areaCodeDictionary setValue:@"1" forKey:@"country_code"];
        [areaCodeDictionary setValue:@"201" forKey:@"area_code"];
        [areaCodeDictionary setValue:@"Bayonne, Jersey City, Union City" forKey:@"city"];
        [areaCodeDictionary setValue:@"New Jersey" forKey:@"state"];
        [areaCodeDictionary setValue:@"United States" forKey:@"country"];
        [areaCodeDictionary setValue:@"false" forKey:@"toll_free"];
     
        NSMutableDictionary* areaCodeDictionary2 = [[NSMutableDictionary alloc] init];
        [areaCodeDictionary2 setValue:@"1" forKey:@"country_code"];
        [areaCodeDictionary2 setValue:@"202" forKey:@"area_code"];
        [areaCodeDictionary2 setValue:@"Washington" forKey:@"city"];
        [areaCodeDictionary2 setValue:@"District of Columbia" forKey:@"state"];
        [areaCodeDictionary2 setValue:@"United States" forKey:@"country"];
        [areaCodeDictionary2 setValue:@"false" forKey:@"toll_free"];
        
        NSMutableDictionary* areaCodeDictionary3 = [[NSMutableDictionary alloc] init];
        [areaCodeDictionary3 setValue:@"1" forKey:@"country_code"];
        [areaCodeDictionary3 setValue:@"203" forKey:@"area_code"];
        [areaCodeDictionary3 setValue:@"Bridgeport, Danbury, Meriden" forKey:@"city"];
        [areaCodeDictionary3 setValue:@"Connecticut" forKey:@"state"];
        [areaCodeDictionary3 setValue:@"United States" forKey:@"country"];
        [areaCodeDictionary3 setValue:@"true" forKey:@"toll_free"];
        
        NSMutableArray* numberArray = [[NSMutableArray alloc] init];
        [numberArray addObject:areaCodeDictionary];
        [numberArray addObject:areaCodeDictionary2];
        [numberArray addObject:areaCodeDictionary3];
        
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Data contains found available area codes" forKey:@"message"];
        [dictionary setObject:numberArray forKey:@"data"];
        [dictionary setObject:pagingDictionary forKey:@"paging"];
        
        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];

    [phaxio listAreaCodesAvailableForPurchasingNumbersWithTollFree:@"" countryCode:@"" country:@"" state:@""];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) listAreaCodes:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Data contains found available area codes"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"total"] isEqualToString:@"47"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"per_page"] isEqualToString:@"3"]);
        XCTAssertTrue([[[json valueForKey:@"paging"] valueForKey:@"page"] isEqualToString:@"1"]);
        
        NSArray* numbers = [json valueForKey:@"data"];
        
        XCTAssertTrue([numbers count] == 3);
        
        NSDictionary* area_code_one = [numbers objectAtIndex:0];
        
        XCTAssertTrue([[area_code_one valueForKey:@"country_code"] isEqualToString:@"1"]);
        XCTAssertTrue([[area_code_one valueForKey:@"area_code"] isEqualToString:@"201"]);
        XCTAssertTrue([[area_code_one valueForKey:@"city"] isEqualToString:@"Bayonne, Jersey City, Union City"]);
        XCTAssertTrue([[area_code_one valueForKey:@"state"] isEqualToString:@"New Jersey"]);
        XCTAssertTrue([[area_code_one valueForKey:@"country"] isEqualToString:@"United States"]);
        XCTAssertTrue([[area_code_one valueForKey:@"toll_free"] isEqualToString:@"false"]);

        NSDictionary* area_code_two = [numbers objectAtIndex:1];
        
        XCTAssertTrue([[area_code_two valueForKey:@"country_code"] isEqualToString:@"1"]);
        XCTAssertTrue([[area_code_two valueForKey:@"area_code"] isEqualToString:@"202"]);
        XCTAssertTrue([[area_code_two valueForKey:@"city"] isEqualToString:@"Washington"]);
        XCTAssertTrue([[area_code_two valueForKey:@"state"] isEqualToString:@"District of Columbia"]);
        XCTAssertTrue([[area_code_two valueForKey:@"country"] isEqualToString:@"United States"]);
        XCTAssertTrue([[area_code_two valueForKey:@"toll_free"] isEqualToString:@"false"]);
   
        NSDictionary* area_code_three = [numbers objectAtIndex:2];
        
        XCTAssertTrue([[area_code_three valueForKey:@"country_code"] isEqualToString:@"1"]);
        XCTAssertTrue([[area_code_three valueForKey:@"area_code"] isEqualToString:@"203"]);
        XCTAssertTrue([[area_code_three valueForKey:@"city"] isEqualToString:@"Bridgeport, Danbury, Meriden"]);
        XCTAssertTrue([[area_code_three valueForKey:@"state"] isEqualToString:@"Connecticut"]);
        XCTAssertTrue([[area_code_three valueForKey:@"country"] isEqualToString:@"United States"]);
        XCTAssertTrue([[area_code_three valueForKey:@"toll_free"] isEqualToString:@"true"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (void)testPhaxioDeleteFaxFile500
{
    serverRespondExpectation = [self expectationWithDescription:@"Delete Fax File"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqualToString:@"api.phaxio.com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary* dictionary = [[NSDictionary alloc] init];
        NSData* data = [self httpBodyForParamsDictionary:dictionary];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:500 headers:nil];
    }];
    
    [phaxio deleteFaxFile:@""];
    
    passingTest = NO;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

- (void)testPhaxioDeleteFaxFileSuccess
{
    serverRespondExpectation = [self expectationWithDescription:@"Delete Fax File"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString* url = [NSString stringWithFormat:@"%@faxes/1234/file?api_key=key&api_secret=secret", api_url];
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setValue:@"true" forKey:@"success"];
        [dictionary setValue:@"Deleted files successfully!" forKey:@"message"];

        NSError* err;
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
        
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    [phaxio deleteFaxFile:@"1234"];
    
    passingTest = YES;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
}

-(void) deleteFaxFile:(BOOL)success andResponse:(NSDictionary *)json
{
    if (passingTest)
    {
        XCTAssertTrue(success);
        XCTAssertTrue([[json valueForKey:@"success"] isEqualToString:@"true"]);
        XCTAssertTrue([[json valueForKey:@"message"] isEqualToString:@"Deleted files successfully!"]);
    }
    else
    {
        XCTAssertFalse(success);
    }
    [serverRespondExpectation fulfill];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString* result = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (BOOL)verifyParameters:(NSMutableDictionary*)parameters forRequestBody:(NSString*)requestBody
{
    NSArray* keys = [parameters allKeys];
    for (int i = 0; i < [keys count]; i++)
    {
        NSString* key = [keys objectAtIndex:i];
        NSString* keyValuePair = [NSString stringWithFormat:@"%@=%@", key, [parameters valueForKey:key]];
        if (![requestBody containsString:keyValuePair]) {
            NSLog(@"Request body does not contain key value pair: %@.", keyValuePair);
            return NO;
        }
    }
    return YES;
}

@end
