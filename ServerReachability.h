/*
 Copyright (c) 2015, Alexey Gubarev
 All rights reserved.
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * ServerReachability.h
 *
 * Created by Alexey Gubarev on 3/25/15.
 * <gubarev.lesha@gmail.com>
 * Copyright (c) 2015, Alexey Gubarev. All rights reserved.
 *
 * v0.0.1
 */


#import <Foundation/Foundation.h>

typedef void(^serverReachabilityCompletion)(BOOL isReachable);

/**
 Provides methods which check connection to server by url.
 
 @author Alexey Gubarev <gubarev.lesha@gmail.com>
 
 @since 0.0.1
 */

@interface ServerReachability : NSObject

/**
 Reachability status. It will be defined after trying connect to server.
 
 @since 0.0.1
 */
@property (nonatomic, readonly) BOOL isReachable;

/**
 Returns a server reachability instance.
 
 @param serverUrl The server url for checking reachability to it
 @return A server reachability instance

 @since 0.0.1
 */
+ (instancetype) reachabilityWithServer:(NSString *)serverUrl;

/**
 Returns a server reachability instance.
 
 @param serverUrl The server url for checking reachability to it
 @return A server reachability instance
 
 @since 0.0.1
 */
- (instancetype) initWithServer:(NSString *)serverUrl;


/**
 Returns a server reachability instance.
 
 @param serverUrl The server url for checking reachability to it
 @param timeout The waiting timeout for checking reachability to server
 @return A server reachability instance
 
 @since 0.0.2
 */
+ (instancetype) reachabilityWithServer:(NSString *)serverUrl timeout:(NSTimeInterval)timeout;

/**
 Returns a server reachability instance.
 
 @param serverUrl The server url for checking reachability to it
 @param timeout The waiting timeout for checking reachability to server
 @return A server reachability instance
 
 @since 0.0.2
 */
- (instancetype) initWithServer:(NSString *)serverUrl timeout:(NSTimeInterval)timeout;

/**
 Reset reachability status.
 
 @since 0.0.1
 */
- (void) resetReachabilityStatus;

@end
