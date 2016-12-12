//
//  Fax.h
//  Phaxio
//
//  Created by Nick Schulze on 11/5/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhaxioAPI.h"
#import <UIKit/UIKit.h>

/**
 Fax class used for working with fax objects
 */
@class Fax;

/**
 Delegate class to handle Fax responses
 */
@protocol FaxDelegate <NSObject>

@optional
/**
 sent fax response
 
 @param success api response result
 
 @param json json response from api
 */
- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;

/**
 cancelled fax response
 
 @param success api response result
 
 @param json json response from api
 */
- (void)cancelledFax:(BOOL)success andResponse:(NSDictionary*)json;

/**
 resenet fax response
 
 @param success api response result
 
 @param json json response from api
 */
- (void)resentFax:(BOOL)success andResponse:(NSDictionary*)json;

/**
 deleted fax response
 
 @param success api response result
 
 @param json json response from api
 */
- (void)deletedFax:(BOOL)success andResponse:(NSDictionary*)json;

/**
 content file response
 
 @param success api response result
 
 @param data data response from api
 */
- (void)contentFile:(BOOL)success andResponse:(NSData*)data;

/**
 small thumbnail response
 
 @param success api response result
 
 @param img image response from api
 */
- (void)smallThumbnail:(BOOL)success andResponse:(UIImage*)img;

/**
 large thumbnail response
 
 @param success api response result
 
 @param img image response from api
 */
- (void)largeThumbnail:(BOOL)success andResponse:(UIImage*)img;

@required
@end

@interface Fax : NSObject <PhaxioAPIDelegate>
{
    /**
     Used to hit the api endpoints
     */
    PhaxioAPI* api;
    /**
     Stores the small thumbnail after it's been retrieved
     */
    UIImage* small_thumbnail;
    /**
     Stores the large thumbnail after it's been retrieved
     */
    UIImage* large_thumbnail;
    /**
     Stores the content file after it's been retrieved
     */
    NSData* content_file;
}

/**
 Used to relay the api response
 */
@property (nonatomic, retain) id <FaxDelegate> delegate;

/**
 The phone numbers the fax was sent to
 */
@property (nonatomic, retain) NSMutableArray* to_phone_numbers;

/**
 The id of the fax
 */
@property (nonatomic, retain) NSString* fax_id;

/**
 The file associated with the fax (a fax must have either a file or content_url)
 */
@property (nonatomic, retain) NSData* file;

/**
 The content url for the fax (a fax must have either a file or content_url)
 */
@property (nonatomic, retain) NSString* content_url;

/**
 Header text for the fax
 */
@property (nonatomic, retain) NSString* header_text;

/**
 Initializes a Fax object
 */
-(id)initFax;

/**
 Sends the fax with the given parameters, response is returned to the delegate method `- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;`
 
 @param batch_delay the amount of time, in seconds, before the batchis fired *optional*
 
 @param batch_collision_avoidance when batch_delay is set, fax will be blocked until machine is no longer busy *optional*
 
 @param callback_url override of default callback url *optional*
 
 @param cancel_timeout number of minutes after fax has been set, to be canceled if the fax has not yet been completed *optional*
 
 @param tag a tag containing metadata relevant to your application *optional*
 
 @param tag_value value of the metadata tag *optional*
 
 @param caller_id a phaxio phone number to be used for your caller id *optional*

 @param test_fail when using a test key, this will simulate a sending failure *optional*
 */
-(void)sendWithBatchDelay:(NSInteger*)batch_delay batchCollisionAvoidance:(BOOL) batch_collision_avoidance callbackUrl:(NSString*)callback_url cancelTimeout:(NSInteger*)cancel_timeout tag:(NSString*)tag tagValue:(NSString*)tag_value callerId:(NSString*)caller_id testFail:(NSString*)test_fail;

/**
 Sends the fax with the default parameters, response is returned to the delegate method `- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)send;

/**
 Cancels the fax, response is returned to the delegate method `- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)cancel;

/**
 Resends the fax, response is returned to the delegate method `- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)resend;

/**
 Deletes the fax, response is returned to the delegate method `- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;`
 */
-(void)deleteFax;

/**
 Retrieves the contentFile, it's returned is returned to the delegate method `- (void)contentFile:(BOOL)success andResponse:(NSData*)data;`
 */
-(NSData*)contentFile;

/**
 Retrieves the smallThumbnail, it's returned is returned to the delegate method `- (void)smallThumbnail:(BOOL)success andResponse:(NSData*)data;`
 */
-(UIImage*)smallThumbnail;

/**
 Retrieves the largeThumbnail, it's returned is returned to the delegate method `- (void)largeThumbnail:(BOOL)success andResponse:(NSData*)data;`
 */
-(UIImage*)largeThumbnail;

@end
