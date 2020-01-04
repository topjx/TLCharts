//
//  ORChartUtilities.m
//  ORAnimateTest
//
//  Created by OrangesAL on 2019/4/24.
//  Copyright © 2019 OrangesAL. All rights reserved.
//

#import "ORChartUtilities.h"

@implementation ORChartUtilities

+ (CAAnimation *)or_strokeAnimationWithDurantion:(NSTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.duration = duration;
    return animation;
}

+ (CAGradientLayer *)or_grandientLayerWithColors:(NSArray <UIColor *>*)colors leftToRight:(BOOL)leftToRight {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    [self or_configGrandientLayer:gradientLayer withColors:colors leftToRight:leftToRight];
    return gradientLayer;
}

+ (void)or_configGrandientLayer:(CAGradientLayer *)gradientLayer withColors:(NSArray <UIColor *>*)colors leftToRight:(BOOL)leftToRight {
    
    if (leftToRight) {
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
    }else {
        gradientLayer.startPoint = CGPointMake(1, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
    }
    
    if (colors.count > 0) {
        gradientLayer.colors = @[(__bridge id)colors.firstObject.CGColor, (__bridge id)colors.lastObject.CGColor];
    }
}

+ (CAShapeLayer *)or_shapelayerWithLineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)color {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    if (color) {
        shapeLayer.strokeColor = color.CGColor;
    }
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    return  shapeLayer;
}


+ (UIBezierPath *)or_pathWithPoints:(NSArray *)points isCurve:(BOOL)isCurve {
    return [self or_closePathWithPoints:points isCurve:isCurve maxY:-10086];
}

+ (UIBezierPath *)or_closePathWithPoints:(NSArray *)points isCurve:(BOOL)isCurve maxY:(CGFloat)maxY {
    
    if (points.count <= 0) {
        return nil;
    }
    
    BOOL isClose = maxY != -10086;
    
    CGPoint p1 = [points.firstObject CGPointValue];
    
    UIBezierPath *beizer = [UIBezierPath bezierPath];
    
    if (isClose) {
        [beizer moveToPoint:CGPointMake(p1.x, maxY)];
        [beizer addLineToPoint:p1];
    }else {
        [beizer moveToPoint:p1];
    }
        
    for (int i = 1;i<points.count;i++ ) {
        
        CGPoint prePoint = [[points objectAtIndex:i-1] CGPointValue];
        CGPoint nowPoint = [[points objectAtIndex:i] CGPointValue];
            
        if (isCurve) {
            [beizer addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
        }else {
            [beizer addLineToPoint:nowPoint];
        }

        if (i == points.count-1 && isClose) {
            [beizer addLineToPoint:CGPointMake(nowPoint.x, maxY)];
            [beizer closePath];
        }
    }
    return beizer;
}

#pragma mark -- ring

+ (UIBezierPath *)or_breakLinePathWithRawRect:(CGRect)rawRect circleWidth:(CGFloat)circleWidth ringWidth:(CGFloat)ringWidth startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle margin:(CGFloat)margin inMargin:(CGFloat)inMargin breakMargin:(CGFloat)breakMargin neatLine:(BOOL)neatLine checkBlock:(CGFloat (^)(CGPoint))checkBlock detailInfoBlock:(void (^)(CGPoint, CGPoint))detailInfoBlock {
    
    CGRect rect = CGRectMake((rawRect.size.width - circleWidth) / 2.0, (rawRect.size.height - circleWidth) / 2.0, circleWidth, circleWidth);
    
    CGFloat middAngle = [self or_middleAngleWithStartAngle:startAngle endAngle:endAngle];
    
    if (ringWidth > 0) {
        
        CGFloat insetAngle = asin(ringWidth / circleWidth);

        CGFloat inset = [self or_differAngleWithSubtractionAngle:endAngle subtractedAngle:startAngle] / (insetAngle * 3);
        inset = MIN(inset, 1);
        
        middAngle = [self or_angle:middAngle byAddAngle:insetAngle * inset];
    }
    
    CGRect inReck = CGRectMake(rect.origin.x - inMargin, rect.origin.y - inMargin, rect.size.width + 2 * inMargin, rect.size.height + 2 * inMargin);
    
    CGRect breakReck = CGRectMake(inReck.origin.x - breakMargin, inReck.origin.y - breakMargin, inReck.size.width + 2 * breakMargin, inReck.size.height + 2 * breakMargin);
    
    if (middAngle == startAngle) {
        middAngle = M_PI*2 - M_PI/5;//M_PI/10
//        CGPoint inPoint = [self or_pointWithCircleRect:inReck angle:M_PI*2 - M_PI/10];
//        CGPoint breakPoint = [self or_pointWithCircleRect:breakReck angle:M_PI*2 - M_PI/10];
    }
    
    CGPoint inPoint = [self or_pointWithCircleRect:inReck angle:middAngle];
    CGPoint breakPoint = [self or_pointWithCircleRect:breakReck angle:middAngle];
    
    if (checkBlock) {
        breakPoint.y += checkBlock(breakPoint);
    }
    
    CGFloat centerX = CGRectGetMidX(rect);
    
    CGPoint edgePoint = CGPointZero;
    
    CGFloat width = (rawRect.size.width - breakReck.size.width) / 2.0 - margin;
    
    if (inPoint.x < centerX) {
        edgePoint = neatLine ? CGPointMake(margin, breakPoint.y) : CGPointMake(breakPoint.x - width, breakPoint.y);
    }else {
        edgePoint = neatLine ? CGPointMake(CGRectGetMaxX(rawRect) - margin, breakPoint.y) : CGPointMake(breakPoint.x + width, breakPoint.y);
    }
    
    if (detailInfoBlock) {
        detailInfoBlock(edgePoint,inPoint);
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:inPoint];
    [path addLineToPoint:breakPoint];
    [path addLineToPoint:edgePoint];
    
    return path;
}

// 圆环
+ (UIBezierPath *)or_ringPathWithRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle ringWidth:(CGFloat)ringWidth closckWise:(BOOL)clockWidth isPie:(BOOL)isPie {
    
    
    if (startAngle == endAngle || startAngle == endAngle - M_PI * 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width / 2.0];
//        if (!isPie) {
            CGRect inReck = CGRectMake(rect.origin.x + ringWidth, rect.origin.y + ringWidth, rect.size.width - 2 * ringWidth, rect.size.height - 2 * ringWidth);
            [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:inReck cornerRadius:inReck.size.width / 2.0] bezierPathByReversingPath]];
