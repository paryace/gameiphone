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
-(void)setNumberArray:(id)responseObject SelectType:(NSMutableDictionary*)selectType
{
    NSLog(@"selectType----%@",selectType);
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSArray * menCount = KISDictionaryHaveKey(responseObject, @"maxVols");
        if (menCount.count>0) {
            [self.m_countArray removeAllObjects];
            [self.m_countArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"maxVols")];
            [self.m_countPickView reloadAllComponents];
            NSInteger item = [self getMaxItem:[KISDictionaryHaveKey(selectType, @"mask") integerValue] CountArray:self.m_countArray];
            NSLog(@"selectItem----%d",item);
            [self.m_countPickView selectRow:item inComponent:0 animated:YES];
            if (self.selectTypeDelegate) {
                [self.selectTypeDelegate selectCount:[self.m_countArray objectAtIndex:item]];
            }
        }
    }
}

-(NSInteger)getMaxItem:(NSInteger)max CountArray:(NSMutableArray*)array{
    if (array.count>0) {
        for (int i = 0; i<array.count; i++) {
            if ([KISDictionaryHaveKey([array objectAtIndex:i], @"mask") integerValue] == max) {
                return i;
            }
        }
        return 0;
    }
    return 0;
}

#pragma mark -- 分类请求成功通知
-(void)setTypeArray:(id)responseObject SelectType:(NSMutableDictionary*)selectType{
    if ([responseObject isKindOfClass:[NSArray class]]) {
        [responseObject removeObjectAtIndex:0];
        [self.m_typeArray removeAllObjects];
        [self.m_typeArray addObjectsFromArray:responseObject];
        [self.m_typePickerView reloadAllComponents];
        NSInteger item = 0;
        if (selectType) {
            item = [self getTypeItem:[KISDictionaryHaveKey(selectType, @"constId") integerValue] TypeArray:self.m_typeArray];
        }
        [self.m_typePickerView selectRow:item inComponent:0 animated:YES];
        if (self.selectTypeDelegate) {
            [self.selectTypeDelegate selectType:[self.m_typeArray objectAtIndex:item]];
        }
    }
}
-(NSInteger)getTypeItem:(NSInteger)constId TypeArray:(NSMutableArray*)array{
    if (array.count>0) {
        for (int i = 0; i<array.count; i++) {
            if ([KISDictionaryHaveKey([array objectAtIndex:i], @"constId") integerValue] == constId) {
                return i;
            }
        }
        return 0;
    }
    return 0;
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
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    label.backgroundColor = [UIColor clearColor];
    
    [customView addSubview:label];
    
    if (pickerView == self.m_typePickerView)
    {
        label.textAlignment = NSTextAlignmentRight;
        customView.frame = CGRectMake(0, 0, 140, 30);
        label.frame = CGRectMake(0, 0, 140, 30);
        label.text = KISDictionaryHaveKey([self.m_typeArray objectAtIndex:row], @"value");
    }else
    {
        label.textAlignment = NSTextAlignmentLeft;
        customView.frame = CGRectMake(20, 0, 140, 30);
        label.frame = CGRectMake(20, 0, 140, 30);
        label.text = KISDictionaryHaveKey([self.m_countArray objectAtIndex:row], @"value");
    }
    return customView;
}
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.m_typePickerView)
    {
        if (row<self.m_typeArray.count) {
            if (self.selectTypeDelegate) {
                [self.selectTypeDelegate selectType:[self.m_typeArray objectAtIndex:row]];
            }
        }
    }else
    {
        if (row<self.m_countArray.count) {
             if (self.selectTypeDelegate) {
                 [self.selectTypeDelegate selectCount:[self.m_countArray objectAtIndex:row]];
            }
        }
    }
}

@end
