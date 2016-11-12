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
- (void)contentFile:(BOOL)success andResponse:(NSData*)data;
- (void)smallThumbnail:(BOOL)success andResponse:(UIImage*)img;
- (void)largeThumbnail:(BOOL)success andResponse:(UIImage*)img;

@required
@end

@interface Fax : NSObject <PhaxioAPIDelegate>
{
    PhaxioAPI* api;
    UIImage* small_thumbnail;
    UIImage* large_thumbnail;
    NSData* content_file;
}

@property (nonatomic, retain) id <FaxDelegate> delegate;

-(id)initFax;

-(void)sendWithBatchDelay:(NSInteger*)batch_delay batchCollisionAvoidance:(BOOL) batch_collision_avoidance callbackUrl:(NSString*)callback_url cancelTimeout:(NSInteger*)cancel_timeout tag:(NSString*)tag tagValue:(NSString*)tag_value callerId:(NSString*)caller_id testFail:(NSString*)test_fail;

-(void)send;

-(void)cancel;

-(void)resend;

-(void)deleteFax;

-(NSData*)contentFile;

-(UIImage*)smallThumbnail;

-(UIImage*)largeThumbnail;

@property (nonatomic, retain) NSMutableArray* to_phone_numbers;
@property (nonatomic, retain) NSString* fax_id;
@property (nonatomic, retain) NSData* file;
@property (nonatomic, retain) NSString* content_url;
@property (nonatomic, retain) NSString* header_text;

@end
