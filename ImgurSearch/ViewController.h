//
//  ViewController.h
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgurFetcher.h"

@interface ViewController : UIViewController
- (IBAction)doRefresh:(id)sender;
- (IBAction)doEscape:(id)sender;
- (IBAction)doCompose:(id)sender;
@property (nonatomic) IBOutlet UIImageView *imgThumb;
@property (nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic) IBOutlet UILabel *lblBy;
@property (nonatomic) IBOutlet UILabel *lblDate;
@property (nonatomic) IBOutlet UILabel *lblID;
@property (nonatomic) IBOutlet UILabel *lblTopic;
@property (nonatomic) IBOutlet UILabel *lblViews;
@property (nonatomic) IBOutlet UILabel *lblImages;
@property (nonatomic) IBOutlet UILabel *lblNSFW;
@property (nonatomic) NSDictionary *image;
@property (nonatomic, strong) NSString *imageBody;
- (IBAction)shareButtonTest:(id)sender;
@end
