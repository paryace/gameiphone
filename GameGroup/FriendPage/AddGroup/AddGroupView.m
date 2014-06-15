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

    self.topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 138)];
    self.topImageView.image = KUIImage(@"topImg_youqu.jpg");
    self.topImageView .backgroundColor = [UIColor grayColor];
    [self.firstScrollView addSubview:self.topImageView];
    
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 158, 300, 40)];
    table_top.image = KUIImage(@"table_top");
    [self.firstScrollView addSubview:table_top];
    
    UIImageView* table_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(290, 174, 12, 8)];
    table_arrow.image = KUIImage(@"arrow_bottom");
    [self.firstScrollView addSubview:table_arrow];
    
//    UIImageView* table_middle = [[UIImageView alloc] initWithFrame:CGRectMake(10, 198, 300, 40)];
//    table_middle.image = KUIImage(@"table_middle");
//    [self.firstScrollView addSubview:table_middle];
    
    UIImageView* table_arrow_two = [[UIImageView alloc] initWithFrame:CGRectMake(290, 214, 12, 8)];
    table_arrow_two.image = KUIImage(@"arrow_bottom");
    [self.firstScrollView addSubview:table_arrow_two];
    
    UIImageView* table_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 199, 300, 40)];
    table_bottom.image = KUIImage(@"table_bottom");
    [self.firstScrollView addSubview:table_bottom];
    
    UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(20, 159, 100, 38)];
    table_label_one.text = @"选择游戏角色";
    table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
    [self.firstScrollView addSubview:table_label_one];
//    
//    UILabel* table_label_two = [[UILabel alloc] initWithFrame:CGRectMake(20, 199, 80, 38)];
//    table_label_two.text = @"所在服务器";
//    table_label_two.textColor = kColorWithRGB(102, 102, 102, 1.0);
//    table_label_two.font = [UIFont boldSystemFontOfSize:15.0];
//    [self.firstScrollView addSubview:table_label_two];
    
    UILabel* table_label_three = [[UILabel alloc] initWithFrame:CGRectMake(20, 199, 80, 38)];
    table_label_three.text = @"群组名称";
    table_label_three.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_three.font = [UIFont boldSystemFontOfSize:15.0];
    [self.firstScrollView addSubview:table_label_three];
    
//    UIImageView* gameImg = [[UIImageView alloc] initWithFrame:CGRectMake(190, 169, 18, 18)];
//    gameImg.image = KUIImage(@"wow");
//    [self.firstScrollView addSubview:gameImg];

    
    m_gamePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gamePickerView.dataSource = self;
    m_gamePickerView.delegate = self;
    m_gamePickerView.showsSelectionIndicator = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];

    
    self.gameTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 158, 180, 40)];
    self.gameTextField.returnKeyType = UIReturnKeyDone;
    self.gameTextField.delegate = self;
    self.gameTextField.inputView = m_gamePickerView;
    self.gameTextField.inputAccessoryView= toolbar;

    self.gameTextField.textAlignment = NSTextAlignmentRight;
    self.gameTextField.font = [UIFont boldSystemFontOfSize:15.0];
    self.gameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.gameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.firstScrollView addSubview:self.gameTextField];
    
//    self.realmTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 198, 180, 40)];
//    self.realmTextField.returnKeyType = UIReturnKeyDone;
//    self.realmTextField.textAlignment = NSTextAlignmentRight;
//    self.realmTextField.delegate = self;
//    self.realmTextField.font = [UIFont boldSystemFontOfSize:15.0];
//    self.realmTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.realmTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [self.firstScrollView addSubview:self.realmTextField];
    
//    UIButton* serverButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 198, 180, 40)];
//    serverButton.backgroundColor = [UIColor clearColor];
//    [serverButton addTarget:self action:@selector(realmSelectClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.firstScrollView addSubview:serverButton];
    
    self.groupNameTf = [[UITextField alloc] initWithFrame:CGRectMake(100, 198, 180, 40)];
    self.groupNameTf.returnKeyType = UIReturnKeyDone;
    self.groupNameTf.delegate = self;
    self.groupNameTf.textAlignment = NSTextAlignmentRight;
    self.groupNameTf.font = [UIFont boldSystemFontOfSize:15.0];
    self.groupNameTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.groupNameTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.firstScrollView addSubview:self.groupNameTf];
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 250, 300, 44)];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button setBackgroundImage:KUIImage(@"group_list_btn1") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playNextGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.firstScrollView addSubview:button];

}
-(void)buildSecondView
{
    self.secondScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(320, 0, self.bounds.size.width, self.bounds.size.height)];
    self.secondScrollView.showsHorizontalScrollIndicator = NO;
    self.secondScrollView.showsVerticalScrollIndicator = NO;
    self.secondScrollView.contentSize = CGSizeMake(0,150+kScreenHeigth);
    [self.scrollView addSubview:self.secondScrollView];
   
    [self getCardWithNet];
    
    self.topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 138)];
    self.topImageView.image = KUIImage(@"topImg_youqu.jpg");
    self.topImageView .backgroundColor = [UIColor grayColor];
    [self.secondScrollView addSubview:self.topImageView];

    
