//
//  GroupInformationViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupInformationViewController.h"
#import "EGOImageView.h"
#import "JoinGroupViewController.h"
#import "SetUpGroupViewController.h"
#import "KKChatController.h"
#import "MembersListViewController.h"
#import "GroupSettingController.h"
@interface GroupInformationViewController ()
{
    UITableView *m_myTableView;
    UILabel *Memb;
    NSMutableDictionary *m_mainDict;
    UIView *boView;
    UIView *aoView;
    UILabel* m_titleLabel;
    NSInteger shiptypeCount;
}
@end

@implementation GroupInformationViewController

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
    
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];

    
    
    m_mainDict =[ NSMutableDictionary dictionary];
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - 50 - 64)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.backgroundColor = [UIColor clearColor];
    m_myTableView.showsVerticalScrollIndicator = NO;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:m_myTableView];
    
    
    UIImageView *topImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, startX, 320, 192)];
    topImg.image = KUIImage(@"groupinfo_top");
    m_myTableView.tableHeaderView = topImg;
    topImg.userInteractionEnabled = YES;
    [self getInfoWithNet];
    
    aoView =[[ UIView alloc]initWithFrame:CGRectMake(0, 142, 320, 50)];
    aoView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f  blue:0/255.0f  alpha:0.5];
    [topImg addSubview:aoView];
    
    
    // Do any additional setup after loading the view.
}

-(void)didClickGroup:(UIButton *)sender
{
    
    if (shiptypeCount==0) {//群主
        
        if (sender.tag ==100) {//发消息
            KKChatController * kkchat = [[KKChatController alloc] init];
            kkchat.chatWithUser = self.groupId;
            kkchat.type = @"group";
            [self.navigationController pushViewController:kkchat animated:YES];
        }else{
            NSLog(@"群设置");
            GroupSettingController *gr = [[GroupSettingController alloc]init];
            gr.groupId = self.groupId;
            gr.shiptypeCount = shiptypeCount;
            [self.navigationController pushViewController:gr animated:YES];
        }
        
    }
   else if (shiptypeCount==1) {//管理员
       if (sender.tag ==100) {//发消息
           KKChatController * kkchat = [[KKChatController alloc] init];
           kkchat.chatWithUser = self.groupId;
           kkchat.type = @"group";
           [self.navigationController pushViewController:kkchat animated:YES];
       }
       else if(sender.tag ==101){
           GroupSettingController *gr = [[GroupSettingController alloc]init];
           gr.groupId = self.groupId;
           gr.shiptypeCount = shiptypeCount;
           [self.navigationController pushViewController:gr animated:YES];
           NSLog(@"群设置");
       }else{
           NSLog(@"退出群");
       }
   
    }
   else if (shiptypeCount==2) {//成员
       if (sender.tag ==100) {//发消息
           KKChatController * kkchat = [[KKChatController alloc] init];
           kkchat.chatWithUser = self.groupId;
           kkchat.type = @"group";
           [self.navigationController pushViewController:kkchat animated:YES];
       }else{
           GroupSettingController *gr = [[GroupSettingController alloc]init];
           gr.groupId = self.groupId;
           gr.shiptypeCount = shiptypeCount;
           [self.navigationController pushViewController:gr animated:YES];
           NSLog(@"群设置");
       }
       
    }
    else{//陌生人
        SetUpGroupViewController *setupVC = [[SetUpGroupViewController alloc]init];
        setupVC.mySetupType = SETUP_JOIN;
        setupVC.groupid = self.groupId;
        [self.navigationController pushViewController:setupVC animated:YES];
    }
    
}


-(void)wlgc:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    JoinGroupViewController * gruupV = [[JoinGroupViewController alloc] init];
    gruupV.groupId = self.groupId;
    [self.navigationController pushViewController:gruupV animated:YES];
}



