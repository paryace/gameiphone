//
//  PreferenceViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-8-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "PreferenceViewController.h"
#import "NewFirstCell.h"
@interface PreferenceViewController ()
{
    UITableView * _prefTb;
    NSMutableArray * _dataArr;
    UIActionSheet * editActionSheet;
    NSInteger   actionSheetCount;
}
@end

@implementation PreferenceViewController

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
    
    [self setTopViewWithTitle:@"我的偏好" withBackButton:YES];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiceTeamRecommendMsg:) name:kteamRecommend object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(roleRemove:) name:RoleRemoveNotify object:nil];
    
    _prefTb = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX) style:UITableViewStylePlain];
    _prefTb.delegate = self;
    _prefTb.dataSource = self;
    [GameCommon setExtraCellLineHidden:_prefTb];

    [self.view addSubview:_prefTb];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getPreferencesWithNet];
}
-(void)getPreferencesWithNet
{
    NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [[PreferencesMsgManager singleton] getPreferencesWithNet:userid reSuccess:^(id responseObject) {
        [self setList:responseObject];
        _dataArr =[self detailDataList:responseObject];
        [_prefTb reloadData];
        [self.mydelegate reloadMsgCount];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"LoignRefreshPreference_wx"];
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
    }];
}
-(NSMutableArray*)detailDataList:(NSMutableArray*)datas{
    NSMutableArray * tempArrayType = [datas mutableCopy];
    for (int i=0; i<tempArrayType.count; i++) {
        NSMutableDictionary * dic = (NSMutableDictionary*)[tempArrayType objectAtIndex:i];
        
        NSMutableDictionary * preDic = [DataStoreManager getPreferenceMsg:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")]];
        NSString *str =[NSString stringWithFormat:@"%d",[[PreferencesMsgManager singleton] getPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId")]];
        
        [dic setObject:str forKey:@"receiveState"];
        if (preDic) {
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"characterName")] forKey:@"characterName"];
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"description")] forKey:@"description"];
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"msgCount")] forKey:@"msgCount"];
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"msgTime")] forKey:@"msgTime"];
            [dic setObject:@"1" forKey:@"haveMsg"];
        }else{
            [dic setObject:@"0" forKey:@"msgCount"];
            [dic setObject:@"1000" forKey:@"msgTime"];
            [dic setObject:@"0" forKey:@"haveMsg"];
        }
    }
    [tempArrayType sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        return [KISDictionaryHaveKey(obj1, @"msgTime") intValue] < [KISDictionaryHaveKey(obj2, @"msgTime") intValue];
    }];
    return tempArrayType;
}

