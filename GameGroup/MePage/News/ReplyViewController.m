//
//  ReplyViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 14-1-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReplyViewController.h"
#import "ReplyCell.h"
#import "MyProfileViewController.h"
#import "TestViewController.h"
#import "OnceDynamicViewController.h"
#import "UserManager.h"
#import "MJRefresh.h"

typedef enum : NSUInteger {
    CommentInputTypeKeyboard,
    CommentInputTypeEmoji,
} CommentInputType;
@interface ReplyViewController ()
{
    UITableView*     m_replyTabel;
    NSMutableArray*  m_dataReply;
    
    NSInteger        m_pageIndex;
    
//    PullUpRefreshView      *refreshView;
//    SRRefreshView   *_slimeView;
    AppDelegate *app;
    UIView* inPutView;
    UIButton* inputButton;
    NSMutableDictionary *commentDic;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;

    BOOL isComeBackComment;
    
    
    NSMutableDictionary *commentOffLineDict;
}
@property (strong,nonatomic) HPGrowingTextView *textView;
@property (nonatomic, strong) EmojiView *theEmojiView;
@property (nonatomic, assign) CommentInputType commentInputType;
@end

@implementation ReplyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

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
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    tapGr.delegate = self;
    [self.view addGestureRecognizer:tapGr];
    
    [self setTopViewWithTitle:@"评论" withBackButton:YES];
    m_pageIndex = 0;
    commentOffLineDict = [NSMutableDictionary dictionary];
    m_dataReply = [[NSMutableArray alloc] initWithCapacity:1];
    
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    m_replyTabel = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth- startX-(KISHighVersion_7?0:20) - 50)];
    m_replyTabel.delegate = self;
    m_replyTabel.dataSource = self;
    [self.view addSubview:m_replyTabel];
    
    [self addheadView];
    [self addFootView];

    
    inPutView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 320, 44)];
    [self.view addSubview:inPutView];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 7, 240, 29)];
    self.textView.isScrollable = NO;
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
	self.textView.returnKeyType = UIReturnKeyDone; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    commentDic = [NSMutableDictionary dictionary];

    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"chat_input.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(10, 7, 320-30-25, 29);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage *rawBackground = [UIImage imageNamed:@"inputbg.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0,0,inPutView.frame.size.width,inPutView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [inPutView addSubview:imageView];
    [inPutView addSubview:entryImageView];
    [inPutView addSubview:self.textView];
    
    inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inputButton setImage:KUIImage(@"emoji") forState:UIControlStateNormal];
    [inputButton setImage:KUIImage(@"keyboard.png") forState:UIControlStateSelected];
    [inputButton addTarget:self action:@selector(emojiBtnClicked:) forControlEvents:UIControlEventTouchDown];
    inputButton.frame = CGRectMake(320-25-10, 9.5, 25, 25);
    [inPutView bringSubviewToFront:inputButton];
    [inPutView addSubview:inputButton];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [self.view addSubview:self.theEmojiView];
    self.theEmojiView.hidden = YES;
    
    [self getDataByNet];
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if(self.theEmojiView.hidden == NO){
        self.theEmojiView.hidden = YES;
        [self autoMovekeyBoard:0];
        self.commentInputType = CommentInputTypeKeyboard;
        inputButton.selected = NO;
    }
    if([self.textView isFirstResponder]){
        [self.textView resignFirstResponder];
    }
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
    [self okButtonClick];
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
//隐藏表情
-(void)hideEmoji
{
    if(self.theEmojiView.hidden == NO){
        self.theEmojiView.hidden = YES;
        [self autoMovekeyBoard:0];
        self.commentInputType = CommentInputTypeKeyboard;
        inputButton.selected = NO;
    }
}
//隐藏键盘
-(void)hideKeyBoard
{
    if([self.textView isFirstResponder]){
        [self.textView resignFirstResponder];
    }
}

