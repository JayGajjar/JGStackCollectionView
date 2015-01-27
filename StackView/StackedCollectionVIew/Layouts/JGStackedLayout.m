//
//  JGStackLayout.m
//
//  Created by Jay Gajjar on 07.01.15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "JGStackedLayout.h"

@interface JGStackedLayout ()

@property (nonatomic, strong) NSDictionary *layoutAttributes;

@end

@implementation JGStackedLayout
@synthesize itemSize;
- (instancetype)init {
    
    self = [super init];
    
    if (self) [self initLayout];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) [self initLayout];
    
    return self;
}

- (void)initLayout {
    
    self.layoutMargin = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    self.topReveal = 120;
    self.bounceFactor = 0.2;
}

#pragma mark - Accessors

- (void)setLayoutMargin:(UIEdgeInsets)margins {
    
    if (!UIEdgeInsetsEqualToEdgeInsets(margins, self.layoutMargin)) {
        
        _layoutMargin = margins;
        
        [self invalidateLayout];
    }
}

- (void)setTopReveal:(CGFloat)topReveal {
    
    if (topReveal != self.topReveal) {
        
        _topReveal = topReveal;
        
        [self invalidateLayout];
    }
}

- (void)setItemSize:(CGSize)itemSizee {
    
    if (!CGSizeEqualToSize(itemSizee, self.itemSize)) {
        
        itemSize = itemSizee;
        
        [self invalidateLayout];
    }
}

- (void)setBounceFactor:(CGFloat)bounceFactor {
    
    if (bounceFactor != self.bounceFactor) {
        
        _bounceFactor = bounceFactor;
        
        [self invalidateLayout];
    }
}

#pragma mark - Layout computation

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (CGSize)collectionViewContentSize {
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), [self.collectionView numberOfItemsInSection:0]* CGRectGetHeight(self.collectionView.bounds) - self.layoutMargin.top - self.layoutMargin.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom-200);
    
    contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds),2000);

    CGSize itemSizee = self.itemSize;
    
    if (CGSizeEqualToSize(itemSizee, CGSizeZero)) {
        
        itemSizee = CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - self.layoutMargin.left - self.layoutMargin.right, CGRectGetHeight(self.collectionView.bounds) - self.layoutMargin.top - self.layoutMargin.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom-200);
    }
    CGFloat itemReveal = self.topReveal;
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), ((self.layoutMargin.top - self.layoutMargin.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom) + itemReveal * itemCount ));

    if (contentSize.height < CGRectGetHeight(self.collectionView.bounds)) {
        
        contentSize.height = CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom;
        
        // Adding an extra point of content height
        // enables scrolling/bouncing
        contentSize.height += 1.0;
    }
    return contentSize;
}

- (void)prepareLayout {
    [self collectionViewContentSize];
    
    CGFloat itemReveal = self.topReveal;
    CGSize itemSizee = self.itemSize;
    
    if (CGSizeEqualToSize(itemSizee, CGSizeZero)) {
        
        itemSizee = CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - self.layoutMargin.left - self.layoutMargin.right, CGRectGetHeight(self.collectionView.bounds) - self.layoutMargin.top - self.layoutMargin.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom-200);
    }
    
    CGPoint contentOffset = self.overwriteContentOffset ? self.contentOffset : self.collectionView.contentOffset;
    
    self.overwriteContentOffset = NO;
    
    NSMutableDictionary *layoutAttributes = [NSMutableDictionary dictionary];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger item = 0; item < itemCount; item++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        // Cards overlap each other
        // via z depth
        //
        attributes.zIndex = item;
        
        // The moving item is hidden
        //
        attributes.hidden = [attributes.indexPath isEqual:self.movingIndexPath];
        
        // By default all items are layed
        // out evenly with each revealing
        // only top part ...
        //
        attributes.frame = CGRectMake(self.layoutMargin.left, self.layoutMargin.top + itemReveal * item, itemSizee.width, itemSizee.height);
        
        NSLog(@"FRame : %@",NSStringFromCGRect(attributes.frame));
        
        if (contentOffset.y + self.collectionView.contentInset.top < 0.0) {
            //if (item <= 4)
            {
                float y = (0.0009 * (contentOffset.y + self.collectionView.contentInset.top) * ((item <= 0)?1:item)) - 0.2;
                if (y > 1) {
                    y = 1;
                }
                
                CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = 1.0 / -1000.0;
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * y, 1.0f, 0.0f, 0.0f);
                attributes.transform3D = rotationAndPerspectiveTransform;
            }
            
        }else{
            //if (item <= 4)
            {
                CGFloat y = -0.2;
                CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = 1.0 / -1000.0;
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * y, 1.0f, 0.0f, 0.0f);
                attributes.transform3D = rotationAndPerspectiveTransform;
            }

        } 
        layoutAttributes[indexPath] = attributes;
    }
    
    self.layoutAttributes = layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    [self.layoutAttributes enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
        
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            
            [layoutAttributes addObject:attributes];
        }
    }];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.layoutAttributes[indexPath];
}
@end