-(void)buildmemberisAudit:(BOOL)isAudit title:(NSString *)title imgArray:(NSArray *)array
{
    boView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    boView.backgroundColor =[ UIColor clearColor];
    [aoView addSubview:boView];
    if (!isAudit) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 40, 20)];
        [boView addSubview:imageView];
        UILabel *label =[[ UILabel alloc]initWithFrame:CGRectMake(60, 10, 200, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat:@"审核队列:%@",title];
        label.font = [UIFont systemFontOfSize:14];
        [boView addSubview:label];
        
    }else{
    UILabel *m_cy_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 85, 20)];
    m_cy_label.backgroundColor = [UIColor clearColor];
    m_cy_label.font = [UIFont boldSystemFontOfSize:13];
    m_cy_label.textColor = [UIColor whiteColor];
    m_cy_label.text = @"群成员";
    m_cy_label.textAlignment = NSTextAlignmentCenter;
    [boView addSubview:m_cy_label];
    
    Memb = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 85, 15)];
    Memb.backgroundColor = [UIColor clearColor];
    Memb.font = [UIFont boldSystemFontOfSize:13];
    Memb.textColor = [UIColor whiteColor];
    Memb.text = title;
    Memb.textAlignment = NSTextAlignmentCenter;
    [boView addSubview:Memb];
        
        for (int i =0; i<array.count; i++) {
            EGOImageView *headimgView = [[EGOImageView alloc]initWithFrame:CGRectMake(100+45*i, 5, 40, 40)];
            headimgView.imageURL  = [ImageService getImageStr:KISDictionaryHaveKey(array[i], @"img") Width:80];
            headimgView.placeholderImage = KUIImage(@"place_girl");
            [boView addSubview:headimgView];
        }
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(290, 0, 30, 50);
//        rightBtn.backgroundColor = [UIColor clearColor];
        [rightBtn setImage:KUIImage(@"right") forState:UIControlStateNormal];
        [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 15)];

        [rightBtn addTarget:self action:@selector(enterMembersPage:) forControlEvents:UIControlEventTouchUpInside];
        [boView addSubview:rightBtn];
    }
}


#pragma mark ---进入组织成员界面
-(void)enterMembersPage:(id)sender
{
    MembersListViewController *memberVC = [[MembersListViewController alloc]init];
    memberVC.groupId = self.groupId ;
    [self.navigationController pushViewController:memberVC animated:YES];
}

