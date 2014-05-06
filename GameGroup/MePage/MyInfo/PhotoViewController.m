//
//  PhotoViewController.m
//  PetGroup
//
//  Created by 阿铛 on 13-9-4.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "PhotoViewController.h"
#import "EGOImageView.h"

@interface PhotoViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,EGOImageViewDelegate>
@property (nonatomic,retain)UIScrollView* sc;
@property (nonatomic,retain)UIImage* myimage;
@property (nonatomic,retain)NSArray* smallImageArray;
@end

@implementation PhotoViewController
/**
 *	@brief	显示一组图片
 *
 *	@param 	sImages 	缩略图集合
 *	@param 	images 	大图集合
 *	@param 	indext 	索引 - 显示这里面的第几张
 *
 *	@return	PhotoViewController
 */
- (id)initWithSmallImages:(NSArray*)sImages images:(NSArray*)images indext:(int)indext

{
    self = [super init];
    if (self) {
        self.smallImageArray = sImages;
        self.imgIDArray = images;
        self.indext = indext;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //建立一个Scorllview, 用来放置每张图片的scorllview, 以支持左右滑动
    self.sc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    _sc.backgroundColor = [UIColor blackColor];
    _sc.pagingEnabled=YES;
    _sc.showsHorizontalScrollIndicator=NO;
    _sc.showsVerticalScrollIndicator=NO;
    _sc.bounces = NO;
    _sc.contentOffset = CGPointMake(self.indext*320, 0);
    _sc.contentSize = CGSizeMake(320*self.imgIDArray.count, _sc.frame.size.height);
    [self.view addSubview:_sc];
    
    //添加手势
    UITapGestureRecognizer* tapOne = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOne:)];
    tapOne.numberOfTapsRequired = 1;
    [_sc addGestureRecognizer:tapOne];
    
    
    for (int i = 0;i < self.imgIDArray.count;i++) {
        
        //为每张图片imageV建立单独的Scorllview
        EGOImageView* imageV = [[EGOImageView alloc]initWithFrame:CGRectMake(110,(_sc.frame.size.height-100)/2 , 100, 100)];
        imageV.placeholderImage = _smallImageArray[i];
        EGOImageView *imgview = [[EGOImageView alloc]init];
        imgview.imageURL =[NSURL URLWithString: _smallImageArray[i]];
        imageV.placeholderImage = imgview.image;
        imageV.userInteractionEnabled = YES;
        imageV.delegate = self;
        
        UIScrollView * subSC = [[UIScrollView alloc]initWithFrame:CGRectMake(i*320, 0, 320, _sc.frame.size.height)];
        subSC.delegate = self;
        [subSC addSubview:imageV];
    
        
        //菊花
        UIActivityIndicatorView*act = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((_sc.frame.size.width-10)/2, (_sc.frame.size.height-10)/2, 10, 10)];
        [act startAnimating];
        [subSC addSubview:act];
        
        NSRange range=[self.imgIDArray[i] rangeOfString:@"<local>"];
        if (self.isComeFrmeUrl ==NO) {      //不是网页图片
            if (range.location!=NSNotFound) {
                NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
                NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,[self.imgIDArray[i] substringFromIndex:7]];
                NSData * nsData= [NSData dataWithContentsOfFile:openImgPath];
                UIImage * openPic= [UIImage imageWithData:nsData];
                imageV.image = openPic;
                [self imageViewLoadedImage:imageV]; //读取图片
            }
            else
                imageV.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString: self.imgIDArray[i]]];
            }
        else{
            imageV.imageURL = [NSURL URLWithString:self.imgIDArray[i]];
        }
        
        [self imageScrollViewStyleByImage:imageV scollView:subSC];  //调整ScorllView样式
   
        [_sc addSubview:subSC];

        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [imageV addGestureRecognizer:longPress];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击
-(void)tapOne:(UITapGestureRecognizer*)tap
{
    self.view.userInteractionEnabled = NO;
    int a = _sc.contentOffset.x/320;
    [UIView animateWithDuration:0.2 animations:^{
        ((UIView*)((UIView*)_sc.subviews[a]).subviews[0]).frame = CGRectMake(160,_sc.frame.size.height/2,0,0);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

//长按
-(void)longPress:(UILongPressGestureRecognizer*)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.myimage = ((EGOImageView*)longPress.view).image;
        UIActionSheet* act = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"保存",nil];
        [act showInView:longPress.view];
    }
}


#pragma mark - actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        UIImageWriteToSavedPhotosAlbum(self.myimage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    self.myimage = nil;
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败,请允许本应用访问您的相册";
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil];
    [alert show];
}
#pragma mark - scrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
// return a view that will be scaled. if delegate returns nil, nothing happens
{
    if (scrollView == _sc) {
        return nil;
    }
    return [scrollView.subviews objectAtIndex:0];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize size = ((UIView*)scrollView.subviews[0]).frame.size;
    if (scrollView.frame.size.height>size.height) {
        ((UIView*)scrollView.subviews[0]).frame = CGRectMake(0, (scrollView.frame.size.height-size.height)/2, size.width, size.height);
    }
}
#pragma mark - EGOImageView delegate


/**
 *	@brief	显示图片
 *
 *	@param 	imageView 	图片
 */
- (void)imageViewLoadedImage:(EGOImageView*)imageView
{


    float a = 0.0;
    CGSize size = imageView.image.size;
    if (320*size.height/size.width<_sc.frame.size.height) {
        a = (_sc.frame.size.height-320*size.height/size.width)/2;
    }
//    imageView.frame = CGRectMake(160,_sc.frame.size.height/2,0,0);
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = CGRectMake(0, a, 320, 320*size.height/size.width);
    }];
    
    //调整ScorllView样式
    UIScrollView* subSC =(UIScrollView*)imageView.superview;
    [self imageScrollViewStyleByImage:imageView scollView:subSC];
    
    [((UIActivityIndicatorView*)imageView.superview.subviews[1]) stopAnimating];

}

/**
 *	@brief	修改ScorllView样式，使之可以缩放和点击，滑动
 *
 *	@param 	imageView 	图片
 *	@param 	scrollView 	图片所在的ScorllVIew
 */
- (void)imageScrollViewStyleByImage:(EGOImageView*)imageView
                          scollView:(UIScrollView*)subSC

{
    NSInteger static cs_width = 320; //宽度就是320
    NSInteger cs_height = cs_width / imageView.image.size.width * imageView.image.size.height;
    subSC.contentSize = CGSizeMake(cs_width,cs_height);
    subSC.bouncesZoom = NO;
    subSC.pagingEnabled = YES;
    subSC.showsHorizontalScrollIndicator=NO;
    subSC.showsVerticalScrollIndicator=NO;
    subSC.maximumZoomScale = 2.0;
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    //未完待续
    [self dismissViewControllerAnimated:NO completion:^{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"图片加载失败" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles: nil];
        [alert show];
    }];
}
@end
