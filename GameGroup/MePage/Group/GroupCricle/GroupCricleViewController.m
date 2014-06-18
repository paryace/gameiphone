//
//  GroupCricleViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupCricleViewController.h"
#import "NearByPhotoCell.h"
#import "LocationManager.h"
#import "TestViewController.h"
#import "MJRefresh.h"
#import "PhotoViewController.h"
#import "OnceDynamicViewController.h"
#import "ReplyViewController.h"
#import "NearByViewController.h"
typedef enum : NSUInteger {
    CommentInputTypeKeyboard,
    CommentInputTypeEmoji,
} CommentInputType;
@interface GroupCricleViewController ()
{
    UICollectionView *m_photoCollectionView;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    NSString *sexStr ;
    AppDelegate *app;
    NSInteger m_currPageCount;
    NSString *cityCode;
    UILabel *nearBylabel;
    UILabel*            m_titleLabel;
    NSInteger           m_searchType;//3全部 0男 1女
    UIButton *menuButton;
    NSMutableArray *wxSDArray;
    
    
    NSMutableArray *commentArray;
    NewNearByCell *openMenuBtn;
    UIView *toolView;
    UIView* tool;
    UIView *inPutView;
    NSString *commentMsgId;
    NSString *destuserId;
    NSString *destMsgId;
    BOOL isComeBackComment;
    UITapGestureRecognizer *hidenMenuTap;
    NSString *methodStr;
    UIButton *senderBnt;
    NSMutableDictionary *cellhightarray;//存放每个Cell的高度
    NSMutableDictionary *commentOffLineDict;
    NSMutableDictionary *delcommentDic;
    float offer;
    int height;
    BOOL _keyboardIsVisible;
}
@property (nonatomic, assign) CommentInputType commentInputType;
@property (nonatomic, strong) EmojiView *theEmojiView;
@end

@implementation GroupCricleViewController
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:Nil];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setTopViewWithTitle:@"群动态" withBackButton:YES];
    
    m_currPageCount = 0;
    m_dataArray = [NSMutableArray array];
    wxSDArray = [NSMutableArray array];
    commentArray = [NSMutableArray array];
    commentOffLineDict = [NSMutableDictionary dictionary];
    cellhightarray = [NSMutableDictionary dictionary];
    delcommentDic = [NSMutableDictionary dictionary];
    
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    NSMutableDictionary * groupInfo = [[GroupManager singleton] getGroupInfo:self.groupId];
    NSString * nickName = KISDictionaryHaveKey(groupInfo, @"groupName");
    UIImageView *topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 187)];
    topImageView.image = KUIImage(@"groupinfo_top");
    [self.view addSubview:topImageView];
    
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 157, 320, 30)];
    lb.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
    lb.textColor = [UIColor whiteColor];
    lb.font = [UIFont systemFontOfSize:12];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.text = nickName;
    [topImageView addSubview:lb];
    m_myTableView.tableHeaderView = topImageView;
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"加载中...";
    [self.view addSubview:hud];
    
    
    [self getInfoWithNet];
    [self addheadView];
    [self addFootView];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    
    NSString *path1  =[RootDocPath stringByAppendingString:@"/HC_groupInfoList"];
    BOOL isTrue1 = [fileManager fileExistsAtPath:path1];
    NSDictionary *fileAttr1 = [fileManager attributesOfItemAtPath:path1 error:NULL];
    if (isTrue1 && [[fileAttr1 objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        m_dataArray= [NSMutableArray arrayWithContentsOfFile:path1];
    }
    [self.view addSubview:self.theEmojiView];
    self.theEmojiView.hidden = YES;
    
    
    
    [self buildcommentView];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if (openMenuBtn.menuImageView.hidden==NO) {
        openMenuBtn.menuImageView.hidden =YES;
    }
    if([self.textView isFirstResponder]){
        [self.textView resignFirstResponder];
    }
    if(self.theEmojiView.hidden == NO){
        self.theEmojiView.hidden = YES;
        [self autoMovekeyBoard:-inPutView.bounds.size.height];
        self.commentInputType = CommentInputTypeKeyboard;
        senderBnt.selected = NO;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
-(void)buildcommentView
{
    inPutView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    [self.view addSubview:inPutView];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    tapGr.delegate = self;
    [self.view addGestureRecognizer:tapGr];
    
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 7, 240, 35)];
    self.textView.isScrollable = NO;
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
	self.textView.returnKeyType = UIReturnKeyDone;
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"chat_input.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(10, 7, 240, 35);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"inputbg.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, inPutView.frame.size.width, inPutView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [inPutView addSubview:imageView];
    [inPutView addSubview:entryImageView];
    [inPutView addSubview:self.textView];
    
    senderBnt = [UIButton buttonWithType:UIButtonTypeCustom];
    [senderBnt setBackgroundImage:KUIImage(@"emoji") forState:UIControlStateNormal];
    [senderBnt setBackgroundImage:KUIImage(@"keyboard.png") forState:UIControlStateSelected];
    [senderBnt addTarget:self action:@selector(emojiBtnClicked:) forControlEvents:UIControlEventTouchDown];
    senderBnt.frame = CGRectMake(260, 0, 50, 50);
    [inPutView bringSubviewToFront:senderBnt];
    
    [inPutView addSubview:senderBnt];
}

#pragma mark ---- 网络请求
-(void)getInfoWithNet
{
    [hud show:YES];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"248" forKey:@"method"];
     [paramDic setObject:self.groupId forKey:@"groupId"];
    [paramDic setObject:@(m_currPageCount) forKey:@"firstResult"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject||![responseObject isKindOfClass:[NSArray class]]){
            return ;
        }
        if (m_currPageCount ==0) {
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray:responseObject];
            for (int i =0; i <m_dataArray.count; i++) {
                m_dataArray[i] = [self contentAnalyzer:m_dataArray[i] withReAnalyzer:NO];
            }
            NSString *filePath = [RootDocPath stringByAppendingString:@"/HC_groupInfoList"];
            [m_dataArray writeToFile:filePath atomically:YES];
        }else{
            NSMutableArray *arr  = [NSMutableArray array];
            NSArray *arrays = [NSArray arrayWithArray:responseObject];
            for (int i =0; i<arrays.count; i++) {
                [arr addObject:[self contentAnalyzer:arrays[i] withReAnalyzer:NO]];
            }
            [m_dataArray addObjectsFromArray:arr];
            
        }
        [m_myTableView reloadData];
        [m_footer endRefreshing];
        [m_header endRefreshing];
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                
            }
        }
        [m_footer endRefreshing];
        [m_header endRefreshing];
        
        [hud hide:YES];
    }];
    
}

