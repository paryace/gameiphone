//
//  AddTeamMsgPushController.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AddTeamMsgPushController.h"

@interface AddTeamMsgPushController ()

@end

@implementation AddTeamMsgPushController

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
    [self setTopViewWithTitle:@"添加推送" withBackButton:YES];
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    
    _m_TableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, self.view.bounds.size.width, self.view.bounds.size.height - startX) style:UITableViewStylePlain];
    _m_TableView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    _m_TableView.delegate = self;
    _m_TableView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:_m_TableView];
    [self.view addSubview:_m_TableView];
    
    _characterView = [[CharacterView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    _characterView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    _characterView.characterDelegate = self;
    _characterView.hidden = YES;
    [self.view addSubview:_characterView];
    
    _typeView = [[TypeView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    _typeView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    _typeView.typeDelegate = self;
    _typeView.hidden = YES;
    [self.view addSubview:_typeView];
    
    _tagView = [[TagView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    _tagView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    _tagView.tagDelegate = self;
    _tagView.hidden = YES;
    [self.view addSubview:_tagView];

    
   NSMutableArray * m_RoleArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [_characterView setDate:m_RoleArray];
    
    _selectGender = @"2";
    _selectPowerable = @"1";
    if ([_type isEqualToString:@"update"]) {
        _selectRoleDict = [NSMutableDictionary dictionary];
        [self initUpdateInfo];
    }
    [_m_TableView reloadData];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"请稍等...";
}

-(void)initUpdateInfo{
    [_selectRoleDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(_updatePreferInfoDic, @"createTeamUser"), @"gameid")] forKey:@"gameid"];
    [_selectRoleDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(_updatePreferInfoDic, @"createTeamUser"), @"realm")] forKey:@"simpleRealm"];
    [_selectRoleDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(_updatePreferInfoDic, @"createTeamUser"), @"characterName")] forKey:@"name"];
    [_selectRoleDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(_updatePreferInfoDic, @"createTeamUser"), @"characterId")] forKey:@"id"];
    _selectTypeDict = KISDictionaryHaveKey(_updatePreferInfoDic, @"type");
    NSMutableArray * tagArray = KISDictionaryHaveKey(_updatePreferInfoDic, @"tags");
    if (tagArray&& tagArray.count>0) {
         _selectTagDict = [tagArray objectAtIndex:0];
    }
    _selectGender = [GameCommon getNewStringWithId:KISDictionaryHaveKey(_updatePreferInfoDic, @"forGirls")];
    _selectPowerable = [GameCommon getNewStringWithId:KISDictionaryHaveKey(_updatePreferInfoDic, @"powerable")];
    
    [_m_TableView reloadData];
}

-(void)selectCharacter:(NSMutableDictionary *)characterDic{
    _selectRoleDict = characterDic;
    [_m_TableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"-----选择角色-----%@",characterDic);
}
-(void)selectType:(NSMutableDictionary *)typeDic{
    _selectTypeDict = typeDic;
    [_m_TableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"-----选择分类-----%@",typeDic);
}
-(void)tagType:(NSMutableDictionary *)tagDic{
    _selectTagDict = tagDic;
    [_m_TableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"-----选择标签-----%@",tagDic);
}

#pragma MARK --联网获取组队分类
-(void)getTypes:(NSString *)gameid
{
    [[ItemManager singleton] getTeamType:gameid reSuccess:^(id responseObject) {
         [_typeView setDate:responseObject];
    } reError:^(id error) {
        [self showErrorAlert:error];
    }];
}
#pragma MARK ---联网获取标签
-(void)getTag:(NSString*)gameid TypeId:(NSString*)typeId CharacterId:(NSString*)characterId
{
    [[ItemManager singleton] getTeamLableRoom:gameid TypeId:typeId CharacterId:characterId reSuccess:^(id responseObject) {
        if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
            [_tagView setDate:responseObject];
        }
    } reError:^(id error) {
        [self showErrorAlert:error];
    }];
}

