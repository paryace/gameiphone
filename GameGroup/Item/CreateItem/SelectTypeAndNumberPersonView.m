//
//  SelectTypeAndNumberPersonView.m
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SelectTypeAndNumberPersonView.h"

@implementation SelectTypeAndNumberPersonView{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.m_typeArray = [NSMutableArray array];
        self.m_countArray = [NSMutableArray array];
        
        self.m_typePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 160, frame.size.height)];
        self.m_typePickerView.backgroundColor = [UIColor whiteColor];
        self.m_typePickerView.dataSource = self;
        self.m_typePickerView.delegate = self;
        self.m_typePickerView.showsSelectionIndicator = YES;
        [self addSubview:self.m_typePickerView];
        
        
        self.m_countPickView = [[UIPickerView alloc]initWithFrame:CGRectMake(160, 0, 160, frame.size.height)];
        self.m_countPickView.backgroundColor = [UIColor whiteColor];
        self.m_countPickView.dataSource = self;
        self.m_countPickView.delegate = self;
        self.m_countPickView.showsSelectionIndicator = YES;
        [self addSubview:self.m_countPickView];
    }
    return self;
}

#pragma mark -- 人数请求成功通知
-(void)setNumberArray:(id)responseObject
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSArray * menCount = KISDictionaryHaveKey(responseObject, @"maxVols");
        if (menCount.count>0) {
            [self.m_countArray removeAllObjects];
            [self.m_countArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"maxVols")];
            [self.m_countPickView reloadAllComponents];
            [self.m_countPickView selectRow:self.m_countArray.count/2 inComponent:0 animated:YES];
            if (self.selectTypeDelegate) {
                [self.selectTypeDelegate selectCount:[self.m_countArray objectAtIndex:self.m_countArray.count/2]];
            }
        }
    }
}
#pragma mark -- 分类请求成功通知
-(void)setTypeArray:(id)responseObject{
    if ([responseObject isKindOfClass:[NSArray class]]) {
        [responseObject removeObjectAtIndex:0];
        [self.m_typeArray removeAllObjects];
        [self.m_typeArray addObjectsFromArray:responseObject];
        [self.m_typePickerView reloadAllComponents];
        [self.m_typePickerView selectRow:self.m_typeArray.count/2 inComponent:0 animated:YES];
        if (self.selectTypeDelegate) {
            [self.selectTypeDelegate selectType:[self.m_typeArray objectAtIndex:self.m_typeArray.count/2]];
        }
    }
}

#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.m_typePickerView)
    {
        return self.m_typeArray.count;
    }
    else
    {
        return self.m_countArray.count;
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView ==self.m_typePickerView)
    {
        return KISDictionaryHaveKey([self.m_typeArray objectAtIndex:row], @"value");
        
    }else
    {
        return KISDictionaryHaveKey([self.m_countArray objectAtIndex:row], @"value");
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 160, 30)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:label];
    
    if (pickerView == self.m_typePickerView)
    {
        label.text = KISDictionaryHaveKey([self.m_typeArray objectAtIndex:row], @"value");
    }else
    {
        label.text = KISDictionaryHaveKey([self.m_countArray objectAtIndex:row], @"value");
    }
    return customView;
}
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.m_typePickerView)
    {
        if (self.selectTypeDelegate) {
            [self.selectTypeDelegate selectType:[self.m_typeArray objectAtIndex:row]];
        }
    }else
    {
        if (self.selectTypeDelegate) {
            [self.selectTypeDelegate selectCount:[self.m_countArray objectAtIndex:row]];
        }
    }
}

@end
