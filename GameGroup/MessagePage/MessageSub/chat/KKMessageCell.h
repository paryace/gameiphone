//
//  KKMessageCell.h
//  XmppDemo
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGOImageView.h"
#import "OHAttributedLabel.h"
#import "KKchatCell.h"

@interface KKMessageCell : KKChatCell<OHAttributedLabelDelegate>

@property (nonatomic, retain) UILabel *senderAndTimeLabel; //显示时间和发送人的label
@property (nonatomic, retain) OHAttributedLabel *messageContentView;
@property (nonatomic, retain) UIButton *bgImageView;    //聊天气泡
//@property (nonatomic, retain) EGOImageView * headImgV;  //头像
@property (nonatomic, retain) UIButton * headBtn;   //头像可点击
@property (nonatomic ,retain) UIButton * chattoHeadBtn;
@property (nonatomic ,retain) UIImageView * ifRead;
@property (nonatomic ,retain) UIImageView * playAudioImageV;


@property (nonatomic, retain) NSTimer* cellTimer;//发送5秒
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UIButton* failImage;
@property (nonatomic, retain) UILabel*  statusLabel;//已读 送达
//@property(nonatomic, assign) NSInteger cellRow;


@property (nonatomic, retain) NSString* messageuuid;    

@property (nonatomic, strong) EGOImageView *msgImageView;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, assign) BOOL isUploadImage;

- (void)refreshStatusPoint:(CGPoint)point status:(NSString*)status;
//用固定的样式初始化，且Cell可复用
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
