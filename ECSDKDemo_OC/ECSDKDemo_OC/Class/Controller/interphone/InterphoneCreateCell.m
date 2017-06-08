//
//  InviteJoinListViewCell.m
//  ECSDKDemo_OC
//
//  Created by jzy on 14/12/11.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "InterphoneCreateCell.h"

@implementation InterphoneCreateCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _portraitImg = [[UIImageView alloc] init];
        _portraitImg.translatesAutoresizingMaskIntoConstraints = NO;
        _portraitImg.contentMode = UIViewContentModeScaleAspectFit;
        _portraitImg.image = [UIImage imageNamed:@"personal_portrait"];
        [self.contentView addSubview:_portraitImg];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_portraitImg(==45)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_portraitImg)]];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_nameLabel];
        
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _numberLabel.font = [UIFont systemFontOfSize:13.0f];
        _numberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _numberLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_numberLabel];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_nameLabel(==25)][_numberLabel(==15)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel,_numberLabel)]];
        
        _selecImage = [[UIImageView alloc] init];
        _selecImage.translatesAutoresizingMaskIntoConstraints = NO;
        _selecImage.image =[UIImage imageNamed:@"select_account_list_unchecked"];
        [self.contentView addSubview:_selecImage];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_selecImage(==24.5)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_selecImage)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[_portraitImg(==45)]-[_nameLabel]-[_selecImage(==24.5)]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_portraitImg,_nameLabel,_selecImage)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portraitImg]-[_numberLabel(_nameLabel)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_portraitImg,_nameLabel,_numberLabel)]];
        
    }
    return self;
}
@end
