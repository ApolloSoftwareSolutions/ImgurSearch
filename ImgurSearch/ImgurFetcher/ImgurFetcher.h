//
//  ImgurFetcher.h
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImgurSearch-Bridging-Header.h"
#import "ImgurSearch-Swift.h"
#define OPENING_MESSAGE     @"Please input image search criteria, and select sort and window."
#define IMG_SEARCH_URL      @"https://api.imgur.com/3/gallery/search*sort**window**page*?q=*search*"
#define CLIENT_ID           @"Client-ID 66cf6e2211673ff"
#define ERROR_MESSAGE      @"You must enter more than 2 characters to search for an image."
#define SAVE_MESSAGE        @"Image Saved to Camera Roll."
#define SCREENSHOT_MESSAGE  @"Screenshot Saved to Camera Roll."
#define IMG_ITEMS           @"data"
#define IMG_IMAGES          @"images"
#define IMG_ACCT_ID         @"account_id"
#define IMG_ACCT_URL        @"account_url"
#define IMG_ACCT_TITLE      @"account_title"
#define IMG_ACCT_DATETIME   @"datetime"
#define IMG_ID              @"id"
#define IMG_ACCT_IMG_COUNT  @"images_count"
#define IMG_LINK            @"link"
#define IMG_NSFW            @"nsfw"
#define IMG_TITLE           @"title"
#define IMG_TOPIC           @"topic"
#define IMG_VIEWS           @"views"
#define IMG_COVER           @"cover"
#define DEFAULT_WINDOW      @"/month"
#define DEFAULT_SORT        @"/viral"

@interface ImgurFetcher : NSObject

+ (NSDictionary *)executeImgurSearch:(NSString *)searchVal sort:(NSString *)sortVal window:(NSString *)windowVal page:(NSString *)pageVal;
+ (NSArray *)searchImgur:(NSString*) searchVal;
+ (NSDictionary *)getMoreInfo:(NSArray *)user atIndex:(NSUInteger)index;
+ (void)setSearchCriteria:(NSString *)searchCriteria;
+ (void)setSort:(NSString *)sort_;
+ (void)setWindow:(NSString *)window_;
+ (NSString *) fetchSearchCriteria;
+ (NSString *) fetchSort;
+ (NSString *) fetchWindow;
@end
