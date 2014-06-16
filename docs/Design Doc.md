Diet-Regime-IOS
==============



# Models

## Database Entities

#### BodyStat
- belongs_to DietPlan
    - date
    - weight
    - bodyfat
    - calories
    - protein
    - fat
    - carbs
    - waistMeasurement
    - calfMeasuremnt
    - chestMeasurement
    - thighMeasurement
    - armMeasurement
    - shoulderMeasurement
    - hipMeasurement

#### DietPlan
- has_many BodyStats
- has_many DietPlanDays
- has_many DietGoals
    - startDate
    - endDate
    - name

#### DietPlanDay
- belongs_to DietPlan
    - name
    - calories
    - protein
    - carbs
    - fat

#### DietGoal
- belongs_to DietPlan
    - weightGoal
    - bodyfatGoal
    - bmiGoal
    - lbmGoal
    - waistGoal
    - chestGoal
    - calfGoal
    - thighGoal
    - shoulderGoal
    - hipGoal
    - armGoal


## Other Classes

#### CoreDataHelper
Helperclass for core data methods pertaining to the app.

#### HealthKitDataHelper
Helperclass for healthkit syncing.

#### CalorieCalculator
class containing the caloric equation and customization methods

#### GoalColorScheme
class with methods for the custom colorthemes as user approaches goals

#### UITheme
class containing overal UIAppearence themes.


## Categories

#### NSDate + Utilities

#### DietPlan + Helper

#### BodyStat + Helper


# Controllers


## Core Controllers

#### CoreTableViewController
Parent class to tableviewcontrollers, contains core methods pertaining to the tableviewcontrollers.

#### CoreViewController
Parent class to viewcontrollers, contains core methods pertaining to the viewcontrollers.

## Logbook

#### BSAddViewController
Handles the user adding logbook entries

#### BSEditViewController
Handles the user editing logbook entries

#### BodyStatTableViewController
The actual logbook that will contain bodystat entries as well as DietPlan start/end entries with multiple options for displaying.

#### ProgressPhotoViewController
The selection view that has users select progress photos from their photo library or take a picture with the iphone camera.

#### ProgressPhotoSelectionViewController
The progressphoto overview. Users will have the option to view all progress photos or only those pertaining to the current dietplan.


## Statistics


#### BSProfileViewController
Where the user can fill in his/her personal body profile (height, age, gender, activity level) in order for the caloric equations to work.

#### BSWeeklyProgressTableViewController
Tableview that shows the users progress on weekly intervals.

#### BSStatisticsTableViewController
Shows user statistics: current weight/bodyfat/measurements, his/her TDEE (total daily energy expenditure), BMR (basal metabolic rate), BMI (body mass index) as well as progress towards goals set in his/her diet plan and recommended changes to the caloric calculation equation according to the app.


## ChartView


#### ChartViewController
Shows a chart of the users progress over time on caloric intake, bodyfat or bodyweight.


## Diet Planner


#### DietPlannerTableViewController
Selection menu of the dietplanner section. User can either create a new diet plan, adjust the existing plan or go to the dietplan archive.

#### DietPlanTableViewController
Here the user can create his diet plan (insert end/startdate, goals, current stats, progress photo ->segue to insert diet plan days). It also shows the estimated caloric deficit/surplus and weight gain/loss on this diet plan once the user has finished inserting his diet plan days.

#### DietPlanEditTableViewController
The edit controller for the current diet plan. Users can have only one currently running dietplan.

#### DietPlanDaysTableViewController
Shows a table of the dietplandays the user has created for a dietplan. He can also rearrange and delete the days.

#### DietPlanDayViewController
Here the user can specify a day in his diet that will be 'cycled' throughout the duration of the dietplan. The user can cycle up to 14 days. For example, he can specify a 'workout' and a 'rest' day with specific caloric and macro nutrient intakes on both days.


#### DietPlanArchiveTableViewController
Shows a tableview of dietplans that have been finished.

#### DietPlanArchiveDetailsTableViewController
Shows the details of a specific dietplan, the results achieved.

#### DietPlanEstimationsTableViewController
Shows a table of the progress a user is expected to make on a specific diet he set up according to the calculation methods.


