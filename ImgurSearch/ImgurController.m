//
//  ImgurController.m
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

#import "ImgurController.h"

@interface ImgurController ()

@end

@implementation ImgurController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBeginningAlert];
}

- (void)showBeginningAlert {
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:OPENING_MESSAGE  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
