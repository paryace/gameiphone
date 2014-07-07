//
//  OpenImgViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "OpenImgViewController.h"

@interface OpenImgViewController ()
{
    UIImageView *splashImageView;
}
@end

@implementation OpenImgViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    splashImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    splashImageView.image = [[UserManager singleton] getOpenImage];
    [[TempData sharedInstance]ChangeShowOpenImg:NO];
    [self.view addSubview:splashImageView];
    [self performSelector:@selector(showLoading:) withObject:nil afterDelay:2];

}
-(void)showLoading:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
