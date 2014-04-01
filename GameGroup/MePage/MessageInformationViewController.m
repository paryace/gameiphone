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
    m_myTableView.bounces = NO;
    [self.view addSubview:m_myTableView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(assa) name:@"testasdasdfasfsSoundOn_wx" object:nil];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndef = @"cell";
    UITableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:cellIndef];;
    if (cell ==nil) {
        cell =[[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndef];
        
        if (indexPath.row ==0) {
            cell.textLabel.text = @"声音";
            UISwitch *soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-80, 5, 60, 30)];
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"])
            {
                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"]intValue]==1) {
                    soundSwitch.on =YES;
                }else{
                    soundSwitch.on =NO;
                }
            }else{
                soundSwitch.on =YES;
            }

            [soundSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:soundSwitch];
        }
        else{
            cell.textLabel.text = @"震动";
            UISwitch *soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-80, 5, 60, 30)];
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"])
            {
                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"]intValue]==1) {
                    soundSwitch.on =YES;
                }else{
                    soundSwitch.on =NO;
                }
            }else{
                soundSwitch.on =YES;
            }

            [soundSwitch addTarget:self action:@selector(switchActionoff:) forControlEvents:UIControlEventValueChanged];

            [cell.contentView addSubview:soundSwitch];

        }
    }
    return cell;

}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
     view.backgroundColor = [UIColor colorWithRed:220/225.0f green:220/225.0f blue:220/225.0f alpha:1];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 50)];
    label.backgroundColor = [UIColor colorWithRed:220/225.0f green:220/225.0f blue:220/225.0f alpha:1];
    label.textColor = [UIColor grayColor];
    label.text = @"当陌游在运行时,你可以设置是否需要声音或者震动";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    [view addSubview:label];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}
-(void)switchAction:(UISwitch*)sender
{
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"wx_sounds_off" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"wx_sounds_open" object:nil];
    }
}
-(void)switchActionoff:(UISwitch*)sender
{
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"wx_vibration_off" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"wx_vibration_open" object:nil];
    }
}


-(void)assa
{
    NSLog(@"sdsfsfsf");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
