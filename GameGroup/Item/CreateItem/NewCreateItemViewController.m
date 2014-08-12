//
//  NewCreateItemViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewCreateItemViewController.h"
#import "EGOImageView.h"
#import "ItemManager.h"

@interface NewCreateItemViewController ()
{
    
    UIScrollView *mainScroll;
    
    UITextField   *  m_gameTf;
    UITextField   *  m_tagTf;
    UITextField   *  m_countTf;
    UILabel       *  placeholderL;
    UILabel       *  m_ziNumLabel;
    UITextView    *  m_miaoshuTV;
    NSInteger        m_maxZiShu;
    DWTagList     *  tagList;
    NSMutableArray * m_tagsArray;
    UIPickerView  *  m_rolePickerView;
    UIPickerView  *  m_tagsPickView;
    UIPickerView  *  m_countPickView;
    UIToolbar     *  toolbar;
    
    NSMutableArray  *  m_flArray;
    NSMutableArray  *  m_RoleArray;
    NSMutableArray  *  m_countArray;
    
    NSDictionary *   selectCharacter;
    NSDictionary *  selectType;
    NSDictionary *  selectPeopleCount;
    NSString * selectCrossServer;
    
    UISwitch *switchView;
    EGOImageView *gameIconImg;
    
    UIAlertView *backAlert;
    
}
@end

@implementation NewCreateItemViewController

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
    [self setTopViewWithTitle:@"创建队伍" withBackButton:YES];
    m_maxZiShu = 30;
    selectCharacter = self.selectRoleDict;
    selectType = self.selectTypeDict;
    
    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(createItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    
    m_maxZiShu = 30;
    m_tagsArray = [NSMutableArray array];
    m_RoleArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    m_flArray  = [NSMutableArray array];
    m_countArray  = [NSMutableArray array];
    [self buildPickView];
    
    
    mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    mainScroll.contentSize = CGSizeMake(0, self.view.bounds.size.height+50);
    [self.view addSubview:mainScroll];
    

    
    m_gameTf = [self buildTextFieldWithFrame:CGRectMake(10, 10 , 300, 40) placeholder:@"请选择角色" rightImg:@"bollow" textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] font:14 textAlignment:NSTextAlignmentLeft];
    m_gameTf.delegate = self;
    m_gameTf.inputAccessoryView = toolbar;
    m_gameTf.inputView = m_rolePickerView;

    gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 15, 25, 25)];
    [mainScroll addSubview:gameIconImg];

    m_tagTf = [self buildTextFieldWithFrame:CGRectMake(10, 60, 300, 40) placeholder:@"请选择分类" rightImg:@"bollow" textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] font:14 textAlignment:NSTextAlignmentLeft];
    m_tagTf.delegate = self;
    m_tagTf.inputAccessoryView = toolbar;
    m_tagTf.inputView = m_tagsPickView;


    m_countTf = [self buildTextFieldWithFrame:CGRectMake(10, 110, 300, 40) placeholder:@"请选择人数" rightImg:@"bollow" textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] font:14 textAlignment:NSTextAlignmentLeft];
    m_countTf.delegate = self;
    m_countTf.inputAccessoryView = toolbar;
    m_countTf.inputView = m_countPickView;
    
    
    UIImageView *imgVc = [[UIImageView alloc]initWithFrame:CGRectMake(10, 160, 300, 80)];
    imgVc.image = KUIImage(@"group_info");
    [mainScroll addSubview:imgVc];
    
    m_miaoshuTV = [[UITextView alloc]initWithFrame:CGRectMake(10, 160, 300, 80)];
    m_miaoshuTV.backgroundColor = [UIColor clearColor];
//    m_miaoshuTV.layer.borderWidth = 1;
//    m_miaoshuTV.layer.borderColor = [[UIColor whiteColor]CGColor];
//    m_miaoshuTV.layer.cornerRadius = 5;
//    m_miaoshuTV.layer.masksToBounds=YES;
    m_miaoshuTV.delegate = self;
    [mainScroll addSubview:m_miaoshuTV];
    
//<<<<<<< HEAD
    placeholderL = [[UILabel alloc]init];
    if (KISHighVersion_7) {
        placeholderL.frame = CGRectMake(15,165, 200, 20);
    }else{
        placeholderL.frame = CGRectMake(12,160, 200, 20);
    }
