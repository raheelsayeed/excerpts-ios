//
//  FetchViewFlowLayout.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 12/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "FetchViewFlowLayout.h"

@implementation FetchViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    return array;
}



/*
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *pose = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    if (<test for incorrect frame>) {
        CGRect frame = pose.frame;
        frame.origin.y = <calculate correct frame>;
        pose.frame = frame;
    }
    return pose;
}
 */
@end
