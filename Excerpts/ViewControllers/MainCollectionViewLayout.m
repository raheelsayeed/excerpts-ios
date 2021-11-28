//
//  MainCollectionViewLayout.m
//  Vignettes
//
//  Created by M Raheel Sayeed on 20/06/13.
//  Copyright (c) 2013 Mohammed Raheel Sayeed. All rights reserved.
//

#import "MainCollectionViewLayout.h"
#import "MainCellSeparatorView.h"
@implementation UICollectionViewFlowLayout (Helpers)

- (BOOL)indexPathLastInSection:(NSIndexPath *)indexPath {
    NSInteger lastItem = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section] -1;
    return  lastItem == indexPath.row;
}

- (BOOL)indexPathInLastLine:(NSIndexPath *)indexPath {
    NSInteger lastItemRow = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:indexPath.section] -1;
    NSIndexPath *lastItem = [NSIndexPath indexPathForItem:lastItemRow inSection:indexPath.section];
    UICollectionViewLayoutAttributes *lastItemAttributes = [self layoutAttributesForItemAtIndexPath:lastItem];
    UICollectionViewLayoutAttributes *thisItemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    
    return lastItemAttributes.frame.origin.y == thisItemAttributes.frame.origin.y;
}

- (BOOL)indexPathLastInLine:(NSIndexPath *)indexPath {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *nextCellAttributes = [self layoutAttributesForItemAtIndexPath:nextIndexPath];
    
    return !(cellAttributes.frame.origin.y == nextCellAttributes.frame.origin.y);
}

@end

@interface MainCollectionViewLayout ()
{
    CGFloat separatorStrokeWidth;
}
@end

@implementation MainCollectionViewLayout

-(id)init {
    self = [super init];
    if (self) {
        
   
        separatorStrokeWidth = ((isIPad) ? 1.3 : 0.3) * [[UIScreen mainScreen] scale];

        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        //self.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
        self.minimumLineSpacing = separatorStrokeWidth;//1.f * [[UIScreen mainScreen] scale];
        self.minimumInteritemSpacing = separatorStrokeWidth;//1.f * [[UIScreen mainScreen] scale];
        self.sectionInset = UIEdgeInsetsZero;
        self.headerReferenceSize = CGSizeMake(self.collectionViewContentSize.width, 30);
        
    }
    return self;
}

-(void)prepareLayout
{
    [self registerClass:[MainCellSeparatorView class] forDecorationViewOfKind:@"Vertical"];
    [self registerClass:[MainCellSeparatorView class] forDecorationViewOfKind:@"Horizontal"];

}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}




- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionView * const cv = self.collectionView;
        
        CGFloat topOffset = cv.contentInset.top;

        /*
        if ([self.collectionView.dataSource isKindOfClass:[UIViewController class]]) {
            UIViewController *collectionViewParentViewController = (UIViewController *)self.collectionView.dataSource;
            topOffset = collectionViewParentViewController.topLayoutGuide.length;
        }
        */
        
        CGPoint const contentOffset = CGPointMake(cv.contentOffset.x, cv.contentOffset.y + topOffset);
        CGPoint nextHeaderOrigin = CGPointMake(INFINITY, INFINITY);
        
        if (indexPath.section+1 < [cv numberOfSections])
        {
            UICollectionViewLayoutAttributes *nextHeaderAttributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section+1]];
            nextHeaderOrigin = nextHeaderAttributes.frame.origin;
        }
        
        CGRect frame = attributes.frame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            frame.origin.y = MIN(MAX(contentOffset.y, frame.origin.y), nextHeaderOrigin.y - CGRectGetHeight(frame));
        }
        else {
            frame.origin.x = MIN(MAX(contentOffset.x, frame.origin.x), nextHeaderOrigin.x - CGRectGetWidth(frame));
        }
        attributes.zIndex = 1024;
        attributes.frame = frame;
    }
 
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    // Prepare some variables.
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.row+1 inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *nextCellAttributes = [self layoutAttributesForItemAtIndexPath:nextIndexPath];
    
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    
    CGRect baseFrame = cellAttributes.frame;
    CGRect nextFrame = nextCellAttributes.frame;
    
//    CGFloat strokeWidth = 0.3f;
    CGFloat spaceToNextItem = 0;
    if (nextFrame.origin.y == baseFrame.origin.y)
        spaceToNextItem = (nextFrame.origin.x - baseFrame.origin.x - baseFrame.size.width);
    

    if ([decorationViewKind isEqualToString:@"Vertical"]) {
        CGFloat padding = 0;

        CGFloat  space = (spaceToNextItem- (separatorStrokeWidth/2));
        
        // Positions the vertical line for this item.
        CGFloat x = baseFrame.origin.x + baseFrame.size.width - space; //+ (space/2);
        layoutAttributes.frame = CGRectMake(x,
                                            baseFrame.origin.y + padding,
                                            separatorStrokeWidth,
                                            baseFrame.size.height - padding*2);
        
    } else if ([decorationViewKind isEqualToString:@"Horizontal"]){
        CGFloat padding = 0.0;

        // Positions the horizontal line for this item.
        layoutAttributes.frame = CGRectMake(baseFrame.origin.x+padding,
                                            baseFrame.origin.y + baseFrame.size.height,
                                            (baseFrame.size.width  + spaceToNextItem) - (padding*2),
                                            separatorStrokeWidth);
    }
    
    layoutAttributes.zIndex = -1;
    return layoutAttributes;
}

- (BOOL)shouldStickHeaderToTopInSection:(NSInteger)sectionNumber
{
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *baseLayoutAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray * layoutAttributes = [baseLayoutAttributes mutableCopy];
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    
    for (NSUInteger idx=0; idx<[layoutAttributes count]; idx++) {
        UICollectionViewLayoutAttributes *thisLayoutItem = layoutAttributes[idx];
        
    //for (UICollectionViewLayoutAttributes *thisLayoutItem in baseLayoutAttributes) {
        if (thisLayoutItem.representedElementCategory == UICollectionElementCategoryCell) {
            
            
            
            // Adds vertical lines when the item isn't the last in a section or in line.
            if (!([self indexPathLastInSection:thisLayoutItem.indexPath] ||
                  [self indexPathLastInLine:thisLayoutItem.indexPath])) {
                UICollectionViewLayoutAttributes *newLayoutItem = [self layoutAttributesForDecorationViewOfKind:@"Vertical" atIndexPath:thisLayoutItem.indexPath];
                [layoutAttributes addObject:newLayoutItem];
            }
            
            // Adds horizontal lines when the item isn't in the last line.
            if (![self indexPathInLastLine:thisLayoutItem.indexPath]) {
                UICollectionViewLayoutAttributes *newHorizontalLayoutItem = [self layoutAttributesForDecorationViewOfKind:@"Horizontal" atIndexPath:thisLayoutItem.indexPath];
                [layoutAttributes addObject:newHorizontalLayoutItem];
            }
        }
        if (thisLayoutItem.representedElementCategory == UICollectionElementCategoryCell || thisLayoutItem.representedElementCategory == UICollectionElementCategorySupplementaryView) {
            
            [missingSections addIndex:(NSUInteger) thisLayoutItem.indexPath.section];  // remember that we need to layout header for this section
        }
        if ([thisLayoutItem.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [layoutAttributes removeObjectAtIndex:idx];  // remove layout of header done by our super, we will do it right later
            idx--;
        }
    }
    
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *layoutAttribute = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (layoutAttributes) {
            [layoutAttributes addObject:layoutAttribute];
        }
    }];
    
    return layoutAttributes;
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    return attributes;
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes * attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    return attributes;
}

@end


