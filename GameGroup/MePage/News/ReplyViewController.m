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
#import "OHASBasicHTMLParser.h"
typedef enum : NSUInteger {
    CommentInputTypeKeyboard,
    CommentInputTypeEmoji,
} CommentInputType;
@interface ReplyViewController ()
{
    UITableView*     m_replyTabel;
    NSMutableArray*  m_dataReply;
    
    NSInteger        m_pageIndex;
    
    PullUpRefreshView      *refreshView;
    SRRefreshView   *_slimeView;
    
    UIView* inPutView;
    UIButton* inputButton;
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
    m_dataReply = [[NSMutableArray alloc] initWithCapacity:1];
    
    m_replyTabel = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth- startX-(KISHighVersion_7?0:20) - 50)];
    m_replyTabel.delegate = self;
    m_replyTabel.dataSource = self;
    [self.view addSubview:m_replyTabel];
    
    refreshView = [[PullUpRefreshView alloc] initWithFrame:CGRectMake(0, kScreenHeigth - startX-(KISHighVersion_7?0:20), 320, REFRESH_HEADER_HEIGHT)];//上拉加载
    [m_replyTabel addSubview:refreshView];
    refreshView.pullUpDelegate = self;
    refreshView.myScrollView = m_replyTabel;
    [refreshView stopLoading:NO];
    
    _slimeView = [[SRRefreshView alloc] init];
    _slimeView.delegate = self;
    _slimeView.upInset = 0;
    _slimeView.slimeMissWhenGoingBack = NO;
    _slimeView.slime.bodyColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    _slimeView.slime.skinColor = [UIColor whiteColor];
    _slimeView.slime.lineWith = 1;
    _slimeView.slime.shadowBlur = 4;
    _slimeView.slime.shadowColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    [m_replyTabel addSubview:_slimeView];
    //    [_slimeView setLoadingWithexpansion];
    
    inPutView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
    [self.view addSubview:inPutView];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 7, 240, 35)];
    self.textView.isScrollable = NO;
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
	self.textView.returnKeyType = UIReturnKeyDone; //just as an example
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
    
    // view hierachy
    [inPutView addSubview:imageView];
    [inPutView addSubview:entryImageView];
    [inPutView addSubview:self.textView];
    
    
    
