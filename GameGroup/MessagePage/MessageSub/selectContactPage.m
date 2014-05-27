//
//  ContactsViewController.m
//  NewXMPPTest
//
//  Created by Tolecen on 13-6-26.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "selectContactPage.h"
#import "XMPPHelper.h"
#import "JSON.h"
#import "PersonTableCell.h"
#import "NewPersonalTableViewCell.h"
#import "ImageService.h"

@interface selectContactPage ()
{
    NSDictionary * selectDict;
    UIView* m_shareView;
    UIView* m_shareViewBg;
    NSInteger shareType;//0为好友 1为广播
    UILabel*  sharePeopleLabel;


}
@end

@implementation selectContactPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        friendDict = [NSMutableDictionary dictionary];
        sectionArray = [NSMutableArray array];
        rowsArray = [NSMutableArray array];
        sectionIndexArray = [NSMutableArray array];
    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"分享给" withBackButton:YES];
    
    self.hidesBottomBarWhenPushed = YES;
    
    self.contactsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height-startX) style:UITableViewStylePlain];
    [self.view addSubview:self.contactsTable];
    self.contactsTable.dataSource = self;
    self.contactsTable.delegate = self;
    
//    hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText = @"查询中...";
//    [hud show:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshFriendList];
    
}

-(void)refreshFriendList
{
    
    NSMutableDictionary *userinfo=[DataStoreManager  newQuerySections:@"1" ShipType2:@"2"];
    friendDict = [userinfo objectForKey:@"userList"];
    NSMutableArray* keys = [userinfo objectForKey:@"nameKey"];
    sectionArray = keys;
    [self.contactsTable reloadData];
}

-(void)addButton:(UIButton *)sender
{
    AddContactViewController * addV = [[AddContactViewController alloc] init];
    [self.navigationController pushViewController:addV animated:YES];
}
-(NSString *)convertChineseToPinYin:(NSString *)chineseName
{
    NSMutableString * theName = [NSMutableString stringWithString:chineseName];
    NSLog(@"hhhh0:%@",theName);
    CFRange range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformToLatin, NO);
    NSLog(@"hhhh1:%@",theName);
    range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformStripCombiningMarks, NO);
    NSLog(@"hhhh:%@",theName);
    NSString * dd = [theName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"hhhh3:%@",dd);
    return dd;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [friendDict allKeys].count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchBar.text];
