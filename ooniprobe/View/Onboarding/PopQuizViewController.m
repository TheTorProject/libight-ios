#import "PopQuizViewController.h"

@interface PopQuizViewController ()

@end

@implementation PopQuizViewController
@synthesize question_number;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.trueButton addTarget:self action:@selector(answer:) forControlEvents:UIControlEventTouchUpInside];
    [self.trueButton setTitle:NSLocalizedString(@"Onboarding.PopQuiz.True", nil) forState:UIControlStateNormal];
    
    [self.falseButton addTarget:self action:@selector(answer:) forControlEvents:UIControlEventTouchUpInside];
    [self.falseButton setTitle:NSLocalizedString(@"Onboarding.PopQuiz.False", nil) forState:UIControlStateNormal];
    
    [self.trueButton setBackgroundColor:[UIColor colorNamed:@"color_green7"]];
    [self.falseButton setBackgroundColor:[UIColor colorNamed:@"color_red7"]];

    [self.closeView addTarget:self action:@selector(dismissPopup) forControlEvents:UIControlEventTouchUpInside];
    
    self.cointainerWindow.layer.cornerRadius = 12;
    self.cointainerWindow.layer.masksToBounds = true;
    [self.cointainerWindow setBackgroundColor:[UIColor colorNamed:@"color_blue5"]];
    
    [self.titleLabel setText:NSLocalizedString(@"Onboarding.PopQuiz.Title", nil)];

    [self reloadQuestion];
}

- (void)reloadQuestion{
    NSMutableAttributedString *questionTitle;
    NSMutableAttributedString *questionText;
    if (question_number == 1){
        questionTitle = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Onboarding.PopQuiz.1.Title", nil)];
        questionText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Onboarding.PopQuiz.1.Question", nil)];
    }
    else if (question_number == 2){
        questionTitle = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Onboarding.PopQuiz.2.Title", nil)];
        questionText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Onboarding.PopQuiz.2.Question", nil)];
    }
    else {
        //should not happen
        assert(false);
    }
    [questionTitle addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"FiraSans-Regular" size:17]
                           range:NSMakeRange(0, questionTitle.length)];

        
    [questionText addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"FiraSans-SemiBold" size:17]
                          range:NSMakeRange(0, questionText.length)];
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n\n"];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr appendAttributedString:questionTitle];
    [attrStr appendAttributedString:newLine];
    [attrStr appendAttributedString:questionText];
    [self.textLabel setAttributedText:attrStr];
}

- (void)nextQuestion {
    if (question_number == 1){
        question_number = 2;
        [self reloadQuestion];
    }
    else if (question_number == 2){
        question_number = 3;
        [self dismissPopup];
    }
}

-(void)dismissPopup{
    [self dismissViewControllerAnimated:YES completion:^{
        //set back question number
        [_delegate setQuestion_number:question_number];
    }];
}

-(IBAction)answer:(id)sender{
    UIButton *buttonPressed = (UIButton*)sender;
    BOOL answer = false;
    if (buttonPressed.tag == 1)
        answer = true;
    LOTAnimationView *animation;
    if (!answer){
        animation = [LOTAnimationView animationNamed:@"crossMark"];
        [animation setBackgroundColor:[UIColor colorNamed:@"color_red7"]];
    }
    else {
        animation = [LOTAnimationView animationNamed:@"checkMark"];
        [animation setBackgroundColor:[UIColor colorNamed:@"color_green7"]];
    }
    animation.contentMode = UIViewContentModeScaleAspectFit;
    [self.cointainerWindow addSubview:animation];
    CGRect c = self.cointainerWindow.bounds;
    animation.frame = CGRectMake(0, 0, c.size.width, c.size.height);
    [self.view setNeedsLayout];
    [animation playWithCompletion:^(BOOL animationFinished) {
        if (!answer)
            [self performSegueWithIdentifier:@"toWrongAnswer" sender:self];
        else
            [self nextQuestion];
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [animation removeFromSuperview];
        });
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toWrongAnswer"]){
        WrongAnswerViewController *vc = (WrongAnswerViewController * )segue.destinationViewController;
        [vc setDelegate:self];
        [vc setQuestion_number:question_number];
    }
}

@end
