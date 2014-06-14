//
//  GroupInfoEditViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupInfoEditViewController.h"
#import "EGOImageView.h"
#import "GroupInfomationJsCell.h"
#import "GroupNameCell.h"
@interface GroupInfoEditViewController ()
{
    NSMutableDictionary *m_mainDict;
    UITableView *m_myTableView;
    UIView *aoView;
    NSMutableDictionary *paramDict;
    UIImageView *topImageView;
}
@end

@implementation GroupInfoEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTopViewWithTitle:@"群信息设置" withBackButton:YES];
    
    m_mainDict = [NSMutableDictionary new];
    paramDict  = [NSMutableDictionary dictionary];
    m_mainDict = (NSMutableDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_group",self.groupId]];
    
    // Do any additional setup after loading the view.
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth -startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.backgroundColor = [UIColor clearColor];
    m_myTableView.showsVerticalScrollIndicator = NO;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:m_myTableView];
    
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(saveChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, startX, 320, 192)];
    topImageView.image = KUIImage(@"groupinfo_top");
    topImageView .userInteractionEnabled = YES;
    topImageView.userInteractionEnabled = YES;
    [topImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTopImage:)]];

    m_myTableView.tableHeaderView = topImageView;
    
    
    UILabel *promptLb= [[UILabel alloc]initWithFrame:CGRectMake(0, 150, 320, 42)];
    promptLb.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
    promptLb.textColor = [UIColor whiteColor];
    promptLb.textAlignment = NSTextAlignmentCenter;
    promptLb.text = @"点击图片更换头图";
    [topImageView addSubview:promptLb];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        static NSString *cellindientf = @"cell12";
        GroupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindientf];
        if (!cell) {
            cell = [[GroupNameCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindientf];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.nameLabel.text = KISDictionaryHaveKey(m_mainDict, @"groupName");
        return cell;

    }
    if (indexPath.row ==1) {
        static NSString *cellinde = @"cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
        ;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"群分类";
        [cell.contentView addSubview:titleLabel];
        
        
        if (m_mainDict &&[m_mainDict allKeys].count>0) {
            
//            EGOImageView *gameImg =[[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//            gameImg.center = CGPointMake(40, 45);
//            NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(m_mainDict, @"gameid")];
//            gameImg.imageURL = [ImageService getImageUrl4:gameImageId];
//            [cell addSubview:gameImg];
            
            NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
            NSArray * us=cell.contentView.subviews;
            for(UIImageView *uv in us)
            {
                if (uv.tag==122222) {
                    [uv removeFromSuperview];
                }
            }
            for (int i =0; i<tags.count; i++) {
                UIImageView * tagImage = [self buildImgVWithframe:CGRectMake(80+(i%2)*88+5*(i%2)-5,10+(i/2)*30+5*(i/2),88,30) title:KISDictionaryHaveKey(tags[i], @"tagName")];
                tagImage.tag=122222;
                [cell.contentView addSubview:tagImage];
            }
        }
        return cell;
    }
    else if (indexPath.row ==2)
    {    static NSString *cellinde2 = @"cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde2];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde2];
        }

        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
        ;
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:titleLabel];
        
        titleLabel.text = @"群组号";
        UILabel *numLb = [[UILabel alloc]initWithFrame:CGRectMake(80, 0,200, 40)];
        numLb.font = [UIFont boldSystemFontOfSize:14];
        numLb.backgroundColor = [UIColor clearColor];
        numLb.textColor =[ UIColor blackColor];
        numLb.text = KISDictionaryHaveKey(m_mainDict, @"groupId");
        [cell addSubview:numLb];
        return cell;
        
    }
    else if (indexPath.row ==3)
    {
        static NSString *cellinde3 = @"cell3";
        GroupInfomationJsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde3];
        if (cell ==nil) {
            cell = [[GroupInfomationJsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde3];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        if (m_mainDict&&[m_mainDict allKeys].count>0) {
            cell.titleLabel.text = @"群介绍";
            cell.contentLabel.text = KISDictionaryHaveKey(m_mainDict, @"info");
            
            CGSize size = [cell.contentLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            float height1 = 0.0;
            if (size.height<40) {
                height1 = 40;
            }else{
                height1 =size.height;
            }
            
            cell.contentLabel.frame = CGRectMake(80, 0, 220,height1);
            cell.photoArray =[ImageService getImageIds2:KISDictionaryHaveKey(m_mainDict, @"infoImg") Width:160];
            
            float height = 0.0;
            if (cell.photoArray.count>0&&cell.photoArray.count<4) {
                height=80;
            }
            else if (cell.photoArray.count>3&&cell.photoArray.count<7){
                height = 160;
            }
            else if (cell.photoArray.count>6&&cell.photoArray.count<10){
                height = 240;
            }
            else{
                height = 0;
            }
            cell.photoView.frame = CGRectMake(80, size.height+10, 230, height);
        }
        return cell;
    }
    else
    {
        static NSString *cellinde4 = @"cell4";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde4];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde4];
        }

        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 100, 20)]
        ;
        tLabel.text = @"创建时间";
        tLabel.textColor = [UIColor grayColor];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:tLabel];
        
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, 150, 20)]
        ;
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:timeLabel];
        
        timeLabel.text = @"2013-04-16";
        return cell;
    }
}
-(void)saveChanged:(id)sender
{
    [paramDict setObject:self.groupId forKey:@"groupId"];
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"239" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            [[NSUserDefaults standardUserDefaults]setObject:m_mainDict forKey:[NSString stringWithFormat:@"%@_group",self.groupId]];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refelsh_groupInfo_wx" object:nil];

            [self showMessageWindowWithContent:@"修改成功" imageType:0];
            [self.navigationController popViewControllerAnimated:YES];
            
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
        CGSize size1 = [KISDictionaryHaveKey(m_mainDict, @"info") sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        NSArray * photoArray =[ImageService getImageIds2:KISDictionaryHaveKey(m_mainDict, @"infoImg") Width:160];
        float height = size1.height;
        
        switch (indexPath.row) {
            case 0:
                return 40;

                break;
            case 1:
                NSLog(@"--------%d",tags.count/2);
                NSInteger tagsRowCount = (tags.count-1)/2+1;
                return  tagsRowCount*30+tagsRowCount*5+15;
                break;
            case 2:
                return 40;
                break;
            case 3:
                if (photoArray.count>0&&photoArray.count<4) {
                    height+=80;
                }
                else if (photoArray.count>3&&photoArray.count<7){
                    height += 160;
                }
                else if (photoArray.count>6&&photoArray.count<10){
                    height += 240;
                }
                else{
                    height += 0;
                }
                
                return 20+height;
                break;
                
            default:
                return 40;
                break;
        }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        EditGroupMessageViewController *editG = [[EditGroupMessageViewController alloc]init];
        editG.placeHold =[m_mainDict objectForKey:@"groupName"];
        editG.editType = EDIT_TYPE_nickName;
        editG.delegate = self;

        [self.navigationController pushViewController:editG animated:YES];
    }
    else if (indexPath.row ==1) {
        CardViewController *cardView = [[CardViewController alloc]init];
        cardView.myDelegate = self;
        [self.navigationController pushViewController:cardView animated:YES];
    }
    else if (indexPath.row ==3) {
        EditGroupMessageViewController *editG = [[EditGroupMessageViewController alloc]init];
        editG.placeHold =[m_mainDict objectForKey:@"info"];
        editG.editType = EDIT_TYPE_signature;
        editG.delegate = self;
        [self.navigationController pushViewController:editG animated:YES];
    }
}

