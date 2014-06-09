//
//  GroupListViewController.m
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupListViewController.h"

@interface GroupListViewController ()

@end

@implementation GroupListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群列表" withBackButton:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
