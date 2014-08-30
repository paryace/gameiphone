//
//  CreateTeamController.m
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CreateTeamController.h"

@interface CreateTeamController (){
    UIView * mainView;
    SelectCharacterView * selectCharacterView;
    SelectTypeAndNumberPersonView * selectTypeAndNumberPersonView;
    CharacterView * characterView;
    UILabel       *  placeholderL;
    UILabel       *  m_ziNumLabel;
    UITextView    *  m_miaoshuTV;
    NSInteger        m_maxZiShu;
    
    UICollectionViewFlowLayout *layout;
    UICollectionView *customPhotoCollectionView;
    
    NSMutableArray  *  m_RoleArray;
    NSMutableArray * m_tagArray;
    
    NSMutableDictionary *   selectCharacter;
    NSMutableDictionary *  selectType;
    NSMutableDictionary *  selectPeopleCount;
}

@end

@implementation CreateTeamController

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
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    
    m_maxZiShu = 30;
    selectCharacter = self.selectRoleDict;
    selectType = self.selectTypeDict;
    m_tagArray = [NSMutableArray array];
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, startX,self.view.frame.size.width, self.view.frame.size.height-startX)];
    [self.view addSubview:mainView];
    
    [self setTopViewWithTitle:@"创建队伍" withBackButton:YES];
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"finish_btn_icon_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"finish_btn_icon_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(createItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    
    selectCharacterView = [[SelectCharacterView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    selectCharacterView.clickDelegate = self;
    [mainView addSubview:selectCharacterView];
    
    selectTypeAndNumberPersonView = [[SelectTypeAndNumberPersonView alloc] initWithFrame:CGRectMake(0, 90, 320, 150)];
    selectTypeAndNumberPersonView.selectTypeDelegate = self;
    [mainView addSubview:selectTypeAndNumberPersonView];
    
    UIView *editIV = [[UIView alloc]initWithFrame:CGRectMake(0, 260, 320, kScreenHeigth-250)];
    editIV.backgroundColor=[UIColor whiteColor];
    [mainView addSubview:editIV];
    
    
    m_miaoshuTV =[[ UITextView alloc]initWithFrame:CGRectMake(10, 270, 300, 50)];
    m_miaoshuTV.delegate = self;
    m_miaoshuTV.layer.borderColor = UIColorFromRGBA(0xaaa9a9, 1).CGColor;
    m_miaoshuTV.layer.borderWidth =0.5;
    m_miaoshuTV.layer.cornerRadius =5.0;
    m_miaoshuTV.font = [UIFont boldSystemFontOfSize:13];
    m_miaoshuTV.textColor = [UIColor blackColor];
    m_miaoshuTV.backgroundColor = [UIColor whiteColor];
    m_miaoshuTV.layer.cornerRadius = 5;
    m_miaoshuTV.layer.masksToBounds = YES;
    [mainView addSubview:m_miaoshuTV];
    
    placeholderL = [[UILabel alloc]init];
    placeholderL.frame = CGRectMake(15,275, 200, 20);
    placeholderL.text = @"请输入或点击下列组队描述";
    placeholderL.enabled = NO;//lable必须设置为不可用
    placeholderL.font = [UIFont systemFontOfSize:14];
    placeholderL.textColor=kColorWithRGB(240,240, 240, 1);
    placeholderL.backgroundColor = [UIColor clearColor];
    [mainView addSubview:placeholderL];
    
    m_ziNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(270, 270+25, 100, 20)];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.font= [UIFont systemFontOfSize:12];
    m_ziNumLabel.textAlignment = NSTextAlignmentLeft;
    [mainView addSubview:m_ziNumLabel];
    
    
    layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing =10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(88, 30);
    customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10.0f, 330, 300, kScreenHeigth - 330-startX) collectionViewLayout:layout];
    customPhotoCollectionView.delegate = self;
    customPhotoCollectionView.scrollEnabled = YES;
    customPhotoCollectionView.showsHorizontalScrollIndicator = NO;
    customPhotoCollectionView.showsVerticalScrollIndicator = NO;
    customPhotoCollectionView.dataSource = self;
    customPhotoCollectionView.hidden = YES;
    customPhotoCollectionView.backgroundColor = [UIColor redColor];
    [customPhotoCollectionView registerClass:[TagCell class] forCellWithReuseIdentifier:@"ImageCell"];
    customPhotoCollectionView.backgroundColor = [UIColor clearColor];;
    [mainView addSubview:customPhotoCollectionView];

    
    
    
    
    characterView = [[CharacterView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    characterView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    characterView.characterDelegate = self;
    characterView.hidden = YES;
    [characterView hiddenSelf];
    [self.view addSubview:characterView];
    
    m_RoleArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [characterView setDate:m_RoleArray];
    
    if (selectCharacter) {
        [self selectCharacterAction:selectCharacter];
    }else{
         [characterView showSelf];
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"操作中...";
}

-(void)onCLick:(UIButton*)action{
    [characterView showSelf];
}
#pragma mark 选择分类
-(void)selectType:(NSMutableDictionary*)typeDic{
    [self selectTypeAction:typeDic];
}
#pragma mark 选择人数
-(void)selectCount:(NSMutableDictionary*)countDic{
    [self selectPersonCountAction:countDic];
}
#pragma mark 选择角色
-(void)selectCharacter:(NSMutableDictionary *)characterDic{
    [self selectCharacterAction:characterDic];
}
-(void)setCharacterInfo:(NSMutableDictionary*)characterDic{
    if (selectCharacter) {
        [selectCharacterView seTCharacterInfo:characterDic];
    }
}

-(void)selectCharacterAction:(NSMutableDictionary*)characterInfo{
    if (characterInfo) {
        selectCharacter =characterInfo;
        [self setCharacterInfo:characterInfo];
        m_maxZiShu = 30;
        m_miaoshuTV.text = @"";
        placeholderL.hidden = NO;
        m_ziNumLabel.text = @"30/30";
        [self getTypes:[GameCommon getNewStringWithId:KISDictionaryHaveKey(characterInfo, @"gameid")]];
    }
}

-(void)selectTypeAction:(NSMutableDictionary*)typeInfo{
    if (typeInfo) {
        selectType =typeInfo;
        [self getPersonCount:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")]typeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(typeInfo, @"constId")]];
        [self getTag:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] TypeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(typeInfo, @"constId")] CharacterId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"id")]];
    }
}
-(void)selectPersonCountAction:(NSMutableDictionary*)personCountInfo{
    if (personCountInfo) {
        selectPeopleCount = personCountInfo;
    }
}

