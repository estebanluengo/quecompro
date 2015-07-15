//
//  DatabaseHelper.m
//  QueCompro
//
//  Created by Esteban Luengo on 28/08/12.
//  Copyright (c) 2012 Esteban Luengo. All rights reserved.
//

#import "DatabaseHelper.h"

@implementation DatabaseHelper

static UIManagedDocument *database;

#define DATABASE @"QueCompro.db"

+ (void)openDatabaseUsingBlock:(completion_block_t)completionBlock{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:DATABASE];
    //si no existe la base de datos se crea en memoria
    
    if (!database){
        database = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    //si existe en disco, lo abrimos
    if ([fileManager fileExistsAtPath:[url path]]){
        if (database.documentState == UIDocumentStateClosed){
            NSLog(@"La base de datos está cerrada. Se procede a abrirla");
            [database openWithCompletionHandler:^(BOOL success){
                completionBlock(database);
            }];
        }else if (database.documentState == UIDocumentStateNormal){
            NSLog(@"La base de datos ya estaba abierta.");
            completionBlock(database);
        }
    }else{
        NSLog(@"La base de datos no existia. Se crea ahora");
        [database saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            completionBlock(database);
        }];
    }
}

@end
