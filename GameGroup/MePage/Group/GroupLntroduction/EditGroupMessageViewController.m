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
    UILabel*       m_ziNumLabel;
    NSInteger      m_maxZiShu;
    UIDatePicker* m_birthDayPick;
    
    UIButton* PhotoB;
    UIImageView* deleteIV;
    NSMutableArray * uploadImagePathArray;
    NSMutableDictionary * reponseStrArray;
    NSInteger imageImdex;
    NSInteger imageWidth;
    NSInteger imageHeight;
    
    UICollectionViewFlowLayout *m_layout;
    UICollectionView *m_photoCollectionView;
    
}
@property (nonatomic,strong)NSMutableArray* pictureArray;
@property (nonatomic,strong)UIActionSheet* addActionSheet;
@property (nonatomic,strong)UIActionSheet* deleteActionSheet;

@end

@implementation EditGroupMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
    
    imageWidth = (self.view.bounds.size.width-10-20)/4;
    imageHeight = (self.view.bounds.size.width-10-20)/4;
    uploadImagePathArray = [NSMutableArray array];
    reponseStrArray = [[NSMutableDictionary dictionary] init];
    m_maxZiShu = 100;
    
    [self setTopViewWithTitle:@"群简介" withBackButton:YES];
    
    
    m_contentTextView = [[UITextView alloc] initWithFrame: CGRectMake(10, 10 + startX, 300, 90)];
    m_contentTextView.backgroundColor = [UIColor whiteColor];
    m_contentTextView.font = [UIFont boldSystemFontOfSize:15.0];
    m_contentTextView.delegate = self;
    m_contentTextView.layer.cornerRadius = 5;
    m_contentTextView.layer.masksToBounds = YES;
    m_contentTextView.text = self.placeHold ? self.placeHold : @"";
    [self.view addSubview:m_contentTextView];
    [m_contentTextView becomeFirstResponder];
    
    
    m_ziNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 105 + startX, 150, 20)];
    m_ziNumLabel.textColor = [UIColor grayColor];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    m_ziNumLabel.font = [UIFont systemFontOfSize:12.0f];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.text = [NSString stringWithFormat:@"还可输入%d个字", m_maxZiShu];
    [self.view addSubview:m_ziNumLabel];
    
    
//    PhotoB = [UIButton buttonWithType:UIButtonTypeCustom];
//    PhotoB.frame = CGRectMake(10, startX + 130, imageWidth, imageHeight);
//    [PhotoB setBackgroundImage:[UIImage imageNamed:@"tianjiazhaopian"] forState:UIControlStateNormal];
//    [PhotoB addTarget:self action:@selector(getAnActionSheet) forControlEvents:UIControlEventTouchUpInside];
//    PhotoB.hidden = NO;
//    [self.view addSubview:PhotoB];
    
    [self buildCollectionView];
    [self refreshZiLabelText];
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 430 + startX, 300, 40)];
    [okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [okButton setTitle:@"完 成" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"Login...";
}
-(void)buildCollectionView
{
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 10;
    m_layout.minimumLineSpacing =5;
    m_layout.itemSize = CGSizeMake(90, 90);
//    m_layout.headerReferenceSize = CGSizeMake(320, 70);
    m_layout.sectionInset = UIEdgeInsetsMake(10,3,3,3);
    
    m_photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, startX+130, 300, 290) collectionViewLayout:m_layout];
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
    return 9;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EditPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    cell.photoImageView.imageURL = nil;
//    NSMutableDictionary * cellDic = [myGroupArray objectAtIndex:indexPath.row];
//    if (indexPath.row ==myGroupArray.count-1) {
//        cell.headImgView.placeholderImage =nil;
//        cell.headImgView.imageURL = nil;
//        NSString *imgStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(cellDic, @"backgroundImg")];
//        cell.headImgView.placeholderImage = KUIImage(imgStr);
//        cell.headImgView.imageURL = nil;
//        cell.titleLabel.backgroundColor = [UIColor clearColor];
//        cell.titleLabel.text = @"";
//    }else{
//        cell.headImgView.placeholderImage = KUIImage(@"mess_news");
//        cell.headImgView.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(cellDic, @"backgroundImg")];
//        cell.titleLabel.backgroundColor  =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
//        cell.titleLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
//        
//    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
//    NSDictionary *dic = [myGroupArray objectAtIndex:indexPath.row];
//    if (indexPath.row ==myGroupArray.count-1) {
//        JoinInGroupViewController *joinIn = [[JoinInGroupViewController alloc]init];
//        [self.navigationController pushViewController:joinIn animated:YES];
//        
//    }else{
//        GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
//        gr.groupId =KISDictionaryHaveKey(dic, @"groupId");
//        [self.navigationController pushViewController:gr animated:YES];
//    }
}




- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_contentTextView.text];
    if(ziNum >= 0)
    {
        m_ziNumLabel.text = [NSString stringWithFormat:@"还可以输入%d字", ziNum];
        m_ziNumLabel.textColor = [UIColor grayColor];
    }
    else
    {
        m_ziNumLabel.text = [NSString stringWithFormat:@"已超过%d字", [[GameCommon shareGameCommon] unicodeLengthOfString:m_contentTextView.text] - m_maxZiShu];
        m_ziNumLabel.textColor = [UIColor redColor];
    }
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
    [self saveMyNews:sender];
}