-(void)buildbelowbutotnWithArray:(NSArray *)array  shiptype:(NSInteger)shiptype
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth-50, 320, 50)];
    [self.view addSubview:view];
    float width = 320/array.count;
    for (int i = 0; i<array.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(width*i, 0, width, 50)];
        [button setTitle:array[i] forState:UIControlStateNormal];
        button.tag = i+100;
        button.backgroundColor = [UIColor grayColor];
        [button addTarget:self action:@selector(didClickGroup:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    
}


-(void)getInfoWithNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];

    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"231" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_mainDict = responseObject;
            
            m_titleLabel.text = KISDictionaryHaveKey(responseObject, @"groupName");
            [m_myTableView reloadData];
            
            BOOL isAuth = [KISDictionaryHaveKey(responseObject, @"state")boolValue];
            
            [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:[NSString stringWithFormat:@"%@_group",self.groupId]];
            

            
            [self buildmemberisAudit:isAuth title:isAuth?[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"rank")]:[NSString stringWithFormat:@"%@/%@",KISDictionaryHaveKey(responseObject, @"currentMemberNum"),KISDictionaryHaveKey(responseObject, @"maxMemberNum")] imgArray:KISDictionaryHaveKey(responseObject, @"memberList")];
            
            
            
            NSString *identity = KISDictionaryHaveKey( responseObject, @"groupUsershipType");
            
            shiptypeCount = [identity intValue];
            
            if ([identity intValue]==0) {//群主
                NSArray *array = @[@"发消息",@"群设置"];
                [self buildbelowbutotnWithArray:array shiptype:[identity intValue]];
            }
            else if ([identity intValue]==1) {//管理员
                NSArray *array = @[@"发消息",@"群设置",@"退出群"];
                [self buildbelowbutotnWithArray:array shiptype:[identity intValue]];
            }
            else if ([identity intValue]==2) {//普通成员
                NSArray *array = @[@"发消息",@"退出群"];
                [self buildbelowbutotnWithArray:array shiptype:[identity intValue]];
   
            }else{//陌生人
                NSArray *array = @[@"申请加入"];
                [self buildbelowbutotnWithArray:array shiptype:[identity intValue]];
   
            }

            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag = 789;
                [alert show];
            }
        }

    }];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 789)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    if (indexPath.row ==0) {
        static NSString *cellinde = @"cell0";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
        ;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:titleLabel];

        titleLabel.text = @"群分类";
        if (m_mainDict &&[m_mainDict allKeys].count>0) {
        NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
            for (int i =0; i<tags.count; i++) {
                [self buildImgVWithframe:CGRectMake(80+(i%2)*88+5*(i%2),10+(i/2)*30+5*(i/2),88,30) title:KISDictionaryHaveKey(tags[i], @"tagName") superView:cell.contentView];
            }
        }
        return cell;
    }
   else if (indexPath.row ==1) {
        static NSString *cellinde = @"cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
        ;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:titleLabel];
        
        titleLabel.text = @"服务器";
        EGOImageView *gameImg =[[EGOImageView alloc]initWithFrame:CGRectMake(68, 10, 20, 20)];
        NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(m_mainDict, @"gameid")];
        gameImg.imageURL = [ImageService getImageUrl4:gameImageId];
        [cell addSubview:gameImg];
        return cell;
    }
    else if (indexPath.row ==2)
    {    static NSString *cellinde2 = @"cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde2];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde2];
        }
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
        ;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:titleLabel];

        titleLabel.text = @"群组号";
        UILabel *numLb = [[UILabel alloc]initWithFrame:CGRectMake(80, 0,200, 40)];
        numLb.font = [UIFont boldSystemFontOfSize:14];
        numLb.backgroundColor = [UIColor clearColor];
        numLb.textColor =[ UIColor blackColor];
        numLb.text = KISDictionaryHaveKey(m_mainDict, @"groupId");
        [cell addSubview:numLb];
        return cell;

    }
    else if (indexPath.row ==3)
    {
        static NSString *cellinde3 = @"cell3";
        GroupInfomationJsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde3];
        if (cell ==nil) {
            cell = [[GroupInfomationJsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde3];
        }
        if (m_mainDict&&[m_mainDict allKeys].count>0) {
            cell.titleLabel.text = @"群介绍";
            cell.contentLabel.text = KISDictionaryHaveKey(m_mainDict, @"info");
            
            CGSize size = [cell.contentLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 230) lineBreakMode:NSLineBreakByCharWrapping];
            
            cell.contentLabel.frame = CGRectMake(80, 10, 230, size.height);
            cell.photoArray =[ImageService getImageIds2:KISDictionaryHaveKey(m_mainDict, @"infoImg") Width:160];
            
            float height = 0.0;
            if (cell.photoArray.count>0&&cell.photoArray.count<4) {
                height=80;
            }
            else if (cell.photoArray.count>3&&cell.photoArray.count<7){
                height = 160;
            }
            else if (cell.photoArray.count>6&&cell.photoArray.count<10){
                height = 240;
            }
            else{
                height = 0;
            }
            cell.photoView.frame = CGRectMake(80, size.height+10, 230, height);
        }
        return cell;
    }
    else
    {
        static NSString *cellinde4 = @"cell4";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde4];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde4];
        }
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 100, 20)]
        ;
        tLabel.text = @"创建时间";
        tLabel.textColor = [UIColor grayColor];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:tLabel];

        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, 150, 20)]
        ;
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:timeLabel];
        
        timeLabel.text = @"2013-04-16";
 
        
        
        return cell;

    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
    if (tags&&[tags isKindOfClass:[NSArray class]]&&tags.count>0) {
        CGSize size1 = [KISDictionaryHaveKey(m_mainDict, @"info") sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 250) lineBreakMode:NSLineBreakByCharWrapping];
        NSArray * photoArray =[ImageService getImageIds2:KISDictionaryHaveKey(m_mainDict, @"infoImg") Width:160];
        float height = 0.0;

    switch (indexPath.row) {
        case 0:
            NSLog(@"--------%d",tags.count/2);
            NSInteger tagsRowCount = (tags.count-1)/2+1;//标签行数
            return  tagsRowCount*30+tagsRowCount*5+10;
            break;
        case 1:
            return 40;
            break;
        case 2:
            if (photoArray.count>0&&photoArray.count<4) {
                height=80;
            }
            else if (photoArray.count>3&&photoArray.count<7){
                height = 160;
            }
            else if (photoArray.count>6&&photoArray.count<10){
                height = 240;
            }
            else{
                height = 0;
            }
            
            return 20+size1.height+height;
            break;
     
        default:
            return 40;
            break;
    }
    }else{
        return 40;
    }
}


-(void)buildImgVWithframe:(CGRect)frame title:(NSString *)title superView:(UIView *)view
{
    UIImageView *imgV =[[ UIImageView alloc]initWithFrame:frame];
    imgV.image = KUIImage(@"card_show");
    imgV.userInteractionEnabled = YES;
    [view addSubview:imgV];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width-20, frame.size.height)];

    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    
    label.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.7];
    label.shadowOffset = CGSizeMake(.7f, 1.0f);

    label.text = title;
    [imgV addSubview:label];
    [imgV bringSubviewToFront:label];
    NSLog(@"%@",title);
}

-(CGSize)getStringSizeWithString:(NSString *)str font:(UIFont *)font
{
    CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
    return size;
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
