//
//  ODHomeVC.m
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

#import "ODHomeVC.h"

@interface ODHomeVC ()

@end

@implementation ODHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UILabel *testLab = [[UILabel alloc] init];
      testLab.frame = CGRectMake(100, 100, 400, 200);
      testLab.text = @"---ODHome你好---啊啊啊啊-";
      [self.view addSubview:testLab];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
