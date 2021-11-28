//
//  TagCollectionFlowLayout.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 23/08/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "TagCollectionFlowLayout.h"
//const NSInteger kMaxCellSpacing = 9;

@implementation TagCollectionFlowLayout

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.sectionInset = UIEdgeInsetsMake(13, 30, 13, 0);
    }
    return self;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
        if (nil == attributes.representedElementKind) {
            NSIndexPath* indexPath = attributes.indexPath;
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return attributesToReturn;
}

/*
- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *result = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    //see if there's already a header attributes object in the results; if so, remove it
    NSArray *attrKinds = [result valueForKeyPath:@"representedElementKind"];
    NSUInteger headerIndex = [attrKinds indexOfObject:UICollectionElementKindSectionHeader];
    if (headerIndex != NSNotFound) {
        [result removeObjectAtIndex:headerIndex];
    }
    
    CGPoint const contentOffset = self.collectionView.contentOffset;
    CGSize headerSize = self.headerReferenceSize;
    
    //create new layout attributes for header
    UICollectionViewLayoutAttributes *newHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    CGRect frame = CGRectMake(0, contentOffset.y, headerSize.width, headerSize.height);  //offset y by the amount scrolled
    newHeaderAttributes.frame = frame;
    newHeaderAttributes.zIndex = 1024;
    
    [result addObject:newHeaderAttributes];
    
    return result;
}
*/



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* currentItemAttributes =
    [super layoutAttributesForItemAtIndexPath:indexPath];
    
    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout sectionInset];
    
    if (indexPath.item == 0) { // first item of section
        CGRect frame = currentItemAttributes.frame;
        frame.origin.x = sectionInset.left; // first item of the section should always be left aligned
        currentItemAttributes.frame = frame;
        return currentItemAttributes;
    }
    
    
    NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    CGFloat previousFrameRightPoint = CGRectGetMaxX(previousFrame) + self.minimumInteritemSpacing; // previousFrame.origin.x + previousFrame.size.width + kMaxCellSpacing;
    
    CGRect currentFrame = currentItemAttributes.frame;
    CGRect strecthedCurrentFrame = CGRectMake(0,
                                              currentFrame.origin.y,
                                              self.collectionView.frame.size.width,
                                              currentFrame.size.height);
    
    
    if (!CGRectIntersectsRect(previousFrame, strecthedCurrentFrame)) { // if current item is the first item on the line
        // the approach here is to take the current frame, left align it to the edge of the view
        // then stretch it the width of the collection view, if it intersects with the previous frame then that means it
        // is on the same line, otherwise it is on it's own new line
        currentFrame.origin.x  = sectionInset.left; // first item on the line should always be left aligned
        currentItemAttributes.frame = currentFrame;
        return currentItemAttributes;
    }
    
    currentFrame.origin.x = previousFrameRightPoint;
    currentItemAttributes.frame = currentFrame;
    return currentItemAttributes;
}
 



@end
