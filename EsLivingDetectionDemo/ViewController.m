//
//  ViewController.m
//  EsLivingDetectionDemo
//
//  Created by ReidLee on 2020/12/23.
//

#import "ViewController.h"
#import <EsLivingDetection/EsLivingDetection.h>
#import "MyHttpClient.h"
#import "GZFRadioCheckBox.h"

//屏幕宽度
#define  SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
//屏幕高度
#define  SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()

@end

@implementation ViewController {
    UITextView *_textView;
    int livingType;
    GZFRadioCheckBox *radioCheckBox;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    //导航栏+状态栏高度
    CGFloat topHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;

    // 横向显示
    radioCheckBox = [[GZFRadioCheckBox alloc] initWithFrame:CGRectMake(5, topHeight + 10 , SCREEN_WIDTH-20, 50)];
    radioCheckBox.isHorizontal = YES; //默认
    radioCheckBox.spacing = 30; //默认 10
    radioCheckBox.index = 5; // 默认 0
    livingType = (int)radioCheckBox.index+1;
    radioCheckBox.showTextColor = [UIColor orangeColor];
    radioCheckBox.showTextFont = [UIFont systemFontOfSize:14];
    // 1：远近，2：眨眼，3：摇头，4: 点头，5:张嘴，6：炫彩
    radioCheckBox.hideTextArray = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4", @"5", @"6", nil];
    radioCheckBox.showTextArray = [NSArray arrayWithObjects:@"远近",@"眨眼",@"摇头",@"点头",@"张嘴",@"炫彩", nil];
    [radioCheckBox radioCheckBoxClick:^(NSUInteger index, NSString *showText, NSString *hideText) {
        self->livingType = (int)index+1;
    }];
    [self.view addSubview:radioCheckBox];

    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    //设置认证按钮布局
    button.frame = CGRectMake(10, topHeight + 80 , SCREEN_WIDTH-20, 50) ;
    [button setTitle:@"开始活体检测" forState:UIControlStateNormal];
    //设置按钮文字颜色
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:137.0/255.0 blue:47.0/255.0 alpha:1.0]];
    //按钮圆角
    [button.layer setCornerRadius:20.0];
    //设置按钮点击事件
    [button addTarget:self action:@selector(startLivingDetect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // 实名认证按钮
    UIButton * rpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rpButton.frame = CGRectMake(10, topHeight + 140 , SCREEN_WIDTH-20, 50) ;
    [rpButton setTitle:@"开始实名认证" forState:UIControlStateNormal];
    [rpButton addTarget:self action:@selector(startRPVerify:) forControlEvents:UIControlEventTouchUpInside];
    [rpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rpButton setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:137.0/255.0 blue:47.0/255.0 alpha:1.0]];
    [rpButton.layer setCornerRadius:20.0];
    [self.view addSubview:rpButton];

    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, topHeight + 2000, SCREEN_WIDTH - 20, SCREEN_HEIGHT - topHeight - 150)];
    // Do any additional setup after loading the view, typically from a nib.
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y,scrollView.frame.size.width, scrollView.frame.size.height)];
    _textView.pagingEnabled = YES;
    _textView.clipsToBounds = YES;
    _textView.editable = NO;

    [self.view addSubview:_textView];
}

-(IBAction)startLivingDetect:(id)sender {
    // 1. 认证初始化
    NSInteger livingType = [radioCheckBox getSelectItem];
    if (livingType > 9999) {
        [self logMsg: @"最多只支持四个活体动作"];
        return ;
    }

    EsLivingDetectResult* esLivingDetectResult = [EsLivingDetectionManager verifyInit: livingType];
    if (esLivingDetectResult.code != ELD_SUCCESS) {
        [self logMsg: esLivingDetectResult.msg];
        return;
    }

    // 2. 获取认证token
    NSString* body = [NSString stringWithFormat:@"initMsg=%@", esLivingDetectResult.data];
    [MyHttpClient ldtInit: body
                   clientCallback:^(NSString * rspMsg) {
        [self logMsg: rspMsg];
        NSDictionary*  dict = [MyHttpClient json2Dict:rspMsg];
        NSString* token = dict[@"token"];
        if (token==nil) {
            [self logMsg: @"获取TOKEN失败"];
        } else {
            // 样式设置 (可选)
            [[[[[[[EsLivingDetectionManager LivingViewStyleInstance]setTextColor:@"#ff1231"]setBackGroundColor:@"#eeeeee"]setProgressBgColor:@"#2222ff"]setProgressStaGradient:@"#ffff00"]setProgressEndGradient:@"#ff0000"]setProgressBorderColor:@"#ff0000"];
            // 3. 发起活体认证
            [EsLivingDetectionManager startDetect: token viewController: self callback:^(EsLivingDetectResult * _Nonnull result) {
                if (result.code == ELD_SUCCESS) {
                    NSString* body = [NSString stringWithFormat:@"token=%@&verifyMsg=%@", result.token, result.data];
                                        [MyHttpClient ldtVerify: body
                                            clientCallback:^(NSString * rspMsg) {
                                                [self logMsg: rspMsg];
                                            } ];
                }else{
                    [self logMsg:result.msg];
                }
            } ];
        }
    }];
}

