//
//  TvView.m
//  ceshi --demo
//
//  Created by 魏星 on 14-5-23.
//  Copyright (c) 2014年 魏星. All rights reserved.
//

#import "TvView.h"
#import "EGOImageButton.h"
#import "GameListCell.h"
@implementation TvView
{
    EGOImageButton * menuButotn;
    UILabel *titleLabel;
    UILabel *textLabel;
}
@synthesize tv,tableArray,textField;


-(id)initWithFrame:(CGRect)frame
{
    if (frame.size.height<390-(KISHighVersion_7?64:44)) {
        frameHeight = 390-(KISHighVersion_7?64:44);
    }else{
        frameHeight = frame.size.height;
    }
    tabheight = frameHeight-30;
    
    frame.size.height = KISHighVersion_7?130:110;
    
    self=[super initWithFrame:frame];
    
    if(self){
        

        self.showList = NO; //默认不显示下拉框
        self.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.6];
        tv = [[UITableView alloc] initWithFrame:CGRectMake(0, KISHighVersion_7?64:44,320, 0)];
        tv.delegate = self;
        tv.dataSource = self;
        tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        tv.rowHeight = 40;
        if (KISHighVersion_7) {
            tv.sectionIndexBackgroundColor = [UIColor clearColor];
        }
        tv.backgroundColor = [UIColor clearColor];
        tv.separatorColor = [UIColor lightGrayColor];
        tv.hidden = YES;
        [self addSubview:tv];
        
        titleLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0,KISHighVersion_7?20:0, 320, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text  = @"发现";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [ UIColor clearColor];
        [self addSubview:titleLabel];
        
        textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,self.bounds.size.height-66, 320, 20)];
        textLabel.text = @"选择游戏 开始您的游戏社交";
        textLabel.textColor =[UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.backgroundColor =[ UIColor clearColor];
        textLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:textLabel];
        menuButotn = [[EGOImageButton alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-30, 44, 44)];
        menuButotn.center = CGPointMake(160, self.bounds.size.height-22);
        [menuButotn addTarget:self action:@selector(dropdown) forControlEvents:UIControlEventTouchUpInside];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"]) {
             NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"];
//            menuButotn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:KISDictionaryHaveKey(dic, @"img")]];
            
            NSString * imageId= KISDictionaryHaveKey(dic, @"img");
            menuButotn.imageURL= [ImageService getImageUrl4:imageId];
        }else{
            [menuButotn setBackgroundImage:KUIImage(@"menu_find") forState:UIControlStateNormal];
        }
        [self addSubview:menuButotn];
        
 
        
    }
    return self;
}
-(void)dropdown{
    
    if (self.myViewDelegate &&[self.myViewDelegate respondsToSelector:@selector(didClickGameIdWithView:)]) {
        [self.myViewDelegate didClickGameIdWithView:self];
    }
    
    if (self.showList) {//如果下拉框已显示，什么都不做
        self.showList = NO;
        tv.hidden = YES;
        
        CGRect sf = self.frame;
        sf.size.height = KISHighVersion_7?130:110;
        [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        self.frame = sf;
        menuButotn.center = CGPointMake(160, self.bounds.size.height-22);
        titleLabel.text = @"发现";
        textLabel.hidden =NO;
        CGRect frame = tv.frame;
        frame.size.height = 0;
        tv.frame = frame;
        [UIView commitAnimations];

        return;
    }else {//如果下拉框尚未显示，则进行显示
        
        CGRect sf = self.frame;
        sf.size.height = frameHeight;
        
        //把dropdownList放到前面，防止下拉框被别的控件遮住
        [self.superview bringSubviewToFront:self];
        tv.hidden = NO;
        self.showList = YES;//显示下拉框
        titleLabel.text = @"请选择游戏";
        textLabel.hidden = YES;
        CGRect frame = tv.frame;
        frame.size.height = 0;
        tv.frame = frame;
        frame.size.height = tabheight;
        [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.frame = sf;
        self.frame = CGRectMake(0, 0, 320, 430);
        menuButotn.center = CGPointMake(160, self.bounds.size.height-30);
        tv.frame = frame;
        [UIView commitAnimations];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    headerLabel.text = tableArray[section];
    [view addSubview:headerLabel];
    return view;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    tableView.tableHeaderView.backgroundColor =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.3];
//    return [tableArray objectAtIndex:section];
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return tableArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.tableDic objectForKey:[tableArray objectAtIndex:section]];

    return [arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    GameListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GameListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *arr = [self.tableDic objectForKey:[tableArray objectAtIndex:indexPath.section]];

    NSDictionary *dic = [arr objectAtIndex:indexPath.row];

    cell.nameLabel.text = KISDictionaryHaveKey(dic, @"name");
//    cell.gameIconImg.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:KISDictionaryHaveKey(dic, @"img")]];
    
    NSString * imageId=KISDictionaryHaveKey(dic, @"img");
    cell.gameIconImg.imageURL= [ImageService getImageUrl4:imageId];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [menuButotn setBackgroundImage:KUIImage(@"") forState:UIControlStateNormal];
    
    NSArray *arr = [self.tableDic objectForKey:[tableArray objectAtIndex:indexPath.section]];
    NSDictionary *dic = [arr objectAtIndex:indexPath.row];
    
    if (self.myViewDelegate &&[self.myViewDelegate respondsToSelector:@selector(didClickGameIdSuccessWithView:section:row:)]) {
        [self.myViewDelegate didClickGameIdSuccessWithView:self section:indexPath.section row:indexPath.row];
    }
    self.showList = NO;
    tv.hidden = YES;
    
    CGRect sf = self.frame;
    sf.size.height = KISHighVersion_7?130:110;
    [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];

    self.frame = sf;
//    menuButotn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:KISDictionaryHaveKey(dic, @"img")]];
    NSString * imageId2=KISDictionaryHaveKey(dic, @"img");
    menuButotn.imageURL=[ImageService getImageUrl4:imageId2];
    menuButotn.center = CGPointMake(160, self.bounds.size.height-22);
    titleLabel.text  = @"发现";
    textLabel.hidden =NO;
    CGRect frame = tv.frame;
    frame.size.height = 0;
    tv.frame = frame;
    [UIView commitAnimations];

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

