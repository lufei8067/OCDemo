//
//  ODHomeVC.m
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

#import "ODHomeVC.h"

@interface ODHomeVC ()

@property(nonatomic, strong) NSArray *dataArray;

@end

@implementation ODHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataArray = @[@"大师班", @"牛逼板", @"嗷嗷嗷", @"嗨啊还", @"的点点滴滴"];
    
    
    UILabel *testLab = [[UILabel alloc] init];
    testLab.frame = CGRectMake(100, 100, 400, 200);
    testLab.text = @"---ODHome你好---啊啊啊啊-";
    [self.view addSubview:testLab];
    
    
    
    UILOG(@"666");
    
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setTitle:@"登录" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(menuCallBack:) forControlEvents:UIControlEventTouchUpInside];
    //[closeBtn setTintColor:[UIColor blackColor]];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:closeBtn];
    [closeBtn setTag:2];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(38);
        make.width.mas_equalTo(38);
    }];
    
    
    //NSSetUncaughtExceptionHandler(&LGEx)
}


-(void)menuCallBack:(UIButton*)btnCallBack{
    
    
   // NSLog(@"%@", [self.dataArray objectAtIndex:6]);
    
    
    
    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperationWithBlock:^{
//
//        void *signal = malloc(1024);
//        free(signal);
//        free(signal);
//
//    }];
    
    [self performSelector:@selector(selString) withObject:nil afterDelay:2.0];
    
}

-(void)selString
{
    void *signal = malloc(1024);
    free(signal);
    free(signal);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
 
    
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
