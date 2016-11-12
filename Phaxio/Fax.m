//
//  Fax.m
//  Phaxio
//
//  Created by Nick Schulze on 11/5/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import "Fax.h"

@implementation Fax

@synthesize to_phone_numbers;
@synthesize fax_id;
@synthesize file;
@synthesize content_url;
@synthesize header_text;

-(id)initFax
{
    self = [super init];
    if (self)
    {
        api = [[PhaxioAPI alloc] init];
        [api setDelegate:self];
    }
    return self;
}

-(void)send
{
    [self sendWithBatchDelay:nil batchCollisionAvoidance:nil callbackUrl:nil cancelTimeout:nil tag:nil tagValue:nil callerId:nil testFail:nil];
}

-(void)sendWithBatchDelay:(NSInteger*)batch_delay batchCollisionAvoidance:(BOOL) batch_collision_avoidance callbackUrl:(NSString*)callback_url cancelTimeout:(NSInteger*)cancel_timeout tag:(NSString*)tag tagValue:(NSString*)tag_value callerId:(NSString*)caller_id testFail:(NSString*)test_fail
{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    
    if (to_phone_numbers == nil)
    {
        //error
    }
    
    if (file == nil && content_url == nil)
    {
        //error
    }
    
    if ([to_phone_numbers count] == 1)
    {
        [parameters setValue:[to_phone_numbers objectAtIndex:0] forKey:@"to"];
    }
    else
    {
        NSString* toNumbers = [to_phone_numbers objectAtIndex:0];
        for (int i = 1; i < [to_phone_numbers count]; i++)
        {
            toNumbers = [NSString stringWithFormat:@"%@,%@", toNumbers, [to_phone_numbers objectAtIndex:i]];
        }
        [parameters setValue:toNumbers forKey:@"to[]"];
    }

    if (file != nil)
    {
        [parameters setValue:file forKey:@"file"];
    }
    
    if (content_url != nil)
    {
        [parameters setValue:content_url forKey:@"content_url"];
    }
    
    if (header_text != nil)
    {
        [parameters setValue:header_text forKey:@"header_text"];
    }
    
    if (batch_delay != nil)
    {
        [parameters setValue:[NSString stringWithFormat:@"%ld",*batch_delay] forKey:@"batch_delay"];
    }
    
    if (batch_collision_avoidance)
    {
        [parameters setValue:@"true" forKey:@"batch_collision_avoidance"];
    }
    
    if (callback_url != nil)
    {
        [parameters setValue:callback_url forKey:@"callback_url"];
    }
    
    if (cancel_timeout != nil)
    {
        [parameters setValue:[NSString stringWithFormat:@"%ld", *cancel_timeout] forKey:@"cancel_timeout"];
    }
    
    if (tag != nil)
    {
        [parameters setValue:tag forKey:@"tag"];
    }
    
    if (caller_id != nil)
    {
        [parameters setValue:caller_id forKey:@"caller_id"];
    }
    
    if (test_fail != nil)
    {
        [parameters setValue:test_fail forKey:@"test_fail"];
    }
    
    [api createAndSendFaxWithParameters:parameters];
}

-(void)cancel
{
    [api cancelFax:fax_id];
}

-(void)resend
{
    [api resendFax:fax_id];
}

-(void)deleteFax
{
    [api deleteFaxWithID:fax_id];
}

-(NSData*)contentFile
{
    if (content_file == nil)
    {
        [api getFaxContentFileWithID:fax_id];
        return nil;
    }
    return content_file;
}

-(UIImage*)smallThumbnail
{
    if (small_thumbnail == nil)
    {
        [api getFaxContentThumbnailSmallWithID:fax_id];
        return nil;
    }
    return small_thumbnail;
}

-(UIImage*)largeThumbnail
{
    if (large_thumbnail == nil)
    {
        [api getFaxContentThumbnailLargeWithID:fax_id];
        return nil;
    }
    return large_thumbnail;
}

- (void)sentFax:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] sentFax:success andResponse:json];
}

- (void)cancelledFax:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] cancelledFax:success andResponse:json];
}

- (void)resentFax:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] resentFax:success andResponse:json];
}

- (void)deleteFax:(BOOL)success andResponse:(NSDictionary*)json
{
    [[self delegate] deletedFax:success andResponse:json];
}

- (void)contentFile:(BOOL)success andResponse:(NSData*)content
{
    if (success) {
        content_file = content;
    }
    [[self delegate] contentFile:success andResponse:content_file];
}

- (void)smallThumbnail:(BOOL)success andResponse:(UIImage*)img
{
    if (success) {
       small_thumbnail = img;
    }
    [[self delegate] smallThumbnail:success andResponse:img];
}

- (void)largeThumbnail:(BOOL)success andResponse:(UIImage*)img
{
    if (success) {
        large_thumbnail = img;
    }
    [[self delegate] largeThumbnail:success andResponse:img];
}

@end
