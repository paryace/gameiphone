//
//  GroupInfoEditViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupInfoEditViewController.h"
#import "EGOImageView.h"
#import "GroupInfomationJsCell.h"
@interface GroupInfoEditViewController ()
{
    NSMutableDictionary *m_mainDict;
    UITableView *m_myTableView;
    UIView *aoView;
    NSMutableDictionary *paramDict;
}
@end

@implementation GroupInfoEditViewController

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

    [self setTopViewWithTitle:@"群信息设置" withBackButton:YES];
    
    m_mainDict = [NSMutableDictionary new];
    paramDict  = [NSMutableDictionary dictionary];
    m_mainDict = (NSMutableDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_group",self.groupId]];
    
    // Do any additional setup after loading the view.
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - 50 - 64)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.backgroundColor = [UIColor clearColor];
    m_myTableView.showsVerticalScrollIndicator = NO;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:m_myTableView];
    
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"share_click.png") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(saveChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    UIImageView *topImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, startX, 320, 192)];
    topImg.image = KUIImage(@"groupinfo_top");
    m_myTableView.tableHeaderView = topImg;
    topImg.userInteractionEnabled = YES;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        static NSString *cellinde = @"cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
        ;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:titleLabel];
        
        titleLabel.text = @"群分类";
        if (m_mainDict &&[m_mainDict allKeys].count>0) {
            
            EGOImageView *gameImg =[[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            gameImg.center = CGPointMake(25, 40);
            NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(m_mainDict, @"gameid")];
            gameImg.imageURL = [ImageService getImageUrl4:gameImageId];
            [cell addSubview:gameImg];
            
            NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
            
            for (int i =0; i<tags.count; i++) {
                CGSize size = [self getStringSizeWithString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tags[i], @"tagName")] font:[UIFont systemFontOfSize:12]];
                [self buildImgVWithframe:CGRectMake(80, 10+30*i, size.width+30, 30) title:KISDictionaryHaveKey(tags[i], @"tagName") superView:cell.contentView];
            }
        }
        return cell;
    }
    else if (indexPath.row ==1)
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
    else if (indexPath.row ==2)
    {
        static NSString *cellinde3 = @"cell3";
        GroupInfomationJsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde3];
        if (cell ==nil) {
            cell = [[GroupInfomationJsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde3];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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


-(void)saveChanged:(id)sender
{
    
    [paramDict setObject:self.groupId forKey:@"groupId"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"239" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];

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
                return 120;
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        CardViewController *cardView = [[CardViewController alloc]init];
        cardView.myDelegate = self;
        [self.navigationController pushViewController:cardView animated:YES];
    }
    else if (indexPath.row ==2) {
        SetUpGroupViewController *setupVC = [[SetUpGroupViewController alloc]init];
        setupVC.groupid = self.groupId;
        setupVC.delegate = self;
        setupVC.mySetupType = SETUP_INFO;
        [self.navigationController pushViewController:setupVC animated:YES];
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
-(void)senderCkickInfoWithDel:(CardViewController *)del array:(NSArray *)array
{
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
    [dic removeObjectForKey:@"tags"];
    [dic setObject:array forKey:@"tags"];
    
//    groupId		群id
//    groupName	群名字（可选）
//    info			群描述（可选）
//    tagIds		群标签（可选）
    
    NSString *tagStr;
    
    for (int i =0; i<array.count; i++) {
        NSDictionary *dic = array[i];
        if (i!=0) {
            tagStr = [NSString stringWithFormat:@"%@,%@",tagStr,[dic objectForKey:@"tagId"]];
        }else{
            tagStr = [dic objectForKey:@"tagId"];
        }
    }
    [paramDict setObject:tagStr forKey:@"tagIds"];
    m_mainDict = dic;
    [m_myTableView reloadData];
}

-(void)comeBackInfoWithController:(SetUpGroupViewController *)controller type:(setUpType)mysetupType info:(NSString *)info
{
    if (mysetupType ==SETUP_NAME) {
        [paramDict setObject:info forKey:@"groupName"];
        NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
        [dic setObject:info forKey:@"groupName"];
        m_mainDict = dic;

    }else if (mysetupType ==SETUP_INFO){
        [paramDict setObject:info forKey:@"info"];
        NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
        [dic setObject:info forKey:@"info"];
        m_mainDict = dic;
    }
    [m_myTableView reloadData];

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