- (void)backButtonClick:(id)sender
{
    
        if(self.theEmojiView.hidden == NO){
            self.theEmojiView.hidden = YES;
            [self autoMovekeyBoard:0];
            self.commentInputType = CommentInputTypeKeyboard;
            inputButton.selected = NO;
            return ;
        }
        if([self.textView isFirstResponder]){
            [self.textView resignFirstResponder];
            return ;
        }
    
    if (!KISEmptyOrEnter(self.textView.text)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定放弃已编写的评论内容吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alert.tag = 100;
        [alert show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (void)getDataByNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.messageid forKey:@"messageId"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:[NSString stringWithFormat:@"%d", m_pageIndex] forKey:@"pageIndex"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"188" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    hud.labelText = @"获取评论中...";
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        if (![responseObject isKindOfClass:[NSArray class]]) {
            [m_header endRefreshing];
            [m_footer endRefreshing];
            return;
        }
//        else if([responseObject count] != 0)
//        {
//            self.messageid = KISDictionaryHaveKey([responseObject objectAtIndex:0], @"messageid");
//        }
        if (m_pageIndex == 0) {//默认展示存储的r
            [m_dataReply removeAllObjects];
        }
        m_pageIndex ++;//从0开始
        
        [m_dataReply addObjectsFromArray:responseObject];
        
        [m_replyTabel reloadData];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [m_header endRefreshing];
        [m_footer endRefreshing];
        
        [hud hide:YES];
    }];
    
}

#pragma mark 原文
- (void)goArticle:(id)sender
{
    OnceDynamicViewController* oneVC = [[OnceDynamicViewController alloc] init];
    oneVC.messageid = self.messageid;
    [self.navigationController pushViewController:oneVC animated:YES];
}

#pragma mark 发表
- (void)okButtonClick
{
    
    
    if (KISEmptyOrEnter(self.textView.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入评论内容" buttonTitle:@"确定"];
        return;
    }
    [self hideEmoji];
    [self hideKeyBoard];
    
    
    
    //离线评论
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSMutableDictionary *commentUser = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    NSString * nickName = [DataStoreManager queryNickNameForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    NSMutableDictionary * userInfo = [DataStoreManager getUserInfoFromDbByUserid:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    NSString * nickName = KISDictionaryHaveKey(userInfo, @"nickname");
    [commentUser setObject:KISDictionaryHaveKey(userInfo, @"img") forKey:@"img"];
    [commentUser setObject:nickName forKey:@"nickname"];
    [commentUser setObject:KISDictionaryHaveKey(userInfo, @"superstar") forKey:@"superstar"];
    [commentUser setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] forKey:@"userid"];
    [commentUser setObject:KISDictionaryHaveKey(userInfo, @"username") forKey:@"username"];
    NSString* comment = self.textView.text;
    
    if (self.textView.placeholder!=nil) {
        NSMutableDictionary *destUser = [NSMutableDictionary dictionary];
        [destUser setObject:KISDictionaryHaveKey(commentOffLineDict, @"id") forKey:@"id"];
        [destUser setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(commentOffLineDict, @"commentUser"), @"nickname") forKey:@"nickname"];
        [destUser setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(commentOffLineDict, @"commentUser"), @"userid") forKey:@"userid"];
        dict =[ NSMutableDictionary dictionaryWithObjectsAndKeys:comment,@"comment",commentUser,@"commentUser",uuid,@"uuid",@"",@"id",@(0),@"commentCellHieght",destUser,@"destUser", [GameCommon getCurrentTime],@"createDate",nil];
    }else{
        dict =[ NSMutableDictionary dictionaryWithObjectsAndKeys:comment,@"comment",commentUser,@"commentUser",uuid,@"uuid",@"",@"id",@(0),@"commentCellHieght",[GameCommon getCurrentTime],@"createDate", nil];
    }
//    [m_dataReply addObject:dict];
    [m_dataReply insertObject:dict atIndex:0];
    [m_replyTabel reloadData];
    
    if (self.textView.placeholder) {
        [self postCommentWithMsgId:self.messageid destUserid:KISDictionaryHaveKey(KISDictionaryHaveKey(commentDic, @"commentUser"), @"userid") destCommentId:KISDictionaryHaveKey(commentDic, @"id") comment:self.textView.text];
    }else{
        [self postCommentWithMsgId:self.messageid destUserid:@"" destCommentId:@"" comment:self.textView.text];
    }
}

