//
//  ViewController.m
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *WebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

@end

@implementation ViewController

/* For error handling for the Unknown and
 malformed JSON in topic */
- (void) viewDidAppear:(BOOL)animated {
    if (![self.image[IMG_ACCT_URL] description] ||
        [[[self.image[IMG_ACCT_URL] description]  description] isEqualToString:@"<null>"] ||
        [[self.image[IMG_ACCT_URL] description]  isEqualToString:@"Unknown"])
    {
        NSLog(@"<--- Missing ACCT URL -->");
        if (!self.image[IMG_COVER])
        {
            _imgThumb.image = [UIImage imageNamed: @"na_button.png"];
        }
            _lblTitle.text = [NSString stringWithFormat: @"Unavailable"];
            _lblID.text = [NSString stringWithFormat: @"Unavailable"];
            _lblTopic.text = [NSString stringWithFormat: @"Unavailable"];
            _lblViews.text =[NSString stringWithFormat: @""];
            _lblImages.text = [NSString stringWithFormat: @""];
            
            if ([self.image[IMG_NSFW] integerValue]>0)
            {
                _lblNSFW.text = [NSString stringWithFormat: @""];
            } else
            {
                _lblNSFW.text = [NSString stringWithFormat: @""];
            }
            _lblDate.text = [NSString stringWithFormat: @"Unavailable"];;
            _lblBy.text = [NSString stringWithFormat: @"Unknown"];
    }
}

- (void) setImage:(NSDictionary *)image {
    _image = image;
    [self updateUI];
}
- (void) setImageNull:(NSDictionary *)image {
    _image = image;
    if (self.image) {
        [self.activitySpinner startAnimating];
        //[self setControls];
        [self.activitySpinner stopAnimating];
    } else {
        self.imageBody = nil;
    }
}

- (NSString *)imageBody {
    return _imageBody ? _imageBody : @"?";
}

- (void)downloadImage:(NSString *)url userid:(NSString *)uid {
    _imgThumb.image = [UIImage imageNamed: @"loading.png"];
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
                        [self loadImageBody];
                });
            
        }
        
    });
}

- (NSString *)grabImageFullPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,self.image[IMG_ACCT_URL],@"_full.jpg"];
}

- (void) setControls {
    _lblTitle.text = [NSString stringWithFormat: @"%@", self.image[IMG_TITLE]];
    //_lblDate.text = [NSString stringWithFormat: @"%@", [[ImgurHelper alloc] getDateTimeWith_ts:[self.image[IMG_ACCT_DATETIME] description]]];
    _lblBy.text = [NSString stringWithFormat: @"%@", self.image[IMG_ACCT_URL]];
    _lblID.text = [NSString stringWithFormat: @"%@", self.image[IMG_ID]];
    _lblTopic.text = [NSString stringWithFormat: @"%@", self.image[IMG_TOPIC]];
    _lblViews.text = [NSString stringWithFormat: @"%@", self.image[IMG_VIEWS]];
    _lblImages.text = [NSString stringWithFormat: @"%@", self.image[IMG_ACCT_IMG_COUNT]];
    
    if ([self.image[IMG_NSFW] integerValue]>0)
    {
        _lblNSFW.text = [NSString stringWithFormat: @"NSFW"];
    } else
    {
        _lblNSFW.text = [NSString stringWithFormat: @""];
    }
}

