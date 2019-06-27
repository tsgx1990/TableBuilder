//
//  TableViewCell1.m
//  TableBuilder
//
//  Created by guanglong on 2019/6/27.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TableViewCell1.h"
#import "TableViewCellModel1.h"

@interface TableViewCell1 ()

@property (weak, nonatomic) IBOutlet UILabel *lbl0;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;

@end

@implementation TableViewCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tb_syncSetModel:(TableViewCellModel1 *)model
{
    self.lbl0.text = model.title0;
    self.lbl1.text = model.title1;
    self.lbl2.text = model.title2;
}

@end
