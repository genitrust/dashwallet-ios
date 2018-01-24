//
//  LeftViewCell.m
//  LGSideMenuControllerDemo
//

#import "LeftViewCell.h"

@implementation LeftViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.titleLabel.alpha = highlighted ? 0.5 : 1.0;
    self.menuImg.alpha = highlighted ? 0.5 : 1.0;
}

@end
