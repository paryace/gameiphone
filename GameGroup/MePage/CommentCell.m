//
//  CommentCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CommentCell.h"
#import "OHASBasicHTMLParser_SmallEmoji.h"

@implementation CommentCell

@synthesize commentContLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nicknameButton = [[UIButton alloc]initWithFrame:CGRectMake(5,0, 100, 16)];
        self.nicknameButton.titleLabel.textColor =  UIColorFromRGBA(0x455ca8, 1);
     //   self.nicknameButton.titleLabel.textColor =  [UIColor redColor];
        [self.contentView addSubview:self.nicknameButton];
        self.nicknameButton.hidden = YES;
        
        self.commentContLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectMake(110, 0, 100,30)];
        self.commentContLabel.delegate = self;
        self.commentContLabel.font = [UIFont systemFontOfSize:12];
        self.commentContLabel.numberOfLines = 0;
        self.commentContLabel.textColor = [UIColor grayColor];
        self.commentContLabel.textAlignment=NSTextAlignmentCenter;
        [self.contentView addSubview:self.commentContLabel];
    }
    return self;
}

//显示可点击的呢称
-(void)showNickNameButton:(NSString *)nickName withSize:(CGSize)commentstrSize;
{
  
    // 实现可点击昵称的原理
    // 生成一个Button覆盖在文字之上， 写着相同的内容。 响应点击。
	CGPoint outputPoint = CGPointZero;
	CGRect bounds = [self bounds];
	if (commentstrSize.height < bounds.size.height)
	{
		// the lines of text are centered in the bounds, so adjust the output point
//		CGFloat boundsMidY = CGRectGetMidY(bounds);
//		CGFloat textMidY = commentstrSize.height / 2.0;
		outputPoint.y = commentstrSize.height-10;
	}
    UIFont *font = self.commentContLabel.font;
    CGSize matchSize = [nickName sizeWithFont:font];
    //CGSize matchSize = commentstrSize;
    CGRect matchFrame = CGRectMake(2,5, matchSize.width + 6.0f, matchSize.height);
    [self.nicknameButton setFrame:matchFrame];
	[self.nicknameButton.titleLabel setFont:font];
    [self.nicknameButton.titleLabel setTextColor:[UIColor clearColor]];
	//[self.nicknameButton setTitle:nickName forState:UIControlStateNormal];
	[self.nicknameButton.titleLabel setLineBreakMode:[self.commentContLabel lineBreakMode]];
	[self.nicknameButton addTarget:self action:@selector(handleNickNameButton:) forControlEvents:UIControlEventTouchUpInside];
    self.nicknameButton.hidden = NO;
}

//点击昵称
- (void)handleNickNameButton:(id)cell
{
    [self.myCommentCellDelegate handleNickNameButton:self];
}


+ (CGSize)getCellHeigthWithStr:(NSString*)contStr
{
    NSAttributedString* commentStr =[CommentCell GetAttributedCommentWithStr:contStr];
    CGSize size1 = [commentStr sizeConstrainedToSize:CGSizeMake(245, MAXFLOAT)];
    NSLog(@"%f, %f",size1.width, size1.height);
    return size1;
}

-(void)refreshsCell
{
    NSAttributedString* commentStr =[CommentCell GetAttributedCommentWithStr:self.commentStr];
    CGSize size1 = [commentStr sizeConstrainedToSize:CGSizeMake(245, MAXFLOAT)];
    self.commentContLabel.frame = CGRectMake(5, 5, 245, size1.height);
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    //	[self.visitedLinks addObject:objectForLinkInfo(linkInfo)];
	[attributedLabel setNeedsRecomputeLinksInText];
	
    if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
    {
        // use default behavior
        return YES;
    }
    else
    {
        switch (linkInfo.resultType) {
            case NSTextCheckingTypeAddress:
                NSLog(@"%@",[linkInfo.addressComponents description]);
                break;
            case NSTextCheckingTypeDate:
                NSLog(@"%@",[linkInfo.date description]);
                break;
            case NSTextCheckingTypePhoneNumber:
                NSLog(@"%@",linkInfo.phoneNumber);
                break;
            default: {
                break;
            }
        }
        return NO;
    }
}

+(NSMutableAttributedString*)GetAttributedCommentWithStr:(NSString*)Str;
{
    
    NSMutableAttributedString* commentStr = [OHASBasicHTMLParser_SmallEmoji attributedStringByProcessingMarkupInString:Str];
    OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle.textAlignment = kCTJustifiedTextAlignment;
    paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 0.0f;
    [commentStr setParagraphStyle:paragraphStyle];
    [commentStr setFont:[UIFont systemFontOfSize:12]];
    [commentStr setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByWordWrapping];
    // [commentStr addAttribute:NSForegroundColorAttributeName value: UIColorFromRGBA(0x455ca8, 1) range:NSMakeRange(0,nickNameLenght)];
    return commentStr;
}
@end

