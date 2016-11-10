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

@class Fax;
@protocol FaxDelegate <NSObject>

@optional
- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)cancelledFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)resentFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)deletedFax:(BOOL)success andResponse:(NSDictionary*)json;
- (void)contentFile:(BOOL)success andResponse:(NSDictionary*)json;
- (void)smallThumbnail:(BOOL)success andResponse:(NSDictionary*)json;
- (void)largeThumbnail:(BOOL)success andResponse:(NSDictionary*)json;

@required
@end

@interface Fax : NSObject <PhaxioAPIDelegate>
{
    PhaxioAPI* api;
    UIImage* small_thumbnail;
    UIImage* large_thumbnail;
    UIImage* content_file;
}

@property (nonatomic, retain) id <FaxDelegate> delegate;

-(id)initFax;

-(void)sendWithBatchDelay:(NSString*)batch_delay batchCollisionAvoidance:(NSString*) batch_collision_avoidance callbackUrl:(NSString*)callback_url cancelTimeout:(NSString*)cancel_timeout tag:(NSString*)tag tagValue:(NSString*)tag_value callerId:(NSString*)caller_id testFail:(NSString*)test_fail;

-(void)send;

-(void)cancel;

-(void)resend;

-(void)deleteFax;

-(UIImage*)contentFile;

-(UIImage*)smallThumbnail;

-(UIImage*)largeThumbnail;

@property (nonatomic, retain) NSMutableArray* to_phone_numbers;
@property (nonatomic, retain) NSString* fax_id;
@property (nonatomic, retain) NSString* file;
@property (nonatomic, retain) NSString* content_url;
@property (nonatomic, retain) NSString* header_text;

@end
