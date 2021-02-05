//
//  TableViewController.m
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

#import "TableViewController.h"
#import "ImgurFetcher.h"
#import "ImgurController.h"

@interface TableViewController ()
@end

@implementation TableViewController

- (void)viewDidLoad {
    [_refreshCtl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    _searchBox.delegate = self;
    ImgurHelper *helper = [ImgurHelper alloc];
    //[self->_searchLabel setText:[helper getSearchStringWithSort:[ImgurFetcher fetchSort] window:[ImgurFetcher fetchWindow]]];
}

-(void) refreshView: (UIRefreshControl *) refresh{
    [ImgurFetcher setSearchCriteria:[_searchBox text]];
    [self searchImages:[ImgurFetcher fetchSearchCriteria]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [ImgurFetcher setSearchCriteria:[textField text]];
    [textField resignFirstResponder];
    [self searchImages:[ImgurFetcher fetchSearchCriteria]];
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    [ImgurFetcher setSearchCriteria:[textField text]];
    textField.text = @"";
    [textField resignFirstResponder];
    _imgResults = NULL;
    [self.tableView reloadData];
    return NO;
}

- (void)setImageResults:(NSArray *)imgResults {
    _imgResults = imgResults;
    [self.tableView reloadData];
}

- (void) searchImages: (NSString*) searchCriteria {
    if (searchCriteria.length > 2) {
        NSLog(@"%@ing %@", @"Search",searchCriteria);
        [ImgurFetcher setSearchCriteria:searchCriteria];
        
        [self.tableView reloadData];
        [self->_refreshCtl beginRefreshing];
        dispatch_queue_t imgSearch= dispatch_queue_create("imgSearch", NULL);
        dispatch_async(imgSearch, ^{
            NSArray *imgrSample = [ImgurFetcher searchImgur:searchCriteria];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImageResults:imgrSample];
                [self->_refreshCtl endRefreshing];
            });
        });
    } else {
        [self throwErrorMessage];
    }
}

- (IBAction)searchButton:(id)sender {
     [ImgurFetcher setSearchCriteria:[_searchBox text]];
    [self searchImages:[ImgurFetcher fetchSearchCriteria]];
    [_searchBox resignFirstResponder];
}

- (void)throwErrorMessage {
    [self->_refreshCtl endRefreshing];
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:ERROR_MESSAGE  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->_searchBox resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
           }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)downloadImage:(NSString *)url userid:(NSString *)uid index:(NSIndexPath *) idx {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started: %@",url);
        NSString *urlToDownload = url;
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData ) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,uid,@".jpg"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved: %@",filePath);

                NSArray *indexPaths = [[NSArray alloc] initWithObjects:idx, nil];
                [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    });
}

- (UIImage *)loadImage:(NSUInteger)row index:(NSIndexPath *) idx{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,[self.imgResults[row][IMG_ACCT_URL] description],@".jpg"];
    NSString *URLPath = [NSString stringWithFormat:@"https://i.imgur.com/%@b.jpg",[self.imgResults[row][IMG_COVER] description]];
   if ([[self.imgResults[row][IMG_ACCT_URL] description] isEqualToString:@"<null>"])
       return nil;
    
   if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        if ([self.imgResults[row][IMG_COVER] description])
        {
            [self downloadImage:[NSString stringWithFormat:@"https://i.imgur.com/%@b.jpg",[self.imgResults[row][IMG_COVER] description]] userid:[self.imgResults[row][IMG_ACCT_URL] description] index:idx];
        }
    } else {
        NSLog(@"file: %@ exists",filePath);
        URLPath = [NSString stringWithFormat:@"%@",filePath];
        return [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL fileURLWithPath:filePath]]];
    }
    
    if (!URLPath) {
        NSLog(@"URL Path is null: %@",filePath);
        URLPath = [NSString stringWithFormat:@"https://i.imgur.com/%@b.jpg",[self.imgResults[row][IMG_COVER] description]];
    }
    
    return[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL: [NSURL fileURLWithPath:URLPath]]];
}

- (NSString *)titleForRow:(NSUInteger)row {
    NSString *title= [NSString stringWithFormat:@""];
    
    if ([self.imgResults[row][IMG_TITLE] description])
    {
       title= [NSString stringWithFormat:@"%@",[self.imgResults[row][IMG_TITLE] description]];
    }
    return [NSString stringWithFormat:@"%@",title];
}

