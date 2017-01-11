
//
//  SessionModel.m
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/8.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import "SessionModel.h"

@implementation SessionModel


- (NSString *)calculateUnit:(unsigned long long)contentlength
{
    if (contentlength >= pow(1024, 3)) {
        return @"GB";
    }else if (contentlength >= pow(1024, 2)){
        return @"MB";
    }else if (contentlength >= 1024){
        return @"KB";
    }else{
        return @"B";
    }
    
}

- (float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    
    if (contentLength >= pow(1024, 3)) {
        return (float)contentLength/(float)pow(1024, 3);
    }else if (contentLength >= pow(1024, 2)){
        return (float)contentLength/(float)pow(1024,2);
    }else if (contentLength >= 1024){
        return (float)contentLength/(float)1024;
    }else{
        return (float)contentLength;
    }
}


#pragma NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.totalSize forKey:@"totalSize"];
    [aCoder encodeInteger:self.totalLength forKey:@"totalLength"];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.totalSize = [aDecoder decodeObjectForKey:@"totalSize"];
        self.totalLength = [aDecoder decodeIntegerForKey:@"totalLength"];
    }
    return  self;
}
@end