## Settings Controllers


#### MainSettingsTableViewController
Settings menu where the user can adjust basic settings (like units/measurements, color theme...) and segue to caloric settings and export settings.

#### CalorieSettingsTableViewController
Settings menu where the user can fully adjust the equations used to derive his BMR and TDEE

#### ExportSettingsTableViewController
Settings menu where the user can export his diet to his email or sync the app up to the healthkit for iOS 8


# Custom TableView Cells:

#### Diet Plan tableviewcell

#### Body Stat tableviewcell

#### Diet Plan Day tableviewcell




Objective - C Style Guide 
========

#### Spacing And Formatting

###### Spaces vs. Tabs
Use only spaces, and indent 4 spaces at a time.

###### Line Length
The maximum line length for Objective-C and Objective-C++ files is 100 columns.

###### Method Declarations and Definitions
One space should be used between the - or + and the return type, and no spacing in the parameter list except between parameters.

###### Method Invocations
Method invocations should be formatted much like method declarations. When there's a choice of formatting styles, follow the convention already used in a given source file.

###### Exceptions
Format exceptions with each @ label on its own line and a space between the @ label and the opening brace ({), as well as between the @catch and the caught object declaration.

###### Protocols
There should not be a space between the type identifier and the name of the protocol encased in angle brackets.

###### Blocks
Code inside blocks should be indented four spaces.

#### Naming

###### File Names
File names should reflect the name of the class implementation that they contain—including case. Follow the convention that your project uses. 

###### Class Names
Class names (along with category and protocol names) should start as uppercase and use mixed case to delimit words.

###### Category Names
Category names should start with a 2 or 3 character prefix identifying the category as part of a project or open for general use. The category name should incorporate the name of the class it's extending.

###### Objective-C Method Names
Method names should start as lowercase and then use mixed case. Each named parameter should also start as lowercase.

###### Variable Names
Variables names start with a lowercase and use mixed case to delimit words. Instance variables have leading underscores. For example: myLocalVariable, _myInstanceVariable.

####Comments
Try writing sensible names to types and variables so your code is self explainatory. 
When writing your comments, write for your audience: the next contributor who will need to understand your code. Be generous—the next one may be you!

######File Comments
A file may optionally start with a description of its contents.

######Declaration Comments
Every interface, category, and protocol declaration should have an accompanying comment describing its purpose and how it fits into the larger picture.

######Implementation Comments
Use vertical bars to quote variable names and symbols in comments rather than quotes or naming the symbol inline.

######Object Ownership
Make the pointer ownership model as explicit as possible when it falls outside the most common Objective-C usage idioms.




####Cocoa and Objective-C Features

######Instance Variables In Headers Should Be @private
Instance variables should typically be declared in implementation files or auto-synthesized by properties. When ivars are declared in a header file, they should be marked @private.

######Identify Designated Initializer
Comment and clearly identify your designated initializer.

######Override Designated Initializer
When writing a subclass that requires an init... method, make sure you override the superclass' designated initializer.

######Overridden NSObject Method Placement
It is strongly recommended and typical practice to place overridden methods of NSObject at the top of an @implementation.

######Initialization
Don't initialize variables to 0 or nil in the init method; it's redundant.

######Keep the Public API Simple
Keep your class simple; avoid "kitchen-sink" APIs. If a method doesn't need to be public, don't make it so. Use a private category to prevent cluttering the public header.

######Use Root Frameworks
Include root frameworks over individual files.

######Properties
Use of the @property directive is preferred, with the following caveat: properties are an Objective-C 2.0 feature which will limit your code to running on the iPhone and Mac OS X 10.5 (Leopard) and higher. Dot notation is allowed only for access to a declared @property.

######Interfaces Without Instance Variables
Omit the empty set of braces on interfaces that do not declare any instance variables.

######Automatically Synthesized Instance Variables
Use of automatically synthesized instance variables is preferred. Code that must support earlier versions of the compiler toolchain (Xcode 4.3 or earlier or when compiling with GCC) or is using properties inherited from a protocol should prefer the @synthesize directive.



