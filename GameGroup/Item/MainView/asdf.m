//
//  asdf.m
//  GameGroup
//
//  Created by 魏星 on 14-8-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "asdf.h"
#import "NewFirstCell.h"
@implementation asdf
{
    BOOL isRun;
    float dd ;
    UIActionSheet *editActionSheet;
    NSInteger      actionSheetCount;
    UITableView *myTableView;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        dd = 10.0f;
        // Initialization code
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, frame.size.height) style:UITableViewStylePlain];
        myTableView.delegate = self;
        myTableView.dataSource = self;
        //        self.myTableView.bounces = NO;
        //        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:myTableView];
        [GameCommon setExtraCellLineHidden:myTableView];
        isRun = YES;
        [self getcontent];
    }
    return self;
}
-(void)getcontent
{
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"301" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            self.personCountLb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"roomCount")];
//            self.teamCountLb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"userCount")];
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


-(void)receiveMsg:(NSDictionary *)msg{
    NSMutableDictionary * msgPayloadDic = [KISDictionaryHaveKey(msg, @"payload") JSONValue];
//    self.personCountLb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msgPayloadDic, @"roomCount")];
//    self.teamCountLb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msgPayloadDic, @"userCount")];
    for (NSMutableDictionary * dic in self.firstDataArray) {
        if ([KISDictionaryHaveKey(msgPayloadDic, @"gameid") intValue] == [KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") intValue]&&[KISDictionaryHaveKey(msgPayloadDic, @"preferenceId") intValue] == [KISDictionaryHaveKey(dic, @"preferenceId") intValue]) {
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgPayloadDic, @"characterName")] forKey:@"characterName"];
            [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgPayloadDic, @"description")] forKey:@"description"];
            [dic setObject:[GameCommon getNewStringWithId:[NSString stringWithFormat:@"%d",[KISDictionaryHaveKey(dic, @"msgCount") intValue]+1]] forKey:@"msgCount"];
        }
    }
    [self.firstDataArray sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        return [KISDictionaryHaveKey(obj1, @"msgTime") intValue] < [KISDictionaryHaveKey(obj2, @"msgTime") intValue];
    }];
    [myTableView reloadData];
}

-(void)readMsg:(NSString *)gameId PreferenceId:(NSString*)preferenceId{
    for (NSMutableDictionary * dic in self.firstDataArray) {
        if ([gameId intValue] == [KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") intValue]&&[preferenceId intValue] == [KISDictionaryHaveKey(dic, @"preferenceId") intValue]) {
            [dic setObject:@"0" forKey:@"msgCount"];
        }
        [myTableView reloadData];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.firstDataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    NewFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[NewFirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    NSDictionary *dic = [self.firstDataArray objectAtIndex:indexPath.row];
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
//     [self.myDelegate enterEditPageWithRow:indexPath.row isRow:0];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

/*
 
 
 
 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
