//
//  EditGroupMessageViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "EditGroupMessageViewController.h"
#import "EditPhotoCell.h"
@interface EditGroupMessageViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    UITextView*   m_contentTextView;
    UILabel *       m_ziNumLabel;
    NSInteger      m_maxZiShu;
    UIDatePicker* m_birthDayPick;
    
    UILabel *       placeholderL;

    
    UICollectionViewFlowLayout *m_layout;
    UICollectionView *m_photoCollectionView;
    NSMutableArray * deleteImageIdArray;//需要删除的图片
    NSMutableArray * uploadImagePathArray;
    NSMutableDictionary * reponseStrArray;
    NSInteger imageImdex;

    NSInteger clickImdex;
    
    
}
@property (nonatomic,strong)UIActionSheet* addActionSheet;
@property (nonatomic,strong)UIActionSheet* deleteActionSheet;
@property (nonatomic,strong)NSMutableString* imageId;

@end

@implementation EditGroupMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
    
    m_maxZiShu = 100;
    self.isChang =NO;
    
    [self setTopViewWithTitle:@"编辑群介绍" withBackButton:NO];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [backButton setBackgroundImage:KUIImage(@"backButton") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"backButton2") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [addButton setBackgroundImage:KUIImage(@"okButton") forState:UIControlStateNormal];
    [addButton setBackgroundImage:KUIImage(@"okButton2") forState:UIControlStateHighlighted];
    [self.view addSubview:addButton];
    [addButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    uploadImagePathArray = [NSMutableArray array];
    reponseStrArray = [[NSMutableDictionary dictionary] init];
    deleteImageIdArray = [NSMutableArray array];
    
    UIView * bgImage = [[UIView alloc] initWithFrame:CGRectMake(5, startX+10, 310, 110)];
    bgImage.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgImage];
    
    m_contentTextView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 310, 90)];
    m_contentTextView.backgroundColor = [UIColor whiteColor];
    m_contentTextView.font = [UIFont boldSystemFontOfSize:15.0];
    m_contentTextView.delegate = self;
    m_contentTextView.text = self.placeHold ? self.placeHold : @"";
    [bgImage addSubview:m_contentTextView];
    
    
    placeholderL = [[UILabel alloc]initWithFrame:CGRectMake(15, startX+15, 200, 20)];
    placeholderL.backgroundColor = [UIColor clearColor];
    placeholderL.textColor = [UIColor grayColor];
    if (![GameCommon isEmtity:self.placeHold]) {
        placeholderL.text = @"";
    }else{
        placeholderL.text = @"在这里输入群的简介信息……";
    }
    placeholderL.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:placeholderL];
    
    m_ziNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, startX+100, 150, 20)];
    m_ziNumLabel.textColor = [UIColor grayColor];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    m_ziNumLabel.font = [UIFont systemFontOfSize:12.0f];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.text = @"";
    [self.view addSubview:m_ziNumLabel];
    
    [self buildCollectionView];
    [self refreshZiLabelText];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"Login...";
}

-(void)buildCollectionView
{
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 1;
    m_layout.minimumLineSpacing =2;
    m_layout.itemSize = CGSizeMake(292/3, 292/3);
    m_photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, startX+130, 300, kScreenHeigth-startX-130) collectionViewLayout:m_layout];
    m_photoCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    m_photoCollectionView.scrollEnabled = YES;
    m_photoCollectionView.delegate = self;
    m_photoCollectionView.dataSource = self;
    [m_photoCollectionView registerClass:[EditPhotoCell class] forCellWithReuseIdentifier:@"titleCell"];
    m_photoCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_photoCollectionView];

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.headImgArray.count>=9) {
        return 9;
    }
    return self.headImgArray.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EditPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    if (self.headImgArray.count>=9) {
        [cell SetPhotoUrlWithCache:[self.headImgArray objectAtIndex:indexPath.row]];
    }else{
        if (indexPath.row ==self.headImgArray.count) {
            cell.photoImageView.image=KUIImage(@"tianjiazhaopian");
        }else{
            [cell SetPhotoUrlWithCache:[self.headImgArray objectAtIndex:indexPath.row]];
        }
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    clickImdex = indexPath.row;
    if (self.headImgArray.count>=9) {
        [self showEditImage];
    }else{
        if (indexPath.row ==self.headImgArray.count) {
            [self photoWallAddAction];
        }else{
            [self showEditImage];
        }
    }
}
-(void)showEditImage
{
    UIActionSheet *actionSheetTemp = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
    actionSheetTemp.tag = actionSheetTypeOperationPic;
    [actionSheetTemp showInView:self.view];

}

