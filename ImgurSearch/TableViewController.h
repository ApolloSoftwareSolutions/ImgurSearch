//
//  TableViewController.h
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgurSearch-Swift.h"

@interface TableViewController : UITableViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshCtl;

- (IBAction)selectWindow:(id)sender;
- (IBAction)searchButton:(id)sender;
- (IBAction)selectSort:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (nonatomic, strong) NSArray *imgResults;
@property (nonatomic, strong) IBOutlet UITextField *searchBox;

@end