//    UIView *cardView = [[UIView alloc]initWithFrame:CGRectMake(0, 155, 320, 40)];
//    cardView.backgroundColor = UIColorFromRGBA(0xf1f1f1, 1);
//    [cardView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterToCardPage:)]];
//
//    [self.secondScrollView addSubview:cardView];
    
    
    UIImageView *carimg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 155, 300, 40)];
    carimg.image = KUIImage(@"group_cardtf");
    carimg.userInteractionEnabled = YES;
    [carimg addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterToCardPage:)]];

    [self.secondScrollView addSubview:carimg];
    
    self.cardTF =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    self.cardTF.userInteractionEnabled = NO;
    self.cardTF.textColor = [UIColor grayColor];
    self.cardTF.numberOfLines = 0;
    self.cardTF.text = @"选择群标签";
    self.cardTF.userInteractionEnabled = YES;
    self.cardTF.backgroundColor = [UIColor clearColor];
    self.cardTF.font = [UIFont systemFontOfSize:14];
    [carimg addSubview:self.cardTF];
    
    
   UICollectionViewFlowLayout* layout1 = [[UICollectionViewFlowLayout alloc]init];
    layout1.minimumInteritemSpacing = 10;
    layout1.minimumLineSpacing =5;
    
   self. titleCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 200, 300, 50) collectionViewLayout:layout1];
    self.titleCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    self.titleCollectionView.scrollEnabled = NO;
    self.titleCollectionView.delegate = self;
    self.titleCollectionView.dataSource = self;
    [self.titleCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"titleCell"];
    [self.titleCollectionView registerClass:[CardTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headviewwww"];
    self.titleCollectionView.backgroundColor = [UIColor clearColor];
    [self.secondScrollView addSubview:self.titleCollectionView];

    
    m_textView =[[ UITextView alloc]initWithFrame:CGRectMake(10, 250, 300, 150)];
    m_textView.delegate = self;
    m_textView.font = [UIFont boldSystemFontOfSize:13];
    m_textView.textColor = [UIColor blackColor];
    m_textView.backgroundColor = [UIColor whiteColor];
    m_textView.layer.cornerRadius = 5;
    m_textView.layer.masksToBounds = YES;
    [self.secondScrollView addSubview:m_textView];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 420, 300, 44);
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setBackgroundImage:KUIImage(@"group_list_btn1") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(enterThirdPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondScrollView addSubview:button];
    
}


-(void)getCardWithNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"236" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.listDict  = responseObject;
            UICollectionView *coView = (UICollectionView *)[self viewWithTag:1001];
            [coView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
        NSDictionary *dic = [self.cardArray objectAtIndex:indexPath.row];
        CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        return CGSizeMake(size.width+25, 30);
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
        return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return self.cardArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    cell.bgImgView.image = KUIImage(@"card_show");
    NSDictionary* dic = [self.cardArray objectAtIndex:indexPath.row];
    cell.titleLabel.frame = cell.bgImgView.frame;
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

//- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
//{
//    NSString *title = KISDictionaryHaveKey([gameInfoArray objectAtIndex:row], @"name");
//    return title;
//}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    NSDictionary *dic = [gameInfoArray objectAtIndex:row];
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"realm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    [customView addSubview:label];
    return customView;
    
}


-(void)playNextGame:(id)sender
{
    [self.groupNameTf resignFirstResponder];
    
    if ([self.gameTextField.text isEqualToString: @""]||[self.realmTextField.text isEqualToString: @""]||[self.groupNameTf.text isEqualToString:@""]) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请将信息填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
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
    
    [self.myDelegate didClickContentWithDel:self content:m_textView.text];
    
    
}


-(void)selectServerNameOK:(id)sender
{
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
        self.gameTextField.text = [NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(dict, @"realm"),KISDictionaryHaveKey(dict, @"name")];
      
        if (self.myDelegate &&[self.myDelegate respondsToSelector:@selector(didClickGameListWithDel:dic:)]) {
            [self.myDelegate didClickGameListWithDel:self dic:dict];
        }
        [self.gameTextField resignFirstResponder];
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

-(void)comebackKeyBoard{
    [m_textView resignFirstResponder];
    [self.groupNameTf resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
