//
//  MyProfileViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-11.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "MyProfileViewController.h"
#import "PhotoViewController.h"
#import "EGOImageView.h"

@interface MyProfileViewController ()
{
    UILabel*       m_titleLabel;
    
    UITableView*   m_myTableView;
    HGPhotoWall    *m_photoWall;
    
    NSMutableArray * uploadImagePathArray;
    NSMutableDictionary * reponseStrArray;
    NSInteger imageImdex;
    
    
    
    NSMutableArray * deleteImageIdArray;//需要删除的图片
    
    UILabel*        m_starSignLabel;//星座
    UILabel*        m_ageLabel;//年龄
    NSTimer *timer;
    BOOL            m_isSort;//图片顺序变化
    NSInteger     picPage;
    UIAlertView* alter1;
    
}
@end

@implementation MyProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.hostInfo = [DataStoreManager queryDUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    m_titleLabel.text = self.hostInfo.nickName;

    if ([self.headImgArray count] == 0) {
        self.headImgArray = [ImageService getImageIds:self.hostInfo.headImgID];
        [m_photoWall setPhotos:[self imageToURL:self.headImgArray]];
        [m_photoWall setEditModel:YES];
    }
  
    [m_myTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    
    m_isSort = NO;
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = self.nickName;
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [addButton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [addButton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    [self.view addSubview:addButton];
    [addButton addTarget:self action:@selector(saveMyPicter:) forControlEvents:UIControlEventTouchUpInside];
    
    uploadImagePathArray = [NSMutableArray array];
    
    reponseStrArray = [[NSMutableDictionary dictionary] init];
    
    deleteImageIdArray = [NSMutableArray array];
    
    
    m_photoWall = [[HGPhotoWall alloc] initWithFrame:CGRectZero];
    m_photoWall.descriptionType = DescriptionTypeImage;
    m_photoWall.useCache = YES;
    m_photoWall.delegate = self;
    m_photoWall.backgroundColor = kColorWithRGB(105, 105, 105, 1.0);
    m_photoWall.tag =1;
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    UIView* footView = [[UIView alloc] initWithFrame:CGRectMake(0, -2, 320, 2)];
    footView.backgroundColor = [UIColor whiteColor];
    m_myTableView.tableFooterView = footView;
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"修改中...";
}

- (void)dealloc
{
    alter1.delegate = nil;
}

#pragma mark 返回
- (void)backButtonClick:(id)sender
{
    if ([uploadImagePathArray count] != 0 || [deleteImageIdArray count] != 0 || m_isSort) {
        alter1 = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的相册还未保存，确认要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alter1.tag = 75;
        [alter1 show];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 75) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 初始化头像 -----------------------
-(NSArray *)imageToURL:(NSArray *)imageArray;
{
    NSMutableArray * temp = [NSMutableArray array];
    for (id headID in imageArray) {
        NSRange range=[headID rangeOfString:@"<local>"];
        if (range.location!=NSNotFound) {
            [temp addObject:headID];
        }
        else{
//          [temp addObject:[ImageService getImgUrl:headID]];
            [temp addObject:[ImageService getImageUrlString:headID Width:112 Height:112]]; //修改图片尺寸，防止被压缩
        }
    }
    return temp;
}

#pragma mark - 相片

- (void)photoWallPhotoTaped:(NSUInteger)index WithPhotoWall:(UIView *)photoWall
{
    PhotoViewController * photoV = [[PhotoViewController alloc] initWithSmallImages:nil images:self.headImgArray indext:index];
    [self presentViewController:photoV animated:NO completion:^{
        
    }];
}

- (void)photoWallMovePhotoFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex
{
    if (index!=newIndex) {
        NSMutableArray * array1 = [NSMutableArray arrayWithArray:self.headImgArray];
        NSString * tempStr = [array1 objectAtIndex:index];
        
        if (newIndex<index) {
            [array1 insertObject:tempStr atIndex:newIndex];
            [array1 removeObjectAtIndex:index+1];
        }
        else{
            [array1 removeObjectAtIndex:index];
            [array1 insertObject:tempStr atIndex:newIndex];
        }
        m_isSort = YES;
        self.headImgArray = array1;
    }
}
- (void)photoWallAddAction
{
    UIActionSheet *actionSheetTemp = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册选择",@"拍照", nil];
    actionSheetTemp.tag = ActionSheetTypeChoosePic;
    [actionSheetTemp showInView:self.view];
}

- (void)photoWallAddFinish
{
    
}

-(void)photoWallDelPhotoAtIndex:(NSInteger)index
{
    NSLog(@"%d",index);
    NSMutableArray * tempH = [NSMutableArray arrayWithArray:self.headImgArray];
    NSString * tempStr = [tempH objectAtIndex:index];
    if ([tempStr rangeOfString:@"<local>"].location!=NSNotFound) {
        NSString *replaced = [tempStr stringByReplacingOccurrencesOfString:@"<local>" withString:@""];
        if ([uploadImagePathArray containsObject:[GameCommon getNewStringWithId:replaced]]) {
            int tempIndex = [uploadImagePathArray indexOfObject:replaced];
            [uploadImagePathArray removeObjectAtIndex:tempIndex];
        }
    }
    else//需要删除的id
    {
        [deleteImageIdArray addObject:tempStr];//小图
    }
    [tempH removeObjectAtIndex:index];
    self.headImgArray = tempH;
    [m_myTableView reloadData];
}

- (void)photoWallDeleteFinish
{
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [m_photoWall setAnimationNO];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==ActionSheetTypeChoosePic) {
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
    NSLog(@"%@",info);
    UIImage * upImage = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];//Image
    /*
     图片保存相册
     */
    if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(upImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }

    NSString * imageName=[NSString stringWithFormat:@"%d_me.jpg",self.headImgArray.count];
    [self writeImageToFile:upImage ImageName:imageName];//完整路径
    NSString * imageLocalUrl=[NSString stringWithFormat:@"<local>%@",imageName];//本地文件名
    NSMutableArray * tempArray;
    if (self.headImgArray) {
        tempArray = [NSMutableArray arrayWithArray:self.headImgArray];
    }
    else
    {
        tempArray = [NSMutableArray array];
    }
    [tempArray addObject:imageLocalUrl];
    [uploadImagePathArray addObject:imageName];
    
    [m_photoWall addPhoto:imageLocalUrl];
    self.headImgArray = tempArray;
    [m_myTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg ImageName:(NSString*)imageName
{
    NSData * imageData=[self compressImage:thumbimg];
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    if ([imageData writeToFile:openImgPath atomically:YES]) {
        return openImgPath;
    }
    return nil;
}
//压缩图片
-(NSData*)compressImage:(UIImage*)thumbimg
{
    UIImage * a = [NetManager compressImage:thumbimg targetSizeX:640 targetSizeY:1136];
    NSData *imageData = UIImageJPEGRepresentation(a, 0.7);
    return imageData;
}

//执行上传（单张）
-(void)uploadPicture:(NSString*)imageName
{
    NSString * path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSString  * uploadImagePath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    UpLoadFileService * up = [[UpLoadFileService alloc] init];
    [up simpleUpload:uploadImagePath UpDeleGate:self];
}

//保存上传图片信息
-(void)saveMyPicter:(id)sender
{
    imageImdex=0;
    [reponseStrArray removeAllObjects];
    if (uploadImagePathArray.count>0) {
        [hud show:YES];
        [self uploadPicture: [uploadImagePathArray objectAtIndex:0]];
    }else
    {
        NSString* headImgStr = [self getImageIdsStr:self.headImgArray];
        [self refreshMyInfo:headImgStr];
    }
}

// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    float pp= percent*100;
    NSLog(@"%f",pp);
    hud.labelText = [NSString stringWithFormat:@"上传第%d张 %.0f％", imageImdex+1,pp];
    
}

//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    
    [reponseStrArray setObject:response forKey:[uploadImagePathArray objectAtIndex:imageImdex]];
    if (reponseStrArray.count==uploadImagePathArray.count) {
        [hud hide:YES];
        [self replyImage];
    }else{
        if (uploadImagePathArray.count>imageImdex) {
            [self uploadPicture:[uploadImagePathArray objectAtIndex:imageImdex+1]];
        }
    }
    imageImdex++;
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
//    NSString *msg = nil ;
//    if(error != NULL){
//        msg = @"保存图片失败,请允许本应用访问您的相册";
//    }else{
//        msg = @"保存图片成功" ;
//    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil];
//    [alert show];
}


-(void)replyImage
{
    NSMutableArray * a1 = [NSMutableArray arrayWithArray:self.headImgArray];//压缩图 头像
    for (int i=0; i<reponseStrArray.count; i++) {
        NSString * a= [uploadImagePathArray objectAtIndex:i];
        for (int i = 0;i<a1.count;i++) {
            if ([[a1 objectAtIndex:i] isEqualToString:[NSString stringWithFormat:@"<local>%@",a]]) {
                [a1 replaceObjectAtIndex:i withObject:[reponseStrArray objectForKey:a]];
            }
        }
    }
    self.headImgArray = a1;
    [self refreshMyInfo:[self getImageIdsStr:self.headImgArray]];
}


-(NSString*)getImageIdsStr:(NSArray*)imageIdArray
{
    NSString* headImgStr = @"";
    for (int i = 0;i<imageIdArray.count;i++) {
        NSString * temp1 = [imageIdArray objectAtIndex:i];
        headImgStr = [headImgStr stringByAppendingFormat:@"%@,",temp1];
    }
    return headImgStr;
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    [hud hide:YES];
    [self showAlertViewWithTitle:@"提示" message:@"上传失败" buttonTitle:@"确定"];
}
//
- (void)refreshMyInfo:(NSString*)imageids//更新个人头像数据
{
    NSString* headImgStr = @"";
    for (int i = 0;i<self.headImgArray.count;i++) {
        NSString * temp1 = [self.headImgArray objectAtIndex:i];
        headImgStr = [headImgStr stringByAppendingFormat:@"%@,",temp1];
    }
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] forKey:@"userid"];
    [paramDict setObject:headImgStr forKey:@"img"];
   
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"104" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [responseObject setObject:[responseObject objectForKey:@"id"] forKey:@"userid"];
            [responseObject setObject:[responseObject objectForKey:@"birthdate"] forKey:@"birthday"];
             NSLog(@"111--保存跟新用户头像的用户信息");
            [[UserManager singleton] saveUserInfoToDb:responseObject ShipType:@"unkonw"];
        }
        [self showMessageWindowWithContent:@"保存成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}
-(void)pop
{
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - 表格
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
            break;
        default:
            return 30;
            break;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return nil;
    }
    UIImageView* topBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    UILabel* titleLabel;
    switch (section) {
        case 1:
        {
            topBg.image = KUIImage(@"inputbg");
            m_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 30, 12)];
            [m_ageLabel setTextColor:[UIColor whiteColor]];
            [m_ageLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
            m_ageLabel.layer.cornerRadius = 3;
            m_ageLabel.layer.masksToBounds = YES;
            m_ageLabel.textAlignment = NSTextAlignmentLeft;
            [topBg addSubview:m_ageLabel];
            
            if ([self.hostInfo.gender isEqualToString:@"0"]) {//男♀♂
                m_ageLabel.text = [NSString stringWithFormat:@"%@%@",@"♂ ",self.hostInfo.age?self.hostInfo.age:@""];
                m_ageLabel.backgroundColor = kColorWithRGB(33, 193, 250, 1.0);
            }
            else
            {
                m_ageLabel.text = [NSString stringWithFormat:@"%@%@",@"♀ ",self.hostInfo.age?self.hostInfo.age:@""];
                m_ageLabel.backgroundColor = kColorWithRGB(238, 100, 196, 1.0);
            }
            CGSize ageSize = [m_ageLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:10.0] constrainedToSize:CGSizeMake(100, 12) lineBreakMode:NSLineBreakByWordWrapping];
            m_ageLabel.frame = CGRectMake(10, 9, ageSize.width + 5, 12);
            NSArray * gameIds=[GameCommon getGameids:self.hostInfo.gameids];
            CGFloat w=(gameIds.count*18)+(gameIds.count*4)-4;
            UIView *gameicomView=[self getGameIconUIView:gameIds X:ageSize.width + 70 Y:6 Width:w Height:18];
            [topBg addSubview:gameicomView];
            
            m_starSignLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(ageSize.width + 25, 0, 50, 30) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:self.hostInfo.starSign textAlignment:NSTextAlignmentLeft];
            [topBg addSubview:m_starSignLabel];
        } break;
        case 2:
        {
            topBg.image = KUIImage(@"table_heard_bg");

            titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"其他" textAlignment:NSTextAlignmentLeft];
        }break;
        default:
            break;
    }
    [topBg addSubview:titleLabel];
    return topBg;
}
-(UIView*)getGameIconUIView:(NSArray*)gameIds X:(CGFloat)x Y:(CGFloat)y Width:(CGFloat)width Height:(CGFloat)height
{
    UIView *gameIconView=[[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
    for (int i=0 ; i<gameIds.count;i++) {
        if (i<3) {
            NSString * gameid=[gameIds objectAtIndex:i];
            EGOImageView *gameImg_one = [[EGOImageView alloc] initWithFrame:CGRectMake(i*23, 0, 20, 20)];
            gameImg_one.backgroundColor = [UIColor clearColor];
            NSString * gameImageId=[GameCommon putoutgameIconWithGameId:gameid];
            if ([GameCommon isEmtity:gameImageId]) {
                gameImg_one.image=KUIImage(@"clazz_0");
            }else{
                gameImg_one.imageURL= [ImageService getImageUrl4:gameImageId];
            }
            [gameIconView addSubview:gameImg_one];
        }
    }
    return gameIconView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return m_photoWall.frame.size.height;
    }
    if([[GameCommon getNewStringWithId:self.hostInfo.superstar] isEqualToString:@"1"])//有认证
    {
        if(indexPath.section == 1 && indexPath.row == 5)//签名
        {
            CGSize textSize = [self.hostInfo.signature sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
            return textSize.height == 0 ? 40 : textSize.height + 25;
        }
        if(indexPath.section == 1 && indexPath.row == 4)//标签
        {
            CGSize textSize = [self.hostInfo.hobby sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
            return textSize.height == 0 ? 40 : textSize.height + 25;
        }
    }
    else
    {
        if(indexPath.section == 1 && indexPath.row == 4)//签名
        {
            CGSize textSize = [self.hostInfo.signature sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
            return textSize.height == 0 ? 40 : textSize.height + 25;
        }
        if(indexPath.section == 1 && indexPath.row == 3)//标签
        {
            CGSize textSize = [self.hostInfo.hobby sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
            return textSize.height == 0 ? 40 : textSize.height + 25;
        }
    }
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 1;
        }break;
        case 1:
        {
            if([[GameCommon getNewStringWithId:self.hostInfo.superstar] isEqualToString:@"1"])
                return 6;
            return 5;
        }
        break;
        default:
        {
            return 1;
        } break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        static NSString *Cell = @"userinfo";
        TextLabelTableCell *cell = (TextLabelTableCell *)[tableView dequeueReusableCellWithIdentifier:Cell];
        if (cell == nil) {
            cell = [[TextLabelTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:Cell];
        }
        if([[GameCommon getNewStringWithId:self.hostInfo.superstar] isEqualToString:@"1"])//有认证
        {
            cell.disField.hidden = YES;
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.nameLabel.text = @"      认证";
                cell.disLabel.text = self.hostInfo.superremark;
                cell.vAuthImg.hidden = NO;
            }
            else if(indexPath.row == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.nameLabel.text = @"陌游ID";
                cell.disLabel.text = self.hostInfo.userId;
                cell.vAuthImg.hidden = YES;
                UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(230, 15, 29, 12)];
                [cell.contentView addSubview:image];
                if (![self.hostInfo.action boolValue]) {
                    NSLog(@"未激活");
                    image.image = [UIImage imageNamed:@"unactive"];
                }else
                {
                    NSLog(@"已状态");
                    image.image = [UIImage imageNamed:@"active"];
                }

            }
            else{
                cell.vAuthImg.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                switch (indexPath.row) {
                    case 2:
                    {
                        cell.nameLabel.text = @"昵称";
                        cell.disLabel.text = self.hostInfo.nickName;
                    } break;
                    case 3:
                    {
                        cell.nameLabel.text = @"生日";
                        cell.disField.hidden = NO;
                        cell.disField.text = self.hostInfo.birthday;
                        cell.cellDelegate = self;
                    } break;
                    case 4:
                    {
                        cell.nameLabel.text = @"个人标签";
                        CGSize textSize = [self.hostInfo.hobby sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
                        cell.disLabel.frame = CGRectMake(100, 10, 190, textSize.height == 0 ? 20 : textSize.height + 5);
                        cell.disLabel.text = [self.hostInfo.hobby isEqualToString:@""] ? @"暂无" : self.hostInfo.hobby;
                        
                    } break;
                    case 5:
                    {
                        cell.nameLabel.text = @"个性签名";
                        CGSize textSize = [self.hostInfo.signature sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
                        cell.disLabel.frame = CGRectMake(100, 10, 190, textSize.height == 0 ? 20 : textSize.height + 5);
                        cell.disLabel.text = [self.hostInfo.signature isEqualToString:@""] ? @"暂无" : self.hostInfo.signature;
                    } break;
                    default:
                        break;
                }
            }
            [cell refreshCell];
            return cell;
        }
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.nameLabel.text = @"陌游ID";
            cell.disLabel.text = self.hostInfo.userId;
            UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(230, 15, 29, 12)];
            [cell.contentView addSubview:image];
            
            NSLog(@"self.hostInfo.action%@",self.hostInfo.action);
            if (![self.hostInfo.action boolValue]) {
                NSLog(@"未激活");
                image.image = [UIImage imageNamed:@"unactive"];
            }else
            {
                NSLog(@"已状态");
                image.image = [UIImage imageNamed:@"active"];
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 1:
                {
                    cell.nameLabel.text = @"昵称";
                    cell.disLabel.text = self.hostInfo.nickName;
                } break;
                case 2:
                {
                    cell.nameLabel.text = @"生日";
                    cell.disField.hidden = NO;
                    cell.disField.text = self.hostInfo.birthday;
                    cell.cellDelegate = self;
                } break;
                case 3:
                {
                    cell.nameLabel.text = @"个人标签";
                    CGSize textSize = [self.hostInfo.hobby sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
                    cell.disLabel.frame = CGRectMake(100, 10, 190, textSize.height == 0 ? 20 : textSize.height + 5);
                    cell.disLabel.text = [self.hostInfo.hobby isEqualToString:@""] ? @"暂无" : self.hostInfo.hobby;

                } break;
                case 4:
                {
                    cell.nameLabel.text = @"个性签名";
                    CGSize textSize = [self.hostInfo.signature sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 200)];
                    cell.disLabel.frame = CGRectMake(100, 10, 190, textSize.height == 0 ? 20 : textSize.height + 5);
                    cell.disLabel.text = [self.hostInfo.signature isEqualToString:@""] ? @"暂无" : self.hostInfo.signature;
                } break;
                default:
                    break;
            }
        }
        [cell refreshCell];
        return cell;
    }
    else if(indexPath.section == 2)
    {
        static NSString *Cell = @"otherCells";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:Cell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:Cell];
        }
        cell.imageView.image = KUIImage(@"time");
        cell.textLabel.text = @"注册时间";
        
        NSString* timeStr = [[GameCommon shareGameCommon] getDataWithTimeInterval:self.hostInfo.createTime];
        cell.detailTextLabel.text = timeStr;
        
        return cell;
    }
    static NSString *Cell = @"Cells";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:Cell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:Cell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (indexPath.section == 0) {
        [cell.contentView addSubview:m_photoWall];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 || indexPath.section == 2) {
        return;
    }
    if([[GameCommon getNewStringWithId:self.hostInfo.superstar] isEqualToString:@"1"])//有认证
    {
        EditMessageViewController* editVC = [[EditMessageViewController alloc] init];
        editVC.delegate =self;
        switch (indexPath.row) {
            case 0:
            case 1:
                return;
                break;
            case 2:
                editVC.editType = EDIT_TYPE_nickName;
                editVC.placeHold = self.hostInfo.nickName;
                break;
            case 3:
//                editVC.editType = EDIT_TYPE_birthday;
                return;
                break;
            case 4:
                editVC.editType = EDIT_TYPE_hobby;
                editVC.placeHold = self.hostInfo.hobby;
                break;
            case 5:
                editVC.editType = EDIT_TYPE_signature;
                editVC.placeHold = self.hostInfo.signature;
                break;
            default:
                break;
        }
        [self.navigationController pushViewController:editVC animated:YES];
        return;
    }
    EditMessageViewController* editVC = [[EditMessageViewController alloc] init];
    editVC.delegate = self;
    switch (indexPath.row) {
        case 0:
            return;
            break;
        case 1:
            editVC.editType = EDIT_TYPE_nickName;
            editVC.placeHold = self.hostInfo.nickName;
            break;
        case 2:
//            editVC.editType = EDIT_TYPE_birthday;
            return;
            break;
        case 3:
            editVC.editType = EDIT_TYPE_hobby;
            editVC.placeHold = self.hostInfo.hobby;
            break;
        case 4:
            editVC.editType = EDIT_TYPE_signature;
            editVC.placeHold = self.hostInfo.signature;
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)birthDaySelected:(NSString*)birthday
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] forKey:@"userId"];
    [paramDict setObject:birthday forKey:@"birthdate"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"104" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // [hud hide:YES];
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD_isok"]];
        hud.labelText = @"保存成功";
        hud.mode = MBProgressHUDModeCustomView;
        [hud hide:YES afterDelay:4];
         NSLog(@"111--保存更新用户信息之后的信息");
        [[UserManager singleton] saveUserInfoToDb:responseObject ShipType:@"5"];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}

-(void)changeMessageWithType:(EditType)type text:(NSString*)text
{
    switch (type) {
        case EDIT_TYPE_nickName:
            self.hostInfo.nickName =text;
            break;
        case EDIT_TYPE_birthday:
            self.hostInfo.birthday = text;
            break;
        case EDIT_TYPE_signature:
            self.hostInfo.signature = text;
            break;
        case EDIT_TYPE_hobby:
            self.hostInfo.hobby = text;
            break;
        default:
            break;
    }
    [m_myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
