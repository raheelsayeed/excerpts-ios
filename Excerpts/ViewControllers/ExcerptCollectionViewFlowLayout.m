//
//  ExcerptCollectionViewFlowLayout.m
//   Renote
//
//  Created by M Raheel Sayeed on 14/06/14.
//  Copyright (c) 2014 Mohammed Raheel Sayeed. All rights reserved.
//

#import "ExcerptCollectionViewFlowLayout.h"

@interface ExcerptCollectionViewFlowLayout ()
@property (nonatomic, strong) NSMutableSet * insertedSectionSet;


@end
@implementation ExcerptCollectionViewFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    self.insertedSectionSet =[NSMutableSet new];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionReload)
        {            
            [_insertedSectionSet addObject:@(updateItem.indexPathAfterUpdate.section)];
        }
    }];
}

-(void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    
    [_insertedSectionSet removeAllObjects];
}
-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes;
    
   
        if ([_insertedSectionSet containsObject:@(decorationIndexPath.section)])
        {
            layoutAttributes = [self layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:decorationIndexPath];
            layoutAttributes.alpha = 0.0f;
            layoutAttributes.transform3D = CATransform3DMakeTranslation(-CGRectGetWidth(layoutAttributes.frame), 0, 0);
        }
    
    return layoutAttributes;
}

-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes;
    
    if ([_insertedSectionSet containsObject:@(itemIndexPath.section)])
    {
        layoutAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        layoutAttributes.transform3D = CATransform3DMakeTranslation([self collectionViewContentSize].width, 0, 0);
    }
    
    return layoutAttributes;
}


@end