#pragma mark - text view delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return m_tagArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TagCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.text =  KISDictionaryHaveKey([m_tagArray objectAtIndex:indexPath.row], @"value");
    cell.titleLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - 点击标签
-(void)tagOnClick:(TagCell*)sender{
    
    NSString *str = m_miaoshuTV.text;
    NSInteger ziNumOld = [[GameCommon shareGameCommon] unicodeLengthOfString:str];
    NSInteger ziNumNew = [[GameCommon shareGameCommon] unicodeLengthOfString:[NSString stringWithFormat:@"%@%@",@"  ",[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_tagArray objectAtIndex:sender.tag], @"value")]]];
    if (ziNumOld+ziNumNew>30) {
        return;
    }
    if (str.length<1) {
        m_miaoshuTV.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_tagArray objectAtIndex:sender.tag], @"value")];
    }else{
        m_miaoshuTV.text =[NSString stringWithFormat:@"%@%@%@",str,@"  ",[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_tagArray objectAtIndex:sender.tag], @"value")]];
    }
    placeholderL.text = @"";
    [self refreshZiLabelText];
}




#pragma mark - text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (textView.text.length>0 || text.length != 0) {
        placeholderL.text = @"";
    }else{
        placeholderL.text = @"请输入或点击下列组队描述";
    }
    return YES;
}

