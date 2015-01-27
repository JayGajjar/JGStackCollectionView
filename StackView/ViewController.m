//
//  ViewController.m
//  StackView
//
//  Created by Jay on 20/01/15.
//  Copyright (c) 2015 ccc. All rights reserved.
//

#import "ViewController.h"
#import "CardCell.h"
#import "JGStackedLayout.h"
#import "JGCardLayout.h"

#define MOVE_ZOOM 0.95


@interface UIColor (randomColor)

+ (UIColor *)randomColor;

@end

@implementation UIColor (randomColor)

+ (UIColor *)randomColor {
    
    CGFloat comps[3];
    
    for (int i = 0; i < 3; i++) {
        
        NSUInteger r = arc4random_uniform(256);
        comps[i] = (CGFloat)r/255.f;
    }
    
    return [UIColor colorWithRed:comps[0] green:comps[1] blue:comps[2] alpha:1.0];
}

@end

@interface ViewController ()<UIGestureRecognizerDelegate>{
    NSMutableArray *dataSource;
    JGStackedLayout *stackedLayout;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dataSource = [@[@"1",@"2",@"3",@"4",] mutableCopy];
    stackedLayout = (JGStackedLayout *)self.collView.collectionViewLayout;
    self.collView.collDataSource = dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView Data Source Methods
// Default is one
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    CardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    cell.title.text = [NSString stringWithFormat:@"Card : %@",dataSource[indexPath.row]];
    cell.contentView.backgroundColor = [UIColor randomColor];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView.collectionViewLayout isKindOfClass:[JGStackedLayout class]]) {
        JGCardLayout *cardLayout = [[JGCardLayout alloc] initWithItemIndex:indexPath.item];
        [self.collView setCollectionViewLayout:cardLayout animated:YES];
    }else{
        [self.collView setCollectionViewLayout:stackedLayout animated:YES];
    }
}

- (IBAction)addButtonAction:(id)sender {
    [self insertItem];
}

#pragma mark - CollectionView CRUD
-(void)insertItem{
    [dataSource addObject:[NSString stringWithFormat:@"%d",dataSource.count+1]];
    [self.collView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:dataSource.count-1 inSection:0]]];
}

-(void)removeItemAtIndexpath:(NSIndexPath *)index{
    [dataSource removeObjectAtIndex:index.row];
    [self.collView deleteItemsAtIndexPaths:@[index]];
}
@end
