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
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 567) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.contactDelegate getContact:selectDict];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
