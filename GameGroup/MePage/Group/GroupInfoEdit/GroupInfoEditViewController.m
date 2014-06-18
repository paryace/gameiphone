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
#import "EditGroupNameViewController.h"
@interface GroupInfoEditViewController ()
{
    NSMutableDictionary *m_mainDict;
    UITableView *m_myTableView;
    UIView *aoView;
    NSMutableDictionary *paramDict;
    EGOImageView *topImageView;
}
@end

@implementation GroupInfoEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTopViewWithTitle:@"群信息设置" withBackButton:YES];
    
    m_mainDict = [NSMutableDictionary new];
    paramDict  = [NSMutableDictionary dictionary];
    m_mainDict = (NSMutableDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_group",self.groupId]];
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth -startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.backgroundColor = [UIColor clearColor];
    m_myTableView.showsVerticalScrollIndicator = NO;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    [GameCommon setExtraCellLineHidden:m_myTableView];
    [self.view addSubview:m_myTableView];
    
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(saveChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    topImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, startX, 320, 192)];
    NSString * imageUrl = KISDictionaryHaveKey(m_mainDict, @"backgroundImg");
    if ([GameCommon isEmtity:imageUrl]) {
        topImageView.image = KUIImage(@"groupinfo_top");
    }else{
        topImageView.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(m_mainDict, @"backgroundImg") Width:320];
    }
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
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"上传中...";
    
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
            
            cell.contentLabel.frame = CGRectMake(80, 5, 210,height1);
            cell.photoArray =[ImageService getImageIds:KISDictionaryHaveKey(m_mainDict, @"infoImg")];
            if (cell.photoArray.count==0) {
                cell.photoView.frame =  CGRectMake(80, height1+5, 210, 0);
            }else{
                NSInteger photoCount = (cell.photoArray.count-1)/3+1;//标签行数
                cell.photoView.frame =  CGRectMake(80, height1+5, 210, photoCount*68+photoCount*2);
            }
            [cell.photoView reloadData];
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
                NSLog(@"--------%d",tags.count/2);
                if (photoArray.count==0) {
                    return (size1.height<40?40:size1.height)+5;
                }else{
                    NSInteger photoCount = (photoArray.count-1)/3+1;//图片行数
                    return photoCount*68+photoCount*2+(size1.height<40?40:size1.height)+10;
                }
                break;
                
            default:
                return 40;
                break;
        }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row ==0) {
        EditGroupNameViewController *editG = [[EditGroupNameViewController alloc]init];
        editG.placeHold =[m_mainDict objectForKey:@"groupName"];
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
        editG.headImgArray = [ImageService getImageIds:KISDictionaryHaveKey(m_mainDict, @"infoImg")];
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

//修改群简介，群图片
-(void)comeBackInfoWithController:(NSString *)info InfoImg:(NSString*)infoImg
{
    [paramDict setObject:info forKey:@"info"];
    [paramDict setObject:infoImg forKey:@"infoImg"];
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
    [dic setObject:info forKey:@"info"];
    [dic setObject:infoImg forKey:@"infoImg"];
    m_mainDict = dic;
    [m_myTableView reloadData];
}
//修改群昵称
-(void)comeBackGroupNameWithController:(NSString *)groupName
{
    [paramDict setObject:groupName forKey:@"groupName"];
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
    [dic setObject:groupName forKey:@"groupName"];
    m_mainDict = dic;
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
    NSString * imagePath=[self writeImageToFile:upImage ImageName:@"groupInfoTopImage.jpg"];
    [self uploadbgImg:imagePath];
    topImageView.image = upImage;
}
//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg ImageName:(NSString*)imageName
{
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    
    NSData *data = UIImageJPEGRepresentation(thumbimg, 0.7);
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if ([data writeToFile:openImgPath atomically:NO]) {
        return openImgPath;
    }
    return nil;
}


//#pragma mark --上传顶部图片
-(void)uploadbgImg:(NSString*)uploadImagePath
{
    [hud show:YES];
    UpLoadFileService * up = [[UpLoadFileService alloc] init];
    [up simpleUpload:uploadImagePath UpDeleGate:self];
    
}
// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    float pp= percent*100;
    hud.labelText = [NSString stringWithFormat:@"%.0f％",pp];
}
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    [hud hide:YES];
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    if (response) {
        [self showMessageWindowWithContent:@"上传成功" imageType:0];
        [paramDict setObject:response forKey:@"backgroundImg"];
        NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:m_mainDict];
        [dic setObject:response forKey:@"backgroundImg"];
        m_mainDict = dic;
        [m_myTableView reloadData];
    }
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    [hud hide:YES];
 [self showMessageWindowWithContent:@"上传图片失败，请重新上传" imageType:0];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