- (void)refreshZiLabelText
{
//    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_miaoshuTV.text];
    NSInteger ziNum = m_maxZiShu - m_miaoshuTV.text.length;
    if (ziNum<=0) {
        m_ziNumLabel.textColor = [UIColor redColor];
    }else{
        m_ziNumLabel.textColor = [UIColor blackColor];
    }
    m_ziNumLabel.text =[NSString stringWithFormat:@"%d%@%d",ziNum,@"/",m_maxZiShu];
    CGSize nameSize = [m_ziNumLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    m_ziNumLabel.frame=CGRectMake(320-nameSize.width-10-10, 270+25, nameSize.width+5, 20);
    m_ziNumLabel.backgroundColor=[UIColor clearColor];
}


#pragma mark --创建
-(void)createItem:(id)sender
{
//    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_miaoshuTV.text];
    NSInteger ziNum = m_maxZiShu - m_miaoshuTV.text.length;

    if (ziNum<0) {
        [self showAlertViewWithTitle:@"提示" message:@"您的描述超出了字数限制,请重新编辑" buttonTitle:@"确定"];
        return;
    }
    if (!selectCharacter) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
        return;
    }
    if (!selectType) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return;
    }
    if ([GameCommon isEmtity:m_miaoshuTV.text]) {
        [self showAlertViewWithTitle:@"提示" message:@"组队描述内容不能为空" buttonTitle:@"OK"];
        return;
    }
    hud.labelText = @"创建中...";
    [hud show:YES];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"id")] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"constId")] forKey:@"typeId"];
    if (selectPeopleCount) {
        [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectPeopleCount, @"mask")] forKey:@"maxVol"];
    }else{
        [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"mask")] forKey:@"maxVol"];
    }
    [paramDict setObject:[NSString stringWithFormat:@"%@%@%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"simpleRealm")],@"-",[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"name")]] forKey:@"roomName"];
    [paramDict setObject:m_miaoshuTV.text forKey:@"description"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"265" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        //发送通知 刷新我的组队页面
        [[TeamManager singleton] saveTeamInfo:responseObject GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")]];
        [[GroupManager singleton] getGroupInfoWithNet:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"groupId")]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
        
        [MessageService groupNotAvailable:@"inTeamSystemMsg" Message:@"创建队伍成功，您可以通过邀请好友快速的组建队伍" GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"groupId")] gameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] roomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"roomId")] team:@"teamchat" UserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"createTeamUser"), @"userid")]];
        
        [self showMessageWindowWithContent:@"创建成功" imageType:0];
        TeamInvitationController *invc = [[TeamInvitationController alloc]init];
        invc.roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"roomId")];
        invc.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")];
        invc.groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"groupId")];
        invc.createFinish = YES;
        [self.navigationController pushViewController:invc animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlert:error];
        [hud hide:YES];
    }];
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
#pragma mark -- 标签请求成功通知
-(void)updateTeamLable:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        m_tagArray = responseObject;
        [customPhotoCollectionView reloadData];
    }
}

#pragma MARK ---联网获取标签
-(void)getTag:(NSString*)gameid TypeId:(NSString*)typeId CharacterId:(NSString*)characterId
{
    [[ItemManager singleton] getTeamLableRoom:gameid TypeId:typeId CharacterId:characterId reSuccess:^(id responseObject) {
        [self updateTeamLable:responseObject];
    } reError:^(id error) {
        [self showErrorAlert:error];
    }];
}
#pragma MARK --联网获取组队分类
-(void)getTypes:(NSString *)gameid
{
    [[ItemManager singleton] getTeamType:gameid reSuccess:^(id responseObject) {
        [selectTypeAndNumberPersonView setTypeArray:responseObject];
    } reError:^(id error) {
        [self showErrorAlert:error];
    }];
}
#pragma mark --- 联网获取人数列表
-(void)getPersonCount:(NSString *)gameid typeId:(NSString *)typeId
{
    [[ItemManager singleton] getPersonCountFromNetWithGameId:gameid typeId:typeId reSuccess:^(id responseObject) {
        [selectTypeAndNumberPersonView setNumberArray:responseObject];
    } reError:^(id error) {
        [self showErrorAlert:error];
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGRect frame = textView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        mainView.frame = CGRectMake(0, -frame.origin.y+5+startX, self.view.frame.size.width, self.view.frame.size.height+frame.origin.y-5);
        customPhotoCollectionView.frame = CGRectMake(10.0f, 330, 300, kScreenHeigth - startX - 5 - 216-10 - frame.size.height);
    }completion:^(BOOL finished) {
        customPhotoCollectionView.hidden = NO;
    }];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [UIView animateWithDuration:0.3 animations:^{
         mainView.frame =CGRectMake(0, startX, self.view.frame.size.width,self.view.frame.size.height-startX);
        customPhotoCollectionView.frame = CGRectMake(10.0f, 330, 300, kScreenHeigth - 330-startX);
    }completion:^(BOOL finished) {
         customPhotoCollectionView.hidden = YES;
    }];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
