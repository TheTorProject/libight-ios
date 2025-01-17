#import "DashboardTableViewCell.h"

@implementation DashboardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setRoundedView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setDescriptor:(OONIDescriptor*)descriptor{
    [self.titleLabel setText:descriptor.title];
    [self.descLabel setText:descriptor.shortDescription];
    [self.titleLabel setTextColor:[UIColor colorNamed:@"color_gray9"]];
    [self.descLabel setTextColor:[UIColor colorNamed:@"color_gray9"]];
    [self.cardbackgroundView setBackgroundColor:[UIColor colorNamed:@"color_gray0"]];
    [self.testLogo setImage:[self imageWithGradient:[UIImage imageNamed:descriptor.icon] startColor:[TestUtility getGradientColorForTest:descriptor.name] endColor:[TestUtility getColorForTest:descriptor.name]]];
}

-(void)setRoundedView{
    self.cardbackgroundView.layer.cornerRadius = 8;
    self.cardbackgroundView.layer.masksToBounds = YES;
    self.cardbackgroundView.layer.borderColor = [UIColor colorNamed:@"color_gray3"].CGColor;
    self.cardbackgroundView.layer.borderWidth = 2.0;
}

//From https://stackoverflow.com/questions/8098130/how-can-i-tint-a-uiimage-with-gradient
-(UIImage *)imageWithGradient:(UIImage *)img startColor:(UIColor *)color1 endColor:(UIColor *)color2 {
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);

    // Create gradient
    NSArray *colors = [NSArray arrayWithObjects:(id)color2.CGColor, (id)color1.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);

    // Apply gradient
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, img.size.height), 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);

    return gradientImage;
}
@end
