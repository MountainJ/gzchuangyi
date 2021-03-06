//
//  MyOrderViewController.m
//  NB2
//
//  Created by Jayzy on 2017/9/11.
//  Copyright © 2017年 Kohn. All rights reserved.
//

#import "MyOrderViewController.h"
#import "ShopHistoryCell.h"

#define SLIDER_HEIGHT   KKFitScreen(80)

@interface MyOrderViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) NSInteger page;

@property (nonatomic,copy) NSString *requstType;
@end

@implementation MyOrderViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20 + NAV_BAR_HEIGHT+JF_TOP_ACTIVE_SPACE + SLIDER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - (20 + NAV_BAR_HEIGHT+JF_TOP_ACTIVE_SPACE) - SLIDER_HEIGHT) style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_LIGHTGRAY_BACK;
        _tableView.delegate  = self;
        _tableView.dataSource = self;
        [ToolControl setSeparatorWithTableView:_tableView];
        [self.view addSubview:_tableView];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topView.titileTx = @"记录查询";
    [self.topView setTopView];
    
    self.requstType = @"1";

    [self intiTopView];

    WS(weakSelf)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1 ;
        [weakSelf requestShopHistoryData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.page ++;
        [weakSelf requestShopHistoryData];
    }];
    self.page = 1;
    [self requestShopHistoryData];
    
}
- (void)intiTopView
{
    NSArray *arraycolcor=[[NSArray alloc] initWithObjects:@"商品购买记录",@"众筹跟投记录", nil];
    for (int i=0; i<2; i++)
    {
        UIButton *but=[UIButton buttonWithType:UIButtonTypeCustom];
        but.frame=CGRectMake(SCREEN_WIDTH/2.0*i, 20 +NAV_BAR_HEIGHT + JF_TOP_ACTIVE_SPACE, SCREEN_WIDTH/2.0, SLIDER_HEIGHT);
        but.tag=1000+i;
        but.titleLabel.font=[UIFont systemFontOfSize:KKFitScreen(28)];
        if (i==0)
        {
            but.selected=YES;
            [but setBackgroundImage:[UIImage imageNamed:@"butnooselectgreen"] forState:UIControlStateNormal];
            [but setBackgroundImage:[UIImage imageNamed:@"frist"] forState:UIControlStateSelected];

            
        }else if(i==1)
        {
            [but setBackgroundImage:[UIImage imageNamed:@"butnooselect"] forState:UIControlStateNormal];
            [but setBackgroundImage:[UIImage imageNamed:@"two"] forState:UIControlStateSelected];

            
        }
        [but addTarget:self action:@selector(clciksign:) forControlEvents:UIControlEventTouchUpInside];
        [but setTitle:[arraycolcor objectAtIndex:i] forState:UIControlStateNormal];
        [self.view addSubview:but];
    }
}

-(void)clciksign:(UIButton *)sender
{
    if(sender.tag==1000)
    {
        sender.selected=YES;
        UIButton *but1=[self.view viewWithTag:1001];
        but1.selected=NO;
        self.requstType = @"1";
    }else
    {
        sender.selected=YES;
        UIButton *but1=[self.view viewWithTag:1000];
        but1.selected=NO;
        self.requstType = @"0";
    }
    [self.tableView.mj_header beginRefreshing];
}

- (void)requestShopHistoryData
{
    if (self.page == 1) {
        [self.dataSource removeAllObjects];
    }
    NSDictionary *paramDict = @{@"id":[NSString stringWithFormat:@"%@",UID],@"md5":[NSString stringWithFormat:@"%@",MD5],@"type":[NSString stringWithFormat:@"%@",self.requstType],@"num":[NSString stringWithFormat:@"%d",5],@"page":[NSString stringWithFormat:@"%ld",(long)self.page]};
    [HttpTool postWithBaseURL:kBaseURL path:@"/api/requestshopOrderlist" params:paramDict success:^(NSDictionary *dict) {
        [SVProgressHUD dismiss];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        if (![dict[RequestResponseCodeKey] isEqualToString:RequestResponseCodeValue]) {
            [ToolControl showHudWithResult:NO andTip:[dict objectForKey:@"msg"]];
            return ;
        }
        if ([[dict objectForKey:@"station"] isEqualToString:@"success"])
        {
            if (![dict[@"result"] count]) {
                [ToolControl showHudWithResult:NO andTip:@"没有更多数据了！"];
                return;
            }
            if ([dict[@"result"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dataDict in dict[@"result"]) {
                    GoodsModel *model = [[GoodsModel alloc] initWithDataDict:dataDict];
                    if ([self.requstType integerValue]) {
                        model.numDescrip = @"购买数量：";
                    }else{
                        model.numDescrip = @"投标数量：";
                    }
                    [self.dataSource addObject:model];
                }
            }else if ([dict[@"result"] isKindOfClass:[NSDictionary class]])
            {
                GoodsModel * model = [[GoodsModel alloc] initWithDataDict:dict[@"result"]];
                if ([self.requstType integerValue]) {
                    model.numDescrip = @"购买数量：";
                }else{
                    model.numDescrip = @"投标数量：";
                }
                [self.dataSource addObject:model];
                
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [ToolControl showHudWithResult:NO andTip:ERRORTITLE];
    }];
}


#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KKFitScreen(220);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ShopHistoryCell";
    ShopHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[ShopHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    GoodsModel *model = [self.dataSource objectAtCheckIndex:indexPath.row];
    cell.model = model;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