//        }
        return path;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2.0;
    
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    if (isPie) {
        CGRect inRect = CGRectMake(rect.origin.x + ringWidth, rect.origin.y + ringWidth, rect.size.width - 2 * ringWidth, rect.size.height - 2 * ringWidth);
        
        [path addLineToPoint:[self or_pointWithCircleRect:inRect angle:endAngle]];
        [path addArcWithCenter:center radius:radius - ringWidth startAngle:endAngle endAngle:startAngle clockwise:NO];
        [path addLineToPoint:[self or_pointWithCircleRect:rect angle:startAngle]];
        return path;
    }
    
    CGPoint squreCenter = [self or_centerWithRect:rect angle:endAngle ringWidth:ringWidth];
    [path addArcWithCenter:squreCenter radius:ringWidth / 2.0 startAngle:endAngle endAngle:[self or_opposingAngleWithAngle:endAngle] clockwise:clockWidth];
    
    [path addArcWithCenter:center radius:radius - ringWidth startAngle:endAngle endAngle:startAngle clockwise:NO];
    
    CGPoint squreCenter1 = [self or_centerWithRect:rect angle:startAngle ringWidth:ringWidth];
    [path addArcWithCenter:squreCenter1 radius:ringWidth / 2.0 startAngle:[self or_opposingAngleWithAngle:startAngle] endAngle:startAngle clockwise:!clockWidth];
    
    return path;
}

//任意角度的对角
+ (CGFloat)or_opposingAngleWithAngle:(CGFloat)angle {
    
    if (angle > M_PI) {
        return angle - M_PI;
    }
    return M_PI + angle;
}

//任意角度 加上 固定角度
+ (CGFloat)or_angle:(CGFloat)angle byAddAngle:(CGFloat)addAngle {
    
    if (addAngle < 0 && (angle + addAngle < 0)) {
        return angle + addAngle +  M_PI * 2;
    }else if (angle + addAngle > M_PI * 2) {
        return angle + addAngle - M_PI * 2;
    }
    return angle + addAngle;
}

//减法
+ (CGFloat)or_differAngleWithSubtractionAngle:(CGFloat)subtractionAngle subtractedAngle:(CGFloat)subtractedAngle {
    
    if (subtractedAngle > subtractionAngle) {
        return subtractionAngle + M_PI * 2 - subtractedAngle;
    }else {
        return subtractionAngle - subtractedAngle;
    }
}

//任意角度间的中点角度
+ (CGFloat)or_middleAngleWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    
//    if (!clockWidth) {
//        CGFloat temp = startAngle;
//        startAngle = endAngle;
//        endAngle = temp;
//    }
    
    if (endAngle < startAngle) {
        return ((startAngle + M_PI * 2) + endAngle) / 2.0;
    }
    return (startAngle + endAngle) / 2.0;
}

// 圆环 任意角度(与半径相切)的 中点
+ (CGPoint)or_centerWithRect:(CGRect)rect angle:(CGFloat)angle ringWidth:(CGFloat)ringWidth {
    
    CGPoint topPoint = [self or_pointWithCircleRect:rect angle:angle];
    
    CGPoint inPoint = [self or_pointWithCircleRect:CGRectMake(rect.origin.x + ringWidth, rect.origin.y + ringWidth, rect.size.width - 2 * ringWidth, rect.size.height - 2 * ringWidth) angle:angle];;
    
    return CGPointMake((topPoint.x + inPoint.x) / 2.0, (topPoint.y + inPoint.y) / 2.0);
}

// 圆上 任意角度的 点
+ (CGPoint)or_pointWithCircleRect:(CGRect)rect angle:(CGFloat)angle {
    
    CGFloat aAngle = angle;
    if (angle >= M_PI * 3 / 2.0) {
        aAngle = angle - M_PI * 3 / 2.0;
    }else {
        aAngle = angle + M_PI / 2;
    }
    
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2.0;
    
    CGFloat pointY = center.y - cos(aAngle) * radius;
    CGFloat pointX = center.x + sin(aAngle) * radius;
    
    return CGPointMake(pointX, pointY);
}

@end


@implementation UIColor (ORRingConfiger)


+ (UIColor *)or_randomColor {
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
    
}

+ (UIColor *)colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha{
    NSString *cString = [[hexStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor whiteColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

@end
