//
//  AppearanceView.m
//   Renote
//
//  Created by M Raheel Sayeed on 24/04/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "AppearanceView.h"
#import "UIFont+EditorFontContentSize.h"

static NSString * const themeNameKey = @"themeName";
@interface AppearanceView () <UITableViewDataSource, UITableViewDelegate>
{
    NSNumber * _isGrid;
    NSDictionary * fontNameMap;
    NSArray * fontFamilies;
}

@property (nonatomic, strong) UITableView * fontTable;
@property (nonatomic, strong) UISegmentedControl * sizeSegmentControl;
@property (nonatomic, strong) UISegmentedControl * themeControl;
@property (nonatomic, strong) UITextView * sampleTextView;
@property (nonatomic, strong) NSArray * fontNames;
@property (nonatomic, strong) UIView * baseView;
@property (nonatomic) UIButton * btn_SystemFont;

@property (nonatomic, strong) NSNumber * expfontSize;
@property (nonatomic, strong) NSString * themeName;
@property (nonatomic, strong) NSString * expFontFamily;

@end

@implementation AppearanceView


- (instancetype)initWithFontNames:(NSArray *)fontNames
{
    self = [super initWithFrame:CGRectMake(0, 0, 295, 500.f)];
    if(self)
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        _expfontSize = [defaults objectForKey:kSettings_EditorFontSize];
        _isGrid      = [defaults objectForKey:kSettings_MainListStyle_Grid];
        _expFontFamily = [defaults objectForKey:kSettings_EditorFontFamily];
        
      
        
        
        _themeName   = [defaults objectForKey:themeNameKey];
        
        self.title = @"Style & Note Font";
        _fontNames = fontNames;
        self.buttonTitles = @[@"Change", @"Default"];
        
    
        
        
        fontNameMap = @{@"Lato-Medium" :@"Lato",
                        @"CourierPrime":@"Courier Prime",
                         @"SourceSansPro-Regular":@"Source Sans Pro",
                         @"DejaVuSansMono": @"DejaVu Sans Mono" ,
                       @"InconsolataLGC-Medium": @"Inconsolata LGC"  ,
                        @"HoeflerText-Regular":@"Hoefler Text" ,
                        @"Sintony" : @"Sintony",
                        @"Verdana" : @"Verdana",
                        @"Avenir"  : @"Avenir",
                        @"HelveticaNeue": @"Helvetica Neue"
                        };
        
        _fontNames = [fontNameMap allValues];

    }
    return self;
}



- (NSString *)sampleText
{
    return [NSString stringWithFormat:@"%@: This is how font will appear.", _expFontFamily];
}
- (NSAttributedString *)sampleAttributedText
{
    
    NSMutableAttributedString * m = [[NSMutableAttributedString alloc] initWithString:[self sampleText]];
    [m addAttribute:NSFontAttributeName value:[UIFont editorFontWithFamily:_expFontFamily bold:YES size:_expfontSize.floatValue] range:NSMakeRange(0, _expFontFamily.length)];
    [m addAttribute:NSFontAttributeName value:[UIFont editorFontWithFamily:_expFontFamily bold:NO size:_expfontSize.floatValue] range:NSMakeRange(_expFontFamily.length, [self sampleText].length - _expFontFamily.length)];
    return [m copy];
}