//=======
//    placeholderL = [[UILabel alloc]initWithFrame:CGRectMake(18,170, 200, 20)];
//>>>>>>> FETCH_HEAD
    placeholderL.backgroundColor = [UIColor clearColor];
    placeholderL.textColor = UIColorFromRGBA(0x9b9b9b, 1);
    placeholderL.text = @"填写组队描述……";
    placeholderL.font = [UIFont systemFontOfSize:13.0];
    [mainScroll addSubview:placeholderL];

    m_ziNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(300-10-10, 245, 100, 20)];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.font= [UIFont systemFontOfSize:12];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    [mainScroll addSubview:m_ziNumLabel];

//    [self buildSwitchView];
    
    tagList = [[DWTagList alloc] initWithFrame:CGRectMake(15.0f, 250.0f,310.0f, 100.0f)];
    tagList.tagDelegate=self;
    [mainScroll addSubview:tagList];
    
    hud  = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"获取中...";
    [self.view addSubview:hud];
    [self isHaveInfo];
}
-(void)buildSwitchView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(170, startX+110, 140, 40)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[UIColor whiteColor]CGColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds=YES;
    [self.view addSubview:view];
    
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    lb.text = @"跨服";
    lb.backgroundColor = [UIColor clearColor];
    lb.font = [UIFont boldSystemFontOfSize:14];
    lb.textColor = [UIColor blackColor];
    lb.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lb];
    
    switchView = [[UISwitch alloc]initWithFrame:CGRectMake(60, 5, 80, 30)];
    [switchView addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:switchView];
}

-(void)initText
{
    m_gameTf.text =[NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(selectCharacter, @"simpleRealm"),KISDictionaryHaveKey(selectCharacter, @"name")];
    m_tagTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"value")];
    m_countTf.text =[NSString stringWithFormat:@"%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectPeopleCount, @"value")]] ;
    gameIconImg.imageURL =[ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(selectCharacter, @"gameid")]];
}

-(void)isHaveInfo
{
    if (selectCharacter&&selectType) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"constId")] isEqualToString:@"0"]) {
            return;
        }
        selectPeopleCount = [[ItemManager singleton] createMaxVols];
        [self initText];
        
        [self getfenleiFromNetWithGameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")]];
        [self getcardFromNetWithGameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] TypeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"constId")] CharacterId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"id")]];
        [self getPersonCountFromNetWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")]typeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"constId")]];
    }
}

#pragma mark -- 标签请求成功通知
-(void)updateTeamLable:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        m_flArray = responseObject;
        [tagList setTags:responseObject average:YES rowCount:3];
        tagList.frame = CGRectMake(10.0f, 250.0f, 310, tagList.fittedSize.height);
    }
}

-(void)changeValue:(UISwitch*)sender
{

    BOOL isButtonOn = [sender isOn];
    if (isButtonOn) {
        selectCrossServer = @"1";
    }else {
        selectCrossServer = @"0";
    }
}
-(void)buildPickView
{
    m_rolePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_rolePickerView.dataSource = self;
    m_rolePickerView.delegate = self;
    m_rolePickerView.showsSelectionIndicator = YES;
    
    
    m_tagsPickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_tagsPickView.dataSource = self;
    m_tagsPickView.delegate = self;
    m_tagsPickView.showsSelectionIndicator = YES;

    m_countPickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_countPickView.dataSource = self;
    m_countPickView.delegate = self;
    m_countPickView.showsSelectionIndicator = YES;

    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];
}

-(UITextField *)buildTextFieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder rightImg:(NSString *)rightImg textColor:(UIColor *)textColor backgroundColor:(UIColor *)bgColor font:(CGFloat)font textAlignment:(NSTextAlignment)textAlignment
{
    UIImageView *customView = [[UIImageView alloc]initWithFrame:frame];
    customView.image = KUIImage(@"group_cardtf");
    customView.userInteractionEnabled = YES;
//    customView.backgroundColor = [UIColor whiteColor];
//    customView.layer.borderWidth = 1;
//    customView.layer.borderColor = [[UIColor whiteColor]CGColor];
//    customView.layer.cornerRadius = 5;
//    customView.layer.masksToBounds=YES;

    
    UITextField *tf =[[UITextField alloc]initWithFrame:CGRectMake(45, 0, frame.size.width-25, frame.size.height)];
    tf.backgroundColor = [UIColor clearColor];
    tf.textColor =textColor;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.textAlignment = textAlignment;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.font = [UIFont systemFontOfSize:font];
    tf.placeholder = placeholder;
    [customView addSubview:tf];

    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width-20, 15, 15, 10)];
    imageView.image = KUIImage(rightImg);
    [customView addSubview:imageView];
    [mainScroll addSubview:customView];
    
    return tf;
}
//点击标签
-(void)tagClick:(UIButton*)sender
{
    NSString *str = m_miaoshuTV.text;
    NSInteger ziNumOld = [[GameCommon shareGameCommon] unicodeLengthOfString:str];
    NSInteger ziNumNew = [[GameCommon shareGameCommon] unicodeLengthOfString:[NSString stringWithFormat:@"%@%@",@"  ",[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_flArray objectAtIndex:sender.tag], @"value")]]];
    
    if (ziNumOld+ziNumNew>30) {
        return;
    }
    
    m_miaoshuTV.text =[NSString stringWithFormat:@"%@%@%@",str,@"  ",[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_flArray objectAtIndex:sender.tag], @"value")]];
    placeholderL.text = @"";
    [self refreshZiLabelText];
}
//点击toolbar 确定button

