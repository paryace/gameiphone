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
    
    
    m_myTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, startX+20, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.bounces = NO;
    m_myTableView.backgroundColor = [UIColor colorWithRed:200/225.0f green:200/225.0f blue:200/225.0f alpha:1];
    [self.view addSubview:m_myTableView];
    self.view.backgroundColor = [UIColor colorWithRed:200/225.0f green:200/225.0f blue:200/225.0f alpha:1];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(assa) name:@"testasdasdfasfsSoundOn_wx" object:nil];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        default:
            return 2;
            break;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndef = @"cell";
    UITableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:cellIndef];;
    if (cell ==nil) {
        cell =[[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndef];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(indexPath.section ==0)
        {
            cell.textLabel.text =@"通知不显示消息内容";
            UISwitch *soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-80, 5, 60, 30)];
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_userInfo_off"]) {
                soundSwitch.on = NO;
            }else{
                soundSwitch.on = YES;
            }
            [soundSwitch addTarget:self action:@selector(infomationAccording:) forControlEvents:UIControlEventValueChanged];

             [cell.contentView addSubview:soundSwitch];
        }
        else if (indexPath.section ==1){//声音和振动
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
    }
    return cell;

}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
     view.backgroundColor = [UIColor colorWithRed:200/225.0f green:200/225.0f blue:200/225.0f alpha:1];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 50)];
    label.backgroundColor = [UIColor colorWithRed:200/225.0f green:200/225.0f blue:200/225.0f alpha:1];
    label.textColor = [UIColor grayColor];
    label.numberOfLines =2;
    switch (section) {
          case 0:
            label.text = @"开启后,当收到陌游通知时,通知提示将不显示发信人和内容摘要。";
            break;
        case 1:
            label.text = @"当陌游在运行时,你可以设置是否需要声音或者振动。";
            break;
        default:
            break;
    }
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
        [self getSoundsWithNetWithcode:@"0"];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"wx_sounds_open" object:nil];
        [self getSoundsWithNetWithcode:@"1"];
    }
    
}

-(void)infomationAccording:(UISwitch*)sender
{
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"wx_userInfo_off" object:nil];
        [self getPushInfoWithNetWithcode:@"1"];

    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wx_userInfo_off"];
         [self getPushInfoWithNetWithcode:@"0"];
    }
}

-(void)getSoundsWithNetWithcode:(NSString*)str
{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    [tempDic setObject:str forKey:@"state"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"178" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    [postDict setObject:tempDic forKey:@"params"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];

}

-(void)getPushInfoWithNetWithcode:(NSString*)str
{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    [tempDic setObject:str forKey:@"state"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"179" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    [postDict setObject:tempDic forKey:@"params"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
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
