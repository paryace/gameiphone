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
    m_tagsArray = [NSMutableArray array];
    m_RoleArray = [NSMutableArray array];
    m_flArray  = [NSMutableArray array];
    m_countArray  = [NSMutableArray array];
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
}


#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView ==m_rolePickerView) {
        return m_RoleArray.count;
    }else if (pickerView == m_countPickView)
    {
        return m_countArray.count;
    }
    else{
        return m_countArray.count;
    }
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
{
    if (pickerView ==m_rolePickerView) {
        return nil;
    }
    else if (pickerView == m_countPickView)
    {
        return KISDictionaryHaveKey([m_flArray objectAtIndex:row], @"name");
    }
    else{
        return KISDictionaryHaveKey([m_countArray objectAtIndex:row], @"name");
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
    return nil;
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
-(void)getcardWithNet
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:(self.gameid?self.gameid:self.gameid) forKey:@"gameid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"285" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_tagsArray removeAllObjects];
            [m_tagsArray addObjectsFromArray:responseObject];
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