#pragma mark ----toolbar 点击确定
-(void)selectServerNameOK:(id)sender
{
    if ([m_gameTf isFirstResponder]) {
        if ([m_RoleArray count] != 0) {
            selectCharacter =[m_RoleArray objectAtIndex:[m_rolePickerView selectedRowInComponent:0]];
            m_gameTf.text = [NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(selectCharacter, @"simpleRealm"),KISDictionaryHaveKey(selectCharacter, @"name")];
            gameIconImg.imageURL =[ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(selectCharacter, @"gameid")]];
            [m_gameTf resignFirstResponder];
            [self getfenleiFromNetWithGameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")]];
        }
    }
    else if ([m_tagTf isFirstResponder])
    {
        if ([m_tagsArray count] != 0) {
            selectType =[m_tagsArray objectAtIndex:[m_tagsPickView selectedRowInComponent:0]];
            m_tagTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"value")];
            [m_tagTf resignFirstResponder];
            
            m_countTf.text = [NSString stringWithFormat:@"%@人",KISDictionaryHaveKey(selectType,@"mask")];
            [self getPersonCountFromNetWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_RoleArray objectAtIndex:[m_rolePickerView selectedRowInComponent:0]], @"gameid")]typeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"constId")]];
            [self getcardFromNetWithGameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] TypeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"constId")] CharacterId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"id")]];
        }
    }
    else{
        if ([m_countArray count] != 0) {
            selectPeopleCount =[m_countArray objectAtIndex:[m_countPickView selectedRowInComponent:0]];
            m_countTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectPeopleCount, @"value")];
            [m_countTf resignFirstResponder];
        }
    }
}


#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView ==m_rolePickerView)
    {
        return m_RoleArray.count;
    }
    else if (pickerView == m_tagsPickView)
    {
        return m_tagsArray.count;
    }
    else
    {
        return m_countArray.count;
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView ==m_rolePickerView) {
        NSDictionary *dic = [m_RoleArray objectAtIndex:row];
        return [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"simpleRealm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    }
    else if (pickerView ==m_tagsPickView)
    {
        return KISDictionaryHaveKey([m_tagsArray objectAtIndex:row], @"value");
        
    }else
    {
        return KISDictionaryHaveKey([m_countArray objectAtIndex:row], @"value");
    }
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
    label.backgroundColor = [UIColor clearColor];
    [customView addSubview:label];

    if (pickerView ==m_rolePickerView) {
        NSDictionary *dic = [m_RoleArray objectAtIndex:row];
        imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
        label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"simpleRealm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    }
    else if (pickerView ==m_tagsPickView)
    {
        label.text = KISDictionaryHaveKey([m_tagsArray objectAtIndex:row], @"value");
    }else
    {
        label.text = KISDictionaryHaveKey([m_countArray objectAtIndex:row], @"value");
    }
    return customView;
}
-(void)setPersonCount:(NSDictionary*)responseObject
{
    NSArray * menCount = KISDictionaryHaveKey(responseObject, @"maxVols");
    if (menCount.count>0) {
        [m_countArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"maxVols")];
        [m_countPickView reloadInputViews];
//        selectPeopleCount = [m_countArray objectAtIndex:0];

        BOOL isOpen = [KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"crossServer"), @"mask")boolValue];
        switch (isOpen) {
            case YES:
                [switchView setOn:YES] ;
                break;
            case NO:
                [switchView setOn:NO] ;
                break;
            default:
                break;
        }
        selectCrossServer = KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"crossServer"), @"mask");
        [self setPersonle:menCount];
    }
}
//设置人数
-(void)setPersonle:(NSArray*)personArray{
    [m_countArray removeAllObjects];
    [m_countArray addObjectsFromArray:personArray];
    [m_countPickView reloadInputViews];
//    if (m_countArray.count>0) {
//        selectPeopleCount = [m_countArray objectAtIndex:0];
//        m_countTf.text =[NSString stringWithFormat:@"%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectPeopleCount, @"mask")]];
//    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    [UIView animateWithDuration:0.3 animations:^{

    mainScroll.contentOffset = CGPointMake(0, 150);
    }];
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        mainScroll.contentOffset = CGPointMake(0, 0);
    }];
    return YES;

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
        placeholderL.text = @"填写组队描述……";
    }
