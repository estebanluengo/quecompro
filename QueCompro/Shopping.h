//
//  Shopping.h
//  QueCompro
//
//  Created by Esteban Luengo on 07/09/12.
//  Copyright (c) 2012 Esteban Luengo Simon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article;

@interface Shopping : NSManagedObject

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSDecimalNumber * cost;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * favourite;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * photo;
@property (nonatomic, retain) NSNumber * ticket;
@property (nonatomic, retain) NSNumber * unique;
@property (nonatomic, retain) Article *article;

@end
