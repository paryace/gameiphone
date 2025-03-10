//
//  AddGroupView.m
//  GameGroup
//
//  Created by 魏星 on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AddGroupView.h"
#import "CardCell.h"
#import "CardTitleView.h"
#import "EGOImageView.h"
@implementation AddGroupView
{
    UICollectionViewFlowLayout *layout;
    UICollectionView * customPhotoCollectionView;
    UITextView *m_textView;
    NSMutableArray *gameInfoArray;
    UIPickerView *m_gamePickerView;
    UILabel *uilabel;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.listDict = [NSMutableDictionary dictionary];
        self.cardArray = [NSMutableArray array];
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.scrollView.scrollEnabled = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.contentSize = CGSizeMake(kScreenWidth *2, 0);
        [self addSubview:self.scrollView];
        gameInfoArray = [NSMutableArray new];
        gameInfoArray  = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
        
        [self buildFirstView];
        [self buildSecondView];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(comebackKeyBoard)]];
        
    }
    
    return self;
}

-(void)buildFirstView
{
    self.firstScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.firstScrollView.showsHorizontalScrollIndicator = NO;
    self.firstScrollView.showsVerticalScrollIndicator = NO;
    self.firstScrollView.contentSize = CGSizeMake(0,150+kScreenHeigth);
    [self.scrollView addSubview:self.firstScrollView];

    self.topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 190)];
    self.topImageView.image = KUIImage(@"addGroup_top1");
    self.topImageView .backgroundColor = [UIColor grayColor];
    [self.firstScrollView addSubview:self.topImageView];
    
    
    UIImageView* table_arrow_two = [[UIImageView alloc] initWithFrame:CGRectMake(10,159+52, 300, 40)];
    table_arrow_two.image = KUIImage(@"group_cardtf");
    [self.firstScrollView addSubview:table_arrow_two];
    
    
    
    UIImageView* table_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 320, 300, 40)];
    table_bottom.image = KUIImage(@"group_cardtf");
    [self.firstScrollView addSubview:table_bottom];
    
    UIButton* table_arrow = [[UIButton alloc] initWithFrame:CGRectMake(270, 158+52, 40, 40)];
    [table_arrow setImageEdgeInsets:UIEdgeInsetsMake(16, 14, 16, 14)];
    [table_arrow setImage:KUIImage(@"arrow_bottom") forState:UIControlStateNormal];
    [table_arrow addTarget:self action:@selector(result:) forControlEvents:UIControlEventTouchUpInside];
    [self.firstScrollView addSubview:table_arrow];

    
    UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(20, 159+52, 70, 38)];
    table_label_one.text = @"选择角色";
    table_label_one.backgroundColor = [UIColor clearColor];
    table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
    [self.firstScrollView addSubview:table_label_one];
    
    UILabel* table_label_three = [[UILabel alloc] initWithFrame:CGRectMake(20, 320, 80, 38)];
    table_label_three.text = @"群组名称";
    table_label_three.backgroundColor = [UIColor clearColor];

    table_label_three.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_three.font = [UIFont boldSystemFontOfSize:15.0];
    [self.firstScrollView addSubview:table_label_three];
    
    UILabel* lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 280, 60)];
    lb.text = @"选择一个角色来建立组织,该角色所在的游戏和服务器将便于其他人找到该组织,你可以在组织创建成功后修改这些设定";
    lb.numberOfLines =0;
    lb.backgroundColor = [UIColor clearColor];
    lb.textColor = kColorWithRGB(200, 200, 200, 1.0);
    lb.font = [UIFont boldSystemFontOfSize:12.0];
    [self.firstScrollView addSubview:lb];

    
    m_gamePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gamePickerView.dataSource = self;
    m_gamePickerView.delegate = self;
    m_gamePickerView.showsSelectionIndicator = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];

    
    self.gameTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 158+52, 200, 40)];
    self.gameTextField.returnKeyType = UIReturnKeyDone;
    self.gameTextField.delegate = self;
    self.gameTextField.inputView = m_gamePickerView;
    self.gameTextField.inputAccessoryView= toolbar;
    self.gameTextField.adjustsFontSizeToFitWidth = YES;

    self.gameTextField.textAlignment = NSTextAlignmentRight;
    self.gameTextField.font = [UIFont boldSystemFontOfSize:15.0];
    self.gameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.gameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.firstScrollView addSubview:self.gameTextField];
    
    self.groupNameTf = [[UITextField alloc] initWithFrame:CGRectMake(100, 320, 180, 40)];
    self.groupNameTf.returnKeyType = UIReturnKeyDone;
    self.groupNameTf.delegate = self;
    self.groupNameTf.placeholder = @"限10字";
    self.groupNameTf.textAlignment = NSTextAlignmentRight;
    self.groupNameTf.font = [UIFont boldSystemFontOfSize:15.0];
    self.groupNameTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.groupNameTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.firstScrollView addSubview:self.groupNameTf];
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10,370, 300, 44)];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button setBackgroundImage:KUIImage(@"group_list_btn1") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playNextGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.firstScrollView addSubview:button];

}