#pragma mark----
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (m_dataArray.count>0) {
        m_myTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    else
    {
        m_myTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    NewNearByCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[NewNearByCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    float m_currmagY =0;
    cell.backgroundColor= [UIColor whiteColor];
    cell.myCellDelegate = self;
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
    if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"unkown"]||[KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"3"]) {
        cell.focusButton.hidden=NO;
    }else
    {
        cell.focusButton.hidden=YES;
    }
    NSString * imageIds = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img");
    cell.headImgBtn.imageURL = [ImageService getImageStr:imageIds Width:80];
    
    //判断赞按钮状态显示相应的图标
    UIButton *button  = cell.zanBtn;
    NSString *isZan=KISDictionaryHaveKey(dict, @"isZan");
    if (isZan !=nil ){
        if([isZan intValue]==0){
            [button setBackgroundImage:[UIImage imageNamed:@"zan_circle_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"zan_circle_click"] forState:UIControlStateHighlighted];
        }else{
            [button setBackgroundImage:[UIImage imageNamed:@"cancle_zan_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"cancle_zan_click"] forState:UIControlStateHighlighted];
        }
    }
    
    
    NSString * nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    }
    cell.nickNameLabel.text =nickName;
    m_currmagY += cell.nickNameLabel.frame.size.height+cell.nickNameLabel.frame.origin.y;//加上nickName的高度
    cell.commentCount = [KISDictionaryHaveKey(dict, @"commentNum")intValue];
    //计算时间
    NSString *time;
    if(![[dict allKeys]containsObject:@"MessageTime"]){
        time = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]];
    }
    else
    {
        time =KISDictionaryHaveKey(dict, @"MessageTime");
    }
    cell.timeLabel.text = time;
    
    //开始正文布局
    NSString *urlLink = KISDictionaryHaveKey(dict, @"urlLink");
    //动态
    if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil) {
        cell.shareView.hidden = YES;
        cell.shareInfoLabel.hidden = YES;
        cell.shareImageView.hidden = YES;
        [cell.titleLabel setEmojiText:KISDictionaryHaveKey(dict, @"msg")];
        
        //动态的高度
        float height1 = [KISDictionaryHaveKey(dict, @"titleLabelHieght") floatValue];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, height1);
        m_currmagY += height1 + 5;
        
        
        //无图动态
        if ([KISDictionaryHaveKey(dict, @"img") isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img") isEqualToString:@" "]) {
            cell.photoCollectionView.hidden =YES;
            
            cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 120, 30);
            cell.openBtn.frame = CGRectMake(270,m_currmagY+5, 50, 40);
            cell.jubaoBtn.frame = CGRectMake(150, m_currmagY+10, 60, 30);
        }
        //有图动态
        else{
            NSArray *imgArray = KISDictionaryHaveKey(dict, @"imgArray");
            cell.photoArray = imgArray;
            cell.photoCollectionView.hidden = NO;
            
            float imgHeight = [KISDictionaryHaveKey(dict, @"imgHieght") floatValue];
            cell.photoCollectionView.frame = CGRectMake(60, m_currmagY, 250,imgHeight);
            m_currmagY += imgHeight;
            
            CGFloat paddingY = 2;
            CGFloat paddingX = 2;
            cell.layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
            cell.layout.minimumLineSpacing = paddingY;
            
            [cell.photoCollectionView reloadData];
            cell.timeLabel.frame = CGRectMake(60,m_currmagY, 120, 30);
            cell.openBtn.frame = CGRectMake(270,m_currmagY-5, 50, 40);
            cell.jubaoBtn.frame = CGRectMake(150, m_currmagY, 60, 30);
            
        }
        
        m_currmagY=cell.timeLabel.frame.origin.y + cell.timeLabel.frame.size.height;
    }
    //后台文章 - URLlink有内容的
    else
    {
        cell.shareView.hidden = NO;
        cell.shareInfoLabel.hidden = NO;
        cell.shareImageView.hidden = NO;
        cell.photoCollectionView.hidden =YES;
        cell.titleLabel.text = KISDictionaryHaveKey(dict, @"title");
        
        float titleLabelHeight;
        //文章高度
        titleLabelHeight = [KISDictionaryHaveKey(dict, @"titleLabelHieght") floatValue];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, titleLabelHeight);
        cell.shareView.frame = CGRectMake(60, titleLabelHeight+35, 250, 50);
        //titleLabelHeight +=5;
        m_currmagY += titleLabelHeight+50 ;
        
        //去除掉首尾的空白字符和换行字符
        NSString *str = KISDictionaryHaveKey(dict, @"msg");
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        cell.shareInfoLabel.text =str;
        
        
        [cell.shareView addTarget:self action:@selector(enterInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareView.tag = indexPath.row;
        
        NSString * imageId=KISDictionaryHaveKey(dict, @"img");
        //无图文章
        if ([GameCommon isEmtity:imageId]) {
            cell.shareImageView.imageURL =nil;
            cell.shareImageView.hidden =YES;
            cell.shareInfoLabel.frame = CGRectMake(5, 5, 245, 40);
            cell.shareInfoLabel.numberOfLines =2;
        }else{  //有图文章
            cell.shareImageView.hidden =NO;
            cell.shareImageView.imageURL = [ImageService getImageUrl4:imageId];
            cell.shareInfoLabel.frame = CGRectMake(60, 5, 190, 40);
            cell.shareInfoLabel.numberOfLines = 2;
        }
        
        cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 120, 30);
        cell.openBtn.frame = CGRectMake(270,m_currmagY+5, 50, 40);
        cell.jubaoBtn.frame = CGRectMake(150, m_currmagY+10, 60, 30);
        m_currmagY  = cell.timeLabel.frame.origin.y + cell.timeLabel.frame.size.height;
    }
    
    // 赞，取最后一个用户的昵称显示
    if ([KISDictionaryHaveKey(dict, @"zanNum")intValue]!=0) {
        NSArray *array = KISDictionaryHaveKey(dict, @"zanList");
        if (array.count>0){ //以前的数据有些没有zanlist
            cell.zanView.frame = CGRectMake(59, m_currmagY, 251, 25);
            NSString * nickName=KISDictionaryHaveKey([array objectAtIndex:0], @"alias");
            if ([GameCommon isEmtity:nickName]) {
                nickName=KISDictionaryHaveKey([array objectAtIndex:0], @"nickname");
            }
            NSString *zanNickName=nickName;
            
            cell.zanView.hidden = NO;
            cell.zanNameLabel.text = zanNickName;
            CGSize size =[zanNickName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
            cell.zanNameLabel.frame = CGRectMake(15, 0, size.width+5, 30);
            cell.zanLabel.text = [NSString stringWithFormat:@"等%@人都觉得赞",KISDictionaryHaveKey(dict,@"zanNum")];
            cell.zanLabel.frame  = CGRectMake(20+size.width, 0, 225-15-size.width, 30);
            m_currmagY +=cell.zanView.frame.size.height;
        }
        else
        {
            cell.zanView.hidden = YES;
        }
        
    }else{
        cell.zanView.hidden = YES;
    }
    // 评论
    commentArray =KISDictionaryHaveKey(dict, @"commentList");
    cell.commentArray = commentArray;
    cell.commentTabelView.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
    [cell.commentTabelView reloadData];
    float commHieght = [KISDictionaryHaveKey(dict, @"commentListHieght") floatValue];
    cell.commentTabelView.frame = CGRectMake(60, m_currmagY, 250,commHieght);
    m_currmagY+= commHieght;
    
    if ([KISDictionaryHaveKey(dict, @"commentNum")intValue]>7) {
        cell.commentMoreBtn.hidden = NO;
        cell.commentMoreBtn.frame = CGRectMake(60, m_currmagY, 250, 20);
        [cell.commentMoreBtn setTitle:[NSString stringWithFormat:@"查看全部%@条评论",KISDictionaryHaveKey(dict, @"commentNum")] forState:UIControlStateNormal];
    }else{
        cell.commentMoreBtn.hidden = YES;
        cell.commentMoreBtn.frame = CGRectZero;
    }
    
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //用分析器初始化m_dataArray
    NSMutableDictionary *dict =[m_dataArray objectAtIndex:indexPath.row];
    [self contentAnalyzer:dict withReAnalyzer:NO];
    float currnetY = [KISDictionaryHaveKey(dict, @"cellHieght") floatValue];
    
    //以动态id为键存放每个cell的高度到集合里
    NSNumber *number = [NSNumber numberWithFloat:currnetY];
    [cellhightarray setObject:number forKey:KISDictionaryHaveKey(dict, @"id")];
    return currnetY;
}


