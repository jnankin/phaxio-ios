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
    
    //Initial setup with the api key and secret.
    [PhaxioAPI setAPIKey:@"thiskey" andSecret:@"thissecret"];
    
    //Phaxio account methods used to retrieve information relevant to the Phaxio account
    Phaxio* phaxio = [[Phaxio alloc] initPhaxio];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