#pragma mark ----tableview delegate  datasourse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        return 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellinde = @"section0";
        SelectCharacterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[SelectCharacterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (_selectRoleDict) {
            NSString * gameImage = [GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectRoleDict, @"gameid")]];
            NSString * characterName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectRoleDict, @"name")];
            NSString * simpleRealm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectRoleDict, @"simpleRealm")];
            cell.headImageView.imageURL = [ImageService getImageUrl4:gameImage];
            cell.characterLable.text = [NSString stringWithFormat:@"%@%@",characterName,simpleRealm];
        }else{
            cell.characterLable.text = @"请选择角色";
        }
        [cell reloadCell];
        return cell;
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            static NSString *cellinde = @"section_row0";
            SelectOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[SelectOtherCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tlb.text = @"选择分类";
            
            if (_selectTypeDict && [_selectTypeDict isKindOfClass:[NSDictionary class]]) {
                cell.characterLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectTypeDict, @"value")];
            }else{
                 cell.characterLable.text = @"请选择分类";
            }
            [cell reloadCell];
            return cell;
        }else if (indexPath.row == 1){
            static NSString *cellinde = @"section_row1";
            SelectOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[SelectOtherCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tlb.text = @"包含关键字";
            if (_selectTypeDict) {
                cell.characterLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectTagDict, @"value")];
            }else{
                cell.characterLable.text = @"请选择标签";
            }
            [cell reloadCell];
            return cell;
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            static NSString *cellinde = @"section1_row0";
            SelectOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[SelectOtherCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tlb.text = @"队长性别";
            if ([_selectGender isEqualToString:@"2"]) {
                cell.characterLable.text = @"不限";
            }else{
                cell.characterLable.text = @"女";
            }
            [cell reloadCell];

            return cell;
        }else if (indexPath.row == 1){
            static NSString *cellinde = @"section1_row1";
            PowerableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[PowerableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.soundSwitch.on = YES;
            cell.switchelegate = self;
            return cell;
        }
    }else{
        static NSString *cellinde = @"section2_row0";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        cell.backgroundColor = [UIColor clearColor];
        UIButton *addPushBtn  =[[UIButton alloc]initWithFrame:CGRectMake(10, 0, 300, 45)];
        [addPushBtn  setTitle:@"添加此推送" forState:UIControlStateNormal];
        [addPushBtn setTitleColor:UIColorFromRGBA(0xffffff, 1) forState:UIControlStateNormal];
        addPushBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        addPushBtn.backgroundColor = kColorWithRGB(85, 134, 192, 1);
        [addPushBtn addTarget:self action:@selector(addPushBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:addPushBtn];
        return cell;
    }
}
-(void)addPushBtnAction:(UIButton*)sender{
    if (!_selectRoleDict) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
        return;
    }
    if (!_selectTypeDict) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return;
    }
    if (!_selectTagDict) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择标签" buttonTitle:@"OK"];
        return;
    }
    if ([_type isEqualToString:@"update"]) {
        [self updatePreferences:KISDictionaryHaveKey(_selectRoleDict, @"gameid") CharacterId:KISDictionaryHaveKey(_selectRoleDict, @"id") Description:KISDictionaryHaveKey(_selectTagDict, @"value") TypeId:KISDictionaryHaveKey(_selectTypeDict, @"constId") ForGirls:_selectGender Powerable:_selectPowerable PreferenceId:KISDictionaryHaveKey(_updatePreferInfoDic, @"preferenceId")];
    }else if ([_type isEqualToString:@"create"]){
        [self addPreferences:KISDictionaryHaveKey(_selectRoleDict, @"gameid") CharacterId:KISDictionaryHaveKey(_selectRoleDict, @"id") Description:KISDictionaryHaveKey(_selectTagDict, @"value") TypeId:KISDictionaryHaveKey(_selectTypeDict, @"constId") ForGirls:_selectGender Powerable:_selectPowerable];
    }
    NSLog(@"----add push msg----");
}
-(void)infomationAccording:(UISwitch*)sender
{
    if ([sender isOn]) {
        _selectPowerable = @"1";
        NSLog(@"----onOpen----");
        
    }else{
        _selectPowerable = @"0";
        NSLog(@"----onClose----");
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [_characterView showSelf];
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            if (!_selectRoleDict||![_selectRoleDict isKindOfClass:[NSDictionary class]]) {
                [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
                return;
            }
            [_typeView showSelf];
            [self getTypes:[GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectRoleDict, @"gameid")]];
        }else if (indexPath.row == 1){
            if (!_selectRoleDict||![_selectRoleDict isKindOfClass:[NSDictionary class]]) {
                [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
                return;
            }
            if (!_selectTypeDict||![_selectTypeDict isKindOfClass:[NSDictionary class]]) {
                [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
                return;
            }
            [_tagView showSelf];
            [self getTag:[GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectRoleDict, @"gameid")] TypeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectTypeDict, @"constId")] CharacterId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(_selectRoleDict, @"id")]];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"女",@"不限",nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [actionSheet showInView:self.view];
        }
    }
    NSLog(@"---onClickItem---");
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
        UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 312, 30)];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = kColorWithRGB(164, 164, 164, 1);
        label.backgroundColor = [UIColor clearColor];
        label.text =@"基本设置";
        [view addSubview:label];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, 320, 1)];
        lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
        [view addSubview:lineView];
        return view;
    }else if(section == 2){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
        UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 312, 30)];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = kColorWithRGB(164, 164, 164, 1);
        label.backgroundColor = [UIColor clearColor];
        label.text =@"额外设置";
        [view addSubview:label];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, 320, 1)];
        lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
        [view addSubview:lineView];
        return view;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, 320, 1)];
    lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
    [view addSubview:lineView];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0) {
        _selectGender = @"1";
    }else if (buttonIndex ==1)
    {
        _selectGender = @"2";
    }
    [_m_TableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)showErrorAlert:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"1000124"]) {
                UIAlertView * backAlert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [backAlert show];
            }else{
                
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark ---
-(void)addPreferences:(NSString*)gameid CharacterId:(NSString*)characterId Description:(NSString*)description TypeId:(NSString*)typeId ForGirls:(NSString*)forGirls Powerable:(NSString*)powerable
{
    [hud show:YES];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:characterId] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:description] forKey:@"description"];
    [paramDict setObject:[GameCommon getNewStringWithId:typeId] forKey:@"typeId"];
    [paramDict setObject:[GameCommon getNewStringWithId:forGirls] forKey:@"forGirls"];
    [paramDict setObject:[GameCommon getNewStringWithId:powerable] forKey:@"powerable"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"282" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"------%@------",responseObject);
        [[NSNotificationCenter defaultCenter]postNotificationName:kAddPreference object:nil userInfo:responseObject];
        [[PreferencesMsgManager singleton] savePreferences:responseObject];
        [self showMessageWindowWithContent:@"添加成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorAlert:error];
    }];
}



#pragma mark ---
-(void)updatePreferences:(NSString*)gameid CharacterId:(NSString*)characterId Description:(NSString*)description TypeId:(NSString*)typeId ForGirls:(NSString*)forGirls Powerable:(NSString*)powerable PreferenceId:(NSString*)preferenceId
{
    [hud show:YES];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:characterId] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:preferenceId] forKey:@"preferenceId"];
    [paramDict setObject:[GameCommon getNewStringWithId:description] forKey:@"description"];
    [paramDict setObject:[GameCommon getNewStringWithId:typeId] forKey:@"typeId"];
    [paramDict setObject:[GameCommon getNewStringWithId:forGirls] forKey:@"forGirls"];
    [paramDict setObject:[GameCommon getNewStringWithId:powerable] forKey:@"powerable"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"283" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"------%@------",responseObject);
        [[NSNotificationCenter defaultCenter]postNotificationName:kUpdatePreference object:nil userInfo:responseObject];
        [[PreferencesMsgManager singleton] savePreferences:responseObject];
        [self showMessageWindowWithContent:@"偏好更新成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorAlert:error];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