#pragma mark 返回
- (void)backButtonClick:(id)sender
{
    if (KISEmptyOrEnter(m_contentTextView.text) || [m_contentTextView.text isEqualToString:self.placeHold]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您这样返回是没有保存的喔！" delegate:self cancelButtonTitle:@"返回"otherButtonTitles:@"确定", nil];
    alert.tag = 345;
    [alert show];
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


#pragma mark - actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _addActionSheet) {
        switch (buttonIndex) {
            case 0:
            {
                UIImagePickerController * imagePicker;
                if (imagePicker==nil) {
                    imagePicker=[[UIImagePickerController alloc]init];
                    imagePicker.delegate=self;
                }
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                    
                    [self presentViewController:imagePicker animated:YES completion:^{
                        
                    }];
                }
                else {
                    UIAlertView *cameraAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相机" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
                    [cameraAlert show];
                }
            }break;
            case 1:
            {
                UIImagePickerController * imagePicker;
                if (imagePicker==nil) {
                    imagePicker=[[UIImagePickerController alloc]init];
                    imagePicker.delegate=self;
                }
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                    
                    [self presentViewController:imagePicker animated:YES completion:^{
                        
                    }];
                }
                else {
                    UIAlertView *libraryAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相册" delegate:nil cancelButtonTitle:@"了解" otherButtonTitles:nil];
                    [libraryAlert show];
                }
            }break;
            default:
                break;
        }
    }else{
        if (buttonIndex == 0) {
            NSUInteger index = [_pictureArray indexOfObject:deleteIV];
            [UIView animateWithDuration:0.3 animations:^{
                PhotoB.frame = ((UIImageView*)[_pictureArray lastObject]).frame;
                for (int i = _pictureArray.count-1; i > index ; i-- ) {
                    ((UIImageView*)_pictureArray[i]).frame = ((UIImageView*)_pictureArray[i-1]).frame;
                }
            }];
            [deleteIV removeFromSuperview];
            [_pictureArray removeObject:deleteIV];
            [uploadImagePathArray removeObjectAtIndex:index];
            PhotoB.hidden = NO;
        }
    }
}


#pragma mark 照片
-(void)getAnActionSheet
{
    if (_pictureArray.count<9) {
        self.addActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [_addActionSheet showInView:self.view];
    }
}


#pragma mark - imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.pictureArray == nil) {
        self.pictureArray = [[NSMutableArray alloc]init];
    }
    PhotoB.hidden = NO;
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage*selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString * imageName=[NSString stringWithFormat:@"%@.jpg",uuid];
    NSString * imagePath=[self writeImageToFile:selectImage ImageName:imageName];//完整路径
    if (imagePath) {
        [uploadImagePathArray addObject:imageName];
    }
    
    UIImageView* imageV = [[UIImageView alloc]initWithFrame:PhotoB.frame];
    imageV.userInteractionEnabled = YES;
    imageV.image = selectImage;
    [self.view addSubview:imageV];
    if (PhotoB.frame.origin.x < PhotoB.frame.size.width*3) {
        PhotoB.frame = CGRectMake(PhotoB.frame.origin.x+ PhotoB.frame.size.width +5, PhotoB.frame.origin.y, PhotoB.frame.size.width, PhotoB.frame.size.height);
    }else{
        PhotoB.frame = CGRectMake(5, PhotoB.frame.origin.y+PhotoB.frame.size.height+5, PhotoB.frame.size.width, PhotoB.frame.size.height);
    }
    [_pictureArray addObject:imageV];
    if (_pictureArray.count == 9) {
        PhotoB.hidden = YES;
    }
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    [imageV addGestureRecognizer:tapGR];
    selectImage =nil;
}

//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg ImageName:(NSString*)imageName
{
    NSData * imageDate=[self compressImage:thumbimg];
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    if ([imageDate writeToFile:openImgPath atomically:YES]) {
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

-(void)tapImage:(UIGestureRecognizer*)tapGR
{
    deleteIV = (UIImageView*)tapGR.view;
    self.deleteActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
    [_deleteActionSheet showInView:self.view];
}

#pragma mark 保存

- (void)saveMyNews:(id)sender
{
    //上传图片
    if (self.pictureArray.count>0) {
        hud.labelText = @"上传图片中...";
        [hud show:YES];
        if (uploadImagePathArray.count>0) {
            [self uploadPicture: [uploadImagePathArray objectAtIndex:0]];
        }
    }else
    {
        [self conbackImage:@""];
    }
}

-(void)conbackImage:(NSString*)imageIds
{
    if (self.delegate) {
        [self.delegate comeBackInfoWithController:m_contentTextView.text InfoImg:imageIds];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

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
    hud.labelText = [NSString stringWithFormat:@"上传第%d张 %.0f％", imageImdex+1,pp];
}
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    [reponseStrArray setObject:response forKey:[uploadImagePathArray objectAtIndex:imageImdex]];
    if (reponseStrArray.count==uploadImagePathArray.count) {
        [hud hide:YES];
        NSMutableString* imageId= [[NSMutableString alloc]init];
        for (int i=0; i<reponseStrArray.count; i++) {
            NSString * a=[uploadImagePathArray objectAtIndex:i];
            [imageId appendFormat:@"%@,",[reponseStrArray objectForKey:a]];
        }
        [self conbackImage:imageId];
    }else{
        [self uploadPicture:[uploadImagePathArray objectAtIndex:imageImdex+1]];
    }
    imageImdex++;
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    [self conbackImage:@""];
    [hud hide:YES];
    [self showAlertViewWithTitle:@"提示" message:@"上传失败" buttonTitle:@"确定"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
