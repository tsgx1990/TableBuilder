//
//  ViewController.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "ViewController.h"
#import "TBTableViewBaseProxy.h"

#import "TableViewCellModel0.h"
#import "TableViewCell0.h"

#import "TableViewCellModel1.h"
#import "TableViewCell1.h"

@interface ViewController () <TBTableViewBaseProxyDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TBTableViewBaseProxy *tableProxy;

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    TableViewCellModel0 *m0 = TableViewCellModel0.new;
    m0.title = @"家庭是指婚姻关系、血缘关系或收养关系基础上产生的，亲属之间所构成的社会生活单位。 [1]  家庭是幸福生活的一种存在。";
    m0.subtitle = @"家庭有广义和狭义之分，狭义是指一夫一妻制构成的社会单元；广义的则泛指人类进化的不同阶段上的各种家庭利益集团即家族。";
    
    TableViewCellModel0 *m1 = TableViewCellModel0.new;
    m1.title = @"从社会设置来说，家庭是最基本的社会设置之一，是人类最基本最重要的一种制度和群体形式。";
    m1.subtitle = @"从功能来说，家庭是儿童社会化，供养老人，是满足经济合作的人类亲密关系的基本单位。从关系来说，家庭是由具有婚姻、血缘和收养关系的人们长期居住的共同群体。";
    
    TableViewCellModel1 *m10 = TableViewCellModel1.new;
    m10.title0 = @"满足经济合作的人类亲密关系的基本单位。满足经济合作的人类亲密关系的基本单位。";
    m10.title1 = @"从关系来说，家庭是由具有婚姻、血缘和收养关系的人们长期居住的共同群体。满足经济合作的人类亲密关系的基本单位。";
    m10.title2 = @"狭义是指一夫一妻制构成的社会单元；广义的则泛指人类进化的不同阶段上的各种家庭利益集团即家族。满足经济合作的人类亲密关系的基本单位。";
    
    self.dataArr = @[m0, m1, m10];
    self.tableProxy = [TBTableViewBaseProxy proxyWithTableView:self.tableView];
    self.tableProxy.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.tableView reloadData];
}

#pragma mark - - TBTableViewBaseProxyDelegate
- (NSInteger)proxy:(TBTableViewBaseProxy *)proxy numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = self.dataArr[indexPath.row];
    model.tb_eleUseXib = YES;
    if ([model isKindOfClass:TableViewCellModel0.class]) {
        model.tb_eleClass = TableViewCell0.class;
    }
    if ([model isKindOfClass:TableViewCellModel1.class]) {
        model.tb_eleClass = TableViewCell1.class;
    }
    return model;
}

@end