-(void)setList:(NSMutableArray*)array
{
    for (NSMutableDictionary * dic in array) {
        if (![KISDictionaryHaveKey(dic, @"type") isKindOfClass:[NSDictionary class]]) {
            [dic setObject:[[ItemManager singleton] createType] forKey:@"type"];
        }
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    NewFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[NewFirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    NSDictionary *dic = [_dataArr objectAtIndex:indexPath.row];
    NSInteger state = [KISDictionaryHaveKey(dic, @"receiveState") intValue];
    NSString *headImg = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterImg");
    cell.bgView.backgroundColor = [UIColor whiteColor];
    cell.headImageV.placeholderImage = KUIImage(@"placeholder");
    cell.headImageV.imageURL = [ImageService getImageStr:headImg Width:100];
    if (![KISDictionaryHaveKey(dic, @"type") isKindOfClass:[NSDictionary class]]) {
        cell.cardLabel.text = @"全部";
    }else{
        cell.cardLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"type"), @"value")];
    }
    cell.nameLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"realm");
    cell.distLabel.text = [self getDescription:dic State:state];
    if ([KISDictionaryHaveKey(dic, @"haveMsg") intValue]==1) {
        [cell setTime:KISDictionaryHaveKey(dic, @"msgTime")];
    }
    if (state == 1) {
        cell.stopImg.image = KUIImage(@"have_soundSong");
        [cell.dotV setMsgCount:[KISDictionaryHaveKey(dic, @"msgCount") intValue]];
    }
    else if (state == 2){
        cell.stopImg.image = KUIImage(@"close_receive");
        [cell.dotV hide];
    }
    else if (state == 3){
        cell.stopImg.image = KUIImage(@"nor_soundSong");
        [cell.dotV setMsgCount:[KISDictionaryHaveKey(dic, @"msgCount") intValue]];
    }
    return cell;
}
-(void)receiveMsg:(NSDictionary *)msg{
    NSMutableDictionary * msgPayloadDic = [KISDictionaryHaveKey(msg, @"payload") JSONValue];
    for (NSMutableDictionary * dic in _dataArr) {
        if ([KISDictionaryHaveKey(msgPayloadDic, @"gameid") intValue] == [KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") intValue]&&[KISDictionaryHaveKey(msgPayloadDic, @"preferenceId") intValue] == [KISDictionaryHaveKey(dic, @"preferenceId") intValue]) {
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgPayloadDic, @"characterName")] forKey:@"characterName"];
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgPayloadDic, @"description")] forKey:@"description"];
            [dic setObject:[GameCommon getNewStringWithId:[NSString stringWithFormat:@"%d",[KISDictionaryHaveKey(dic, @"msgCount") intValue]+1]] forKey:@"msgCount"];
        }
    }
    [_dataArr sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        return [KISDictionaryHaveKey(obj1, @"msgTime") intValue] < [KISDictionaryHaveKey(obj2, @"msgTime") intValue];
    }];
    [_prefTb reloadData];
}

-(void)readMsg:(NSString *)gameId PreferenceId:(NSString*)preferenceId{
    for (NSMutableDictionary * dic in _dataArr) {
        if ([gameId intValue] == [KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") intValue]&&[preferenceId intValue] == [KISDictionaryHaveKey(dic, @"preferenceId") intValue]) {
            [dic setObject:@"0" forKey:@"msgCount"];
        }
        [_prefTb reloadData];
    }
}

-(void)didRoleRomeve:(NSString*)characterId{
    for (NSMutableDictionary * dic in _dataArr) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterId")] isEqualToString:[GameCommon getNewStringWithId:characterId]]) {
            [_dataArr removeObject:dic];
        }
    }
    [_prefTb reloadData];
    [self.mydelegate reloadMsgCount];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self enterEditPageWithRow:indexPath.row];
}

