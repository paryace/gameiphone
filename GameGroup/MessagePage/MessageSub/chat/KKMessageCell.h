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

@property (nonatomic, retain) OHAttributedLabel *messageContentView;

//用固定的样式初始化，且Cell可复用
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