#pragma mark --getTime //时间戳方法
- (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    if (((int)(theCurrentT-theMessageT))<60) {
        return @"1分钟以前";
    }
    if (((int)(theCurrentT-theMessageT))<60*59) {
        return [NSString stringWithFormat:@"%.f分钟以前",((theCurrentT-theMessageT)/60+1)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*24) {
        return [NSString stringWithFormat:@"%.f小时以前",((theCurrentT-theMessageT)/3600)==0?1:((theCurrentT-theMessageT)/3600)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*48) {
        return @"昨天";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    return [messageDateStr substringFromIndex:5];
}
#pragma mark ---addRefreshHeadview and refreshFootView
//添加下拉刷新
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currPageCount = 0;
        hud.labelText = @"加载中...";
        [self getInfoWithNet];
        
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    m_header = header;
}

//添加上拉加载更多
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        hud.labelText = @"加载中...";
        m_currPageCount = m_dataArray.count;
        [self getInfoWithNet];
    };
    m_footer = footer;
}
- (void)bigImgWithCircle:(NewNearByCell*)myCell WithIndexPath:(NSInteger)row
{
    NSLog(@"点击查看大图");
    NSDictionary *dict = [m_dataArray objectAtIndex:myCell.tag];
    NSArray *array1 = [NSArray  array];
    
    NSString *imgStr =KISDictionaryHaveKey(dict, @"img");
    NSString *str;
    if ([imgStr isEqualToString:@""] || [imgStr isEqualToString:@" "]) {
        str = @"";
    }else{
        str = [imgStr substringFromIndex:imgStr.length-1];
        NSString *str2;
        if ([str isEqualToString:@","]) {
            str2= [imgStr substringToIndex:imgStr.length-1];
        }
        else {
            str2 = imgStr;
        }
        array1 = [NSArray array];
        array1 = [str2 componentsSeparatedByString:@","];
    }
    PhotoViewController * pV = [[PhotoViewController alloc] initWithSmallImages:nil images:array1 indext:row];
    [self presentViewController:pV animated:NO completion:^{
    }];
    
}

