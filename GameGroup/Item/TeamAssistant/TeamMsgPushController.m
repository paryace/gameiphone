//
//  TeamMsgPushController.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamMsgPushController.h"

@interface TeamMsgPushController ()

@end

@implementation TeamMsgPushController

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
    [self setTopViewWithTitle:@"组队推送" withBackButton:YES];
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3,1);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPreferenceInfo:) name:kAddPreference object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upadtePreferenceInfo:) name:kUpdatePreference object:nil];
    
    _characterKey = [NSMutableArray array];
    _characterDic = [NSMutableDictionary dictionary];
    
    _m_TableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, self.view.bounds.size.width, self.view.bounds.size.height - startX) style:UITableViewStylePlain];
    _m_TableView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    _m_TableView.delegate = self;
    _m_TableView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:_m_TableView];
    [self.view addSubview:_m_TableView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"请稍等...";
    
    [self getPreferencesWithNet];
}
#pragma mark ----
-(void)addPreferenceInfo:(NSNotification*)notification{
    [self addNewPreference:notification.userInfo];
}
#pragma mark ----
-(void)upadtePreferenceInfo:(NSNotification*)notification{
    [self updatePreference:notification.userInfo];
}

#pragma mark ----tableview delegate  datasourse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _characterKey.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == _characterKey.count-1){
        return 1;
    }
    return [[_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:section]]] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellinde = @"headcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
        lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
        [cell.contentView addSubview:lineView];
        
        UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 13, 320-25, 20)];
        tlb.backgroundColor = [UIColor clearColor];
        tlb.textColor = [UIColor blackColor];
        tlb.text = @"接受以下推送(4)";
        tlb.font =[ UIFont systemFontOfSize:16];
        [cell.contentView addSubview:tlb];
        
        UISwitch *soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-80, 8, 60, 30)];
        soundSwitch.on = YES;
        [soundSwitch addTarget:self action:@selector(infomationAccording:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:soundSwitch];
        
        return cell;
    }else if (indexPath.section == _characterKey.count-1) {
        static NSString *cellinde = @"footercell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
        lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
        [cell.contentView addSubview:lineView];
        
        UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 13, 320-25, 20)];
        tlb.backgroundColor = [UIColor clearColor];
        tlb.textColor = kColorWithRGB(139, 169, 209, 1);
        tlb.text = @"添加推送";
        tlb.font =[ UIFont systemFontOfSize:16];
        [cell.contentView addSubview:tlb];
        return cell;
    }
    static NSString *indifience = @"TeamMsgPushCell";
    TeamMsgPushCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[TeamMsgPushCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSArray * groupArray =  [_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:indexPath.section]]];
    if (groupArray && groupArray.count>0) {
        NSMutableDictionary * dic = [groupArray objectAtIndex:indexPath.row];
        NSMutableDictionary * typeDic = KISDictionaryHaveKey(dic, @"type");
        if (typeDic && [typeDic isKindOfClass:[NSDictionary class]]) {
             cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(typeDic, @"value")];
        }else{
            cell.titleLabel.text = @"";
        }
        cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"keyword")];
