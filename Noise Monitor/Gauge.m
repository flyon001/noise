//
//  Gauge.m
//  Noise Monitor
//
//  Created by Frank Lyons on 8/31/16.
//  Copyright © 2016 Frank Lyons. All rights reserved.
//

#import "Gauge.h"

@implementation Gauge
@synthesize rotateAnimationSpeed;
@synthesize rotateDegreeValueTo;
@synthesize gaugeView;
@synthesize markerDegreeValueTo;
@synthesize markerPreviousDegreeValue;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        //center of the needle should be on bottom center of frame.
        centerX = frame.size.width /2; //center of the arc x position
        centerY = frame.size.height;// bottom of the arc y position
        needleWidth = 5;
        needleHight = 105;
        lineWidth = 35;
        rotateStartValue = YES;
        rotateAnimationSpeed = .1;
        gaugeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        radius = 100;
        
       
        
        pointMarker = [UIBezierPath bezierPath];
        
        //Green segment of background of gauge
        UIBezierPath* arcPath1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX,centerY)
                                                              radius:radius
                                                              startAngle:M_PI
                                                              endAngle:M_PI + M_PI_4
                                                              clockwise:YES];
        //Yellow segment of background of gauge
        UIBezierPath* arcPath2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX,centerY)
                                                              radius:radius
                                                              startAngle:M_PI + M_PI_4
                                                              endAngle:M_PI + M_PI_2
                                                              clockwise:YES];
        //Red segment of background of gauge
        UIBezierPath* arcPath3 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX,centerY)
                                                               radius:radius
                                                               startAngle:3*M_PI /2
                                                               endAngle:0
                                                               clockwise:YES];
       

        //green segment of background of gague settings
        CAShapeLayer* arc1 = [CAShapeLayer layer];
        arc1.path = arcPath1.CGPath;
        arc1.lineWidth = lineWidth;
        arc1.strokeColor = [[UIColor greenColor] CGColor];
        arc1.backgroundColor = [[UIColor whiteColor] CGColor];
        arc1.fillColor = [[UIColor whiteColor] CGColor];
        [[gaugeView layer] addSublayer:arc1];
       
        //yellow segment of background of gague settings
        CAShapeLayer* arc2 = [CAShapeLayer layer];
        arc2.path = arcPath2.CGPath;
        arc2.lineWidth = lineWidth;
        UIColor* yellow = [UIColor yellowColor];
        UIColor* darkYellow = [self darkerColor:yellow];
        arc2.strokeColor = darkYellow.CGColor;
        arc2.backgroundColor = [[UIColor whiteColor] CGColor];
        arc2.fillColor = [[UIColor whiteColor] CGColor];
        [[gaugeView layer] addSublayer:arc2];
        
        //red segment of background of gague settings
        CAShapeLayer* arc3 = [CAShapeLayer layer];
        arc3.path = arcPath3.CGPath;
        arc3.lineWidth = lineWidth;
        arc3.strokeColor = [[UIColor redColor] CGColor];
        arc3.backgroundColor = [[UIColor whiteColor] CGColor];
        arc3.fillColor = [[UIColor whiteColor] CGColor];
        [[gaugeView layer] addSublayer:arc3];
        
        //alarm marker line on gauge
        UIBezierPath *positionMarker = [UIBezierPath bezierPathWithRect:CGRectMake(centerX, centerY, 5, 45)];
        marker = [CAShapeLayer layer];
        marker.path = positionMarker.CGPath;
        marker.bounds = CGPathGetBoundingBox(positionMarker.CGPath);
        marker.strokeColor = [[UIColor blueColor] CGColor];
        marker.fillColor = [[UIColor blueColor]CGColor];
        marker.position = CGPointMake(centerX, centerY);
        marker.anchorPoint = CGPointMake(0, -1.75);
        CGFloat angleMarker = M_PI_2;
        marker.transform = CATransform3DMakeRotation(angleMarker, 0, 0, 1.0);//shift through the z-axis
        [[gaugeView layer] addSublayer:marker];
        

        //The center circle(dot) for needle
         UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(centerX-5, centerY, 10, 10)];
        CAShapeLayer *dot = [CAShapeLayer layer];
        dot.path = circle.CGPath;
        dot.strokeColor = [[UIColor blackColor]CGColor];
        dot.fillColor = [[UIColor blackColor]CGColor];
        [[gaugeView layer]addSublayer:dot];
        
        //Needle for gauge, to be animated for gauge
        UIBezierPath *needle = [UIBezierPath bezierPathWithRect:CGRectMake(centerX, centerY, needleWidth, needleHight)];
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = needle.CGPath;
        //anchor point of the needle shape object
        shapeLayer.bounds = CGPathGetBoundingBox(shapeLayer.path);
        shapeLayer.anchorPoint = CGPointMake(.5, 0);
        shapeLayer.position = CGPointMake(centerX , centerY+5);
        //The line drawn is repositoned to start of scale"180 degree"(needs to be shifted clockwise pi/2).
        CGFloat angle = M_PI_2;
        shapeLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1.0);//shift through the z-axis
        //add layer to view
        [[gaugeView layer] addSublayer:shapeLayer];
        
        
        
    }
        return self;
}
//darken the yellow part of the background
-(UIColor*)darkerColor: (UIColor*) color
{
    CGFloat r,g,b,a;
    if([color getRed:&r green:&g blue:&b alpha:&a])
    {
        return [UIColor colorWithRed:MAX(r-0.05, 0.0) green:MAX(g-0.1, 0.0) blue:MAX(b-0.1, 0.0) alpha:MAX(a-0.1, 0.0)];
    }
    return nil;
}