-(void)result:(id)sender
{
    [self.gameTextField becomeFirstResponder];
}

-(void)buildSecondView
{
    self.secondScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(320, 0, self.bounds.size.width, self.bounds.size.height)];
    self.secondScrollView.showsHorizontalScrollIndicator = NO;
    self.secondScrollView.showsVerticalScrollIndicator = NO;
    self.secondScrollView.contentSize = CGSizeMake(0,100+kScreenHeigth);
    [self.scrollView addSubview:self.secondScrollView];
    
    self.topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 190)];
    self.topImageView.image = KUIImage(@"addGroup_top2");
    self.topImageView .backgroundColor = [UIColor grayColor];
    [self.secondScrollView addSubview:self.topImageView];

    UIImageView *carimg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 155+52, 300, 40)];
    carimg.image = KUIImage(@"group_cardtf");
    carimg.userInteractionEnabled = YES;
    [carimg addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterToCardPage:)]];

    [self.secondScrollView addSubview:carimg];
    
    UIImageView *rightImg = [[UIImageView alloc]initWithFrame:CGRectMake(260, 15, 10, 10)];
    rightImg.image = KUIImage(@"right");
    [carimg addSubview:rightImg];

    self.cardTF =[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 40)];
    self.cardTF.userInteractionEnabled = NO;
    self.cardTF.textColor = [UIColor grayColor];
    self.cardTF.numberOfLines = 0;
    self.cardTF.text = @"选择群分类";
    self.cardTF.userInteractionEnabled = YES;
    self.cardTF.backgroundColor = [UIColor clearColor];
    self.cardTF.font = [UIFont systemFontOfSize:14];
    [carimg addSubview:self.cardTF];
    
    UILabel *lb =[[ UILabel alloc]initWithFrame:CGRectMake(10, 255, 300, 13)];
    lb.backgroundColor = [UIColor clearColor];
    lb.font = [UIFont systemFontOfSize:12];
    lb.textColor = [UIColor grayColor];
    lb.text = @"选择正确的分类才能让更多的玩家发现本群";
    [self.secondScrollView addSubview:lb];
    
    
    
   UICollectionViewFlowLayout* layout1 = [[UICollectionViewFlowLayout alloc]init];
    layout1.minimumInteritemSpacing = 3;
    layout1.minimumLineSpacing =5;
    layout1.itemSize = CGSizeMake(88, 30);
    self. titleCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 267+5, 300, [self getTagViewHight]) collectionViewLayout:layout1];
    
    self.titleCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    self.titleCollectionView.scrollEnabled = NO;
    self.titleCollectionView.delegate = self;
    self.titleCollectionView.dataSource = self;
    [self.titleCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"titleCell"];
    [self.titleCollectionView registerClass:[CardTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headviewwww"];
    self.titleCollectionView.backgroundColor = [UIColor clearColor];
    [self.secondScrollView addSubview:self.titleCollectionView];

    
    
    self.editIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 280+52, 300, 150)];
    self.editIV.backgroundColor=[UIColor whiteColor];
    self.editIV.image = KUIImage(@"group_info");
    [self.secondScrollView addSubview:self.editIV];

    
    m_textView =[[ UITextView alloc]initWithFrame:CGRectMake(10, 280+52, 300, 150)];
    m_textView.delegate = self;
    m_textView.layer.borderColor = UIColorFromRGBA(0xaaa9a9, 1).CGColor;
    m_textView.layer.borderWidth =0.5;
    m_textView.layer.cornerRadius =5.0;
    m_textView.font = [UIFont boldSystemFontOfSize:13];
    m_textView.textColor = [UIColor blackColor];
    m_textView.backgroundColor = [UIColor whiteColor];
    m_textView.layer.cornerRadius = 5;
    m_textView.layer.masksToBounds = YES;
    [self.secondScrollView addSubview:m_textView];

    uilabel = [[UILabel alloc]init];
    
    uilabel.frame =CGRectMake(10, 8,200, 20);
    uilabel.text = @"请填写描述内容(10字以上)";
    uilabel.enabled = NO;//lable必须设置为不可用
    uilabel.font = [UIFont systemFontOfSize:14];
    uilabel.backgroundColor = [UIColor clearColor];
    [m_textView addSubview:uilabel];
}

