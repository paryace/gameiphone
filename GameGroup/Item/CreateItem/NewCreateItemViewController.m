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
    
    NSMutableDictionary  *m_uploadDict;
    
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
    m_uploadDict = [NSMutableDictionary dictionary];
    [self buildPickView];
    
    m_gameTf = [self buildTextFieldWithFrame:CGRectMake(10, startX+10 , 300, 40) placeholder:@"请选择游戏" rightImg:@"right" textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] font:14 textAlignment:NSTextAlignmentRight];
    m_gameTf.delegate = self;
    m_gameTf.inputAccessoryView = toolbar;
    m_gameTf.inputView = m_rolePickerView;

    [self.view addSubview:m_gameTf];
    
    m_tagTf = [self buildTextFieldWithFrame:CGRectMake(10, startX+60, 300, 40) placeholder:@"请选择分类" rightImg:@"right" textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] font:14 textAlignment:NSTextAlignmentRight];
    m_tagTf.delegate = self;
    m_tagTf.inputAccessoryView = toolbar;
    m_tagTf.inputView = m_tagsPickView;

    [self.view addSubview:m_tagTf];

    m_countTf = [self buildTextFieldWithFrame:CGRectMake(10, startX+110, 140, 40) placeholder:@"请选择人数" rightImg:@"right" textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] font:14 textAlignment:NSTextAlignmentCenter];
    m_countTf.delegate = self;
    m_countTf.inputAccessoryView = toolbar;
    m_countTf.inputView = m_countPickView;

    [self.view addSubview:m_countTf];

    
    m_miaoshuTV = [[UITextView alloc]initWithFrame:CGRectMake(10, startX+160, 300, 80)];
    m_miaoshuTV.backgroundColor = [UIColor whiteColor];
    m_miaoshuTV.layer.borderWidth = 1;
    m_miaoshuTV.layer.borderColor = [[UIColor grayColor]CGColor];
    m_miaoshuTV.layer.cornerRadius = 5;
    m_miaoshuTV.layer.masksToBounds=YES;
    m_miaoshuTV.delegate = self;
    [self.view addSubview:m_miaoshuTV];
    
    placeholderL = [[UILabel alloc]initWithFrame:CGRectMake(15, startX+165, 200, 20)];
    placeholderL.backgroundColor = [UIColor clearColor];
    placeholderL.textColor = [UIColor grayColor];
    placeholderL.text = @"填写组队描述……";
    placeholderL.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:placeholderL];

    m_ziNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(300-10-10, startX+245, 100, 20)];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.font= [UIFont systemFontOfSize:12];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:m_ziNumLabel];

    tagList = [[DWTagList alloc] initWithFrame:CGRectMake(10.0f, startX+250.0f,300.0f, 300.0f)];
    tagList.tagDelegate=self;
    [self.view addSubview:tagList];

    
    // Do any additional setup after loading the view.
}

-(void)buildSwitchViewWithDic:(NSDictionary *)dic
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(170, startX+110, 140, 40)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[UIColor grayColor]CGColor];
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
    
    UISwitch *switchView = [[UISwitch alloc]initWithFrame:CGRectMake(60, 5, 80, 30)];
    BOOL isOpen = [KISDictionaryHaveKey(dic, @"mask")boolValue];
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
    [switchView addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:switchView];
}

-(void)changeValue:(UISwitch*)sender
{
    BOOL isButtonOn = [sender isOn];
    if (isButtonOn) {
        [m_uploadDict setObject:@"1" forKey:@"crossServer"];
    }else {
        [m_uploadDict setObject:@"0" forKey:@"crossServer"];
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
    UITextField *tf =[[UITextField alloc]initWithFrame:frame];
    tf.backgroundColor = bgColor;
    tf.textColor =textColor;
    tf.textAlignment = textAlignment;
    tf.font = [UIFont systemFontOfSize:font];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.placeholder = placeholder;
    EGOImageView *gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(frame.size.width-20, 15, 12.5, 12.5)];
    [tf addSubview:gameIconImg];
    
    
    return tf;
}
-(void)tagClick:(UIButton*)sender
{
    m_miaoshuTV.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_flArray objectAtIndex:sender.tag], @"value")];
    placeholderL.text = @"";
}
//点击toolbar 确定button
-(void)selectServerNameOK:(id)sender
{
    if ([m_gameTf isFirstResponder]) {
        if ([m_RoleArray count] != 0) {
         NSDictionary *   selectCharacter =[m_RoleArray objectAtIndex:[m_rolePickerView selectedRowInComponent:0]];
            m_gameTf.text = [NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(selectCharacter, @"simpleRealm"),KISDictionaryHaveKey(selectCharacter, @"name")];
            [m_uploadDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"id")] forKey:@"characterId"];
            [m_uploadDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] forKey:@"gameid"];
            [m_gameTf resignFirstResponder];
            [self getfenleiFromNetWithGameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")]];
            
            [self getcardFromNetWithGameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")]];
            
        }
    }
    else if ([m_tagTf isFirstResponder])
    {
        if ([m_tagsArray count] != 0) {
            NSDictionary *  selectCharacter =[m_tagsArray objectAtIndex:[m_tagsPickView selectedRowInComponent:0]];
            m_tagTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"value")];

            [m_tagTf resignFirstResponder];
            [m_uploadDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"constId")] forKey:@"typeId"];
            
            [self getPersonCountFromNetWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_RoleArray objectAtIndex:[m_rolePickerView selectedRowInComponent:0]], @"gameid")]typeId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"constId")]];
        }
    }
    else{
        if ([m_countArray count] != 0) {
            NSDictionary *  selectCharacter =[m_countArray objectAtIndex:[m_countPickView selectedRowInComponent:0]];
            m_countTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"value")];
            [m_countTf resignFirstResponder];
            [m_uploadDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"mask")] forKey:@"maxVol"];
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

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    if (pickerView ==m_rolePickerView) {
        NSDictionary *dic = [m_RoleArray objectAtIndex:row];
        UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
        imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
        [customView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"simpleRealm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
        [customView addSubview:label];
        return customView;

    }
    else if (pickerView ==m_tagsPickView)
    {
        UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = KISDictionaryHaveKey([m_tagsArray objectAtIndex:row], @"value");
        [customView addSubview:label];
        return customView;

    }else
    {
        UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = KISDictionaryHaveKey([m_countArray objectAtIndex:row], @"value");
        [customView addSubview:label];
        return customView;
    }
}
-(void)getfenleiFromNetWithGameid:(NSString *)gameid
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:gameid forKey:@"gameid"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"277" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_tagsArray removeAllObjects];
            [m_tagsArray addObjectsFromArray:responseObject];
            [m_tagsPickView reloadInputViews];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
