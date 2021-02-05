//
//  ImgurFetcher.m
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

#import "ImgurFetcher.h"

@implementation ImgurFetcher

NSString* _search = @"";
NSString* _sort = DEFAULT_SORT;
NSString* _window = DEFAULT_WINDOW;

bool isFinished = false;

+ (NSString *)fetchSearchCriteria {
    return _search;
}

+ (NSString *)fetchSort {
    return _sort;
}

+ (NSString *)fetchWindow {
    return _window;
}

+ (void)setSearchCriteria:(NSString *)searchCriteria {
    _search = searchCriteria;
}

+ (void)setWindow:(NSString *)window_ {
    _window = window_;
}

+ (void)setSort:(NSString *)sort{
    _sort = sort;
}

+ (void) callAPI_async: (NSString *)URL {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:0];
    NSURLSession *session = [NSURLSession sharedSession];
    [request setValue:CLIENT_ID forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    NSDictionary *res = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
                                                    
                                                    if (error)
                                                        NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
                                                    
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self search_completed:res];
                                                    });
                                                }];
    [dataTask resume];
}
NSDictionary *results_;
+ (void) search_completed:(NSDictionary *) results {
    results_ = results;
    isFinished = true;
}

+ (NSDictionary *)executeImgFetch:(NSString *)URL {
    NSLog(@"fetching %@", URL);
    [self callAPI_async:URL];
    do {
        if (isFinished) {
            isFinished = false;
            return results_;
        }
    }
    while(1);
    return results_;
}


+ (NSDictionary *)
    executeImgurSearch:(NSString *)searchVal
    sort:(NSString *)sortVal
    window:(NSString *)windowVal
    page:(NSString *)pageVal
{
    searchVal = [searchVal stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    sortVal = [sortVal stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    windowVal = [windowVal stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    pageVal = [pageVal stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString* searchString = [IMG_SEARCH_URL stringByReplacingOccurrencesOfString:@"*search*" withString:searchVal];

    searchString = [searchString stringByReplacingOccurrencesOfString:@"*sort*" withString:sortVal];
    
    searchString = [searchString stringByReplacingOccurrencesOfString:@"*window*" withString:windowVal];
    
    searchString = [searchString stringByReplacingOccurrencesOfString:@"*page*" withString:pageVal];
    NSLog(@"Search String: %@\n", searchString);
    return [self executeImgFetch:searchString];
}


+ (NSArray *)searchImgur:(NSString*) searchVal {
    return [[self executeImgurSearch:searchVal
                                 sort:[self fetchSort]
                               window:[self fetchWindow]
                                 page:@""]
             valueForKeyPath:@"data"];
}

+ (NSDictionary *)getMoreInfo:(NSArray *)user atIndex:(NSUInteger)index {
    return [NSDictionary dictionaryWithDictionary:[user objectAtIndex:index]];
}

@end
