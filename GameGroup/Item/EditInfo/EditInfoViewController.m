//
//  EditInfoViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "EditInfoViewController.h"

@interface EditInfoViewController ()
{
    UITextView *firstTextView;
    UITextView *secondTextView;
    DWTagList     *  tagList;
    NSMutableArray  *  m_flArray;
    UILabel       *  placeholderL;
    UILabel       *  m_ziNumLabel;
    NSInteger        m_maxZiShu;


}
@end

@implementation EditInfoViewController

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
    m_maxZiShu = 30;
    
    [self setTopViewWithTitle:@"队伍信息设置" withBackButton:YES];
    m_flArray = [NSMutableArray array];

    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(saveChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    firstTextView = [[UITextView alloc]initWithFrame:CGRectMake(20, startX+10, 280, 90)];
    firstTextView.font = [UIFont systemFontOfSize:14];
    firstTextView.backgroundColor = [UIColor whiteColor];
    firstTextView.text = self.firstStr;
    firstTextView.delegate = self;
    [self.view addSubview:firstTextView];
    
    m_ziNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(300-10-10, startX+80, 100, 20)];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.font= [UIFont systemFontOfSize:12];
    m_ziNumLabel.text = [NSString stringWithFormat:@"%d/%d",firstTextView.text.length,m_maxZiShu];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:m_ziNumLabel];

    
    tagList = [[DWTagList alloc]initWithFrame:CGRectMake(20, startX+110, 280, 60)];
    tagList.tagDelegate=self;
    [self.view addSubview:tagList];
    
    
//    secondTextView =  [[UITextView alloc]initWithFrame:CGRectMake(20, startX+90, 280, 70)];
//    secondTextView.font = [UIFont systemFontOfSize:14];
//    secondTextView.text = self.secondStr;
//    secondTextView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:secondTextView];

//    UIButton *dissolutionRoom = [[UIButton alloc]initWithFrame:CGRectMake(20, startX+180, 280, 44)];
////    [dissolutionRoom setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
////    [dissolutionRoom setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
//    dissolutionRoom.backgroundColor = [UIColor grayColor];
//    [dissolutionRoom setTitle:@"解散群组" forState:UIControlStateNormal];
////    dissolutionRoom.backgroundColor = [UIColor clearColor];
//    [dissolutionRoom addTarget:self action:@selector(dissolutionRoom:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:dissolutionRoom];

    hud = [[MBProgressHUD alloc]initWithView: self.view];
    [self.view addSubview:hud];
    hud.labelText = @"保存中...";
    [self getcardFromNetWithGameid:self.gameid TypeId:self.typeId CharacterId:self.characterId];
    // Do any additional setup after loading the view.
}
-(void)getcardFromNetWithGameid:(NSString*)gameid TypeId:(NSString*)typeId CharacterId:(NSString*)characterId
{
    [[ItemManager singleton] getTeamLableRoom:gameid TypeId:typeId CharacterId:characterId reSuccess:^(id responseObject) {
        [self updateTeamLable:responseObject];
    } reError:^(id error) {
        [self showErrorAlert:error];
    }];
}
#pragma mark -- 标签请求成功通知
-(void)updateTeamLable:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        m_flArray = responseObject;
        [tagList setTags:responseObject average:YES rowCount:3];
        tagList.frame = CGRectMake(20.0f, startX+ 110.0f, tagList.fittedSize.width-10, tagList.fittedSize.height);
    }
}
-(void)tagClick:(UIButton*)sender
{
    
    NSInteger textlength = [[GameCommon shareGameCommon] unicodeLengthOfString:firstTextView.text];
    
    NSString * tagValue =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey([m_flArray objectAtIndex:sender.tag], @"value")];
    NSInteger tagValueLength = [[GameCommon shareGameCommon] unicodeLengthOfString:tagValue];
    if (textlength+tagValueLength>30) {
        return;
    }
    if (firstTextView.text&&firstTextView.text.length>0) {
        firstTextView.text =[NSString stringWithFormat:@"%@ %@",firstTextView.text,[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_flArray objectAtIndex:sender.tag], @"value")]];
    }else{
        firstTextView.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_flArray objectAtIndex:sender.tag], @"value")];

    }
    
    
    placeholderL.text = @"";
    [self refreshZiLabelText];
}

-(void)saveChanged:(id)sender
{
    [hud show:YES];
    [firstTextView resignFirstResponder];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:self.itemId forKey:@"roomId"];
    [paramDict setObject:firstTextView.text forKey:@"description"];
    [paramDict setObject:self.gameid forKey:@"gameid"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"274" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate refreshMyTeamInfoWithViewController:self];
        [self showMessageWindowWithContent:@"修改成功" imageType:0];
 
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];

}




-(void)dissolutionRoom:(id)sender
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.itemId forKey:@"roomId"];
    [postDict setObject:paramDict forKey:@"params"];

    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"270" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self showMessageWindowWithContent:@"解散成功" imageType:1];
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
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
#pragma mark - text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = m_maxZiShu-[[GameCommon shareGameCommon] unicodeLengthOfString:new];
    if(res >= 0){
        return YES;
    }
    else{
        m_ziNumLabel.textColor = [UIColor redColor];
        return NO;
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}
- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:firstTextView.text];
    if (ziNum<0) {
        ziNum=0;
    }else{
        m_ziNumLabel.textColor = [UIColor blackColor];
    }
    m_ziNumLabel.text =[NSString stringWithFormat:@"%d%@%d",ziNum,@"/",m_maxZiShu];
    CGSize nameSize = [m_ziNumLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    m_ziNumLabel.frame=CGRectMake(320-nameSize.width-10-20, 80+startX, nameSize.width, 20);
    m_ziNumLabel.backgroundColor=[UIColor clearColor];
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
