//
//  SendNewsViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-31.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "SendNewsViewController.h"
#import "Emoji.h"
#import "EmojiView.h"
#import "UpLoadFileService.h"
#import "HelpViewController.h"
@interface SendNewsViewController ()<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    UIButton* PhotoB;
    UIImageView* deleteIV;
    NSInteger  m_maxZiShu;//发表字符数量
    UILabel *m_ziNumLabel;//提示文字
    UIAlertView* alert1;
    NSMutableArray * uploadImagePathArray;
    NSMutableDictionary * reponseStrArray;
    NSInteger imageImdex;
    NSInteger imageWidth;
    NSInteger imageHeight;
}
@property (nonatomic,strong)UITextView* dynamicTV;
@property (nonatomic,strong)UILabel* placeholderL;
@property (nonatomic,strong)NSMutableArray* pictureArray;
@property (nonatomic,strong)UIActionSheet* addActionSheet;
@property (nonatomic,strong)UIActionSheet* deleteActionSheet;
@property (nonatomic,strong)NSMutableString* imageId;

@end

@implementation SendNewsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_maxZiShu = 225;
    imageWidth = (self.view.bounds.size.width-10-20)/4;
    imageHeight = (self.view.bounds.size.width-10-20)/4;
    
    [self setTopViewWithTitle:@"发表动态" withBackButton:YES];

    uploadImagePathArray = [NSMutableArray array];
    reponseStrArray = [[NSMutableDictionary dictionary] init];
    
    
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [addButton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [addButton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    [self.view addSubview:addButton];
    [addButton addTarget:self action:@selector(saveMyNews:) forControlEvents:UIControlEventTouchUpInside];
    [self setMainView];
}

- (void)setMainView
{
    UIImageView* editIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 40+startX, 320-5, 128)];
    editIV.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:editIV];
    
    self.dynamicTV = [[UITextView alloc]initWithFrame:CGRectMake(5, 40+startX, 320-5, 108)];
    _dynamicTV.backgroundColor = [UIColor clearColor];
    _dynamicTV.font = [UIFont systemFontOfSize:13];
    _dynamicTV.delegate = self;
    if (self.defaultContent && ![self.defaultContent isEqualToString:@""]) {
        _dynamicTV.text = self.defaultContent;
    }
    [self.view addSubview:_dynamicTV];
    [self.dynamicTV becomeFirstResponder];
    
    self.placeholderL = [[UILabel alloc]initWithFrame:CGRectMake(10, 41+startX, 200, 20)];
    _placeholderL.backgroundColor = [UIColor clearColor];
    _placeholderL.textColor = [UIColor grayColor];
    if (self.defaultContent && ![self.defaultContent isEqualToString:@""]) {//不是分享头衔
        _placeholderL.text = @"";
    }
    else
        _placeholderL.text = @"今天想跟别人说点什么……";
    _placeholderL.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:_placeholderL];
    
    PhotoB = [UIButton buttonWithType:UIButtonTypeCustom];
    PhotoB.frame = CGRectMake(5, startX + 173, imageWidth, imageHeight);
    [PhotoB setBackgroundImage:[UIImage imageNamed:@"tianjiazhaopian"] forState:UIControlStateNormal];
    [PhotoB addTarget:self action:@selector(getAnActionSheet) forControlEvents:UIControlEventTouchUpInside];
    PhotoB.hidden = NO;
    [self.view addSubview:PhotoB];

    if (self.titleImage) {
        UIImageView* titleimg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 173 + startX, imageWidth, imageHeight)];
        titleimg.image = self.titleImage;
        titleimg.userInteractionEnabled = YES;
        [self.view addSubview:titleimg];
        
        UITapGestureRecognizer*tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
        [titleimg addGestureRecognizer:tapGR];

        PhotoB.frame = CGRectMake(5 + imageWidth +5, startX + 173, imageWidth, imageHeight);
        if (self.pictureArray == nil) {
            self.pictureArray = [[NSMutableArray alloc]init];
        }
        [_pictureArray addObject:titleimg];
        [uploadImagePathArray addObject:self.titleImageName];
    }
    
    m_ziNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(23, startX+148, 200, 20)];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.font= [UIFont systemFontOfSize:12];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:m_ziNumLabel];
    
    
    UIView * topView=[[UIView alloc] initWithFrame:CGRectMake(0, startX,320, 40)];
    UIButton * topBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    [topBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [topBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [topBtn setTitle:@"如何使用网页发表长动态" forState:UIControlStateNormal];
    topBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [topBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    topBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    topBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    topBtn.userInteractionEnabled = YES;
    [topBtn addTarget:self action:@selector(HelpAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:topBtn];
    
    UIImageView *topimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16, 8, 12)];
    topimageView.image = KUIImage(@"right_arrow");
    topimageView.backgroundColor = [UIColor clearColor];
    [topView addSubview:topimageView];
    [self.view addSubview:topView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = @"正在为您发布...";
    
}

-(void)HelpAction:(id)sender
{
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    helpVC.myUrl = @"release.html";
    [self.navigationController pushViewController:helpVC animated:YES];
}
- (void)dealloc
{
    alert1.delegate = nil;
}

- (void)backButtonClick:(id)sender
{
    if (!KISEmptyOrEnter(self.dynamicTV.text) || self.pictureArray.count>0) {
        alert1 = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您是否放弃当前编辑？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert1.tag = 67;
        [alert1 show];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 67) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark 保存

- (void)saveMyNews:(id)sender
{
    if (_dynamicTV.text.length<=0)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"你还没有想好说些什么!" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [hud show:YES];
    [self.dynamicTV resignFirstResponder];
    
    //上传图片
    if (self.pictureArray.count>0) {
        [self.view bringSubviewToFront:hud];
        NSMutableArray* imageArray = [[NSMutableArray alloc]init];
        NSMutableArray* nameArray = [[NSMutableArray alloc]init];
        for (int i = 0;i< self.pictureArray.count;i++) {
            [imageArray addObject:((UIImageView*)self.pictureArray[i]).image];
            [nameArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        hud.labelText = @"上传图片中...";
        [hud show:YES];
        
        if (uploadImagePathArray.count>0) {
            [self uploadPicture: [uploadImagePathArray objectAtIndex:0]];
        }
    }else
    {
        [self publishWithImageString:@""];
    }
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
        self.imageId = [[NSMutableString alloc]init];
        for (int i=0; i<reponseStrArray.count; i++) {
            NSString * a=[uploadImagePathArray objectAtIndex:i];
            [_imageId appendFormat:@"%@,",[reponseStrArray objectForKey:a]];
        }
        [self publishWithImageString:_imageId];
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



-(void)publishWithImageString:(NSString*)imageID
{
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:@"3" forKey:@"type"];
    
    NSString *trimmedString = [self.dynamicTV.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [paramDict setObject:trimmedString forKey:@"msg"];
    [paramDict setObject:imageID forKey:@"img"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"134" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    hud.labelText = @"发表中...";
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            //保存发送的动态 放置“我” 界面
            if (responseObject&&[responseObject isKindOfClass:[NSDictionary class]]) {
                [DataStoreManager saveDSlatestDynamic:responseObject];
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateLastDynicmicInfo object:responseObject userInfo:nil];
            }
            [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:@"dynamicFromMe_wx"];
            if (self.delegate&&[self.delegate respondsToSelector:@selector(dynamicListAddOneDynamic:)])
                [self.delegate dynamicListAddOneDynamic:responseObject];
        }
        if (self.defaultContent && ![self.defaultContent isEqualToString:@""])
        {
        }
        else{
        }
        [self showMessageWindowWithContent:@"发表成功" imageType:0];
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
#pragma mark 照片
-(void)getAnActionSheet
{
    if (_pictureArray.count<9) {
        [_dynamicTV resignFirstResponder];
        if (self.addActionSheet != nil) {
            [_addActionSheet showInView:self.view];
            return;
        }
        self.addActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [_addActionSheet showInView:self.view];
    }
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

#pragma mark - text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length>0 || text.length != 0) {
        _placeholderL.text = @"";
    }else{
        _placeholderL.text = @"今天想跟别人说点什么……";
    }

    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = m_maxZiShu-[[GameCommon shareGameCommon] unicodeLengthOfString:new];
    if(res >= 0){
        return YES;
    }
    else{
        [self showAlertViewWithTitle:@"提示" message:@"最多不能超过225个字" buttonTitle:@"确定"];
        return NO;
    }
}

- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:_dynamicTV.text];
    if (ziNum<0) {
        ziNum=0;
    }
    m_ziNumLabel.text =[NSString stringWithFormat:@"%d%@%d",ziNum,@"/",m_maxZiShu];
    
    
    CGSize nameSize = [m_ziNumLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    m_ziNumLabel.frame=CGRectMake(320-5-nameSize.width, startX+148,nameSize.width,20);
    m_ziNumLabel.backgroundColor=[UIColor clearColor];
}
#pragma mark - touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_dynamicTV resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