-(void)postCommentWithMsgId:(NSString *)msgid destUserid:(NSString *)destUserid destCommentId:(NSString *)destCommentId comment:(NSString *)comment
{
    hud.labelText = @"评论中...";
    [hud show:YES];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgid forKey:@"messageId"];
    NSString *str= [NSString stringWithFormat:@"%@",destCommentId];
    if (![str isEqualToString:@""]) {
        [paramDic setObject:destUserid forKey:@"destUserid"];
        [paramDic setObject:destCommentId forKey:@"destCommentId"];
    }
    [paramDic setObject:comment forKey:@"comment"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"186" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
        [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSString *commentStr;
                NSString *destUserid = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(responseObject, @"destUserid")];
                commentStr = KISDictionaryHaveKey(responseObject, @"comment");
                
                NSDictionary *commentUser = [NSDictionary dictionaryWithObjectsAndKeys:[DataStoreManager queryFirstHeadImageForUser_userManager:KISDictionaryHaveKey(responseObject, @"userid")],@"img",[DataStoreManager queryNickNameForUser:KISDictionaryHaveKey(responseObject, @"userid")],@"nickname",KISDictionaryHaveKey(responseObject, @"userid"),@"userid", nil];
                
                if ([destUserid isEqualToString:@""]||[destUserid isEqualToString:@" "]) {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:commentStr,@"comment",commentUser,@"commentUser",KISDictionaryHaveKey(responseObject, @"createDate"),@"createDate",KISDictionaryHaveKey(responseObject, @"id"),@"id", nil];
//                    [m_dataReply insertObject:dic atIndex:0];
                     [m_dataReply replaceObjectAtIndex:0 withObject:dic];
                    [m_replyTabel reloadData];
                    
                }else{
                    NSDictionary *destUser = [NSDictionary dictionaryWithObjectsAndKeys:KISDictionaryHaveKey(KISDictionaryHaveKey(commentDic, @"commentUser"), @"img"),@"img",KISDictionaryHaveKey(KISDictionaryHaveKey(commentDic, @"commentUser"), @"nickname"),@"nickname",KISDictionaryHaveKey(responseObject, @"destUserid"),@"usesrid", nil];
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:commentStr,@"comment",commentUser,@"commentUser",KISDictionaryHaveKey(responseObject, @"createDate"),@"createDate",KISDictionaryHaveKey(responseObject, @"id"),@"id", destUser,@"destUser",nil];
//                    [m_dataReply insertObject:dic atIndex:0];
                    [m_dataReply replaceObjectAtIndex:0 withObject:dic];
                    [m_replyTabel reloadData];
                }
            }
            [self showMessageWindowWithContent:@"评论成功" imageType:0];
            [hud hide:YES];
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
    
    [self.textView resignFirstResponder];
    self.textView.text = nil;
    self.textView.placeholder= nil;
    
}



#pragma mark 输入
#pragma mark HPExpandingTextView delegate
//改变键盘高度
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = inPutView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	inPutView.frame = r;
}

-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self.textView resignFirstResponder];
    
    [self okButtonClick];
    return YES;
}

#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
     self.theEmojiView.hidden = YES;
    self.commentInputType = CommentInputTypeKeyboard;
    inputButton.selected = NO;
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self autoMovekeyBoard:0];
}

-(void) autoMovekeyBoard: (float) h{
    
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:0.2];
	//inPutView.frame = CGRectMake(0.0f, (float)(self.view.frame.size.height-h-inPutView.frame.size.height), 320.0f, inPutView.frame.size.height);
    
    CGRect containerFrame = inPutView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (h + containerFrame.size.height);
	// animations settings
    
	
	// set views with new info
	inPutView.frame = containerFrame;
}


