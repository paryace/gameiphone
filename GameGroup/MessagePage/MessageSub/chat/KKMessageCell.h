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
@property (nonatomic ,retain) UIImageView * ifRead;
@property (nonatomic ,retain) UIImageView * playAudioImageV;

//用固定的样式初始化，且Cell可复用
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