- (void) grabImageInformation {
    if ([self.image[IMG_ACCT_URL] isEqualToString:@"Unknown"] ||
        [self.image[IMG_ACCT_URL] isEqualToString:@"<null>"])
    {
        NSLog(@"User is null returning -->");
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *fullImage = [NSString stringWithFormat:@"%@_full",self.image[IMG_ACCT_URL]];
    
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,self.image[IMG_ACCT_URL],@".jpg"];
    NSString *URLPath = [NSString stringWithFormat:@"https://i.imgur.com/%@b.jpg",self.image[IMG_COVER]];
    
    NSString  *filePathFull = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,self.image[IMG_ACCT_URL],@"_full.jpg"];
    NSString *URLPathFull = [NSString stringWithFormat:@"https://i.imgur.com/%@.jpg",self.image[IMG_COVER]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        if (self.image[IMG_COVER])
        {
            [self downloadImage:[NSString stringWithFormat:@"https://i.imgur.com/%@b.jpg",self.image[IMG_COVER]] userid:self.image[IMG_ACCT_URL]];
        }
    } else {
        NSLog(@"file: %@ exists",filePath);
        URLPath = [NSString stringWithFormat:@"%@",filePath];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePathFull])
    {
        if (self.image[IMG_COVER])
        {
            [self downloadImage:[NSString stringWithFormat:@"https://i.imgur.com/%@.jpg",self.image[IMG_COVER]] userid:fullImage];
        }
    } else {
        NSLog(@"full_file: %@ exists",filePathFull);
        URLPathFull = [NSString stringWithFormat:@"%@",filePathFull];
    }
    
    if (!URLPathFull) {
        NSLog(@"URL Path is null: %@",filePathFull);
        URLPathFull = [NSString stringWithFormat:@"https://i.imgur.com/%@b.jpg",self.image[IMG_COVER]];
    }
    
    if (!URLPath) {
        NSLog(@"URL Path is null: %@",filePath);
        URLPath = [NSString stringWithFormat:@"https://i.imgur.com/%@b.jpg",self.image[IMG_COVER]];
    }

    if (!self.image[IMG_COVER])
    {
        _imgThumb.image = [UIImage imageNamed: @"na_button.png"];
    } else {
        if ([self grabImageFullPath])
        [_imgThumb setImage:[UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL fileURLWithPath:[self grabImageFullPath]]]]];
        else if (filePath)
          [_imgThumb setImage:[UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL fileURLWithPath:filePath]]]];
    }
    NSLog(@"End of grabImageInformation -->");
}

- (void)loadImageBody {
    if (self.image) {
        [self.activitySpinner startAnimating];
        [self grabImageInformation];
        [self setControls];
        [self.activitySpinner stopAnimating];
    } else {
        self.imageBody = nil;
    }
}

- (void)updateUI {
    self.navigationItem.title = self.image[IMG_ACCT_URL];
    [self loadImageBody];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        if (completed) {
            NSString *msg = [NSString stringWithFormat:@"Successfully shared to %@", activityType];
            [self throwMessage:msg];
        }
        
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}

-(NSData *)getImageFromView:(UIView *)view {
    NSData *pngImg;
    CGFloat max, scale = 1.0;
    CGSize viewSize = [view bounds].size;
    
    CGSize size = [view sizeThatFits:CGSizeZero];
    
    max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
    if( max > 960 )
        scale = 960/max;
    
    UIGraphicsBeginImageContextWithOptions( size, YES, scale );
    
    [view setFrame: CGRectMake(0, 0, size.width, size.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    pngImg = UIImagePNGRepresentation( UIGraphicsGetImageFromCurrentImageContext() );
    
    UIGraphicsEndImageContext();
    return pngImg;
}

- (IBAction)shareButtonTest:(id)sender {
    NSLog(@"Sharing Data");
    NSString *imagePath = [self grabImageFullPath];
    NSURL *imageUrl;
    NSString *fileName;
    if (imagePath)
    {
       imageUrl = [NSURL fileURLWithPath:imagePath];
    } else {
        NSData *compressedImage = [self getImageFromView:self.WebView];
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        fileName = [NSString stringWithFormat:@"%@.png",self.image[IMG_ACCT_URL]];
        imagePath = [docsPath stringByAppendingPathComponent:fileName];
        NSURL *imageUrl     = [NSURL fileURLWithPath:imagePath];
        
        [compressedImage writeToURL:imageUrl atomically:YES]; // save the file
    }
    if (!fileName){
        fileName = @"From Imgur:";
    }
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[ fileName, imageUrl ] applicationActivities:nil];

    [self presentActivityController:controller];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)doRefresh:(id)sender {
    [self updateUI];
}

- (IBAction)doEscape:(id)sender {
    
}

- (IBAction)doCompose:(id)sender {
    UIView *view = self.view;
    
    ImgurHelper *imgHelper = [ImgurHelper alloc];
    //[imgHelper captureScreenWithView:view];
    [self throwMessage:SCREENSHOT_MESSAGE];
}

- (void)throwMessage:(NSString *) message{
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:message  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