-(void)enterPersonPageWithCell:(NewNearByCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    TestViewController *test = [[TestViewController alloc]init];
    test.userId = KISDictionaryHaveKey(KISDictionaryHaveKey(dic,@"user"), @"userid");
    NSString * nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname");
    }
    test.nickName = nickName;
    [self.navigationController pushViewController: test animated:YES];
}
#pragma mark Content分析器
- (NSMutableDictionary *)contentAnalyzer:(NSMutableDictionary *)contentDict withReAnalyzer:(BOOL)reAnalyzer;
{
    if ([[contentDict allKeys]containsObject:@"Analyzed"] && [KISDictionaryHaveKey(contentDict, @"Analyzed") boolValue] && !reAnalyzer ) {  //如果已经分析过
        return contentDict;
    }
    
    float cellHeight = 0.0f; //行高
    
    //昵称
    cellHeight += 30;
    
    //正文高度
    if([[contentDict allKeys]containsObject:@"titleLabelHieght"] &&!reAnalyzer)
    {
        cellHeight += [KISDictionaryHaveKey(contentDict, @"titleLabelHieght") floatValue];
    }
    else{
        
        NSString *urlLink = KISDictionaryHaveKey(contentDict, @"urlLink");
        if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil){
            //普通正文
            NSString *str = KISDictionaryHaveKey(contentDict, @"msg");
            str = [UILabel getStr:str];
            CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            [contentDict setObject:@(size.height) forKey:@"titleLabelHieght"];
            cellHeight += size.height +5 ;  //+5为了不和下面太紧
            
            //图片
            if([[contentDict allKeys]containsObject:@"imgHieght"] &&!reAnalyzer)
            {
                cellHeight +=[KISDictionaryHaveKey(contentDict, @"imgHieght") floatValue];
            }
            else{
                if([KISDictionaryHaveKey(contentDict, @"img") isEqualToString:@""]||[KISDictionaryHaveKey(contentDict, @"img") isEqualToString:@" "])
                {
                    //无图
                    cellHeight += 0;
                    
                    [contentDict setObject:@(0) forKey:@"imgHieght"];
                }
                else
                {
                    //有图， 先解析出图片数组
                    NSMutableString *imgStr = KISDictionaryHaveKey(contentDict, @"img");
                    NSString *str = [imgStr substringFromIndex:imgStr.length];
                    NSString *str2;
                    if ([str isEqualToString:@","]) {
                        str2= [imgStr substringToIndex:imgStr.length-1];
                    }
                    else {
                        str2 = imgStr;
                    }
                    NSArray *collArray = [imgStr componentsSeparatedByString:@","];
                    
                    if ([[collArray lastObject]isEqualToString:@""]||[[collArray lastObject]isEqualToString:@" "]) {
                        [(NSMutableArray*)collArray removeLastObject];
                    }
                    [contentDict setObject:collArray forKey:@"imgArray"];
                    
                    //根据图片数组接卸图片所占高度
                    int i = (collArray.count-1)/3;
                    float imgViewHeight = i*80+80; //图片的高度
                    imgViewHeight += (i+1)*2; //图片的padding, 为2
                    [contentDict setObject:@(imgViewHeight) forKey:@"imgHieght"];
                    
                    cellHeight +=imgViewHeight;
                }
            }
        }
        else {
            //分享的链接 URL
            //NSString *strTitle = KISDictionaryHaveKey(contentDict, @"title");
            NSString *strTitle = KISDictionaryHaveKey(contentDict, @"title");
            NSLog(@"strTitle:%@",strTitle);
            CGSize size1 = [strTitle sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            NSLog(@"heightfloot:%f",size1.height);
            NSNumber* titleLabelHieght = [NSNumber numberWithFloat:size1.height];
            [contentDict setObject:titleLabelHieght forKey:@"titleLabelHieght"];
            
            cellHeight += size1.height  +50 +5 ;  //+5为了不和下面太紧
        }
    }
    
    
    
    //时间label, 删除按钮与btn_more  50
    cellHeight += 50;
    
    //赞label
    if ([KISDictionaryHaveKey(contentDict, @"zanNum")intValue]!=0)
    {
        NSArray *array = KISDictionaryHaveKey(contentDict, @"zanList");
        if (array.count>0){ //以前的数据有些没有zanlist
            cellHeight +=30;
        }
    }
    
    //评论table
    if ([[contentDict allKeys]containsObject:@"commentListHieght"] &&!reAnalyzer) {
        cellHeight +=[KISDictionaryHaveKey(contentDict, @"commentListHieght") floatValue];
    }
    else{
        float commHieght = 0.0f;
        NSArray *commentsArray =KISDictionaryHaveKey(contentDict, @"commentList");
        for (int i =0; i<commentsArray.count; i++) {
            NSMutableDictionary *dic = [commentsArray objectAtIndex:i];
            //判断是否是回复某人的评论
            if([[dic allKeys]containsObject:@"commentCellHieght"] &&!reAnalyzer){
                float commentCellHeight = [KISDictionaryHaveKey(dic, @"commentCellHieght") floatValue];
                commHieght +=commentCellHeight;
            }
            else{   //如果没算高度， 算出高度，存起来
                NSString *str ;
                if ([[dic allKeys]containsObject:@"commentStr"] &&!reAnalyzer) {
                    str =KISDictionaryHaveKey(dic, @"commentStr");
                }
                else{
                    NSString * nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"commentUser"), @"alias");
                    if ([GameCommon isEmtity:nickName]) {
                        nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"commentUser"), @"nickname");
                    }
                    if ([[dic allKeys]containsObject:@"destUser"]) {
                        
                        NSString * nickName2=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"destUser"), @"alias");
                        if ([GameCommon isEmtity:nickName2]) {
                            nickName2=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"destUser"), @"nickname");
                        }
                        str =[NSString stringWithFormat:@"%@ 回复 %@: %@",nickName,nickName2,KISDictionaryHaveKey(dic, @"comment")];
                    }else{
                        str =[NSString stringWithFormat:@"%@: %@",nickName,KISDictionaryHaveKey(dic, @"comment")];
                    }
                    str = [UILabel getStr:str];
                    [dic setObject:str forKey:@"commentStr"];
                }
                
                //计算ceommentCell 的高度
                CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                float height1= size.height+5;
                [dic setObject:@(height1) forKey:@"commentCellHieght"];
                commHieght += height1;
            }
        }
        [contentDict setObject:@(commHieght) forKey:@"commentListHieght"];
        cellHeight += commHieght;
    }
    
    //查看更多评论label
    if ([KISDictionaryHaveKey(contentDict, @"commentNum")intValue]>7) {
        cellHeight += 20;
    }
    [contentDict setObject:@(cellHeight) forKey:@"cellHieght"];
    
    bool Analyzed = YES;
    [contentDict setObject:@(Analyzed) forKey:@"Analyzed"];
    
    return contentDict;
}