//    NSLog(@"%@",searchBar.text);
//    
//    searchResultArray = [friendsArray filteredArrayUsingPredicate:resultPredicate ]; //注意retain
//    NSLog(@"%@",searchResultArray);
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
//        return [searchResultArray count];
//    }
    NSArray *array =[friendDict objectForKey:sectionArray[section]];
    return array.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell33";
    NewPersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[NewPersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    NSDictionary * tempDict;
        tempDict = [[friendDict objectForKey:[sectionArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.headImageV.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString *iamgeId=[GameCommon getHeardImgId:KISDictionaryHaveKey(tempDict, @"img")];
    NSURL * url=[ImageService getImageStr:iamgeId Width:80];
    cell.headImageV.imageURL = url;
    
    NSString *genderimage=[self genderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.sexImg.image =KUIImage(genderimage);
    
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    cell.nameLabel.text = nickName;
    
    NSString *titleName=KISDictionaryHaveKey(tempDict, @"titleName");
    cell.distLabel.text = (titleName==nil||[titleName isEqualToString:@""]) ? @"暂无头衔" : titleName;
    cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(tempDict, @"rarenum") integerValue]];
    CGSize nameSize = [cell.nameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.nameLabel.frame = CGRectMake(80, 5, nameSize.width + 5, 20);
    cell.sexImg.frame = CGRectMake(80 + nameSize.width, 5, 20, 20);
    NSArray * gameids=[GameCommon getGameids:KISDictionaryHaveKey(tempDict, @"gameids")];
    [cell setGameIconUIView:gameids];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        selectDict = [[friendDict objectForKey:[sectionArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self.contactDelegate getContact:selectDict];

    [self.navigationController popViewControllerAnimated:YES];
    

//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否确认发送给 %@?", KISDictionaryHaveKey(selectDict, @"displayName")] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    alert.tag = 567;
//    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 567) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.contactDelegate getContact:selectDict];

//            [self dismissViewControllerAnimated:YES completion:^{
//                
//            }];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
//        return 1;
//    }
//    
//    return sectionArray.count;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
//    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
//        return @"";
//    }
    return [sectionArray objectAtIndex:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionArray;
}
-(void)back
{
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";//
    }
}
//性别图标
-(NSString*)genderImage:(NSString*)gender
{
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}

#pragma mark -分享功能

/*
- (void)setShareView
{
    if (m_shareView == nil) {
        m_shareViewBg = [[UIView alloc] initWithFrame:self.view.frame];
        m_shareViewBg.backgroundColor = [UIColor blackColor];
        m_shareViewBg.alpha = 0.5;
        [self.view addSubview:m_shareViewBg];
        
        m_shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 170)];
        m_shareView.center = self.view.center;
        m_shareView.backgroundColor = [UIColor whiteColor];
        m_shareView.layer.cornerRadius = 3;
        m_shareView.layer.masksToBounds = YES;
        [self.view addSubview:m_shareView];
        
        CGSize titleSize = CGSizeZero;
        if ([GameCommon getNewStringWithId:KISDictionaryHaveKey(self.contentDic, @"title")].length > 0) {
            titleSize = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.contentDic, @"title")] sizeWithFont:[UIFont boldSystemFontOfSize:15.0] constrainedToSize:CGSizeMake(260, 40)];
        }
        
        //        float titleHeg = titleSize.height > 50 ? 50 : titleSize.height;
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 260, titleSize.height)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 2;
        titleLabel.text = KISDictionaryHaveKey(self.contentDic, @"title");
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [m_shareView addSubview:titleLabel];
        
        if ([GameCommon getNewStringWithId:KISDictionaryHaveKey(self.contentDic, @"thumb")].length > 0 && ![[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.contentDic, @"thumb")] isEqualToString:@"null"]) {
            EGOImageView* thumb = [[EGOImageView alloc] initWithFrame:CGRectMake(10, (titleSize.height > 0 ? titleSize.height : 10) + 15, 50, 50)];
            thumb.layer.cornerRadius = 5;
            thumb.layer.masksToBounds = YES;
            thumb.placeholderImage = KUIImage(@"have_picture");
            NSString* imgStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.contentDic, @"thumb")];
            NSURL * titleImage = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/50",imgStr]];
            thumb.imageURL = titleImage;
            [m_shareView addSubview:thumb];
            
            CGSize contentSize = [KISDictionaryHaveKey(self.contentDic, @"msg") sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(200, 50)];
            UILabel* contentLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(70, (titleSize.height > 0 ? titleSize.height : 10) + 15, 170, contentSize.height) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:KISDictionaryHaveKey(self.contentDic, @"msg") textAlignment:NSTextAlignmentLeft];
            contentLabel.numberOfLines = 0;
            [m_shareView addSubview:contentLabel];
        }
        else
        {
            CGSize contentSize = [KISDictionaryHaveKey(self.contentDic, @"msg") sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(260, 50)];
            
            UILabel* contentLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, (titleSize.height > 0 ? titleSize.height : 10) + 15, 260, contentSize.height) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:KISDictionaryHaveKey(self.contentDic, @"msg") textAlignment:NSTextAlignmentLeft];
            contentLabel.numberOfLines = 0;
            [m_shareView addSubview:contentLabel];
        }
        if (shareType == 0) {
            sharePeopleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(15, 95, 250, 30) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont systemFontOfSize:13.0] text:[NSString stringWithFormat:@"分享给：%@", KISDictionaryHaveKey(selectDict, @"displayName")] textAlignment:NSTextAlignmentLeft];
        }
        else
        {
            sharePeopleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(15, 95, 250, 30) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont systemFontOfSize:13.0] text:@"分享给：好友及粉丝" textAlignment:NSTextAlignmentLeft];
        }
        [m_shareView addSubview:sharePeopleLabel];
        
        UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 125, 120, 35)];
        [cancelBtn setBackgroundColor:kColorWithRGB(186, 186, 186, 1.0)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_shareView addSubview:cancelBtn];
        
        UIButton* sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(145, 125, 120, 35)];
        [sendBtn setBackgroundColor:kColorWithRGB(35, 167, 211, 1.0)];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(okShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_shareView addSubview:sendBtn];
    }
    else
    {
        m_shareViewBg.hidden = NO;
        m_shareView.hidden = NO;
        if (shareType == 0) {
            sharePeopleLabel.text = [NSString stringWithFormat:@"分享给：%@", KISDictionaryHaveKey(selectDict, @"displayName")];
        }
        else
        {
            sharePeopleLabel.text = @"分享给：好友及粉丝";
        }
    }
    
}

*/


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
