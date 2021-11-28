//
//  LineProgressView.h
//   Renote
//
//  Created by M Raheel Sayeed on 31/05/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface LineProgressView : UIView
{
    
    CALayer *maskLayer;
}

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
@property (nonatomic, readwrite, assign) CGFloat progress;

- (void)startAnimating;
- (void)stopAnimating;


@end