-(void)changeShiptypeWithCell:(NewNearByCell *)myCell
{
    
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"userid") forKey:@"frienduserid"];
    if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"shiptype")isEqualToString:@"unkown"]) {
        [paramDict setObject:@"2" forKey:@"type"];
    }else if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"shiptype")isEqualToString:@"3"]){
        [paramDict setObject:@"1" forKey:@"type"];
    }
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"109" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            [DataStoreManager changshiptypeWithUserId:KISDictionaryHaveKey(KISDictionaryHaveKey([m_dataArray objectAtIndex:myCell.tag], @"user"), @"userid") type:KISDictionaryHaveKey(responseObject, @"shiptype")];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
        }
        for (int i = 0 ;i<m_dataArray.count;i++) {
            NSMutableDictionary *dicTemp = [m_dataArray objectAtIndex:i];
            NSMutableDictionary *dicUser =KISDictionaryHaveKey(dicTemp, @"user");
            if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dicTemp, @"user"), @"userid")isEqualToString:
                 KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"userid")]) {
                NSLog(@"前user--%@",dicUser);
                
                [dicUser setObject:KISDictionaryHaveKey(responseObject, @"shiptype") forKey:@"shiptype"];
                NSLog(@"后user--%@",dicUser);
                [m_dataArray replaceObjectAtIndex:i withObject:dicTemp];
            }
        }
        [wxSDArray removeAllObjects];
        [wxSDArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
        
        if (![wxSDArray containsObject:KISDictionaryHaveKey(KISDictionaryHaveKey([m_dataArray objectAtIndex:myCell.tag], @"user"), @"userid")]) {
            [self getSayHelloWithID:KISDictionaryHaveKey(KISDictionaryHaveKey([m_dataArray objectAtIndex:myCell.tag], @"user"), @"userid")];
        }
        myCell.focusButton.hidden =YES;
        [m_myTableView reloadData];
        [self showMessageWindowWithContent:@"添加成功" imageType:0];
        
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
-(void)getSayHelloWithID:(NSString *)userid
{
    
    [self DetectNetwork];
    
    NSMutableDictionary * postDict1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:userid forKey:@"touserid"];
    [postDict1 addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict1 setObject:@"153" forKey:@"method"];
    [postDict1 setObject:paramDict forKey:@"params"];
    
    [postDict1 setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [wxSDArray addObject:userid];
        [DataStoreManager storeThumbMsgUser:userid type:@"1"];
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sayHello_wx_info_id"];
        [[NSUserDefaults standardUserDefaults]setObject:wxSDArray forKey:@"sayHello_wx_info_id"];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
    
}

-(void)didClickToComment:(NewNearByCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    ReplyViewController *rep = [[ReplyViewController alloc]init];
    rep.messageid = KISDictionaryHaveKey(dic,@"id");
    [self.navigationController pushViewController:rep animated:YES];
    
}

-(void)didClickToZan:(NewNearByCell *)myCell
{
    NSMutableDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    NSMutableDictionary *commentUser = [NSMutableDictionary dictionary];
    [commentUser setObject:@"" forKey:@"img"];
    [commentUser setObject:[DataStoreManager queryNickNameForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]] forKey:@"nickname"];
    [commentUser setObject:@"0" forKey:@"superstar"];
    [commentUser setObject:@"" forKey:@"userid"];
    [commentUser setObject:@"" forKey:@"username"];
    
    
    NSString *isZan = KISDictionaryHaveKey(dic, @"isZan");
    if ([isZan intValue]==0) {//假如是未赞状态
        [self showMessageWindowWithContent:@"赞已成功" imageType:0];
        [myCell.zanButton setBackgroundImage:KUIImage(@"zan_cancle_nearBy") forState:UIControlStateNormal];
        [dic setObject:@"1" forKey:@"isZan"];
        //请求网络点赞
        [self postZanWithMsgId:KISDictionaryHaveKey(dic, @"id") IsZan:YES];
    }else{//假如是已经赞的状态
        [self showMessageWindowWithContent:@"已取消" imageType:0];
        [myCell.zanButton setBackgroundImage:KUIImage(@"zan_circle_normal") forState:UIControlStateNormal];
        [dic setObject:@"0" forKey:@"isZan"];
        //请求网络取消
        [self postZanWithMsgId:KISDictionaryHaveKey(dic, @"id") IsZan:NO];
    }
}
//上传赞
-(void)postZanWithMsgId:(NSString *)msgid IsZan:(BOOL)isZan
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgid forKey:@"messageId"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"185" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        NSString* uuid = [[GameCommon shareGameCommon] uuid];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:msgid,@"msgId",uuid,@"uuid",nil];
        [DataStoreManager saveOfflineZanWithDic:dic];
    }
    else{
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [m_myTableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, id error) {
            [m_myTableView reloadData];
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark ---cell delegate  openMenuCell
- (void)openMenuCell:(NewNearByCell*)myCell
{
    if(openMenuBtn) //如果有打开的cell
    {
        //关闭它
        NewNearByCell* cell = openMenuBtn;
        cell.menuImageView.hidden = YES;
        if (openMenuBtn.tag == myCell.tag) {    //如果打开的是自己
            openMenuBtn=nil;
            return;
        }
    }
    [myCell.contentView bringSubviewToFront:myCell.menuImageView];
    [myCell.contentView  becomeFirstResponder];
    myCell.menuImageView.hidden = NO;
    openMenuBtn=myCell;}
#pragma mark ---cell delegate  commentAndZan
//评论button方法
-(void)pinglunWithCircle:(NewNearByCell *)myCell
{
    destuserId=@"";
    self.textView.text = nil;
    self.textView.placeholder= nil;
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    isComeBackComment = NO;
    commentMsgId =KISDictionaryHaveKey(dic, @"id");
    myCell.menuImageView.hidden = YES;
    [self.textView becomeFirstResponder];
    [self keyboardLocation:myCell];
}
#pragma mark ---评论赞 点击方法
-(void)zanWithCircle:(NewNearByCell *)myCell
{
    NSLog(@"赞");
    NSDictionary *zanDic= [m_dataArray objectAtIndex:myCell.tag];
    myCell.menuImageView.hidden = YES;
    NSMutableDictionary *commentUser = [NSMutableDictionary dictionary];
    [commentUser setObject:@"" forKey:@"img"];
    [commentUser setObject:[DataStoreManager queryNickNameForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]] forKey:@"nickname"];
    [commentUser setObject:@"0" forKey:@"superstar"];
    [commentUser setObject:@"" forKey:@"userid"];
    [commentUser setObject:@"" forKey:@"username"];
    
    for (NSMutableDictionary *dic in m_dataArray) {
        if ([KISDictionaryHaveKey(dic, @"id") intValue]==[KISDictionaryHaveKey(zanDic, @"id") intValue]) {
            
            NSMutableArray *arr = KISDictionaryHaveKey(dic, @"zanList");
            int commentNum  = [KISDictionaryHaveKey(dic, @"zanNum")intValue];
            NSString *isZan=KISDictionaryHaveKey(dic, @"isZan");
            NSString *userid = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"),@"userid");
            if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
                [self showAlertViewWithTitle:@"提示" message:@"您不能对自己进行赞" buttonTitle:@"确定"];
                return;
            }
            if ([isZan intValue]==0) {//假如是未赞状态
                if (commentNum<=0) {
                    float temphight=[[cellhightarray objectForKey:KISDictionaryHaveKey(zanDic, @"id")]floatValue];
                    temphight+=30;
                    NSNumber *number = [NSNumber numberWithFloat:temphight];
                    [cellhightarray removeObjectForKey:KISDictionaryHaveKey(zanDic, @"id")];
                    [cellhightarray setObject:number forKey:KISDictionaryHaveKey(zanDic, @"id")];
                }
                [arr insertObject:commentUser atIndex:0];
                [dic setValue:[NSString stringWithFormat:@"%d",commentNum+1] forKey:@"zanNum"];
                [dic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"isZan"];
                [self showMessageWindowWithContent:@"赞已成功" imageType:0];
                if (commentNum<1) {
                    float s =[KISDictionaryHaveKey(dic, @"cellHieght")floatValue];
                    [dic setObject:@(s+30) forKey:@"cellHieght"];
                }
                [m_myTableView reloadData];
                //请求网络点赞
                [self postZanWithMsgId:KISDictionaryHaveKey(zanDic, @"id") IsZan:YES];
            }else{//假如是已经赞的状态
                if (commentNum==1) {
                    float temphight=[[cellhightarray objectForKey:KISDictionaryHaveKey(zanDic, @"id")]floatValue];
                    temphight-=30;
                    NSNumber *number = [NSNumber numberWithFloat:temphight];
                    [cellhightarray removeObjectForKey:KISDictionaryHaveKey(zanDic, @"id")];
                    [cellhightarray setObject:number forKey:KISDictionaryHaveKey(zanDic, @"id")];
                }
                [arr removeObject:commentUser];
                [dic setValue:[NSString stringWithFormat:@"%d",commentNum-1] forKey:@"zanNum"];
                [dic setValue:[NSString stringWithFormat:@"%d",0] forKey:@"isZan"];
                [self showMessageWindowWithContent:@"已取消" imageType:0];
                if (commentNum==1) {
                    [dic setObject:@([KISDictionaryHaveKey(dic, @"cellHieght")floatValue]-30) forKey:@"cellHieght"];
                }
                [m_myTableView reloadData];
                //请求网络取消
                [self postZanWithMsgId:KISDictionaryHaveKey(zanDic, @"id") IsZan:NO];
            }
            if (myCell.tag<20) {
                [self saveinfoToUserDefaults:m_dataArray];
            }
            
        }
    }
}
#pragma mark ---cell delegate  commentAndZan