-(void)enterEditPageWithRow:(NSInteger)row
{
    NSMutableDictionary * didDic = [_dataArr objectAtIndex:row];
    [self updateMsg:didDic];
    [self.mydelegate searchTeamBackViewWithDic:didDic];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateMsg:(NSMutableDictionary*)didDic{
    [DataStoreManager updatePreferenceMsg:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(didDic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(didDic, @"preferenceId")] Successcompletion:^(BOOL success, NSError *error) {
        [self readMsg:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(didDic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(didDic, @"preferenceId")]];
        [_prefTb reloadData];
        [self.mydelegate reloadMsgCount];
    }];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        tableView.editing = NO;
        editActionSheet = [[UIActionSheet alloc]initWithTitle:@"编辑" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"正常模式" otherButtonTitles:@"无红点模式",@"静音模式", @"删除偏好",nil];
        editActionSheet.tag = indexPath.row;
        actionSheetCount = indexPath.row;
        [editActionSheet showInView:self.view];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"设置";
}
-(NSString*)getDescription:(NSDictionary*)dic State:(NSInteger)state{
    if (state == 1) {//正常
        if ([KISDictionaryHaveKey(dic, @"haveMsg") intValue]==1) {
            return [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(dic, @"characterName"),@":",KISDictionaryHaveKey(dic, @"description")];
        }else{
            if ([GameCommon isEmtity:KISDictionaryHaveKey(dic,@"desc")]) {
                return @"正在收听此类的组队";
            }else{
                return [NSString stringWithFormat:@"%@%@%@",@"正在收听", KISDictionaryHaveKey(dic,@"desc") ,@"的组队"];
            }
        }
    }
    else if (state == 2){//无红点
        if ([KISDictionaryHaveKey(dic, @"haveMsg") intValue]==1) {
            if ([KISDictionaryHaveKey(dic, @"msgCount") intValue]>0) {
                return [NSString stringWithFormat:@"%@%@%@%@",@"(",KISDictionaryHaveKey(dic, @"msgCount"),@"条消息) ",[NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(dic, @"characterName"),@":",KISDictionaryHaveKey(dic, @"description")]];
            }else{
                return [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(dic, @"characterName"),@":",KISDictionaryHaveKey(dic, @"description")];
            }
        }else{
            if ([KISDictionaryHaveKey(dic, @"msgCount") intValue]>0) {
                return [NSString stringWithFormat:@"%@%@%@%@",@"(",KISDictionaryHaveKey(dic, @"msgCount"),@"条消息) ",@"已关闭组队搜索"];
            }else{
                if ([GameCommon isEmtity:KISDictionaryHaveKey(dic,@"desc")]) {
                    return  @"已经关闭收听此类的组队";
                }else{
                    return [NSString stringWithFormat:@"%@%@%@",@"已关闭收听", KISDictionaryHaveKey(dic,@"desc") ,@"的组队"];
                }
            }
        }
        
    }
    else if (state == 3){//静音
        if ([KISDictionaryHaveKey(dic, @"haveMsg") intValue]==1) {
            return [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(dic, @"characterName"),@":",KISDictionaryHaveKey(dic, @"description")];
        }else{
            if ([GameCommon isEmtity:KISDictionaryHaveKey(dic,@"desc")]) {
                return  @"正在收听此类的组队";
            }else{
                return  [NSString stringWithFormat:@"%@%@%@",@"正在收听", KISDictionaryHaveKey(dic,@"desc") ,@"的组队"];
            }
        }
    }
    return @"";
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *dic = [_dataArr objectAtIndex:actionSheetCount];
    switch (buttonIndex) {
        case 0:
            NSLog(@"正常模式");
            [[PreferencesMsgManager singleton] setPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") State:1];
            [dic setValue:@"1" forKey:@"receiveState"];
            break;
        case 1:
            NSLog(@"无红点模式");
            [[PreferencesMsgManager singleton] setPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") State:2];
            [dic setValue:@"2" forKey:@"receiveState"];
            break;
        case 2:
            NSLog(@"静音模式");
            [[PreferencesMsgManager singleton] setPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") State:3];
            [dic setValue:@"3" forKey:@"receiveState"];
            break;
        case 3:
            NSLog(@"删除偏好");
            [self deleteCellWithIndexPathRow:actionSheetCount];
            break;
        default:
            break;
    }
    [_prefTb reloadData];
    [self.mydelegate reloadMsgCount];
}

-(void)deleteCellWithIndexPathRow:(NSInteger)row
{
    NSDictionary *dic = [_dataArr objectAtIndex:row];
    [[PreferencesMsgManager singleton] deletePreferences:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") Completion:^(BOOL success, NSError *error) {
        [[NSUserDefaults standardUserDefaults]setObject:_dataArr forKey:[NSString stringWithFormat:@"item_preference_%@",[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]];
        [_dataArr removeObjectAtIndex:row];
        [_prefTb deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }];
}

-(void)deletePreference:(NSString*)gameId PreferenceId:(NSString*)preferenceId reSuccess:(void (^)(id responseObject))resuccess{
    NSMutableDictionary *paramDict =[ NSMutableDictionary dictionary];
    NSMutableDictionary *postDict =[ NSMutableDictionary dictionary];
    [paramDict setObject:gameId forKey:@"gameid"];
    [paramDict setObject:preferenceId forKey:@"preferenceId"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"289" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}
-(void)showAlertDialog:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark --新的偏好消息
-(void)receiceTeamRecommendMsg:(NSNotification*)notification{
    NSDictionary * msg = notification.userInfo;
    [self receiveMsg:msg];
}
#pragma mark -- 删除角色
-(void)roleRemove:(NSNotification*)notification{
    NSDictionary * msg = notification.userInfo;
    [self didRoleRomeve:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"characterId")]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
