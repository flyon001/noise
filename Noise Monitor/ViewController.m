//
//  ViewController.m
//  Noise Monitor
//
//  Created by Frank Lyons on 8/10/16.
//  Copyright © 2016 Frank Lyons. All rights reserved.
//

#import "ViewController.h"
#import "Gauge.h"


@interface ViewController ()
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    Gauge *gauge;
    NSTimer *timer;
    float updatingValueSpeed;
    float animationSpeed;
    float level;        //conversion value from decibles, 0dB to 160 dB (ranging from quiet to loud)
    float decibels;     //value of averagePowerForChannel:0 (-120dB to 0dB,ranging from quite to loud)
    float peakdB;       //max decibel reading
    bool bg;            //relates to program being in background
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    peakdB = 0.0;
    level = 0.0;
    updatingValueSpeed = .07;
    
    //init gauge and set it to view on screen
    gauge = [[Gauge alloc]initWithFrame:CGRectMake(0, 0, 250, 150)];
    gauge.rotateAnimationSpeed = .07;
    [_gaugeBox addSubview:gauge.gaugeView];
    gauge.markerPreviousDegreeValue = _sliderSelection.value;
    gauge.markerDegreeValueTo =_sliderSelection.value;
    [gauge animateGaugeMarker];
    
   
    //notify view controller app is in the background,see custom method
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appInBg:) //custom method
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    //notify view controller app is in the foreground, see custom method
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appInFg:) //custom method
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    NSError *error = nil;
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"]; //not recording to nothing!
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(error != nil)
    {
        NSLog(@"Error: Session setCategory:AVAudioSessionCategoryPlayAndRecord failed");
    }
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    recorder =[[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    if(error != nil)
    {
        NSLog(@"ERROR: Recorder failed to alloc");
    }

    recorder.delegate =self;
    recorder.meteringEnabled = YES;
    
    
    [recorder prepareToRecord];
    
    //setup for player
    NSString *path = [NSString stringWithFormat:@"%@/alarm.wav", [[NSBundle mainBundle] resourcePath]];
    NSURL *filePath =[NSURL fileURLWithPath:path];
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:filePath error:&error];
    if (error != nil)
    {
        NSLog(@"ERROR in player init");
    }
    
    [player prepareToPlay];
    
    //sound will come out of speaker, gain control of volume from device
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error != nil)
    {
        NSLog(@"ERROR in overideSpeaker");
    }
    

    
    //button configurations for record
    [_recordButton setTitle:@"Begin Monitoring" forState:UIControlStateNormal];
    self.recordButton.layer.borderWidth = 1;
    self.recordButton.layer.cornerRadius = 16.0f;
    [_recordButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.recordButton.layer.borderColor = [[UIColor blueColor] CGColor];
    
    //button cpmfigurations for max reset button
    [_maxRest setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.maxRest.layer.borderColor = [[UIColor blueColor]CGColor];
    self.maxRest.layer.borderWidth = 1;
    self.maxRest.layer.cornerRadius = 16.0f;
    
    //set textbox init values
    self.sliderValue.text = [NSString stringWithFormat:@"%.f", self.sliderSelection.value];
    self.currentdBLabel.text = [NSString stringWithFormat:@"%.f", level];
    self.highestdB.text = [NSString stringWithFormat:@"%.f",peakdB ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)recordButton:(id)sender
{
    if(!recorder.recording)
    {
        [self startMonitoring];

    }
    else
    {
        [self stopMonitoring];
    }
}

- (IBAction)slider:(id)sender
{
    gauge.markerDegreeValueTo = self.sliderSelection.value;
    [gauge animateGaugeMarker];
    self.sliderValue.text = [NSString stringWithFormat:@"%.f", self.sliderSelection.value];
    
}

- (IBAction)maxReset:(id)sender
{
    peakdB = 0;
    NSString *zero = [NSString stringWithFormat:@"%i",(int)peakdB];
    self.highestdB.text = zero;
}

-(void)updateMetering:(NSTimer*)timer
{
    [recorder updateMeters];
    decibels = [recorder averagePowerForChannel:1];
    
        [self decibelConversion];
    //level has to be a number
    if (!isnan(level))
    {
        
        [self highestDecibel];
        gauge.rotateDegreeValueTo = level;
        [gauge animateGauge];
        
        //place current value into textbox
        NSString *currentdbValue = [NSString stringWithFormat:@"%.f",level];
        self.currentdBLabel.text = currentdbValue;
        
        //place highest decibel into textbox
        NSString *max = [NSString stringWithFormat:@"%.f",peakdB];
        self.highestdB.text = max;
    }
    //check if alarm needs to be triggered
    if (level > self.sliderSelection.value)
    {
    
        [self alarmTrigger];
    }
    
}
/*float decibles is used to make a new decibel reading called level, where 0 is
 quiet and 160 is loud*/
-(void)decibelConversion
{
    const float minDecibels = -60.0f; //set from a quite room.

    if (decibels < decibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    level = level * 120.0f;
    

}
-(void)highestDecibel
{
    if (level > peakdB)
    {
        peakdB = level;
       
    }
}
-(void)startMonitoring
{
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:&error];
    if (error != nil)
    {
        NSLog(@"ERROR: Session setActive:Yes failed");
    }
    
    //start recording
    [recorder record];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:updatingValueSpeed //per second (updating speed)
                                             target:self
                                           selector:@selector(updateMetering:) //goto custom method for timer
                                           userInfo:nil
                                            repeats:YES];
    
    //change state of button while recording
    [_recordButton setTitle:@"Stop Monitoring" forState:UIControlStateNormal];
    
}
-(void)stopMonitoring
{
    NSError *error = nil;
    [recorder stop];
    
    //Stop updating timer
    [timer invalidate];
    timer = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:&error];
    if(error != nil)
    {
        NSLog(@"ERROR: Session setActive:NO failed");
    }
    [_recordButton setTitle:@"Resume Monitoring" forState:UIControlStateNormal];
    
    //reset current decibles label output
    decibels = 0;
    NSString* zero = [NSString stringWithFormat:@"%i",(int)decibels];
    self.currentdBLabel.text = zero;
    
    //animation on guage must be at 0
    [gauge stopAnimateGauge];
}
-(void)alarmTrigger
{
    if (bg)
    {
        
        [recorder pause]; //must pause to play notification sound
        //format alert body message with decibel limit that set off notification
        NSString *message = [NSString stringWithFormat:@"%.f dB - Excceded Decibel Limit! ",level];
        UILocalNotification* localNotif = [[UILocalNotification alloc]init];
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:1]; //per Seconds
        //localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.soundName = @"alarm.caf";
        localNotif.alertBody = message;
        localNotif.repeatInterval = NO;
        
        [[UIApplication sharedApplication]scheduleLocalNotification:localNotif];
        sleep(5); //make sure wait long enough or else local notification sound will be read as decibel reading from device speaker
        [recorder record];
    }
    else
    {
        [self stopMonitoring];
        player.numberOfLoops=50; //alarm is not infinite
        [player play];
        //make sure play starts before message,app sometimes does not play alert sound
        while (!player.playing)
        {
            [player play];
        }
        
        //alert configuration
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Noise Monitor"
                                                                       message:@"Exceeded Decibel Limit!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        //button configuration for alert
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Press to Deactivate Alarm"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {[player stop];}];
        [alert addAction:action];
        
        //show alert
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}
//custom method to signal app is in background, signaled by NSNotification in ViewDidLoad
-(void)appInBg:(NSNotification *) note
{
    bg = true;
}
//custom method to siganl app is in foreground, signaled by NSNotification in ViewDidLoad
-(void)appInFg:(NSNotification *) note
{
    bg = false;
}


@end
