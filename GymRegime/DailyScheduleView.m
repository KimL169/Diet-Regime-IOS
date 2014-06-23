//
//  DailyScheduleView.m
//  GymRegime
//
//  Created by Kim on 19/06/14.
//  Copyright (c) 2014 Kim. All rights reserved.
//

#import "DailyScheduleView.h"
#import "DietPlanDay.h"
#import "DietPlan+Helper.h"
#import "CalorieCalculator.h"

@interface DailyScheduleView ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *deficitSurplusLabel;
@property (strong, nonatomic) IBOutlet UILabel *proteinLabel;
@property (strong, nonatomic) IBOutlet UILabel *carbLabel;
@property (strong, nonatomic) IBOutlet UILabel *fatLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *calorieValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *proteinGramValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *carbGramValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *fatGramValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *deficitSurplusValueLabel;

@property (strong, nonatomic) IBOutlet UILabel *proteinPercentageLabel;
@property (strong, nonatomic) IBOutlet UILabel *carbPercentageLabel;
@property (strong, nonatomic) IBOutlet UILabel *fatPercentageLabel;


@property (strong, nonatomic) DietPlan *dietPlan;

@property (nonatomic) float proteinPercentage;
@property (nonatomic) float carbPercentage;
@property (nonatomic) float fatPercentage;


@end

@implementation DailyScheduleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //set the labels
        self.backgroundColor = [UIColor darkGrayColor];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(9, 40, 221, 21)];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:_nameLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(52, 20, 164, 20)];
        _titleLabel.text = @"Diet plan for today!";
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_titleLabel];
        
        self.deficitSurplusLabel = [[UILabel alloc]initWithFrame:CGRectMake(141, 73, 89, 21)];
        _deficitSurplusLabel.text = @"deficit/surplus";
        _deficitSurplusLabel.textColor = [UIColor whiteColor];
        _deficitSurplusLabel.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:_deficitSurplusLabel];
        
        self.deficitSurplusValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(170, 102, 68, 21)];
        _deficitSurplusValueLabel.textColor = [UIColor whiteColor];
        _deficitSurplusValueLabel.textAlignment = NSTextAlignmentLeft;
        _deficitSurplusValueLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_deficitSurplusValueLabel];
        
        self.caloriesLabel = [[UILabel alloc]initWithFrame:CGRectMake(9, 102, 68, 21)];
        _caloriesLabel.text = @"Calories:";
        _caloriesLabel.textColor = [UIColor whiteColor];
        _caloriesLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:_caloriesLabel];
        
        self.proteinLabel = [[UILabel alloc]initWithFrame:CGRectMake(9, 142, 68, 21)];
        _proteinLabel.text = @"Protein:";
        _proteinLabel.textColor = [UIColor whiteColor];
        _proteinLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:_proteinLabel];
        
        self.carbLabel = [[UILabel alloc]initWithFrame:CGRectMake(9, 171, 68, 21)];
        _carbLabel.text = @"Carbs:";
        _carbLabel.textColor = [UIColor whiteColor];
        _carbLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:_carbLabel];
        
        self.fatLabel = [[UILabel alloc]initWithFrame:CGRectMake(9, 200, 68, 21)];
        _fatLabel.text = @"Fat:";
        _fatLabel.textColor = [UIColor whiteColor];
        _fatLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:_fatLabel];
        
        self.calorieValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 102, 68, 21)];
        _calorieValueLabel.textColor = [UIColor whiteColor];
        _calorieValueLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_calorieValueLabel];
        
        self.proteinGramValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 142, 68, 21)];
        _proteinGramValueLabel.textColor = [UIColor whiteColor];
        _proteinGramValueLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_proteinGramValueLabel];
        
        self.carbGramValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 171, 68, 21)];
        _carbGramValueLabel.textColor = [UIColor whiteColor];
        _carbGramValueLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_carbGramValueLabel];
        
        self.fatGramValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 200, 68, 21)];
        _fatGramValueLabel.textColor = [UIColor whiteColor];
        _fatGramValueLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_fatGramValueLabel];
        
        self.proteinPercentageLabel = [[UILabel alloc]initWithFrame:CGRectMake(162, 142, 68, 21)];
        _proteinPercentageLabel.textColor = [UIColor whiteColor];
        _proteinPercentageLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_proteinPercentageLabel];
        
        self.carbPercentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(162, 171, 68, 21)];
        _carbPercentageLabel.textColor = [UIColor whiteColor];
        _carbPercentageLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_carbPercentageLabel];
        
        self.fatPercentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(162, 200, 68, 21)];
        _fatPercentageLabel.textColor = [UIColor whiteColor];
        _fatPercentageLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_fatPercentageLabel];
        
        UILabel *tapToClose = [[UILabel alloc]initWithFrame:CGRectMake(0, 264, 250, 21)];
        tapToClose.text = @"tap to close";
        tapToClose.textColor = [UIColor lightGrayColor];
        tapToClose.font = [UIFont systemFontOfSize:11];
        tapToClose.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tapToClose];
    }
    return self;
}

- (void)getPercentagesFromDietPlanDay: (DietPlanDay *)day {
    _proteinPercentage =  (([day.proteinGrams floatValue] * 4) / [day.calories floatValue]) * 100;
    _carbPercentage =  (([day.carbGrams floatValue] * 4) / [day.calories floatValue]) * 100;
    _fatPercentage =  (([day.fatGrams floatValue] * 9) / [day.calories floatValue]) * 100;
}


- (void)setLabelsForDietPlan: (DietPlan *)dietPlan {
    
    //get the correct dietplan day (see dietplan helper).
    DietPlanDay *day = [dietPlan returnDietPlanDayForDate:[NSDate date]];
    //if a diet plan day exists set labels to them.
    if (day) {
        
        //set the value percentages.
        _nameLabel.text = [NSString stringWithFormat:@"%@", day.name];
        _calorieValueLabel.text = [NSString stringWithFormat:@"%d gr", [day.calories intValue]];
        _proteinGramValueLabel.text = [NSString stringWithFormat:@"%d gr", [day.proteinGrams intValue]];
        _carbGramValueLabel.text = [NSString stringWithFormat:@"%d gr", [day.carbGrams intValue]];
        _fatGramValueLabel.text = [NSString stringWithFormat:@"%d gr", [day.fatGrams intValue]];
        
        CalorieCalculator *calculator = [[CalorieCalculator alloc]init];
        
        NSNumber *maintenance = [[calculator returnUserMaintenanceAndBmr] valueForKey:@"maintenance"];
        if ([maintenance integerValue] != 0) {
            int deficitSurplus = ([day.calories intValue] - [maintenance intValue]);
            
            _deficitSurplusValueLabel.text = [NSString stringWithFormat:@"%d", deficitSurplus];

        } else {
            _deficitSurplusValueLabel.text = @"-";

        }
        
        //set the percentage labels
        [self getPercentagesFromDietPlanDay:day];
        
        _proteinPercentageLabel.text = [NSString stringWithFormat:@"%.1f%%", _proteinPercentage];
        _carbPercentageLabel.text = [NSString stringWithFormat:@"%.1f%%", _carbPercentage];
        _fatPercentageLabel.text = [NSString stringWithFormat:@"%.1f%%", _fatPercentage];

    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