//    inputButton = [[UIButton alloc] initWithFrame:CGRectMake(255, 8, 60, 35)];
//    [inputButton setBackgroundImage:KUIImage(@"blue_small_3_normal") forState:UIControlStateNormal];
//    [inputButton setBackgroundImage:KUIImage(@"blue_small_3_click") forState:UIControlStateHighlighted];
//    [inputButton setTitle:@"发表" forState:UIControlStateNormal];
//    inputButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
//    [inputButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [inputButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [inPutView addSubview:inputButton];
    
    
    
    
    inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inputButton setBackgroundImage:KUIImage(@"emoji") forState:UIControlStateNormal];
    [inputButton setBackgroundImage:KUIImage(@"keyboard.png") forState:UIControlStateSelected];
    [inputButton addTarget:self action:@selector(emojiBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    inputButton.frame = CGRectMake(260, 0, 50, 50);
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
        [self autoMovekeyBoard:-inPutView.bounds.size.height];
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
    
    [paramDict setObject:self.messageid forKey:@"messageid"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:[NSString stringWithFormat:@"%d", m_pageIndex] forKey:@"pageIndex"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"137" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    hud.labelText = @"获取评论中...";
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        if (![responseObject isKindOfClass:[NSArray class]]) {
            [refreshView stopLoading:YES];
            [_slimeView endRefresh];
            return;
        }
        else if([responseObject count] != 0)
        {
            self.messageid = KISDictionaryHaveKey([responseObject objectAtIndex:0], @"messageid");
        }
        if (m_pageIndex == 0) {//默认展示存储的
            [m_dataReply removeAllObjects];
        }
        m_pageIndex ++;//从0开始
        
        [m_dataReply addObjectsFromArray:responseObject];
        
        [m_replyTabel reloadData];
        
        [refreshView stopLoading:NO];
        [refreshView setRefreshViewFrame];
        
        [_slimeView endRefresh];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [refreshView stopLoading:NO];
        [_slimeView endRefresh];
        
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
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:@"5" forKey:@"type"];
    if (!self.textView.placeholder) {
        [paramDict setObject:self.textView.text forKey:@"msg"];
    }else{
        [paramDict setObject:[NSString stringWithFormat:@"%@%@",self.textView.placeholder,self.textView.text] forKey:@"msg"];
    }
    
    NSString *msgStr = [paramDict objectForKey:@"msg"];
    [paramDict setObject:self.messageid forKey:@"messageid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"134" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    self.textView.placeholder = @"";
    hud.labelText = @"评论中...";
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic  = responseObject;
            NSString * myUserid = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
            NSDictionary* user=[[UserManager singleton] getUser:myUserid];
            NSString * myNickName = [user objectForKey:@"nickname"];
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
            NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
            [dic removeObjectForKey:@"msg"];
            [dic setObject:msgStr forKey:@"msg"];
            [dic setObject:myUserid forKey:@"userid"];
            [dic setObject:myNickName forKey:@"nickname"];
            [dic setObject:@"5" forKey:@"type"];
            [dic setObject:[user objectForKey:@"img"] forKey:@"userimg"];
            [dic setObject:strNowTime forKey:@"createDate"];
            self.textView.text = nil;

            [m_dataReply insertObject:dic atIndex:0];
            [m_replyTabel reloadData];
            [self showMessageWindowWithContent:@"评论成功" imageType:0];
        }
        
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
    float heigth = [ReplyCell getContentHeigthWithStr:KISDictionaryHaveKey([m_dataReply objectAtIndex:indexPath.row], @"msg")] + 30;
    return heigth < 60 ? 60 : heigth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* tempDic = [m_dataReply objectAtIndex:indexPath.row];
    
    static NSString *identifier = @"myCell";
    ReplyCell *cell = (ReplyCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
    NSString* imageName = [GameCommon getHeardImgId:KISDictionaryHaveKey(tempDic, @"userimg")];
    if ([imageName isEqualToString:@""]||[imageName isEqualToString:@" "]) {
        cell.headImageV.imageURL = nil;
    }else{
        if (imageName) {
            cell.headImageV.imageURL = [NSURL URLWithString:[[BaseImageUrl stringByAppendingString:imageName] stringByAppendingString:@"/80"]];;
        }else
        {
            cell.headImageV.imageURL = nil;
        }
    }
    
    cell.nickNameLabel.text = [KISDictionaryHaveKey(tempDic, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :KISDictionaryHaveKey(tempDic, @"nickname");
    cell.timeLabel.text = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"createDate")]];
//    cell.commentLabel.text = KISDictionaryHaveKey(tempDic, @"msg");
    
    
    NSMutableAttributedString* commentStr = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:KISDictionaryHaveKey(tempDic, @"msg")];
    OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle.textAlignment = kCTJustifiedTextAlignment;
    paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 0.0f;
    [commentStr setParagraphStyle:paragraphStyle];
    [commentStr setFont:[UIFont systemFontOfSize:12]];
    
    cell.commentLabel.attributedText = commentStr;

    
    
    cell.commentStr = KISDictionaryHaveKey(tempDic, @"msg");
    cell.rowIndex = indexPath.row;
    cell.myDelegate = self;
    
    [cell refreshCell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_replyTabel deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* tempDict = [m_dataReply objectAtIndex:indexPath.row];
    //    NSString* nickName = [KISDictionaryHaveKey(tempDict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :KISDictionaryHaveKey(tempDict, @"nickname");
    NSString* nickName = KISDictionaryHaveKey(tempDict, @"nickname");
    
    self.textView.placeholder = [NSString stringWithFormat:@"回复 %@：", nickName];
    [self.textView becomeFirstResponder];
    
    
}

-(void)CellHeardButtonClick:(int)rowIndex
{
    NSDictionary* tempDict = [m_dataReply objectAtIndex:rowIndex];
    //    if ([KISDictionaryHaveKey(tempDict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
    //        MyProfileViewController * myP = [[MyProfileViewController alloc] init];
    //        [self.navigationController pushViewController:myP animated:YES];
    //    }
    //    else
    //    {
    TestViewController* detailV = [[TestViewController alloc] init];
    detailV.userId = KISDictionaryHaveKey(tempDict, @"userid");
    detailV.nickName = KISDictionaryHaveKey(tempDict, @"nickname");
    detailV.isChatPage = NO;
    [self.navigationController pushViewController:detailV animated:YES];
    //    }
}

#pragma mark  scrollView  delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (m_replyTabel.contentSize.height < m_replyTabel.frame.size.height) {
        refreshView.viewMaxY = 0;
    }
    else
        refreshView.viewMaxY = m_replyTabel.contentSize.height - m_replyTabel.frame.size.height;
    [refreshView viewdidScroll:scrollView];
    
    [_slimeView scrollViewDidScroll];
}


#pragma mark pull up refresh
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == m_replyTabel)
    {
        [refreshView viewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == m_replyTabel)
    {
        [refreshView didEndDragging:scrollView];
        
        [_slimeView scrollViewDidEndDraging];
    }
}

- (void)PullUpStartRefresh:(PullUpRefreshView *)refreshView
{
    [self getDataByNet];
}

#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    m_pageIndex = 0;
    
    [self getDataByNet];
}

-(void)endRefresh
{
    [_slimeView endRefreshFinish:^{
        
    }];
}

#pragma mark 手势
- (void)tapTopViewClick:(id)sender
{
    [self.textView resignFirstResponder];
}
//手势代理的方法，解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]])
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