//    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
//    NSInteger res = m_maxZiShu-[[GameCommon shareGameCommon] unicodeLengthOfString:new];
//    if(res >= 0){
        return YES;
//    }
//    else{
//        return NO;
//    }
}

- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_miaoshuTV.text];
    if (ziNum<=0) {
//        ziNum=0;
        m_ziNumLabel.textColor = [UIColor redColor];
    }else{
        m_ziNumLabel.textColor = [UIColor blackColor];
    }
    m_ziNumLabel.text =[NSString stringWithFormat:@"%d%@%d",ziNum,@"/",m_maxZiShu];
    CGSize nameSize = [m_ziNumLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    m_ziNumLabel.frame=CGRectMake(320-nameSize.width-10-10, 215, nameSize.width, 20);
    m_ziNumLabel.backgroundColor=[UIColor clearColor];
}


#pragma mark --创建
-(void)createItem:(id)sender
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_miaoshuTV.text];

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
//    if (!selectPeopleCount) {
//        [self showAlertViewWithTitle:@"提示" message:@"请选择人数" buttonTitle:@"OK"];
//        return;
//    }
    if ([GameCommon isEmtity:m_miaoshuTV.text]) {
        [self showAlertViewWithTitle:@"提示" message:@"组队描述内容不能为空" buttonTitle:@"OK"];
        return;
    }
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
//    [paramDict setObject:[GameCommon getNewStringWithId:selectCrossServer] forKey:@"crossServer"];
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
        
        [MessageService groupNotAvailable:@"inTeamSystemMsg" Message:@"您已经成功创建了队伍" GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"groupId")] gameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] roomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"roomId")] team:@"teamchat" UserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"createTeamUser"), @"userid")]];
        
        
        [self showMessageWindowWithContent:@"创建成功" imageType:0];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlert:error];
        [hud hide:YES];
    }];
}
-(void)showErrorAlert:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {/*1000124*/
            
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"1000124"]) {
                backAlert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [backAlert show];
            }else{
            
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            }
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField ==m_tagTf) {
        if ([GameCommon isEmtity:m_gameTf.text]) {
            [m_tagTf resignFirstResponder];
            [self showMessageWindowWithContent:@"请先选择角色" imageType:0];
        }
    }
    else if (textField ==m_countTf)
    {
        if ([GameCommon isEmtity:m_gameTf.text]) {
            [m_countTf resignFirstResponder];
            [self showMessageWithContent:@"请先选择角色" point:CGPointMake(160,startX+100)];
        }else if ([GameCommon isEmtity:m_tagTf.text]){
            [m_countTf resignFirstResponder];
            [self showMessageWithContent:@"请先选择分类" point:CGPointMake(160,startX+150)];

        }
    }
}
#pragma MARK ---联网获取标签
-(void)getcardFromNetWithGameid:(NSString*)gameid TypeId:(NSString*)typeId CharacterId:(NSString*)characterId
{
    [[ItemManager singleton] getTeamLableRoom:gameid TypeId:typeId CharacterId:characterId reSuccess:^(id responseObject) {
        [self updateTeamLable:responseObject];
    } reError:^(id error) {
        [self showErrorAlert:error];
    }];
}
#pragma MARK --联网获取组队分类
-(void)getfenleiFromNetWithGameid:(NSString *)gameid
{
    [[ItemManager singleton] getTeamType:gameid reSuccess:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [responseObject removeObjectAtIndex:0];
            [m_tagsArray removeAllObjects];
            [m_tagsArray addObjectsFromArray:responseObject];
            [m_tagsPickView reloadInputViews];
        }
    } reError:^(id error) {
        
        [[ItemManager singleton]getTeamType:gameid reSuccess:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                [responseObject removeObjectAtIndex:0];
                [m_tagsArray removeAllObjects];
                [m_tagsArray addObjectsFromArray:responseObject];
                [m_tagsPickView reloadInputViews];
            }

        } reError:^(id error) {
            [self showErrorAlert:error];
            m_gameTf.text = @"";
            gameIconImg.imageURL = nil;

        }];
        
    }];
}
#pragma mark --- 联网获取人数列表
-(void)getPersonCountFromNetWithGameId:(NSString *)gameid typeId:(NSString *)typeId
{
    [[ItemManager singleton] getPersonCountFromNetWithGameId:gameid typeId:typeId reSuccess:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self setPersonCount:responseObject];
        }
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

- (void)dealloc
{
    backAlert.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
