//
//  NavViewController.h
//  NB2
//
//  Created by zcc on 16/2/19.
//  Copyright © 2016年 Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavViewController : UINavigationController<UINavigationControllerDelegate>
+(NavViewController *) mangerNavController;
@end