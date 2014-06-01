//
//  MacroDietCircularSlider.m
//  GymRegime
//
//  Created by Kim on 31/05/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "MacroDietCircularSlider.h"
#import <QuartzCore/QuartzCore.h>

@implementation MacroDietCircularSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //// General Declarations
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.41 green: 1 blue: 0.114 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 1 green: 0.114 blue: 0.114 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.343 green: 0.343 blue: 1 alpha: 1];
    UIColor* fillColor2 = [UIColor colorWithRed:.30 green:0.30 blue:0.30 alpha:1];
    
    //// Shadow Declarations
    UIColor* shadow = strokeColor;
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 5.5;
    
    //// background Drawing
    UIBezierPath* backgroundPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(10, 10, 250, 250)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [strokeColor setFill];
    [backgroundPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// protein Drawing
    CGRect proteinRect = CGRectMake(10, 10, 250, 250);
    UIBezierPath* proteinPath = [UIBezierPath bezierPath];
    [proteinPath addArcWithCenter: CGPointMake(CGRectGetMidX(proteinRect), CGRectGetMidY(proteinRect)) radius: CGRectGetWidth(proteinRect) / 2 startAngle: 270 * M_PI/180 endAngle: 0 * M_PI/180 clockwise: YES];
    [proteinPath addLineToPoint: CGPointMake(CGRectGetMidX(proteinRect), CGRectGetMidY(proteinRect))];
    [proteinPath closePath];
    
    [fillColor setFill];
    [proteinPath fill];
    
    
    //// fat Drawing
    CGRect fatRect = CGRectMake(10, 10, 250, 250);
    UIBezierPath* fatPath = [UIBezierPath bezierPath];
    [fatPath addArcWithCenter: CGPointMake(CGRectGetMidX(fatRect), CGRectGetMidY(fatRect)) radius: CGRectGetWidth(fatRect) / 2 startAngle: 137 * M_PI/180 endAngle: 270 * M_PI/180 clockwise: YES];
    [fatPath addLineToPoint: CGPointMake(CGRectGetMidX(fatRect), CGRectGetMidY(fatRect))];
    [fatPath closePath];
    
    [color setFill];
    [fatPath fill];
    
    
    //// carbs Drawing
    CGRect carbsRect = CGRectMake(10, 10, 250, 250);
    UIBezierPath* carbsPath = [UIBezierPath bezierPath];
    [carbsPath addArcWithCenter: CGPointMake(CGRectGetMidX(carbsRect), CGRectGetMidY(carbsRect)) radius: CGRectGetWidth(carbsRect) / 2 startAngle: 0 * M_PI/180 endAngle: 137 * M_PI/180 clockwise: YES];
    [carbsPath addLineToPoint: CGPointMake(CGRectGetMidX(carbsRect), CGRectGetMidY(carbsRect))];
    [carbsPath closePath];
    
    [color2 setFill];
    [carbsPath fill];
    
    
    //// center Drawing
    UIBezierPath* centerPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(75.5, 75.5, 120, 120)];
    [fillColor2 setFill];
    [centerPath fill];
    
    ////// center Inner Shadow
    CGRect centerBorderRect = CGRectInset([centerPath bounds], -shadowBlurRadius, -shadowBlurRadius);
    centerBorderRect = CGRectOffset(centerBorderRect, -shadowOffset.width, -shadowOffset.height);
    centerBorderRect = CGRectInset(CGRectUnion(centerBorderRect, [centerPath bounds]), -1, -1);
    
    UIBezierPath* centerNegativePath = [UIBezierPath bezierPathWithRect: centerBorderRect];
    [centerNegativePath appendPath: centerPath];
    centerNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(centerBorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow.CGColor);
        
        [centerPath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(centerBorderRect.size.width), 0);
        [centerNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [centerNegativePath fill];
    }
    CGContextRestoreGState(context);
    
}




@end
