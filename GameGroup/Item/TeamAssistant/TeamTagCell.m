//
//  TeamTagCell.m
//  GameGroup
//
//  Created by Apple on 14-9-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamTagCell.h"

@implementation TeamTagCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _tagList = [[DWTagList alloc] initWithFrame:CGRectMake(10, 10, 300, self.frame.size.height)];
        _tagList.tagDelegate=self;
        [self addSubview:_tagList];

    }
    return self;
}
-(void)setTagDate:(NSMutableArray*)typeArray{
    _tagArray=typeArray;
    if (_tagArray.count>0) {
        NSInteger tagsRowCount = (_tagArray.count-1)/3+1;//标签行数
        _tagList.frame = CGRectMake(10, 10, 300,tagsRowCount*30+tagsRowCount*5+15);
    }else{
        _tagList.frame = CGRectMake(10, 10, 300,0);
    }
    [_tagList setTags:typeArray average:YES rowCount:3];
}
-(void)tagClick:(UIButton*)sender{
    NSMutableDictionary * tagDic = [_tagArray objectAtIndex:sender.tag];
    if (self.tagDelegate) {
        [self.tagDelegate tagType:tagDic];
    }
}
@end
