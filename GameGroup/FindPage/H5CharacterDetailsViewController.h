//
//  H5CharacterDetailsViewController.h
//  GameGroup
//
//  Created by Marss on 14-7-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "SendNewsViewController.h"

@interface H5CharacterDetailsViewController : BaseViewController<UIAlertViewDelegate,UIWebViewDelegate,UIActionSheetDelegate,TableViewDatasourceDidChange>
@property(nonatomic,strong)NSString* gameId;
@property(nonatomic,strong)NSString* characterName;
@property(nonatomic,strong)NSString* characterId;
@end
