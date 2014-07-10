//
//  TvView.h
//  ceshi --demo
//
//  Created by 魏星 on 14-5-23.
//  Copyright (c) 2014年 魏星. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TvViewDelegate;

@interface TvView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *tv;//下拉列表
    NSMutableArray *tableArray;//下拉列表数据
    UITextField *textField;//文本输入框
    CGFloat tabheight;//table下拉列表的高度
    CGFloat frameHeight;//frame的高度
}
@property(nonatomic,assign)BOOL showList;
@property (nonatomic,retain) UITableView *tv;
@property(nonatomic,strong)NSMutableDictionary *tableDic;
@property (nonatomic,retain) NSMutableArray *tableArray;
@property (nonatomic,retain) UITextField *textField;
@property (nonatomic,strong) id<TvViewDelegate>myViewDelegate;
@property (nonatomic,strong)UILabel *textLabel;
-(void)dropdown;

@end

@protocol TvViewDelegate <NSObject>

-(void)didClickGameIdWithView:(TvView *)myView;
-(void)didClickGameIdSuccessWithView:(TvView *)myView section:(NSInteger)section row:(NSInteger)row;
@end