//        if ([KISDictionaryHaveKey(dic, @"haveMsg") intValue]==1) {
//            [cell setTime:KISDictionaryHaveKey(dic, @"msgTime")];
//        }
        if (!KISDictionaryHaveKey(dic, @"receiveState")) {
            NSInteger state = [KISDictionaryHaveKey(dic, @"receiveState") intValue];
            if (state == 1) {
                cell.stopImg.image = KUIImage(@"have_soundSong");
            }
            else if (state == 2){
                cell.stopImg.image = KUIImage(@"close_receive");
            }
            else if (state == 3){
                cell.stopImg.image = KUIImage(@"nor_soundSong");
            }
        }else{
            cell.stopImg.image = KUIImage(@"have_soundSong");
        }
    }else{
        cell.titleLabel.text = @"";
        cell.contentLabel.text = @"";
    }
    return cell;
}
//总开关
-(void)infomationAccording:(UISwitch*)sender
{
    if ([sender isOn]) {
        NSLog(@"----onOpen----");
        [self preferenceMainSwitch:@"0" reSuccess:^(id responseObject) {
            sender.on = NO;
            [self msgSwitich:@"3"];
        }];
        
    }else{
        [self preferenceMainSwitch:@"1" reSuccess:^(id responseObject) {
            sender.on = YES;
            [self msgSwitich:@"1"];
        }];
        NSLog(@"----onClose----");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 46;
    }else if (indexPath.section == _characterKey.count-1){
        return 46;
    }
    return 65;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    if (indexPath.section == _characterKey.count-1){
        AddTeamMsgPushController *detailVC = [[AddTeamMsgPushController alloc]init];
        detailVC.type = @"create";
        [self.navigationController pushViewController:detailVC animated:YES];
        return;
    }
    NSArray * groupArray =  [_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:indexPath.section]]];
    if (groupArray && groupArray.count>0) {
        NSMutableDictionary * dic = [groupArray objectAtIndex:0];
        AddTeamMsgPushController *detailVC = [[AddTeamMsgPushController alloc]init];
        detailVC.type = @"update";
        detailVC.updatePreferInfoDic = dic;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    NSLog(@"---onClickItem---");
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
        return view;
    }else if (section == _characterKey.count-1){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
        return view;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
    view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
    EGOImageView * gamgImageView =[[EGOImageView alloc]initWithFrame:CGRectMake(20, 10, 15, 15)];
    [view addSubview:gamgImageView];
    
    UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 320-45, 35)];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = kColorWithRGB(164, 164, 164, 1);
    label.backgroundColor = [UIColor clearColor];
    
    [view addSubview:label];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 35, 320, 1)];
    lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
    [view addSubview:lineView];
    
    
    NSArray * groupArray =  [_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:section]]];
    if (groupArray && groupArray.count>0) {
        NSMutableDictionary * dic = [groupArray objectAtIndex:0];
        NSString * gameImage = [GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")]];
        gamgImageView.imageURL = [ImageService getImageUrl4:gameImage];
        label.text =[NSString stringWithFormat:@"%@--%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"realm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterName")]];
    }
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }else if (section ==_characterKey.count-1){
        return 30;
    }
    return 35;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return @"";
    }else if (indexPath.section ==_characterKey.count-1){
        return @"";
    }
    return @"设置";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        tableView.editing = NO;
       UIActionSheet * editActionSheet = [[UIActionSheet alloc]initWithTitle:@"编辑" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"正常模式" otherButtonTitles:@"无红点模式",@"静音模式", @"删除偏好",nil];
        editActionSheet.tag = indexPath.row;
        _detailIndexPath = indexPath;
        [editActionSheet showInView:self.view];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }else if (indexPath.section ==_characterKey.count-1){
        return NO;
    }
    return YES;
}
//偏好设置
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray * groupArray =  [_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:_detailIndexPath.section]]];
    if (groupArray && groupArray.count>0) {
        NSMutableDictionary * dic = [groupArray objectAtIndex:_detailIndexPath.row];
        switch (buttonIndex) {
            case 0:
            {
                [self preferenceBranchSwitch:@"1" GameId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") reSuccess:^(id responseObject) {
                    NSLog(@"正常模式");
                    [[PreferencesMsgManager singleton] setPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") State:1];
                    [dic setValue:@"1" forKey:@"receiveState"];
                    [_m_TableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_detailIndexPath] withRowAnimation:NO];
                }];
            }
                break;
            case 1:
            {
                [self preferenceBranchSwitch:@"0" GameId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") reSuccess:^(id responseObject) {
                    NSLog(@"无红点模式");
                    [[PreferencesMsgManager singleton] setPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") State:2];
                    [dic setValue:@"2" forKey:@"receiveState"];
                    [_m_TableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_detailIndexPath] withRowAnimation:NO];
                }];
            }
                break;
            case 2:
            {
                [self preferenceBranchSwitch:@"0" GameId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") reSuccess:^(id responseObject) {
                    NSLog(@"静音模式");
                    [[PreferencesMsgManager singleton] setPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") State:3];
                    [dic setValue:@"3" forKey:@"receiveState"];
                    [_m_TableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_detailIndexPath] withRowAnimation:NO];
                }];
            }
                break;
            case 3:
                NSLog(@"删除偏好");
                [self deleteCellWithIndexPathRow:_detailIndexPath];
                break;
            default:
                break;
        }
    }
}

//总开关
-(void)msgSwitich:(NSString*)state{
    for (NSString * keyStr in  _characterKey) {
        NSArray * groupArray =  [_characterDic objectForKey:[GameCommon getNewStringWithId:keyStr]];
        for (NSMutableDictionary * dic in groupArray) {
            [[PreferencesMsgManager singleton] setPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId") State:1];
            [dic setValue:state forKey:@"receiveState"];
        }
    }
    [_m_TableView reloadData];
    
}

//获取偏好列表
-(void)getPreferencesWithNet
{
    [hud show:YES];
    NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [[PreferencesMsgManager singleton] getPreferencesWithNet:userid reSuccess:^(id responseObject) {
        [hud hide:YES];
        [self ssasasa:responseObject];
        [_m_TableView reloadData];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlert:error];
    }];
}


//删除偏好
-(void)deleteCellWithIndexPathRow:(NSIndexPath*)indexPath
{
    NSArray * groupArray =  [_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:indexPath.section]]];
    if (groupArray && groupArray.count>0) {
        NSMutableDictionary * dic = [groupArray objectAtIndex:indexPath.row];
        [self deletePreference:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")] reSuccess:^(id responseObject) {
            NSLog(@"----delete---");
            [self deletePreferFromLoca:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")] IndexPath:indexPath];
        }];
    }
}