-(NSArray *)imageToURL:(NSArray *)imageArray;
{
    NSMutableArray * temp = [NSMutableArray array];
    for (id headID in imageArray) {
        NSRange range=[headID rangeOfString:@"<local>"];
        if (range.location!=NSNotFound) {
            [temp addObject:headID];
        }
        else{
            [temp addObject:[ImageService getImgUrl:headID]];
        }
    }
    return temp;
}
- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_contentTextView.text];
    if (ziNum<0) {
        ziNum=0;
    }
    m_ziNumLabel.text =[NSString stringWithFormat:@"%d%@%d",ziNum,@"/",m_maxZiShu];
}


- (void)okButtonClick:(id)sender
{
    [m_contentTextView resignFirstResponder];
    if (KISEmptyOrEnter(m_contentTextView.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入有效的文字！" buttonTitle:@"确定"];
        return;
    }
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_contentTextView.text];
    if (ziNum < 0) {
        [self showAlertViewWithTitle:@"提示" message:@"输入字数超过上限，请修改！" buttonTitle:@"确定"];
        return;
    }
    [self saveMyPicter:sender];
}

#pragma mark 返回
- (void)backButtonClick:(id)sender
{
    if (KISEmptyOrEnter(m_contentTextView.text) || ![m_contentTextView.text isEqualToString:self.placeHold]||self.isChang) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您这样返回是没有保存的喔！" delegate:self cancelButtonTitle:@"返回"otherButtonTitles:@"确定", nil];
        alert.tag = 345;
        [alert show];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 345) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark textView delegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}

#pragma mark 手势
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_contentTextView resignFirstResponder];
}

#pragma mark - text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length>0 || text.length != 0) {
        placeholderL.text = @"";
    }else{
        placeholderL.text = @"在这里输入群的简介信息……";
    }
    
    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = m_maxZiShu-[[GameCommon shareGameCommon] unicodeLengthOfString:new];
    if(res >= 0){
        return YES;
    }
    else{
        [self showAlertViewWithTitle:@"提示" message:@"最多不能超过100个字" buttonTitle:@"确定"];
        return NO;
    }
}


-(void)conbackImage:(NSString*)imageids
{
    if (self.delegate) {
        [self.delegate comeBackInfoWithController:m_contentTextView.text InfoImg:imageids];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)photoWallDelPhotoAtIndex:(NSInteger)index
{
    NSLog(@"%d",index);
    self.isChang = YES;
    NSMutableArray * tempH = [NSMutableArray arrayWithArray:self.headImgArray];
    NSString * tempStr = [tempH objectAtIndex:index];
    if ([tempStr rangeOfString:@"<local>"].location!=NSNotFound) {
        NSString *replaced = [tempStr stringByReplacingOccurrencesOfString:@"<local>" withString:@""];
        if ([uploadImagePathArray containsObject:[GameCommon getNewStringWithId:replaced]]) {
//            int tempIndex = [uploadImagePathArray indexOfObject:replaced];
//            [uploadImagePathArray removeObjectAtIndex:tempIndex];
            [uploadImagePathArray removeObject:replaced];
        }
    }
    else//需要删除的id
    {
        [deleteImageIdArray addObject:tempStr];//小图
    }
    [tempH removeObjectAtIndex:index];
    self.headImgArray = tempH;
    [m_photoCollectionView reloadData];
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
        [self conbackImage:headImgStr];
    }
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

//执行上传（单张）
-(void)uploadPicture:(NSString*)imageName
{
    NSString * path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSString  * uploadImagePath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    UpLoadFileService * up = [[UpLoadFileService alloc] init];
    [up simpleUpload:uploadImagePath UpDeleGate:self];
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
         [self conbackImage:[self getImageIdsStr:self.headImgArray]];
    }else{
        [self uploadPicture:[uploadImagePathArray objectAtIndex:imageImdex+1]];
    }
    imageImdex++;
}

//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    [hud hide:YES];
    [self showAlertViewWithTitle:@"提示" message:@"上传失败" buttonTitle:@"确定"];
}
- (void)photoWallAddAction
{
    UIActionSheet *actionSheetTemp = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册选择",@"拍照", nil];
    actionSheetTemp.tag = actionSheetTypeChoosePic;
    [actionSheetTemp showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==actionSheetTypeChoosePic) {
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
    }else if (actionSheet.tag ==actionSheetTypeOperationPic)
    {
        if (buttonIndex ==0)
        {
            [self photoWallDelPhotoAtIndex:clickImdex];
            
        }else if (buttonIndex ==1)
        {
        }
        
    }

}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.headImgArray.count>=9) {
        return;
    }
    self.isChang = YES;
    UIImage * upImage = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];//Image
    /*
     图片保存相册
     */
    if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(upImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    NSString* uuid = [[GameCommon shareGameCommon] uuid];

    NSString * imageName=[NSString stringWithFormat:@"%@_group.jpg",uuid];
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
    
    self.headImgArray = tempArray;
    [m_photoCollectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
