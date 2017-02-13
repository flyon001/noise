//
//  Gauge.h
//  Noise Monitor
//
//  Created by Frank Lyons on 8/31/16.
//  Copyright © 2016 Frank Lyons. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface Gauge: UIView
{
    
    CGFloat centerX;
    CGFloat centerY;
    CGFloat radius;
    CGFloat needleWidth;
    CGFloat needleHight;
    CAShapeLayer* shapeLayer;
    CAShapeLayer* marker;
    UIBezierPath *pointMarker;
    UIView* gaugeView;
    CGFloat lineWidth;
    CGFloat rotateDegreeValueTo;
    CGFloat rotateFromPreviosValue;
    CGFloat markerDegreeValuteTo;
    CGFloat markerPreviosDegreeValue;

    BOOL rotateStartValue;
    float rotateAnimationSpeed;
    
}

@property UIView* gaugeView;
@property float rotateAnimationSpeed;
@property CGFloat rotateDegreeValueTo;
@property CGFloat markerDegreeValueTo;
@property CGFloat markerPreviousDegreeValue;
-(void)animateGauge;
-(void)stopAnimateGauge;
-(void)animateGaugeMarker;


@end