- (void)handleNickNameButton_HeadCell:(NewNearByCell*)cell withIndexPathRow:(NSInteger)row
{
    TestViewController *testVC = [[TestViewController alloc]init];
    NSDictionary *dic = [m_dataArray objectAtIndex:cell.tag];
    NSDictionary *dict = [KISDictionaryHaveKey(dic, @"commentList") objectAtIndex:row];
    if ( [KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"userid")isEqualToString:@""]) {
        return;
    }
    NSString *userid = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"userid");
    NSString *nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname");
    }
    testVC.userId =userid;
    testVC.nickName = nickName;
    testVC.viewType = VIEW_TYPE_STRANGER1;
    [self.navigationController pushViewController:testVC animated:YES];
}

-(void)tapZanNickNameWithCell:(NewNearByCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    NSDictionary *zanDic  = [KISDictionaryHaveKey(dic,@"zanList")objectAtIndex:0];
    TestViewController *testVC = [[TestViewController alloc]init];
    NSString *userid =KISDictionaryHaveKey(zanDic, @"userid");
    NSString *nickName = KISDictionaryHaveKey(zanDic, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName =KISDictionaryHaveKey(zanDic, @"nickname");
    }
    testVC.userId =userid;
    testVC.nickName = nickName;
    [self.navigationController pushViewController:testVC animated:YES];
    
}

#pragma mark ---发送评论
-(void)updateComment
{
    NSLog(@"commentView-->%@",self.textView.text);
    
    if (self.textView.text.length<1) {
        [self showMessageWithContent:@"评论不能回复空内容" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
    if([self.textView isFirstResponder]){
        [self.textView resignFirstResponder];
    }
    if(self.theEmojiView.hidden == NO){
        self.theEmojiView.hidden = YES;
        [self autoMovekeyBoard:-inPutView.bounds.size.height];
        self.commentInputType = CommentInputTypeKeyboard;
        senderBnt.selected = NO;
    }
    
    //离线评论
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSMutableDictionary *commentUser = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString * nickName = [DataStoreManager queryNickNameForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [commentUser setObject:@"" forKey:@"img"];
    [commentUser setObject:nickName forKey:@"nickname"];
    [commentUser setObject:@"0" forKey:@"superstar"];
    [commentUser setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] forKey:@"userid"];
    [commentUser setObject:@"" forKey:@"username"];
    NSString* comment = self.textView.text;
    
    if (self.textView.placeholder!=nil) {
        NSMutableDictionary *destUser = [NSMutableDictionary dictionary];
        [destUser setObject:KISDictionaryHaveKey(commentOffLineDict, @"id") forKey:@"id"];
        [destUser setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(commentOffLineDict, @"commentUser"), @"nickname") forKey:@"nickname"];
        [destUser setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(commentOffLineDict, @"commentUser"), @"userid") forKey:@"userid"];
        dict =[ NSMutableDictionary dictionaryWithObjectsAndKeys:comment,@"comment",commentUser,@"commentUser",uuid,@"uuid",@"",@"id",@(0),@"commentCellHieght",destUser,@"destUser", nil];
    }else{
        dict =[ NSMutableDictionary dictionaryWithObjectsAndKeys:comment,@"comment",commentUser,@"commentUser",uuid,@"uuid",@"",@"id",@(0),@"commentCellHieght", nil];
    }
    
    //将评论添加到数组里、
    int i = -1;
    for (int j = 0;j<m_dataArray.count;j++) {
        NSMutableDictionary *dic = [m_dataArray objectAtIndex:j];
        if ([KISDictionaryHaveKey(dic, @"id") intValue]==[commentMsgId intValue]) {
            //添加赞数
            int commentNum  = [KISDictionaryHaveKey(dic, @"commentNum")intValue];
            [dic setObject:[NSString stringWithFormat:@"%d",commentNum+1] forKey:@"commentNum"];
            NSMutableArray *arr = KISDictionaryHaveKey(dic, @"commentList");
            [arr insertObject:dict atIndex:0];
            dic = [self contentAnalyzer:dic withReAnalyzer:YES];    //分析器强制更新这一条
            i = [m_dataArray indexOfObject:dic];
        }
    }
    if (i>=0&&i<20) {
        [self saveinfoToUserDefaults:m_dataArray];
    }
    
    [self showMessageWindowWithContent:@"评论成功" imageType:0];
    [m_myTableView reloadData];
    //执行提交评论操作
    [self postCommentWithMsgId:commentMsgId destUserid:destuserId destCommentId:destMsgId comment:self.textView.text uuid:uuid];
    [self.textView resignFirstResponder];
    commentMsgId =nil;
    destuserId = nil;
    destMsgId = nil;
}

