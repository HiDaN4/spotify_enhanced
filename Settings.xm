#import "headers.h"


// ## Mark - Section Settings Header
@interface SPTTableViewSectionHeaderView : UIView


-(void)setSize:(NSInteger)size;

-(void)setTitle:(NSString*)title;


+(CGFloat)preferredHeight;


@end

// ## Mark - Setting Table View Controller

@interface SettingsViewController : UITableViewController

@property (nonatomic, strong) NSString* pageIdentifier;
@property (nonatomic, strong) NSString* viewURI;

@property (nonatomic, strong) NSMutableArray* sections;

@property (nonatomic, assign) double amount;
@property (nonatomic, assign) BOOL shouldDisplaySettingCell;

@end


static void loadPrefs() {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"isEnabled"] == nil) {
        // first run
        [defaults setBool:SGTW_isEnabled forKey:@"isEnabled"];
        [defaults setBool:SGTW_alwaysScreenOn forKey:@"always_on"];
        [defaults setDouble:SGTW_AmountToForward forKey:@"amount_forward"];
        [defaults setDouble:SGTW_AmountToRewind forKey:@"amount_rewind"];
    } else {
        SGTW_isEnabled = [defaults boolForKey:@"isEnabled"];
        SGTW_alwaysScreenOn = [defaults boolForKey:@"always_on"];
        SGTW_AmountToForward = [defaults doubleForKey:@"amount_forward"];
        SGTW_AmountToRewind = [defaults doubleForKey:@"amount_rewind"];
    }    

}


static void updatePrefs() {

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:SGTW_isEnabled forKey:@"isEnabled"];
    [defaults setBool:SGTW_alwaysScreenOn forKey:@"always_on"];
    [defaults setDouble:SGTW_AmountToForward forKey:@"amount_forward"];
    [defaults setDouble:SGTW_AmountToRewind forKey:@"amount_rewind"];

}


// ## Mark - INIT

%ctor {
    loadPrefs();
    if (SGTW_alwaysScreenOn == YES && [[UIApplication sharedApplication] isIdleTimerDisabled] == NO)
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}




static NSString* kPageSettingURI = @"spotify:config:playback";

static NSInteger kPageSettingSectionIndex = 1;


@interface NSNumber (CGFloatAdditions)

+ (NSNumber*)numberWithCGFloat: (CGFloat)value;
- (CGFloat)CGFloatValue;

@end


@implementation NSNumber (CGFloatAdditions)

+ (NSNumber*)numberWithCGFloat: (CGFloat)value
{
#if CGFLOAT_IS_DOUBLE
    return [NSNumber numberWithDouble: (double)value];
#else
    return [NSNumber numberWithFloat: value];
#endif
}

- (CGFloat)CGFloatValue
{
#if CGFLOAT_IS_DOUBLE
    return [self doubleValue];
#else
    return [self floatValue];
#endif
}


@end



%hook SettingsViewController

%property (nonatomic, assign) BOOL shouldDisplaySettingCell;
%property (nonatomic, assign) double amount;

-(void)viewDidLoad {

    %orig;
    
    if ([self.viewURI isEqualToString:kPageSettingURI]) {
        self.shouldDisplaySettingCell = YES;
        NSMutableArray* sections = [self sections];
        
        [sections insertObject:kPageSettingURI atIndex:kPageSettingSectionIndex];
        [self setAmount:0];
        
    } else {
        self.shouldDisplaySettingCell = NO;
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.shouldDisplaySettingCell == YES && section == kPageSettingSectionIndex)
        return SGTW_isEnabled ? 4 : 1;
    
    return %orig;
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.shouldDisplaySettingCell == YES && section == kPageSettingSectionIndex) {
        return [NSClassFromString(@"SPTTableViewSectionHeaderView") preferredHeight];
    }
    
    return %orig;
}


-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* header = nil;
    
    if (self.shouldDisplaySettingCell == YES && section == kPageSettingSectionIndex) {
        
        SPTTableViewSectionHeaderView* spHeader = (SPTTableViewSectionHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SpotifyGesturesSettingHeader"];
        if (spHeader == nil) {
            spHeader = [[objc_getClass("SPTTableViewSectionHeaderView") alloc] initWithReuseIdentifier:@"SpotifyGesturesSettingHeader"];
            CGRect frame = CGRectMake(0, 0, tableView.bounds.size.width, [NSClassFromString(@"SPTTableViewSectionHeaderView") preferredHeight]);
            [spHeader setFrame:frame];
            [spHeader setTitle:@"Spotify with Gestures by HiDaN"];
        }
        header = spHeader;
    } else {
        header = %orig;
    }
    
    return header;
    
}



-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (self.shouldDisplaySettingCell == YES && indexPath.section == kPageSettingSectionIndex) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SpotifyGesturesSettingCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SpotifyGesturesSettingCell"];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Enabled";
            cell.detailTextLabel.text = nil;
            
            UISwitch* onOffSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [onOffSwitch addTarget:self action:@selector(onOff_tweak) forControlEvents:UIControlEventValueChanged];
            [onOffSwitch setOn:SGTW_isEnabled];
            cell.accessoryView = onOffSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"FastForward by";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ s", @(SGTW_AmountToForward)];
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Rewind by";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ s", @(SGTW_AmountToRewind)];
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Always On Screen";
            cell.detailTextLabel.text = nil;
            UISwitch* onOffSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [onOffSwitch addTarget:self action:@selector(onOffAlwaysScreenOn) forControlEvents:UIControlEventValueChanged];
            [onOffSwitch setOn:SGTW_alwaysScreenOn];
            cell.accessoryView = onOffSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }
    return %orig;
    
}



%new
-(void)onOff_tweak {
    SGTW_isEnabled = !SGTW_isEnabled;
    
    NSArray* indexPaths = @[
                            [NSIndexPath indexPathForRow:1 inSection:kPageSettingSectionIndex],
                            [NSIndexPath indexPathForRow:2 inSection:kPageSettingSectionIndex],
                            [NSIndexPath indexPathForRow:3 inSection:kPageSettingSectionIndex]
                            ];
    
    [self.tableView beginUpdates];
    
    if (SGTW_isEnabled) {
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
        
    } else {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    [self.tableView endUpdates];
    updatePrefs();
    
}



%new
-(void)onOffAlwaysScreenOn {
   SGTW_alwaysScreenOn = !SGTW_alwaysScreenOn;
    if (SGTW_alwaysScreenOn == YES && [[UIApplication sharedApplication] isIdleTimerDisabled] == NO)
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    else if (SGTW_alwaysScreenOn == NO)
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    updatePrefs(); 
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shouldDisplaySettingCell == YES && indexPath.section == kPageSettingSectionIndex) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (indexPath.row == 0 || indexPath.row == 3) // enabled or always on screen do not need alerts
            return;
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"New value" message:@"Enter new value in seconds" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (alert.textFields.firstObject != nil && alert.textFields.firstObject.text != nil) {
                if (indexPath.row == 1)
                    SGTW_AmountToForward = alert.textFields.firstObject.text.doubleValue;
                else if (indexPath.row == 2)
                    SGTW_AmountToRewind = alert.textFields.firstObject.text.doubleValue;
                
                updatePrefs();
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"10";
        }];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        %orig;
    }
    
}



%end