/**
 * 实名认证
 */
-(IBAction)startRPVerify:(id)sender {
    // 1. 认证初始化
    NSInteger livingType = [radioCheckBox getSelectItem];
    if (livingType > 9999) {
        [self logMsg: @"最多只支持四个活体动作"];
        return ;
    }

    [[EsLivingDetectionManager LivingConfigInstance]SetMode: 1]; // 0 ： 仅活体 （默认）  1 ： 全流程，除活体外还支持其他交互页面 (当前仅支持实名认证交互界面)
    [[EsLivingDetectionManager LivingConfigInstance]SetWithOcr:true]; // 是否包括导航条
    [[EsLivingDetectionManager LivingConfigInstance]SetOcrFirst:false]; // OCR 优先
    [[EsLivingDetectionManager LivingConfigInstance]SetOcrIncFront:true]; // 是否包括身份证正面 (国徽面)
    [[EsLivingDetectionManager LivingConfigInstance]SetNavigateShow:false]; // 是否包括导航条（多动作才有导航条）
    EsLivingDetectResult* esLivingDetectResult = [EsLivingDetectionManager verifyInit: livingType];
    if (esLivingDetectResult.code != ELD_SUCCESS) {
        [self logMsg: esLivingDetectResult.msg];
        return;
    }

    // 2. 获取认证token
    NSString* body = [NSString stringWithFormat:@"initMsg=%@&certName=%@&certNo=%@", esLivingDetectResult.data, @"", @""];
    [MyHttpClient rpInit: body clientCallback:^(NSString * rspMsg) {
        [self logMsg: rspMsg];
        NSDictionary*  dict = [MyHttpClient json2Dict:rspMsg];
        NSString* token = dict[@"token"];
        if (token==nil) {
            [self logMsg: @"获取TOKEN失败"];
        } else {
            // 样式设置 (可选)
            [[[[[[[EsLivingDetectionManager LivingViewStyleInstance]setTextColor:@"#ff1231"]setBackGroundColor:@"#eeeeee"]setProgressBgColor:@"#2222ff"]setProgressStaGradient:@"#ffff00"]setProgressEndGradient:@"#ff0000"]setProgressBorderColor:@"#ff0000"];
            // 3. 发起实名认证
            [EsLivingDetectionManager startOcrFaceAuth:self token:token callback:^(EsLivingDetectResult * _Nonnull result) {
                if (result.code == ELD_SUCCESS) {
                    NSString* body = [NSString stringWithFormat:@"token=%@&verifyMsg=%@", result.token, result.data];
                                        [MyHttpClient rpVerify: body
                                            clientCallback:^(NSString * rspMsg) {
                                                [self logMsg: rspMsg];
                                                NSLog(@"认证结果 ： %@", rspMsg);
                                            } ];
                }else{
                    [self logMsg:result.msg];
                }
            } ];
        }
    }];
}


- (void)logMsg:(NSString*)content {
    if (content == NULL) {
        return;
    }
    content = [NSString stringWithFormat:@"%@ \n", content];
    dispatch_async(dispatch_get_main_queue(), ^{

        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:content];
        [string addAttribute:NSForegroundColorAttributeName
                       value:[UIColor blackColor]
                       range:NSMakeRange(0, content.length)];

        [string addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:15]
                       range:NSMakeRange(0 , content.length)];
        NSMutableAttributedString* tvStr = [[NSMutableAttributedString alloc] initWithAttributedString:self->_textView.attributedText];

        [tvStr appendAttributedString:string];
        [self->_textView setAttributedText:tvStr];
    });
}

@end
