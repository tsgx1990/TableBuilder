//
//  TableViewIntrinsicCell.m
//  TableBuilder
//
//  Created by guanglong on 2019/7/25.
//  Copyright © 2019 guanglong. All rights reserved.
//

#import "TableViewIntrinsicCell.h"

@interface TableViewIntrinsicCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation TableViewIntrinsicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tb_syncSetModel:(TableViewIntrinsicModel0 *)model
{
    self.imgView.backgroundColor = model.imgColor;
}

- (CGFloat)tb_elementHeightForModel:(NSObject *)model
{
    return 100;
}

@end
