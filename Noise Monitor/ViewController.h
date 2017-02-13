//
//  ViewController.h
//  Noise Monitor
//
//  Created by Frank Lyons on 8/10/16.
//  Copyright © 2016 Frank Lyons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController : UIViewController<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *currentdBLabel;
@property (weak, nonatomic) IBOutlet UILabel *sliderValue;
@property (weak, nonatomic) IBOutlet UISlider *sliderSelection;
@property (weak, nonatomic) IBOutlet UILabel *highestdB;
@property (weak, nonatomic) IBOutlet UIButton *maxRest;
@property (weak, nonatomic) IBOutlet UIView *gaugeBox;

@end

