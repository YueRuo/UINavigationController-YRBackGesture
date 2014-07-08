//
//  ViewController.m
//  YRBackGestureDemo
//
//  Created by 王晓宇 on 14-7-8.
//  Copyright (c) 2014年 YueRuo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat randomR=arc4random()%255/255.0f;
    CGFloat randomG=arc4random()%255/255.0f;
    
    UIButton *pushButton=[[UIButton alloc]initWithFrame:CGRectMake(20, 80, 120, 50)];
    [pushButton setBackgroundColor:[UIColor colorWithRed:randomR green:randomG blue:0.8 alpha:1]];
    [pushButton setTitle:@"Push" forState:UIControlStateNormal];
    [pushButton addTarget:self action:@selector(pushNewVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];
    
    UIActivityIndicatorView *indicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(130, 200, 60, 60)];
    [indicatorView setBackgroundColor:[UIColor colorWithRed:randomR green:randomG blue:0.8 alpha:1]];
    [self.view addSubview:indicatorView];
    [indicatorView startAnimating];
    
    UILabel *tipsLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 170, 320, 30)];
    [tipsLabel setTextAlignment:NSTextAlignmentCenter];
    [tipsLabel setText:@"支持动态效果,指示器不停"];
    [self.view addSubview:tipsLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)pushNewVC{
    ViewController *newViewController=[[ViewController alloc]initWithNibName:nil bundle:nil];
    CGFloat randomR=arc4random()%255/255.0f;
    CGFloat randomG=arc4random()%255/255.0f;
    [newViewController.view setBackgroundColor:[UIColor colorWithRed:randomR green:randomG blue:0.8 alpha:1]];
    [self.navigationController pushViewController:newViewController animated:true];
}

@end
