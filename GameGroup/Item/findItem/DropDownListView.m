//
//  DropDownListView.m
//  GameGroup
//
//  Created by Marss on 14-7-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "DropDownListView.h"
#import "FindRoleCell.h"
#import "DropTitleCell.h"
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians)*(180.0/M_PI))

@implementation DropDownListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *lineImageView1 =[[UIImageView alloc]initWithImage:KUIImage(@"team_line_2")];
        lineImageView1.frame = CGRectMake(0, 0, frame.size.width, 1);
        [self addSubview:lineImageView1];
        
        UIImageView *lineImageView2 =[[UIImageView alloc]initWithImage:KUIImage(@"team_line_2")];
        lineImageView2.frame = CGRectMake(0, frame.size.height-1, frame.size.width, 1);
        [self addSubview:lineImageView2];
        
        UIImageView *lineView2 =[[ UIImageView alloc]initWithImage:KUIImage(@"team_line_1")];
        lineView2.frame = CGRectMake(227, 0, 1, frame.size.height);
        [self addSubview:lineView2];

        currentExtendSection = -1;
        self.dropDownDataSource = datasource;
        self.dropDownDelegate = delegate;
        
        NSInteger sectionNum =0;
        if ([self.dropDownDataSource respondsToSelector:@selector(numberOfSections)] ) {
            sectionNum = [self.dropDownDataSource numberOfSections];
        }
        if (sectionNum == 0) {
            self = nil;
        }
        //初始化默认显示view
        CGFloat sectionWidth = (1.0*(frame.size.width)/sectionNum);
        for (int i = 0; i <sectionNum; i++) {
//            UIImageView * tabIcon = [[UIImageView alloc] initWithFrame:CGRectMake(i*sectionWidth+5, (self.frame.size.height-20)/2, 20, 20)];
//            [tabIcon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"item_%d",i+1]]];
//            [tabIcon setContentMode:UIViewContentModeScaleToFill];
//            [self addSubview:tabIcon];
            
            
            UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*sectionWidth+5+2+20, 1, sectionWidth-7-12-20-3, frame.size.height-2)];
            sectionBtn.backgroundColor = UIColorFromRGBA(0x282c32, 1);
            sectionBtn.tag = SECTION_BTN_TAG_BEGIN + i;
            [sectionBtn addTarget:self action:@selector(sectionBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            NSString *sectionBtnTitle = @"-";
            if ([self.dropDownDataSource respondsToSelector:@selector(titleInSection:index:)]) {
                sectionBtnTitle = [self.dropDownDataSource titleInSection:i index:[self.dropDownDataSource defaultShowSection:i]];
            }
            [sectionBtn  setTitle:sectionBtnTitle forState:UIControlStateNormal];
            [sectionBtn setTitleColor:UIColorFromRGBA(0xdaeefa, 1) forState:UIControlStateNormal];
            sectionBtn.titleLabel.font = [UIFont systemFontOfSize:kFontSize(28)];
            [self addSubview:sectionBtn];
            
            UIImageView *sectionBtnIv = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth*i +(sectionWidth - 16), (self.frame.size.height-12)/2, 15, 15)];
            [sectionBtnIv setImage:[UIImage imageNamed:@"down_dark_normal.png"]];
            [sectionBtnIv setContentMode:UIViewContentModeScaleToFill];
            sectionBtnIv.tag = SECTION_IV_TAG_BEGIN + i;
            [self addSubview: sectionBtnIv];
            switch (i) {
                case 0:
                    sectionBtn.frame = CGRectMake(0,1, 227, frame.size.height-2);
                    sectionBtnIv.frame = CGRectMake(227-16, (self.frame.size.height-12)/2, 12, 12);
                    break;
                case 1:
                    sectionBtn.frame = CGRectMake(228, 1, 92, frame.size.height-2);
                    sectionBtnIv.frame = CGRectMake(320-16, (self.frame.size.height-12)/2, 12, 12);
                    break;
                default:
                    break;
            }
        }
    }
    return self;
}

-(void)sectionBtnTouch:(UIButton *)btn
{
    NSInteger section = btn.tag - SECTION_BTN_TAG_BEGIN;
    [self showHide:section];
}
-(void)showHide:(NSInteger)section{
    BOOL isOpen = [self.dropDownDelegate clickAtSection:section];
    if (isOpen) {
        [self hideView];
        if (currentExtendSection == section) {
            [self hideExtendedChooseView];
        }else{
            currentExtendSection = section;
            [self showView];
            [self showChooseListViewInSection:currentExtendSection];
        }
    }
}
-(void)hideView{
    UIImageView *currentIV= (UIImageView *)[self viewWithTag:(SECTION_IV_TAG_BEGIN +currentExtendSection)];
    [UIView animateWithDuration:0.3 animations:^{
        currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
        [currentIV setImage:[UIImage imageNamed:@"down_dark_normal.png"]];
    }];
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +currentExtendSection];
    [btn setTitleColor:UIColorFromRGBA(0xdaeefa, 1) forState:UIControlStateNormal];
}
-(void)showView{
    UIImageView *currentIV = (UIImageView *)[self viewWithTag:SECTION_IV_TAG_BEGIN + currentExtendSection];
    [UIView animateWithDuration:0.3 animations:^{
        currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
        [currentIV setImage:[UIImage imageNamed:@"down_dark_click.png"]];
    }];
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +currentExtendSection];
    [btn setTitleColor:UIColorFromRGBA(0x3eacf5, 1)forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title inSection:(NSInteger) section
{
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +section];
    if (title.length>14) {
        title = [NSString stringWithFormat:@"%@...",[title substringToIndex:14]];
    }

    [btn setTitle:title forState:UIControlStateNormal];
}