-(void)deletePreferFromLoca:(NSString*)gameId PreferenceId:(NSString*)preferenceId IndexPath:(NSIndexPath*)indexPath{
    [[PreferencesMsgManager singleton] deletePreferences:gameId PreferenceId:preferenceId Completion:^(BOOL success, NSError *error) {
        [[_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:indexPath.section]]] removeObjectAtIndex:indexPath.row];
        [_m_TableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationRight];

        
        if ([[_characterDic objectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:indexPath.section]]] count]<=0) {
            [_characterDic removeObjectForKey:[GameCommon getNewStringWithId:[_characterKey objectAtIndex:indexPath.section]]];
            [_characterKey removeObject:[_characterKey objectAtIndex:indexPath.section]];
            [_m_TableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
        }
    }];
}
//删除偏好
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
//分组
-(void)ssasasa:(NSMutableArray*)array{
    BOOL found;
    for (NSMutableDictionary *dic in array){
        
        NSMutableDictionary * preDic = [DataStoreManager getPreferenceMsg:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")]];
        
        NSString *statestr =[NSString stringWithFormat:@"%d",[[PreferencesMsgManager singleton] getPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId")]];
        [dic setObject:statestr forKey:@"receiveState"];
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

        NSString *c = [NSString stringWithFormat:@"%@%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterId")]];
        found = NO;
        for (NSString *str in [_characterDic allKeys]){
            if ([str isEqualToString:c])
            {
                found = YES;
            }
        }if (!found){
            [_characterDic setValue:[[NSMutableArray alloc] init] forKey:c];
            [_characterKey addObject:c];
        }
    }
    
    for (NSDictionary *dic in array)
    {
        [[_characterDic objectForKey:[NSString stringWithFormat:@"%@%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterId")]]] addObject:dic];
    }
    [_characterKey insertObject:@"1" atIndex:0];
    [_characterKey insertObject:@"2" atIndex:_characterKey.count];
    [[_characterDic objectForKey:@"1"] addObject:[[NSMutableDictionary alloc] init]];
    [[_characterDic objectForKey:@"2"] addObject:[[NSMutableDictionary alloc] init]];
    NSLog(@"--%@--",_characterDic);
}

//添加偏好
-(void)addNewPreference:(NSDictionary*)preferInfo{
     NSString *key = [NSString stringWithFormat:@"%@%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(preferInfo, @"createTeamUser"), @"gameid")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(preferInfo, @"createTeamUser"), @"characterId")]];
    if ([_characterKey containsObject:key]) {
         [[_characterDic objectForKey:key] addObject:preferInfo];
    }else{
        
        [_characterDic setValue:[[NSMutableArray alloc] init] forKey:key];
        
        [[_characterDic objectForKey:key] addObject:preferInfo];
        [[_characterDic objectForKey:@"1"] addObject:[[NSMutableDictionary alloc] init]];
        [[_characterDic objectForKey:@"2"] addObject:[[NSMutableDictionary alloc] init]];
        
        [_characterKey addObject:key];
        [_characterKey insertObject:@"1" atIndex:0];
        [_characterKey insertObject:@"2" atIndex:_characterKey.count];
    }
     [_m_TableView reloadData];
}
//更新偏好
-(void)updatePreference:(NSDictionary*)preferInfo{
    NSString *key = [NSString stringWithFormat:@"%@%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(preferInfo, @"createTeamUser"), @"gameid")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(preferInfo, @"createTeamUser"), @"characterId")]];
    
    NSArray * updateArray = [[_characterDic objectForKey:key] mutableCopy];
    for (int i = 0; i<updateArray.count; i++) {
        NSMutableDictionary * dic = [updateArray objectAtIndex:i];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(preferInfo, @"preferenceId")] isEqualToString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")]]) {
            [[_characterDic objectForKey:key] replaceObjectAtIndex:i withObject:preferInfo];
        }
    }
    [_m_TableView reloadData];
}
//显示错误信息
-(void)showErrorAlert:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}


//总开关
-(void)preferenceMainSwitch:(NSString*)isOpen reSuccess:(void (^)(id responseObject))resuccess{
    hud.labelText = @"请稍等...";
    [hud show:YES];
    NSMutableDictionary *paramDict =[ NSMutableDictionary dictionary];
    NSMutableDictionary *postDict =[ NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:isOpen] forKey:@"isOpen"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"312" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorAlert:error];
    }];
}

//单个开关
-(void)preferenceBranchSwitch:(NSString*)isOpen GameId:(NSString*)gameId PreferenceId:(NSString*)preferenceId reSuccess:(void (^)(id responseObject))resuccess{
    hud.labelText = @"请稍等...";
//    [hud show:YES];
    NSMutableDictionary *paramDict =[ NSMutableDictionary dictionary];
    NSMutableDictionary *postDict =[ NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:gameId] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:preferenceId] forKey:@"preferenceId"];
    [paramDict setObject:[GameCommon getNewStringWithId:isOpen] forKey:@"isOpen"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"284" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorAlert:error];
    }];
}

-(void)showErrorMsg:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
