//
//  SetViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-20.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "SetViewController.h"
#import "NormalTableCell.h"
#import "EGOCache.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "FeedBackViewController.h"
#import "ShowTextViewController.h"
#import "ActivationCodeViewController.h"
#import "MessageInformationViewController.h"
#import "BlackListViewController.h"

@interface SetViewController ()
{
    UITableView*  m_myTableView;
    BOOL isOver;
    UIAlertView * huancunAlert;
    UIAlertView * upDataAlert;
    UIAlertView * loyOutalert;
}
@end

@implementation SetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"设置" withBackButton:YES];
    
    
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20)) style:UITableViewStyleGrouped];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    m_myTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:m_myTableView];
    UIView *topVIew = [[UIView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, 209)];
    topVIew.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    m_myTableView.tableHeaderView = topVIew;
    UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 165)];
    headImageView.image = KUIImage(@"head_me.jpg");
    [topVIew addSubview:headImageView];
    
    UILabel *banbenView = [[UILabel alloc]initWithFrame:CGRectMake(20, 165, 300, 44)];
    banbenView.backgroundColor = [UIColor clearColor];
    banbenView.text =[NSString stringWithFormat:@"当前版本:%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
    banbenView.textColor = UIColorFromRGBA(0x666666, 1);
    banbenView.font = [UIFont systemFontOfSize:16];
    [topVIew addSubview:banbenView];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.delegate = self;
    hud.labelText = @"清理中...";
    hud.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hud];
    
    
}

#pragma mark 表格
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 6;
            break;
        case 1:
            return 1;
            break;

        default:
            return 1;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    NormalTableCell *cell = (NormalTableCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NormalTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:
        {
            //            if (indexPath.row == 0) {
            //                cell.leftImageView.image = KUIImage(@"me_set_info");
            //                cell.titleLable.text = @"关于陌游";
            //            }
            //            else
            //            {
            //                cell.leftImageView.image = KUIImage(@"me_set_delete");
            //                cell.titleLable.text = @"清理缓存";
            //            }
            
            switch (indexPath.row) {
                case 0:
                    cell.leftImageView.image = KUIImage(@"clean_me");
                    cell.titleLable.text = @"清理缓存";
                    
                    break;
                case 1:
                    cell.leftImageView.image = KUIImage(@"updata_me");
                    cell.titleLable.text = @"检查更新";
                    
                    break;
                case 2:
                    cell.leftImageView.image = KUIImage(@"xieyi_me");
                    cell.titleLable.text = @"用户协议";
                    
                    break;
                case 3:
                    cell.leftImageView.image = KUIImage(@"feedback_me");
                    cell.titleLable.text = @"意见反馈";
                    
                    break;
                case 4:
                    cell.leftImageView.image = KUIImage(@"activationCode");
                    cell.titleLable.text = @"兑换码";
                    
                    break;
                  case 5:
                    cell.leftImageView.image = KUIImage(@"blacklist");
                    cell.titleLable.text = @"我的黑名单";
                default:
                    break;
            }
            
        } break;
        case 1:
        {
            cell.leftImageView.image = KUIImage(@"messageinfo");
            cell.titleLable.text = @"新消息提醒";
        } break;
        case 2:
        {
            cell.leftImageView.image = KUIImage(@"me_set_exit");
            cell.titleLable.text = @"退出登录";
        } break;

        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row ==0)
            {
                huancunAlert = [[UIAlertView alloc]initWithTitle:nil message:@"您确认要清除所有的缓存吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
                huancunAlert.tag = 110;
                [huancunAlert show];
            }
            else if (indexPath.row ==1)
            {
                if ([[NSUserDefaults standardUserDefaults]objectForKey:@"IOSURL"]==nil) {
                    [self showAlertViewWithTitle:nil message:@"您已经是最新版本了" buttonTitle:@"确定"];
                }else{
                    upDataAlert = [[UIAlertView alloc]initWithTitle:nil message:@"现在有新版本,是否更新?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    upDataAlert.tag = 111;
                    [upDataAlert show];
                }
                
            }
            else if (indexPath.row ==2)
            {
                ShowTextViewController *textView = [[ShowTextViewController alloc]init];
                textView.myViewTitle = @"用户协议";
                textView.fileName = @"protocol";
                [self.navigationController pushViewController:textView animated:YES];
            }
            else if (indexPath.row ==3)
            {
                FeedBackViewController* VC = [[FeedBackViewController alloc] init];
                [self.navigationController pushViewController:VC animated:YES];
            }
            else if (indexPath.row ==4)
            {
                ActivationCodeViewController* VC = [[ActivationCodeViewController alloc] init];
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                BlackListViewController *bl =[[BlackListViewController alloc]init];
                [self.navigationController pushViewController:bl animated:YES];
            }
            
        } break;
        case 1:
        {
            MessageInformationViewController *msVC = [[MessageInformationViewController alloc]init];
            [self.navigationController pushViewController:msVC animated:YES];
        }
            break;

        case 2:
        {
            loyOutalert = [[UIAlertView alloc]initWithTitle:nil message:@"您确认要退出登陆吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            loyOutalert.tag = 112;
            [loyOutalert show];
        } break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (110 == alertView.tag) {
            [hud showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
            dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
            dispatch_async(queue, ^{
                [[EGOCache globalCache] clearCache];
                // Set determinate mode
                // myProgressTask uses the HUD instance to update progress
                NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
                NSFileManager *fm = [NSFileManager defaultManager];
                NSDirectoryEnumerator *e = [fm enumeratorAtPath:cache];
                NSString *fileName = nil;
                while (fileName = [e nextObject]) {
                    NSError *error = nil;
                    NSString *filePath = [cache stringByAppendingPathComponent:fileName];
                    [fm removeItemAtPath:filePath error:&error];
                }

            });
        }
        else if(112 == alertView.tag)   //退出登陆
        {
            [self loginOutNet];
        }else if(111==alertView.tag)
        {
            if(buttonIndex==1){
            NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"IOSURL"]];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
            }
        }
    }
}

- (unsigned long long)fileSizeAtPath:(NSString*) filePath
{
    NSDictionary* attr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [[attr objectForKey:NSFileSize] unsignedLongLongValue];
}
- (void)loginOutNet
{
    //    XMPPHelper *xmppHelper = [[XMPPHelper alloc]init];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    //    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"102" forKey:@"method"];//退出登陆
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"layoutresponseObject%@", responseObject);
        // [GameCommon loginOut];//注销
        
        //[self.navigationController popViewControllerAnimated:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        
    }];
    [GameCommon loginOut];
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)myProgressTask
{
    float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		hud.progress = progress;
		usleep(50000);
	}
}

-(void)dealloc
{
    upDataAlert.delegate = nil;
    huancunAlert.delegate = nil;
    loyOutalert.delegate = nil;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
