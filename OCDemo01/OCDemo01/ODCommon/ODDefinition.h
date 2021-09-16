//
//  ODDefinition.h
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

#ifndef ODDefinition_h
#define ODDefinition_h


//屏幕宽高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


#define IS_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define TopHeight     (IS_iPhoneX?88:64)
#define TabbarHeight  (IS_iPhoneX?83:(49 + 6 - 6))
#define NavBarHeight   44
#define StatusBarHeight (IS_iPhoneX?44:20)
#define BottomSafeHeight (IS_iPhoneX?34:20)


#endif /* ODDefinition_h */