-(void)animateGauge
{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
   // rotate.delegate = self;
    CGFloat rotateRadianValueTo = [self degreeToRadian:rotateDegreeValueTo];
    if(rotateStartValue)
    {
        rotate.fromValue = @(M_PI_2);
        rotate.toValue = @(rotateRadianValueTo);
        rotateFromPreviosValue = rotateRadianValueTo;
        
        rotateStartValue = NO;
    }
    else
    {
        rotate.fromValue =@(rotateFromPreviosValue);
        rotate.toValue = @(rotateRadianValueTo);
        rotateFromPreviosValue = rotateRadianValueTo;
    }
    rotate.duration = rotateAnimationSpeed; // time of animation
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotate.fillMode = kCAFillModeForwards;
    rotate.removedOnCompletion = NO;
    [shapeLayer addAnimation:rotate
                            forKey:@"myRotationAnimation"];
    
}
-(void)stopAnimateGauge
{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
   // rotate.delegate = self;
    rotate.fromValue = @(rotateFromPreviosValue);
    rotate.toValue = @(M_PI_2);
    rotateStartValue = YES;
    rotate.duration = rotateAnimationSpeed; // time of animation
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotate.fillMode = kCAFillModeForwards;
    rotate.removedOnCompletion = NO;
    [shapeLayer addAnimation:rotate
                      forKey:@"myRotationAnimation"];
    
}
-(void)animateGaugeMarker
{

    CGFloat toValue = [self degreeToRadian:markerDegreeValueTo];
    CABasicAnimation *animateMarker = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
   // animateMarker.delegate = self;
    animateMarker.fromValue = @(markerPreviosDegreeValue);
    animateMarker.toValue = @(toValue);
    animateMarker.duration = rotateAnimationSpeed;
   // animateMarker.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animateMarker.fillMode = kCAFillModeForwards;
    animateMarker.removedOnCompletion = NO;
    [marker addAnimation:animateMarker
                      forKey:@"myRotationAnimation"];
    markerPreviosDegreeValue = toValue;
}
-(CGFloat)degreeToRadian:(CGFloat)degree
{
    //90 is the offset,needle is drawn straight dowwn and then transformed to the
    //right by 90 degrees(need the 90 degress to be shifted when calculating)
    //This only applies to animation needle
    
    return (degree + 90) * (M_PI/180);
}
-(CGFloat)markerDegreeToRadian:(CGFloat)degree
{
    return (degree + 180) * (M_PI/180);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}
*/

@end