//删除评论
-(void)delcomment
{
    
    NSMutableDictionary *dic = [m_dataArray objectAtIndex:[[delcommentDic objectForKey:@"mycell"]intValue]];
    NSMutableArray *arr = [dic objectForKey:@"commentList"];
    NSString *msgId = KISDictionaryHaveKey([arr objectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]], @"id");
    [NSCharacterSet decimalDigitCharacterSet];
    
    
    hud.labelText = @"删除中...";
    [hud show:YES];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgId forKey:@"commentId"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"195" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        [dic setObject:@([KISDictionaryHaveKey(dic, @"commentListHieght")floatValue]-[KISDictionaryHaveKey([arr objectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]], @"commentCellHieght")floatValue]) forKey:@"commentListHieght"];
        
        [dic setObject:@([KISDictionaryHaveKey(dic, @"cellHieght")floatValue]-[KISDictionaryHaveKey([arr objectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]], @"commentCellHieght")floatValue]) forKey:@"cellHieght"];
        
        [cellhightarray removeObjectForKey:KISDictionaryHaveKey(dic, @"id")];
        [self showMessageWindowWithContent:@"删除成功" imageType:0];
        [arr removeObjectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]];
        [m_myTableView reloadData];
        
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


-(void)saveinfoToUserDefaults:(NSMutableArray *)array
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [RootDocPath stringByAppendingString:@"/HC_groupInfoList"];
    BOOL isTrue = [fileManager fileExistsAtPath:path];
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:NULL];
    
    if (isTrue && [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        NSArray *clearArray = [NSArray array];
        [clearArray writeToFile:path atomically:YES];
        [array writeToFile:path atomically:YES];
    }else{
        [array writeToFile:path atomically:YES];
    }
}
#pragma mark ---tableviewdelegate ----点击自己发的评论-删除  点击他人评论 回复
//点击删除或者点击回复某人的评论
- (void)editCommentOfYouWithCircle:(NewNearByCell *)mycell withIndexPath:(NSInteger)row
{
    NSDictionary *dic = [m_dataArray objectAtIndex:mycell.tag];
    NSDictionary *dict = [KISDictionaryHaveKey(dic, @"commentList") objectAtIndex:row];
    //点击的是自己的评论，弹出删除菜单
    if( [KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"userid")isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        
        NSString *msgid =[NSString stringWithFormat:@"%@", KISDictionaryHaveKey(dict, @"id")];
        if ([msgid isEqualToString:@""]||[msgid isEqualToString:@" "]) {
            return;
        }
        UIActionSheet *act = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除评论" otherButtonTitles: nil];
        act.tag = 888888;
        
        [delcommentDic removeAllObjects];
        [delcommentDic setObject:@(mycell.tag) forKey:@"mycell"];
        [delcommentDic setObject:@(row) forKey:@"row"];
        [act showInView:self.view];
    }else{//点击的是别人的评论，弹出评论框
        self.textView.text = nil;
        self.textView.placeholder= nil;
        [self.textView becomeFirstResponder];
        [self keyboardLocation:mycell];
        isComeBackComment = YES;
        NSDictionary *dic = [m_dataArray objectAtIndex:mycell.tag];
        commentMsgId =KISDictionaryHaveKey(dic, @"id");
        NSArray *array = [dic objectForKey:@"commentList"];
        NSDictionary *dict = [array objectAtIndex:row];
        NSString* nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"alias");
        if ([GameCommon isEmtity:nickName]) {
            nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname");
        }
        self.textView.placeholder = [NSString stringWithFormat:@"回复 %@：", nickName];
        self.textView.placeholderColor = [UIColor grayColor];
        
        //将对方信息保存在临时变量
        [commentOffLineDict setDictionary:dict];
        destMsgId =KISDictionaryHaveKey(dict, @"id");
        destuserId = KISDictionaryHaveKey(KISDictionaryHaveKey(dict,@"commentUser"), @"userid");
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag ==888888){
        if (buttonIndex==0) {
            
            [self delcomment];
        }else{
            return;
        }
    }
}

//tableView定位
-(void)keyboardLocation:(NewNearByCell *)mycell
{
    for (int i=0; i<(mycell.tag+1); i++) {
        NSDictionary *dict =[m_dataArray objectAtIndex:i];
        offer+=[[cellhightarray objectForKey:KISDictionaryHaveKey(dict, @"id")]floatValue];
    }
    if(iPhone5){
        offer+=(185-height-23);
    }else{
        offer+=(185-height+65);
    }
    
    [m_myTableView scrollRectToVisible:CGRectMake(0, offer, m_myTableView.frame.size.width, m_myTableView.frame.size.height) animated:YES];
    offer=0;
}
#pragma mark --- clickseeBigImage


//上传评论
-(void)postCommentWithMsgId:(NSString *)msgid destUserid:(NSString *)destUserid destCommentId:(NSString *)destCommentId comment:(NSString *)comment uuid:(NSString *)uuid
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgid forKey:@"messageId"];
    if (isComeBackComment ==YES) {
        [paramDic setObject:destUserid?destUserid:@"" forKey:@"destUserid"];
        [paramDic setObject:destCommentId?destCommentId:@"" forKey:@"destCommentId"];
    }
    [paramDic setObject:comment forKey:@"comment"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"186" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    //如果没有网，将数据保存到数据库。。。。
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:msgid forKey:@"msgId"];
        [dict setObject:destUserid?destUserid:@"" forKey:@"destUserid"];
        [dict setObject:destCommentId?destCommentId:@"" forKey:@"destCommentId"];
        [dict setObject:comment forKey:@"comments"];
        [dict setObject:uuid forKey:@"uuid"];
        [DataStoreManager saveCommentsWithDic:dict];
        return;
    }
    else{
        [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (![responseObject isKindOfClass:[NSDictionary class]]) {
                return ;
            }
            for (int i = 0; i <m_dataArray.count; i++) {
                NSDictionary *dic = [m_dataArray objectAtIndex:i];
                if ([KISDictionaryHaveKey(dic, @"id")intValue]==[msgid intValue]) {
                    NSArray *array = [dic objectForKey:@"commentList"];
                    for (int i = 0; i < array.count; i++) {
                        NSMutableDictionary *commDic = (NSMutableDictionary *)[array objectAtIndex:i];
                        if ([[commDic allKeys]containsObject:@"uuid"]&&[[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(commDic, @"uuid")]isEqualToString:uuid]) {
                            [commDic setObject:KISDictionaryHaveKey(responseObject, @"id") forKey:@"id"];
                        }
                    }
                }
            }
            [m_myTableView reloadData];
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
    
    [self.textView resignFirstResponder];
    self.textView.text = nil;
    self.textView.placeholder= nil;
    
}

#pragma mark----
#pragma mark ----查看全部评论
-(void)enterCommentPageWithCell:(NewNearByCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    ReplyViewController *reply = [[ReplyViewController alloc]init];
    reply.messageid = KISDictionaryHaveKey(dic, @"id");
    reply.isHaveArticle = YES;
    [self.navigationController pushViewController:reply animated:YES];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    self.theEmojiView.hidden = YES;
    self.commentInputType = CommentInputTypeKeyboard;
    senderBnt.selected = NO;
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self autoMovekeyBoard:keyboardRect.size.height];
    height = keyboardRect.size.height;
    [self keyboardDidShow];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self.view bringSubviewToFront:self.textView];
    [self autoMovekeyBoard:-inPutView.bounds.size.height];
    [self keyboardDidHide];
}
-(void) autoMovekeyBoard: (float) h{

    CGRect containerFrame = inPutView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (h + containerFrame.size.height);
	inPutView.frame = containerFrame;
}
- (void)keyboardDidShow
{
    _keyboardIsVisible = YES;
}