-(UIImageView*)buildImgVWithframe:(CGRect)frame title:(NSString *)title
{
    UIImageView *imgV =[[ UIImageView alloc]initWithFrame:frame];
    imgV.image = KUIImage(@"card_show");
    imgV.userInteractionEnabled = YES;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width-20, frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.7];
    label.shadowOffset = CGSizeMake(.7f, 1.0f);
    label.text = title;
    [imgV addSubview:label];
    [imgV bringSubviewToFront:label];
    NSLog(@"%@",title);
    return imgV;
}

-(CGSize)getStringSizeWithString:(NSString *)str font:(UIFont *)font
{
    CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
    return size;
}
-(void)senderCkickInfoWithDel:(CardViewController *)del array:(NSArray *)array
{
    if (array.count==0) {
        return;
    }
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
    [dic removeObjectForKey:@"tags"];
    [dic setObject:array forKey:@"tags"];
    
//    groupId		群id
//    groupName	群名字（可选）
//    info			群描述（可选）
//    tagIds		群标签（可选）
    
    NSString *tagStr;
    
    for (int i =0; i<array.count; i++) {
        NSDictionary *dic = array[i];
        if (i!=0) {
            tagStr = [NSString stringWithFormat:@"%@,%@",tagStr,[dic objectForKey:@"tagId"]];
        }else{
            tagStr = [dic objectForKey:@"tagId"];
        }
    }
    [paramDict setObject:tagStr forKey:@"tagIds"];
    m_mainDict = dic;
    [m_myTableView reloadData];
}

-(void)comeBackInfoWithController:(EditGroupMessageViewController *)controller type:(EditType)mysetupType info:(NSString *)info
{
    if (mysetupType ==EDIT_TYPE_nickName) {
        [paramDict setObject:info forKey:@"groupName"];
        NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
        [dic setObject:info forKey:@"groupName"];
        m_mainDict = dic;

    }else if (mysetupType ==EDIT_TYPE_signature){
        [paramDict setObject:info forKey:@"info"];
        NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
        [dic setObject:info forKey:@"info"];
        m_mainDict = dic;
    }
    [m_myTableView reloadData];

}

#pragma mark --改变顶部图片
-(void)changeTopImage:(UITapGestureRecognizer*)sender
{
    UIActionSheet *acs = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"相机", nil];
    acs.tag =9999999;
    [acs showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==9999999) {
        UIImagePickerController * imagePicker;
        if (buttonIndex==1)
            //这里捕捉“毁灭键”,其实该键的index是0，从上到下从0开始，称之为毁灭是因为是红的
        {
            if (imagePicker==nil) {
                imagePicker=[[UIImagePickerController alloc]init];
                imagePicker.delegate=self;
                imagePicker.allowsEditing = YES;
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:^{
                    
                }];
            }
            else {
                UIAlertView *cameraAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相机" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
                [cameraAlert show];
            }
        }
        else if (buttonIndex==0) {
            if (imagePicker==nil) {
                imagePicker=[[UIImagePickerController alloc]init];
                imagePicker.delegate=self;
                imagePicker.allowsEditing = YES;
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                //                [self presentModalViewController:imagePicker animated:YES];
                [self presentViewController:imagePicker animated:YES completion:^{
                    
                }];
            }
            else {
                UIAlertView *libraryAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相册" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
                [libraryAlert show];
            }
        }
        
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * upImage = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];
    //    [self uploadbgImg:upImage];
    topImageView.image = upImage;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