- (UIView *)containerView
{
    if(_baseView) return _baseView;
    
    UIColor * orange = kColor_Orange;
    
    CGFloat effectiveFullWidth = self.bounds.size.width - 40.f;
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, 200);
    self.baseView = [[UIView alloc] initWithFrame:frame];

    BOOL usingSystemFontSize = (_expfontSize.floatValue == 0.0);
    CGFloat padding = 10.f;
    frame.size.height = 80;
    self.sampleTextView = [[UITextView alloc] initWithFrame:frame];
    _sampleTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _sampleTextView.textColor = [UIColor darkTextColor];
    
    if(usingSystemFontSize)
    {
        _sampleTextView.font = [UIFont editorFontWithFamily:_expFontFamily bold:NO size:0.0];
    }
    else
    {
        _sampleTextView.font = [UIFont editorFontWithFamily:_expFontFamily bold:NO  size:[_expfontSize floatValue]];
    }    
    _sampleTextView.layer.cornerRadius = 3.0;
    _sampleTextView.clipsToBounds = YES;
    _sampleTextView.backgroundColor = nil;

    

    _sampleTextView.userInteractionEnabled = NO;
    [_baseView addSubview:_sampleTextView];
    
    frame.origin.y = CGRectGetMaxY(_sampleTextView.frame) + padding;
    frame.size.width = (self.frame.size.width/2) - padding;
    frame.size.height  = 150;
    
    self.fontTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.fontTable.dataSource = self;
    self.fontTable.backgroundColor = [UIColor clearColor];
    self.fontTable.delegate = self;
    [_baseView addSubview:_fontTable];
    
    
    frame.origin.x = CGRectGetMaxX(_fontTable.frame) +  padding;
    frame.size.width = effectiveFullWidth - frame.origin.x;

    frame.size.height = 60;
    self.btn_SystemFont = [UIButton buttonWithType:UIButtonTypeSystem];
    _btn_SystemFont.tintColor = orange;
    _btn_SystemFont.frame = frame;
    [_btn_SystemFont setTitle:@"Use System Font Size" forState:UIControlStateNormal];
    [_btn_SystemFont.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_btn_SystemFont.titleLabel setNumberOfLines:2];
    _btn_SystemFont.tag = 2;
    _btn_SystemFont.selected = usingSystemFontSize;
    [_btn_SystemFont addTarget:self action:@selector(usefontSystemSize:) forControlEvents:UIControlEventTouchUpInside];
    _btn_SystemFont.layer.borderColor = [orange CGColor];
    _btn_SystemFont.layer.borderWidth = 1.f;
    _btn_SystemFont.layer.cornerRadius = 6.f;
    
    [_baseView addSubview:_btn_SystemFont];
    
    frame.origin.y = CGRectGetMaxY(_btn_SystemFont.frame) + padding;
    frame.size.height = 36.f;

    self.sizeSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"+", @"—"]];
    _sizeSegmentControl.frame = frame;
    [_sizeSegmentControl addTarget:self action:@selector(sizeValueChanged:) forControlEvents:UIControlEventValueChanged];
    _sizeSegmentControl.tintColor = orange;
//    _sizeSegmentControl.enabled = !usingSystemFontSize;
    [_baseView addSubview:_sizeSegmentControl];
    
    UISegmentedControl * listType = [[UISegmentedControl alloc] initWithItems:@[@"Grid", @"List"]];
    frame.origin.y = frame.size.height + frame.origin.y + padding;
    listType.frame = frame;
    listType.selectedSegmentIndex = (_isGrid.boolValue) ? 0 : 1;
    [listType addTarget:self action:@selector(listTypeSelector:) forControlEvents:UIControlEventValueChanged];
    listType.tintColor = orange;
    [_baseView addSubview:listType];
    
    
    
    /*
    frame.origin.y = CGRectGetMaxY(_sizeSegmentControl.frame) + padding;
    self.themeControl = [[UISegmentedControl alloc] initWithItems:@[@"Light", @"Dark"]];
    if ([_themeName isEqualToString:@"Dark"]) {
        self.themeControl.selectedSegmentIndex = 1;
    }
    _themeControl.frame = frame;
    [_themeControl addTarget:self action:@selector(themeChanged:) forControlEvents:UIControlEventValueChanged];
    _themeControl.tintColor = [UIColor colorWithRed:0.97 green:0.41 blue:0.05 alpha:1.00];

    //[_baseView addSubview:_themeControl];
    */
    
    frame = _baseView.frame;
    frame.size.height = CGRectGetMaxY(listType.frame);
    _baseView.frame = frame;
    
    return _baseView;
}
- (void)listTypeSelector:(UISegmentedControl *)seg
{
    _isGrid = (seg.selectedSegmentIndex == 0) ? @YES : @NO;
}

