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
//        self.backgroundColor = kColorWithRGB(188, 188, 194, 0.8);
        self.backgroundColor = [UIColor blackColor];
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
            UIImageView * tabIcon = [[UIImageView alloc] initWithFrame:CGRectMake(i*sectionWidth+5, (self.frame.size.height-20)/2, 20, 20)];
            [tabIcon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"item_%d",i+1]]];
            [tabIcon setContentMode:UIViewContentModeScaleToFill];
            [self addSubview:tabIcon];
            
            
            UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*sectionWidth+5+2+20, 1, sectionWidth-7-12-20-3, frame.size.height-2)];
            sectionBtn.tag = SECTION_BTN_TAG_BEGIN + i;
            [sectionBtn addTarget:self action:@selector(sectionBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            NSString *sectionBtnTitle = @"-";
            if ([self.dropDownDataSource respondsToSelector:@selector(titleInSection:index:)]) {
                sectionBtnTitle = [self.dropDownDataSource titleInSection:i index:[self.dropDownDataSource defaultShowSection:i]];
            }
            [sectionBtn  setTitle:sectionBtnTitle forState:UIControlStateNormal];
            [sectionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            sectionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            [self addSubview:sectionBtn];
            
            UIImageView *sectionBtnIv = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth*i +(sectionWidth - 16), (self.frame.size.height-12)/2, 12, 12)];
            [sectionBtnIv setImage:[UIImage imageNamed:@"down_dark.png"]];
            [sectionBtnIv setContentMode:UIViewContentModeScaleToFill];
            sectionBtnIv.tag = SECTION_IV_TAG_BEGIN + i;
            [self addSubview: sectionBtnIv];
            if (i<sectionNum && i != 0) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(sectionWidth*i, frame.size.height/4, 1, frame.size.height/2)];
                lineView.backgroundColor = [UIColor lightGrayColor];
                [self addSubview:lineView];
            }
            
        }
        
    }
    return self;
}

-(void)sectionBtnTouch:(UIButton *)btn
{
    NSInteger section = btn.tag - SECTION_BTN_TAG_BEGIN;
    BOOL isOpen = [self.dropDownDelegate clickAtSection:section];
    if (isOpen) {
        UIImageView *currentIV= (UIImageView *)[self viewWithTag:(SECTION_IV_TAG_BEGIN +currentExtendSection)];
        [UIView animateWithDuration:0.3 animations:^{
            currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
        }];
        if (currentExtendSection == section) {
            [self hideExtendedChooseView];
        }else{
            currentExtendSection = section;
            currentIV = (UIImageView *)[self viewWithTag:SECTION_IV_TAG_BEGIN + currentExtendSection];
            [UIView animateWithDuration:0.3 animations:^{
                currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
            }];
            [self showChooseListViewInSection:currentExtendSection choosedIndex:[self.dropDownDataSource defaultShowSection:currentExtendSection]];
        }
    }
}

- (void)setTitle:(NSString *)title inSection:(NSInteger) section
{
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +section];
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

-(void)showChooseListViewInSection:(NSInteger)section choosedIndex:(NSInteger)index
{
    if (!self.mTableView) {
        self.mTableBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height , self.frame.size.width, self.mSuperView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
        self.mTableBaseView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTappedAction:)];
        [self.mTableBaseView addGestureRecognizer:bgTap];
        
        self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 240) style:UITableViewStylePlain];
        self.mTableView.delegate = self;
        self.mTableView.dataSource = self;
        
    }
    
    //修改tableview的frame
//    int sectionWidth = (self.frame.size.width)/[self.dropDownDataSource numberOfSections];
    int sectionWidth = (self.frame.size.width);
    CGRect rect = self.mTableView.frame;
//    rect.origin.x = sectionWidth *section;
    rect.origin.x = 0;

    rect.size.width = sectionWidth;
    rect.size.height = 0;
    self.mTableView.frame = rect;
    [self.mSuperView addSubview:self.mTableBaseView];
    [self.mSuperView addSubview:self.mTableView];
    
    //动画设置位置
    rect .size.height = 240;
    [UIView animateWithDuration:0.3 animations:^{
        self.mTableBaseView.alpha = 0.2;
        self.mTableView.alpha = 0.2;
        
        self.mTableBaseView.alpha = 1.0;
        self.mTableView.alpha = 1.0;
        self.mTableView.frame =  rect;
    }];
    [self.mTableView reloadData];
}

-(void)bgTappedAction:(UITapGestureRecognizer *)tap
{
    UIImageView *currentIV = (UIImageView *)[self viewWithTag:(SECTION_IV_TAG_BEGIN + currentExtendSection)];
    [UIView animateWithDuration:0.3 animations:^{
        currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
    }];
    [self hideExtendedChooseView];
}
#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection ==0) {
        return 60;
    }else
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        NSString *chooseCellTitle;
        if (currentExtendSection==0) {
            chooseCellTitle = [NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey([self.dropDownDataSource contentInsection:currentExtendSection index:indexPath.row], @"simpleRealm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey([self.dropDownDataSource contentInsection:currentExtendSection index:indexPath.row], @"name")]];
        }else{
            chooseCellTitle = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
        }
        
        
        UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + currentExtendSection];
        [currentSectionBtn setTitle:chooseCellTitle forState:UIControlStateNormal];
        
        [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
        [self hideExtendedChooseView];
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
    NSLog(@"----%d",currentExtendSection);
    if (currentExtendSection ==0) {
        static NSString * cellIdentifier = @"cellIdentifier";

        FindRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[FindRoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.backgroundColor = kColorWithRGB(27, 29, 34, 1);
        NSDictionary *dic = [self.dropDownDataSource contentInsection:currentExtendSection index:indexPath.row];
        NSString *imgStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")];
        cell.headImgView.imageURL = [ImageService getImageStr:imgStr Width:100];
        cell.roleNameLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"name")];
        NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")];

        cell.gameIconImg.imageURL = [ImageService getImageUrl4:gameImageId];
        cell.realmLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"simpleRealm")];
        cell.zdlLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value2")];
        cell.zdlLabel.adjustsFontSizeToFitWidth = YES;
        cell.zdlNumLabel.text= [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value3")];
        return cell;
    }else if(currentExtendSection ==1){
        static NSString * indentifier = @"cell";

    DropTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[DropTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.backgroundColor = [UIColor blackColor];
    cell.titleLabel.text = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
    cell.titleLabel.font = [UIFont systemFontOfSize:12];
    cell.titleLabel.textColor = [UIColor whiteColor];
    return cell;
    }
    return nil;
}

@end
