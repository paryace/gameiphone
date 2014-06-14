//
//  KKMessageCell.h
//  XmppDemo
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGOImageView.h"
#import "PBEmojiLabel.h"
#import "KKchatCell.h"

@interface KKMessageCell : KKChatCell

@property (nonatomic, retain) UILabel *messageContentView;

//用固定的样式初始化，且Cell可复用
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
