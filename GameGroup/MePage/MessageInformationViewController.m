//
//  MessageInformationViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-3-31.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MessageInformationViewController.h"

@interface MessageInformationViewController ()
{
    UITableView *m_myTableView;
}
@end

@implementation MessageInformationViewController

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
    
    [self setTopViewWithTitle:@"消息设置" withBackButton:YES];
    
    
    m_myTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndef = @"cell";
    UITableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:cellIndef];;
    if (cell ==nil) {
        cell =[[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndef];
        
        if (indexPath.section ==0) {
            cell.textLabel.text = @"声音";
            UISwitch *soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-80, 5, 60, 30)];
            soundSwitch.on = YES;//设置初始为ON的一边
            [soundSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:soundSwitch];
        }
        else{
            cell.textLabel.text = @"震动";
            UISwitch *soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-80, 5, 60, 30)];
            soundSwitch.on = YES;//设置初始为ON的一边
            [soundSwitch addTarget:self action:@selector(switchActionoff:) forControlEvents:UIControlEventValueChanged];

            [cell.contentView addSubview:soundSwitch];

        }
    }
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"testSoundOff_wx" object:nil];

}

-(void)switchAction:(UISwitch*)sender
{
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"testasdasdfasfsSoundOn_wx" object:nil];
        NSLog(@"12312132↓");
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"testSousadfasdfasfasfndOff_wx" object:nil];
         NSLog(@"12312132↑");
    }

}
-(void)switchActionoff:(UISwitch*)sender
{
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"asdfsadfasdfasdfasfsf" object:nil];
        NSLog(@"asdfasdfasf↓");
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"asdfasfasfdasfdasfasfsadf" object:nil];
        NSLog(@"asdfasdfasfdas↑");
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
