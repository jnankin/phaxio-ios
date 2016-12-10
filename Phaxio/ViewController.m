//
//  ViewController.m
//  Phaxio
//
//  Created by Nick Schulze on 11/3/16.
//  Copyright © 2016 Phaxio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    //Initial setup with the api key and secret.
    [PhaxioAPI setAPIKey:@"key" andSecret:@"secret"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