- (void)usefontSystemSize:(UIButton *)sender
{
    sender.selected = !sender.selected;
 
    [_sizeSegmentControl setSelectedSegmentIndex:-1];
    
    if(sender.selected)
    {
        _sampleTextView.font = [UIFont editorFontWithFamily:_expFontFamily bold:NO size:0.0];
    }
    else
    {
        CGFloat fsize = _sampleTextView.font.pointSize;
        _expfontSize = @(fsize);
        _sampleTextView.font = [UIFont editorFontWithFamily:_expFontFamily bold:NO size:fsize];
    }
}
/*
- (UIFont *)fontWithSystemSize
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody fontName:_expfontName];
}*/
- (void)themeChanged:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 1)
    {
        _themeName = @"Dark";
        _sampleTextView.backgroundColor = [UIColor blackColor];
        _sampleTextView.textColor       = [UIColor lightTextColor];
        [[NSUserDefaults standardUserDefaults] setObject:@"Dark" forKey:themeNameKey];
    }
    else
    {
        _themeName = @"Default";
        _sampleTextView.backgroundColor = nil;
        _sampleTextView.textColor       = [UIColor darkTextColor];
        [[NSUserDefaults standardUserDefaults] setObject:@"Default" forKey:themeNameKey];

    }
}

- (void)sizeValueChanged:(UISegmentedControl *)segment
{
    _btn_SystemFont.selected = NO;
    
    
    CGFloat fontSize;
    fontSize = [[_sampleTextView font] pointSize];

    if(segment.selectedSegmentIndex == 0)
    {
        if(fontSize > 33.f) return;
        
        fontSize += 1.f;
    }
    else
    {
        if(fontSize < 12.f) return;
        fontSize -= 1.f;
    }
    
    [_sampleTextView setFont:[_sampleTextView.font fontWithSize:fontSize]];
    

    _expfontSize = @(fontSize);
    
    [segment setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fontNames.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"font";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [UIColor clearColor];
    }
    NSString * fontFamily = _fontNames[indexPath.row];
//    NSString * fontFamily = fontNameMap[fontName];
    
    cell.textLabel.text = fontFamily;
    cell.textLabel.font = [UIFont editorFontWithFamily:fontFamily bold:NO size:15];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fontSize = [[_sampleTextView font] pointSize];
    
    
    _expFontFamily = _fontNames[indexPath.row];
    
    /*
    NSString * fontFamily = fontNameMap[_expfontName];
    
    _expFontFamily = fontFamily;
    */
    self.sampleTextView.text = [self sampleText];
    self.sampleTextView.font = [UIFont editorFontWithFamily:_expFontFamily bold:NO size:fontSize];
//    self.sampleTextView.attributedText = [self sampleAttributedText];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _sampleTextView.text = [self sampleText];

    BOOL isDark = [_themeName isEqualToString:@"Dark"];
    
    if(isDark)
    {
        _sampleTextView.backgroundColor = [UIColor blackColor];
        _sampleTextView.textColor       = [UIColor lightTextColor];
    }
    else
    {
        _sampleTextView.backgroundColor = kVignetteViewBGColor;
        _sampleTextView.textColor       = [UIColor darkTextColor];
    }
    
    _themeControl.selectedSegmentIndex = (isDark) ? 1 : 0;
}

- (id)resultObject
{
    if(_btn_SystemFont.isSelected)
    {
        _expfontSize = @(0.0);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_isGrid forKey:kSettings_MainListStyle_Grid];
  
    return @{kSettings_EditorFontFamily: _expFontFamily,
             kSettings_EditorFontSize: _expfontSize};
    
    
}


@end
