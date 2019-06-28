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

#import "TableViewHeadModel0.h"
#import "TableViewHead0.h"

#import "TableViewHeadModel1.h"
#import "TableViewHead1.h"
#import "TableViewHeadSetter1.h"

@interface ViewController () <TBTableViewBaseProxyDelegate, TBTableViewCellDelegate>

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
    
    TableViewCellModel1 *m11 = TableViewCellModel1.new;
    m11.title0 = @"检查出滑膜肉瘤之后，学校曾经组织了募捐活动，在学校食堂放置了几处募捐箱，筹集了8万元钱，也有人进行义卖筹钱。所做的这一切都是希望能够帮助挽回年轻的生命，结果却是未能如愿。";
    m11.title1 = @"2015年3月，休学一年的魏则西回到学校，转入计算机专业2013级2班。2015年3月，休学一年的魏则西回到学校，转入计算机专业2013级2班。2015年3月，休学一年的魏则西回到学校，转入计算机专业2013级2班。2015年3月，休学一年的魏则西回到学校，转入计算机专业2013级2班。2015年3月，休学一年的魏则西回到学校，转入计算机专业2013级2班。";
    m11.title2 = @"2014年4月，魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。魏则西被查出得了滑膜肉瘤。这是一种恶性软组织肿瘤，目前没有有效的治疗手段，生存率极低。休学。";
    
    
    TableViewHeadModel0 *hm0 = TableViewHeadModel0.new;
    hm0.leftTitle = @"魏则西在父母的带领下先后从陕西咸阳4次前往北京治疗。";
    hm0.rightTitle = @"“我和他妈妈谢谢广大知友对则西的关爱，希望大家关爱生命，热爱生活。”";
    
    TableViewHeadModel0 *hm1 = TableViewHeadModel0.new;
    hm1.leftTitle = @"于是魏则西开始了在武警北京总队第二医院先后4次的治疗。";
    hm1.rightTitle = @"转入计算机专业2013级2班。";
    
    TableViewHeadModel1 *hm10 = TableViewHeadModel1.new;
    hm10.leftTitle = @"1966年转为地方建制，1988年定名为西安电子科技大学。";
    hm10.midTitle = @"学校前身是1931年诞生于江西瑞金的中央军委无线电学校，是毛泽东等老一辈革命家亲手创建的第一所工程技术学校。是毛泽东等老一辈革命家亲手创建的第一所工程技术学校。";
    hm10.rightTitle = @"产生了120多位解放军将领，成长起了19位两院院士。";
    
    self.dataArr = @[@{@"head": hm0, @"data": @[m10, m1]},
                     @{@"head": hm1, @"data": @[m0]},
                     @{@"head": hm10, @"data": @[m11]}];
    
    self.tableProxy = [TBTableViewBaseProxy proxyWithTableView:self.tableView];
    self.tableProxy.delegate = self;
}

#pragma mark - - TBTableViewBaseProxyDelegate

- (NSInteger)numberOfSectionsInProxy:(TBTableViewBaseProxy *)proxy
{
    return self.dataArr.count;
}

- (NSInteger)proxy:(TBTableViewBaseProxy *)proxy numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArr[section][@"data"] count];
}

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = self.dataArr[indexPath.section][@"data"][indexPath.row];
    model.tb_eleUseXib = YES;
    if ([model isKindOfClass:TableViewCellModel0.class]) {
        model.tb_eleClass = TableViewCell0.class;
        model.tb_eleDoNotCacheHeight = YES;
    }
    if ([model isKindOfClass:TableViewCellModel1.class]) {
        model.tb_eleClass = TableViewCell1.class;
        model.tb_eleWeakDelegate = self;
    }
    return model;
}

- (NSObject *)modelInProxy:(TBTableViewBaseProxy *)proxy forHeaderInSection:(NSInteger)section
{
    NSObject *model = self.dataArr[section][@"head"];
    model.tb_eleUseXib = YES;
    if ([model isKindOfClass:TableViewHeadModel0.class]) {
        model.tb_eleClass = TableViewHead0.class;
    }
    if ([model isKindOfClass:TableViewHeadModel1.class]) {
        model.tb_eleClass = TableViewHead1.class;
        model.tb_eleSetter = TableViewHeadSetter1.new;
    }
    return model;
}

#pragma mark - - TBTableViewCellDelegate
- (void)didSelectCell:(UITableViewCell *)cell withModel:(NSObject *)model atIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"aaa");
}

@end