#pragma mark - table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_dataReply count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReplyCell *cell = (ReplyCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    float heigth = cell.commentLabel.frame.size.height + 35;
    return heigth < 60 ? 60 : heigth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSLog(@"cellForRowAtIndexPath: %d",indexPath.row);
   // NSDictionary* tempDic = [m_dataReply objectAtIndex:indexPath.row];
    NSMutableDictionary *tempDic=[NSMutableDictionary dictionaryWithDictionary:[m_dataReply objectAtIndex:indexPath.row]];
    
    static NSString *identifier = @"myCell";
    ReplyCell *cell = (ReplyCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
    
    NSString * userimageIds=KISDictionaryHaveKey(KISDictionaryHaveKey(tempDic, @"commentUser"), @"img");
    
    cell.headImageV.imageURL = [ImageService getImageStr:userimageIds Width:80];
 
    NSMutableDictionary *commentD =KISDictionaryHaveKey(tempDic,@"commentUser");
    NSString * nickName=KISDictionaryHaveKey(commentD, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(commentD, @"nickname");
    }
    cell.nickNameLabel.text = nickName;
    cell.timeLabel.text = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"createDate")]];
    
    NSString* commentStr;
    if ([[tempDic allKeys]containsObject:@"destUser"]) {
        
        NSMutableDictionary *destUserDic =KISDictionaryHaveKey(tempDic,@"destUser");
        NSString * desnickName=KISDictionaryHaveKey(destUserDic, @"alias");
        if ([GameCommon isEmtity:desnickName]) {
            desnickName=KISDictionaryHaveKey(destUserDic, @"nickname");
        }
        commentStr = [NSString stringWithFormat:@"回复 %@:%@",desnickName,KISDictionaryHaveKey(tempDic, @"comment")];
        cell.commentStr = commentStr;
    }else{
        commentStr = KISDictionaryHaveKey(tempDic, @"comment");
        cell.commentStr = commentStr;

    }
    
    [cell.commentLabel setEmojiText:cell.commentStr];
    
    //计算高度, 刷新Cell
    if([[tempDic allKeys]containsObject:@"commentCellHeight"])
    {
        float height = [KISDictionaryHaveKey(tempDic, @"commentCellHeight") floatValue];
        cell.commentLabel.frame = CGRectMake(65, 28, 245, height);
    }
    else{
        CGSize sizeThatFits = [cell.commentLabel sizeThatFits:CGSizeMake(245, MAXFLOAT)];
        float height1= sizeThatFits.height;
        cell.commentLabel.frame = CGRectMake(65, 28, 245, height1);
        //纪录下高度
       // NSNumber* cellHeight = [NSNumber numberWithFloat:height];
        [tempDic setObject:@(height1) forKey:@"commentCellHeight"];
    }
    
    cell.rowIndex = indexPath.row;
    cell.myDelegate = self;
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_replyTabel deselectRowAtIndexPath:indexPath animated:YES];
    
    commentDic = [m_dataReply objectAtIndex:indexPath.row];
    if ([KISDictionaryHaveKey(KISDictionaryHaveKey(commentDic, @"commentUser"), @"userid")intValue]==[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]intValue]) {
        return;
    }
    NSString* nickName =KISDictionaryHaveKey(KISDictionaryHaveKey(commentDic, @"commentUser"),@"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName =KISDictionaryHaveKey(KISDictionaryHaveKey(commentDic, @"commentUser"),@"nickname");
    }
    isComeBackComment = YES;
    self.textView.placeholder = [NSString stringWithFormat:@"回复 %@：", nickName];
    [self.textView becomeFirstResponder];
    
    [commentOffLineDict setDictionary:commentDic];
}

-(void)CellHeardButtonClick:(int)rowIndex
{
    NSDictionary* tempDict = [m_dataReply objectAtIndex:rowIndex];
    
    TestViewController* detailV = [[TestViewController alloc] init];
    detailV.userId = KISDictionaryHaveKey( KISDictionaryHaveKey(tempDict, @"commentUser"),@"userid");
    detailV.nickName = KISDictionaryHaveKey(tempDict, @"nickname");
    detailV.isChatPage = NO;
    [self.navigationController pushViewController:detailV animated:YES];
    //    }
}
//添加下拉刷新
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_replyTabel;
    
    header.scrollView = m_replyTabel;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_pageIndex = 0;
        [self getDataByNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    //  [header beginRefreshing];
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
    footer.scrollView = m_replyTabel;
    
    footer.scrollView = m_replyTabel;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getDataByNet];
    };
    m_footer = footer;
}

#pragma mark 手势
- (void)tapTopViewClick:(id)sender
{
    [self.textView resignFirstResponder];
}
//手势代理的方法，解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]||[touch.view isKindOfClass:[UIScrollView class]])
    {
        return NO;
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
