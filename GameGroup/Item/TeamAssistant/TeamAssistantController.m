//
//  TeamAssistantController.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamAssistantController.h"

@interface TeamAssistantController ()

@end

@implementation TeamAssistantController

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
    [self setTopViewWithTitle:@"组队助手" withBackButton:YES];
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    UIButton *delButton=[UIButton buttonWithType:UIButtonTypeCustom];
    delButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [delButton setBackgroundImage:KUIImage(@"deleteButton") forState:UIControlStateNormal];
    [delButton setBackgroundImage:KUIImage(@"deleteButton2") forState:UIControlStateHighlighted];
    [self.view addSubview:delButton];
    [delButton addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    UIButton *loadmoreBtn  =[[UIButton alloc]initWithFrame:CGRectMake(8, 1, 312, 50)];
    [loadmoreBtn  setTitle:@"点击查看更多" forState:UIControlStateNormal];
    [loadmoreBtn setTitleColor:kColorWithRGB(164, 164, 164, 1) forState:UIControlStateNormal];
    loadmoreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [loadmoreBtn addTarget:self action:@selector(loadMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:loadmoreBtn];
    
    _m_TableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, self.view.bounds.size.width, self.view.bounds.size.height - startX) style:UITableViewStylePlain];
    _m_TableView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    _m_TableView.delegate = self;
    _m_TableView.dataSource  = self;
   
    [GameCommon setExtraCellLineHidden:_m_TableView];
    [self.view addSubview:_m_TableView];
     _m_TableView.tableFooterView = footerView;
}
-(void)cleanBtnClick:(UIButton*)sender{
    NSLog(@"----cLearMsg---");
}
-(void)loadMoreAction:(UIButton*)sender{
    NSLog(@"----load more msg---");
}


#pragma mark ----tableview delegate  datasourse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellinde = @"headcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImageView * headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 30, 30)];
        headImageView.image = KUIImage(@"group_msg_icon");
        [cell.contentView addSubview:headImageView];
        
        UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(46, 13, 320-51, 20)];
        tlb.backgroundColor = [UIColor clearColor];
        tlb.textColor = [UIColor blackColor];
        tlb.text = @"正在接受组队推送(4)";
        tlb.font =[ UIFont systemFontOfSize:16];
        [cell.contentView addSubview:tlb];
        return cell;
    }
    static NSString *indifience = @"TeamAssistantCell";
    TeamAssistantCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[TeamAssistantCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    cell.headImg.imageURL =[ImageService getImageStr:@"26FED4D04D6349668E9F99F4316FC43E" Width:120] ;
    NSString * gameImage = [GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:@"1"]];
    cell.gameIconImg.imageURL = [ImageService getImageUrl4:gameImage];
    NSString *title = [NSString stringWithFormat:@"[%@/%@]%@",[GameCommon getNewStringWithId:@"2"],[GameCommon getNewStringWithId:@"25"],[GameCommon getNewStringWithId:@"来妹子 来上单 来中单 来打野 不吭"]];
    cell.titleLabel.text = title;
    cell.contentLabel.text = [GameCommon getNewStringWithId:@"伊森利恩-乔小渔的组队"];
    cell.timeLabel.text = @"15分钟前";
    [cell refreText:cell.timeLabel.text];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 46;
    }
    return 80;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        TeamMsgPushController *detailVC = [[TeamMsgPushController alloc]init];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    NSLog(@"---onClickItem---");
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
        UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(8, 0, 312, 40)];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = kColorWithRGB(164, 164, 164, 1);
        label.backgroundColor = [UIColor clearColor];
        if (section ==1) {
            label.text =@"共有3条未读的组队";
        }
        [view addSubview:label];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, 320, 1)];
        lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
        [view addSubview:lineView];
        return view;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return @"删除";
    }
   return @"";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"-----delete the msg----");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