- (BOOL)isShow
{
    if (currentExtendSection == -1) {
        return NO;
    }
    return YES;
}
-  (void)hideExtendedChooseView
{
    if (currentExtendSection != -1) {
        currentExtendSection = -1;
        CGRect rect = self.mTableView.frame;
        rect.size.height = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.mTableBaseView.alpha = 1.0f;
            self.mTableView.alpha = 1.0f;
            
            self.mTableBaseView.alpha = 0.2f;
            self.mTableView.alpha = 0.2;
            
            self.mTableView.frame = rect;
        }completion:^(BOOL finished) {
            [self.mTableView removeFromSuperview];
            [self.mTableBaseView removeFromSuperview];
        }];
    }
}

-(void)showChooseListViewInSection:(NSInteger)section
{
    if (!self.mTableView) {
        self.mTableBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height , self.frame.size.width, self.mSuperView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
        self.mTableBaseView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTappedAction:)];
        [self.mTableBaseView addGestureRecognizer:bgTap];
        self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 240) style:UITableViewStylePlain];
        self.mTableView.backgroundColor = kColorWithRGB(27, 29, 35, 1);
        self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.mTableView.delegate = self;
        self.mTableView.dataSource = self;
        
    }
    [self resetFrame];
    [self.mSuperView addSubview:self.mTableBaseView];
    [self.mSuperView addSubview:self.mTableView];
    //动画设置位置
    [UIView animateWithDuration:0.3 animations:^{
        self.mTableBaseView.alpha = 0.2;
        self.mTableView.alpha = 0.2;
        self.mTableBaseView.alpha = 1.0;
        self.mTableView.alpha = 1.0;
    }];
    [self.mTableView reloadData];
}


-(void)resetFrame{
    CGRect rect = self.mTableView.frame;
    rect.origin.x = 0;
    rect.size.width = 320;
//    if (currentExtendSection==0) {
////        rect.size.height = kScreenHeigth-(KISHighVersion_7?64:44)-50-40;
//        
//    }else{
        rect .size.height = ([self.dropDownDataSource numberOfRowsInSection:currentExtendSection]*(currentExtendSection==0?70:40))>(self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40)?(self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40):([self.dropDownDataSource numberOfRowsInSection:currentExtendSection]*(currentExtendSection==0?70:40));
//    }
    self.mTableView.frame = rect;
}

-(void)bgTappedAction:(UITapGestureRecognizer *)tap
{
    [self showHide:currentExtendSection];
}
#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection ==0) {
        return 70;
    }else{
        return 40;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        NSString *chooseCellTitle;
        if (currentExtendSection==0) {
            chooseCellTitle = [NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey([self.dropDownDataSource contentInsection:currentExtendSection index:indexPath.row], @"simpleRealm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey([self.dropDownDataSource contentInsection:currentExtendSection index:indexPath.row], @"name")]];
//            if (chooseCellTitle.length>6) {
//                [NSString stringWithFormat:@"%@%@",[chooseCellTitle substringToIndex:6],@"..."];
//            }
        }else{
            chooseCellTitle = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
            if (chooseCellTitle.length>14) {
                chooseCellTitle = [NSString stringWithFormat:@"%@...",[chooseCellTitle substringToIndex:14]];
            }
        }
        [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
        [self showHide:currentExtendSection];
    }
}

#pragma mark -- UITableView DataSource


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropDownDataSource numberOfRowsInSection:currentExtendSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection ==0) {
        static NSString * cellIdentifier = @"cellIdentifiercha";
        FindRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[FindRoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectedBackgroundView = [[UIView alloc ]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGBA(0x282b32, 1);
        cell.backgroundColor = kColorWithRGB(27, 29, 35, 1);
        NSDictionary *dic = [self.dropDownDataSource contentInsection:currentExtendSection index:indexPath.row];
        NSString *imgStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")];
        cell.headImgView.imageURL = [ImageService getImageStr:imgStr Width:100];
        cell.roleNameLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"name")];
        NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")];

        cell.gameIconImg.imageURL = [ImageService getImageUrl4:gameImageId];
        cell.realmLabel.text = [NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"simpleRealm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value1")]];
        
        cell.zdlLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value2")];
        cell.zdlLabel.adjustsFontSizeToFitWidth = YES;
        cell.zdlNumLabel.text= [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value3")];
        return cell;
    }else{
        static NSString * cellIdentifier = @"cellIdentifierText";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.backgroundColor = kColorWithRGB(27, 29, 35, 1);
        cell.textLabel.text = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:kFontSize(28)];
        cell.textLabel.textColor = UIColorFromRGBA(0xdbedfa, 1);
        UIImageView * lineView =[[ UIImageView alloc]initWithFrame:CGRectMake(0, 39, self.frame.size.width, 1)];
        lineView.image  = KUIImage(@"team_line_2");
        [cell.contentView addSubview:lineView];

        return cell;
    }
    return nil;
}

@end