-(NSInteger)getTagViewHight
{
    if (self.cardArray.count==0) {
        return 0;
    }
    NSInteger tagCount = (self.cardArray.count-1)/3+1;
    return 30*tagCount+5*tagCount;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
        return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self. titleCollectionView.frame = CGRectMake(10, 267+10, 300, [self getTagViewHight]);
    self.editIV.frame = CGRectMake(10, self.titleCollectionView.frame.size.height+self.titleCollectionView.frame.origin.y+5, 300, 150);
    m_textView.frame = CGRectMake(10, self.titleCollectionView.frame.size.height+self.titleCollectionView.frame.origin.y+5, 300, 150);
        return self.cardArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    cell.bgImgView.image = KUIImage(@"card_show");
    NSDictionary* dic = [self.cardArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = KISDictionaryHaveKey(dic, @"tagName");
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        [self.cardArray removeObjectAtIndex:indexPath.row];
        [self.titleCollectionView reloadData];
}

-(void)buildCardButtonWithFrame:(CGRect)frame title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [self.secondScrollView addSubview:button];
}

#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return gameInfoArray.count;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    NSDictionary *dic = [gameInfoArray objectAtIndex:row];
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"simpleRealm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    [customView addSubview:label];
    return customView;
    
}


-(void)playNextGame:(id)sender
{
    [self.groupNameTf resignFirstResponder];
    
    
    if ([GameCommon isEmtity:self.gameTextField.text]||[GameCommon isEmtity:self.groupNameTf.text]) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请将信息填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [al show];
        return;
    }
    if (self.groupNameTf.text.length>10) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请将公会名限定10字符以内" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [al show];
 
        return;
    }
    
    NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
    if (self.myDelegate &&[self.myDelegate respondsToSelector:@selector(didClickPageOneWithDel:WithDic:)]) {
        [self.myDelegate didClickPageOneWithDel:self WithDic:dict];
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    self.scrollView.contentOffset = CGPointMake(320, 0);
    [UIView commitAnimations];

}
-(void)enterThirdPage:(id)sender
{
    if (self.cardArray.count<1) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择标签" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [al show];

        return;
    }
    
    if ([m_textView.text isEqualToString:@""]||[m_textView.text isEqualToString:@""]) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请填写群介绍" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [al show];

        return;
    }
    if (m_textView.text.length<10) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请填写群介绍(10字以上)" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [al show];
        
        return;
    }
    
    [self.myDelegate didClickContentWithDel:self content:m_textView.text];
    
    
}

-(void)selectServerNameOK:(id)sender
{
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
        self.gameTextField.text = [NSString stringWithFormat:@"%@ %@",KISDictionaryHaveKey(dict, @"simpleRealm"),KISDictionaryHaveKey(dict, @"name")];
      
        if (self.myDelegate &&[self.myDelegate respondsToSelector:@selector(didClickGameListWithDel:dic:)]) {
            [self.myDelegate didClickGameListWithDel:self dic:dict];
        }
        [self.gameTextField resignFirstResponder];
        
           self.listDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gameid")],@"gameid",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"id")],@"characterId", nil];
        
    }
}

-(void)realmSelectClick:(id)sender
{
    if (self.myDelegate &&[self.myDelegate respondsToSelector:@selector(didClickRealmListWithDel:)]) {
        [self.myDelegate didClickRealmListWithDel:self];
    }
}

-(void)enterToCardPage:(id)sender
{
    if (self.myDelegate &&[self.myDelegate respondsToSelector:@selector(didClickCardWithDel:dic:)]) {
        [self.myDelegate didClickCardWithDel:self dic:self.listDict];
    }
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        uilabel.text = @"请填写描述内容(10字以上)";
    }else{
        uilabel.text = @"";
    }
}
-(void)comebackKeyBoard{
    [m_textView resignFirstResponder];
    [self.groupNameTf resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)dealloc
{
    self.groupNameTf.delegate=nil;
}

@end