- (NSString *)subtitleForRow:(NSUInteger)row {
    NSString* images = [NSString stringWithFormat:@""];
    NSString* views = [NSString stringWithFormat:@"()"];
    
    ImgurHelper *helper = [ImgurHelper alloc];
    //NSString* dateTime = [helper getDateTimeWith_ts:
                         // [self.imgResults[row][IMG_ACCT_DATETIME] description]];
    
    NSString *acct_url= [NSString stringWithFormat:@"Invalid"];
    
    if ([self.imgResults[row][IMG_ACCT_URL] description])
    {
        acct_url= [NSString stringWithFormat:@"%@",[self.imgResults[row][IMG_ACCT_URL] description]];
    }
    if ([self.imgResults[row][IMG_ACCT_IMG_COUNT] description])
    {
        if ([[self.imgResults[row][IMG_ACCT_IMG_COUNT] description] integerValue] > 1)
        {
            images= [NSString stringWithFormat:@"%@ images",[self.imgResults[row][IMG_ACCT_IMG_COUNT] description]];
        } else {
            images= [NSString stringWithFormat:@"%@ image",[self.imgResults[row][IMG_ACCT_IMG_COUNT] description]];
        }
    }
    
    if ([[self.imgResults[row][IMG_VIEWS] description] integerValue] > 1)
    {
        views= [NSString stringWithFormat:@"(%@ views)",[self.imgResults[row][IMG_VIEWS] description]];
    } else {
        views= [NSString stringWithFormat:@"(%@ view)",[self.imgResults[row][IMG_VIEWS] description]];
    }
    
    if (!acct_url || [acct_url isEqualToString:@"<null>"])
    {
        acct_url = @"Unknown";
    }
    return [NSString stringWithFormat:@"by %@ on %@",acct_url, nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imgResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ImageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = [self loadImage:indexPath.row index:indexPath];
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    //[categoryArray removeObjectAtIndex:indexPath.row];
    if (![self.imgResults[indexPath.row][IMG_ACCT_URL] description] ||
        [[self.imgResults[indexPath.row][IMG_ACCT_URL] description] isEqualToString:@"<null>"] ||
        [[self.imgResults[indexPath.row][IMG_ACCT_URL] description] isEqualToString:@"Unknown"])
    {
        NSLog(@"Row has some null values as owners -> %ld row ",(long)indexPath.row);
        @try {

        } @catch (NSException *ex) {
            
        }
    }
    
    return cell;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
            @try {
                if (![self.imgResults[indexPath.row][IMG_ACCT_URL] description] ||
                    [[self.imgResults[indexPath.row][IMG_ACCT_URL] description] isEqualToString:@"<null>"] ||
                    [[self.imgResults[indexPath.row][IMG_ACCT_URL] description] isEqualToString:@"Unknown"])
                {
                    return;
                }
                if ([segue.identifier isEqualToString:@"ShowImage"]) {
                    if ([segue.destinationViewController respondsToSelector:@selector(setImage:)]) {
                        [segue.destinationViewController performSelector:@selector(setImage:) withObject:[ImgurFetcher getMoreInfo:self.imgResults atIndex:indexPath.row]];
                    }
                }
            } @catch (NSException *ex) {
                NSLog(@"Can't see this field!");
            }
    }
}

- (IBAction)selectSort:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
        message:@"Select Sort:"
        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *topAction = [UIAlertAction actionWithTitle:@"Top" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setSort:@"/top"];
        [self choiceSelected];
    }];
    UIAlertAction *viralAction = [UIAlertAction actionWithTitle:@"Viral" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setSort:@"/viral"];
        [self choiceSelected];
    }];
    UIAlertAction *timeAction = [UIAlertAction actionWithTitle:@"Time" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setSort:@"/time"];
        [self choiceSelected];
    }];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:topAction];
    [alert addAction:timeAction];
    [alert addAction:viralAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)selectWindow:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
        message:@"Select Window:"
        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *timeDay = [UIAlertAction actionWithTitle:@"Day" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setWindow:@"/day"];
        [self choiceSelected];
    }];
    UIAlertAction *timeWeek = [UIAlertAction actionWithTitle:@"Week" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setWindow:@"/week"];
       [self choiceSelected];
    }];
    UIAlertAction *timeMonth = [UIAlertAction actionWithTitle:@"Month" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setWindow:@"/month"];
        [self choiceSelected];
    }];
    UIAlertAction *timeYear = [UIAlertAction actionWithTitle:@"Year" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setWindow:@"/year"];
        [self choiceSelected];
    }];
    UIAlertAction *timeAll = [UIAlertAction actionWithTitle:@"All" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ImgurFetcher setWindow:@"/all"];
        [self choiceSelected];
    }];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:timeDay];
    [alert addAction:timeWeek];
    [alert addAction:timeYear];
    [alert addAction:timeMonth];
    [alert addAction:timeAll];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void) choiceSelected {
    ImgurHelper *helper = [ImgurHelper alloc];
   //[self->_searchLabel setText:[helper getSearchStringWithSort:[ImgurFetcher fetchSort] window:[ImgurFetcher fetchWindow]]];
    [ImgurFetcher setSearchCriteria:[ImgurFetcher fetchSearchCriteria]];
    [self searchImages:[ImgurFetcher fetchSearchCriteria]];
}
@end