- (void)keyboardDidHide
{
    _keyboardIsVisible = NO;
}

- (BOOL)keyboardIsVisible
{
    return _keyboardIsVisible;
}
#pragma mark 输入
#pragma mark HPExpandingTextView delegate
//改变键盘高度
//改变键盘高度
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
	CGRect r = inPutView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	inPutView.frame = r;
}
//评论按钮
-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self updateComment];
    return YES;
}
//手势代理的方法，解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]||[touch.view isKindOfClass:[UIScrollView class]])
    {
        return NO;
    }
    return YES;
}


#pragma mark - Views
//表情按钮
- (EmojiView *)theEmojiView{
    if (!_theEmojiView) {
        _theEmojiView = [[EmojiView alloc]
                         initWithFrame:CGRectMake(0,
                                                  self.view.frame.size.height-253,
                                                  320,
                                                  253)
                         WithSendBtn:YES];
        _theEmojiView.delegate = self;
    }
    return _theEmojiView;
}
//点击添加表情按钮
-(void)emojiBtnClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (self.commentInputType != CommentInputTypeEmoji) {//点击切到表情
        [self showEmojiScrollView];
    }else{//点击切回键盘
        [self showKeyboardView];
        
    }
}
//显示键盘
-(void)showKeyboardView
{
    [self.textView becomeFirstResponder];
    self.commentInputType = CommentInputTypeKeyboard;
    self.theEmojiView.hidden = YES;
}
//显示表情布局
-(void)showEmojiScrollView
{
    self.commentInputType = CommentInputTypeEmoji;
    [self.textView resignFirstResponder];
    self.theEmojiView.hidden = NO;
    self.theEmojiView.frame = CGRectMake(0,self.view.frame.size.height-253,320,253);
    [self autoMovekeyBoard:253];
}

//删除表情
-(void)deleteEmojiStr
{
    if (self.textView.text.length>=1) {
        if ([self.textView.text hasSuffix:@"] "] && [self.textView.text length] >= 5) {
            self.textView.text = [self.textView.text substringToIndex:(self.textView.text.length-5)];
        }
        else
        {
            self.textView.text = [self.textView.text substringToIndex:(self.textView.text.length-1)];
        }
    }
}
//发送表情
-(void)emojiSendBtnDo
{
    
    [self updateComment];
}
//选择表情
-(NSString *)selectedEmoji:(NSString *)ssss
{
	if (self.textView.text == nil) {
		self.textView.text = ssss;
	}
	else {
		self.textView.text = [self.textView.text stringByAppendingString:ssss];
	}
    return 0;
}
#pragma mark --举报
-(void)jubaoThisInfoWithCell:(NewNearByCell*)myCell
{
    // NSDictionary *dic =[m_dataArray objectAtIndex:myCell.tag];
    
    UIAlertView *jubaoAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确认举报这条动态么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"举报", nil];
    
    jubaoAlert.tag = myCell.tag;
    [jubaoAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        hud.labelText = @"举报中...";
        [hud show:YES];
        NSString* str = [NSString stringWithFormat:@"本人举报动态messageid为%@ 的文章含不良内容，请尽快处理！", KISDictionaryHaveKey([m_dataArray objectAtIndex:alertView.tag],@"id")];
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:str ,@"msg",@"Platform=iphone", @"detail",KISDictionaryHaveKey([m_dataArray objectAtIndex:alertView.tag],@"id"),@"id",@"dynamic",@"type",nil];
        NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
        [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [postDict setObject:@"155" forKey:@"method"];
        [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
        [postDict setObject:dic forKey:@"params"];
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            [self showAlertViewWithTitle:@"提示" message:@"感谢您的举报，我们会尽快处理！" buttonTitle:@"确定"];
        } failure:^(AFHTTPRequestOperation *operation, id error) {
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }}}];
        
    }
}
#pragma mark --enter OnceDynamicViewController Page  进入动态详情界面
-(void)enterInfoPage:(UIButton *)sender
{
    NSDictionary *dict = [m_dataArray objectAtIndex:sender.tag];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"id");
    
    NSString * imageIds=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img");
    detailVC.imgStr = [ImageService getImgUrl:imageIds];
    
    NSMutableDictionary *userDic=KISDictionaryHaveKey(dict, @"user");
    NSString * nickName=KISDictionaryHaveKey(userDic, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(userDic, @"nickname");
    }
    detailVC.nickNameStr = [KISDictionaryHaveKey(dict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :nickName;
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

//根据标题的长度更改UIActivity的位置
- (void)getmsgIdwithCircle:(NewNearByCell *)myCell withindexPath:(NSInteger)row
{
    
}
-(void)transferClickEventsWithCell:(NewNearByCell *)myCell withIndexPath:(NSInteger)row
{
    
}
-(void)hiddenOrShowMenuImageViewWithCell:(NewNearByCell*)myCell
{
    
}
-(void)delCellWithCell:(NewNearByCell*)myCell
{
    
}

@end