//        [self showErrorAlert:error];
        [hud hide:YES];
    }];

    
}

-(void)getPersonCountFromNetWithGameId:(NSString *)gameid typeId:(NSString *)typeId
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:gameid forKey:@"gameid"];
    [paramDict setObject:typeId forKey:@"typeId"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"298" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [m_countArray removeAllObjects];
            [m_countArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"maxVols")];
            [m_countPickView reloadInputViews];
            [self buildSwitchViewWithDic:KISDictionaryHaveKey(responseObject, @"crossServer")];
            
            [m_uploadDict setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"crossServer"), @"mask") forKey:@"crossFire"];

        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        //        [self showErrorAlert:error];
        [hud hide:YES];
    }];
    
    
}


- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}


#pragma mark - text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length>0 || text.length != 0) {
        placeholderL.text = @"";
    }else{
        placeholderL.text = @"填写组队描述……";
    }
    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = m_maxZiShu-[[GameCommon shareGameCommon] unicodeLengthOfString:new];
    if(res >= 0){
        return YES;
    }
    else{
//        [self showAlertViewWithTitle:@"提示" message:@"最多不能超过100个字" buttonTitle:@"确定"];
        m_ziNumLabel.textColor = [UIColor redColor];
        return NO;
    }
}

- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_miaoshuTV.text];
    if (ziNum<0) {
        ziNum=0;
    }else{
        m_ziNumLabel.textColor = [UIColor blackColor];
    }
    m_ziNumLabel.text =[NSString stringWithFormat:@"%d%@%d",ziNum,@"/",m_maxZiShu];
    CGSize nameSize = [m_ziNumLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    m_ziNumLabel.frame=CGRectMake(320-nameSize.width-10-10, 215+startX, nameSize.width, 20);
    m_ziNumLabel.backgroundColor=[UIColor clearColor];
}


#pragma MARK ---联网获取标签
-(void)getcardFromNetWithGameid:(NSString*)gameid
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:gameid forKey:@"gameid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"285" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_flArray removeAllObjects];
            [m_flArray addObjectsFromArray:responseObject];
            [tagList setTags:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        [hud hide:YES];
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


#pragma mark --创建
-(void)createItem:(id)sender
{
    if ([GameCommon isEmtity:m_gameTf.text]) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择游戏" buttonTitle:@"OK"];
        return;
    }
    if ([GameCommon isEmtity:m_tagTf.text]) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return;
    }
    if ([GameCommon isEmtity:m_countTf.text]) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择人数" buttonTitle:@"OK"];
        return;
    }
    if ([GameCommon isEmtity:m_miaoshuTV.text]) {
        [self showAlertViewWithTitle:@"提示" message:@"组队描述内容不能为空" buttonTitle:@"OK"];
    }
    [hud show:YES];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_uploadDict, @"characterId")] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_uploadDict, @"gameid")] forKey:@"gameid"];
    [paramDict setObject:m_miaoshuTV.text forKey:@"description"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_uploadDict, @"typeId")] forKey:@"typeId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_uploadDict, @"maxVol")] forKey:@"maxVol"];
    
    
    if ([[m_uploadDict allKeys]containsObject:@"crossServer"]) {
        [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_uploadDict, @"crossServer")] forKey:@"crossServer"];
    }else{
        [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_uploadDict, @"crossFire")] forKey:@"crossServer"];
    }


    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"265" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        //发送通知 刷新我的组队页面
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
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
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    
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
