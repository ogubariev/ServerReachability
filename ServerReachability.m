/*
 Copyright (c) 2015, Alexey Gubarev, <gubarev.lesha@gmail.com>
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
 */


#import "ServerReachability.h"

#include <sys/socket.h>
#include <netdb.h>


const __darwin_time_t kServerReachabilityTimeoutInterval = 3;

bool connect_w_to(struct addrinfo *serverInfo, int timeout);

@interface ServerReachability ()
@property (nonatomic, strong) NSNumber *isReachableChecked;
@property (nonatomic, strong) NSString *serverUrl;
@end

@implementation ServerReachability

@dynamic isReachable;

+ (instancetype)reachabilityWithServer:(NSString *)serverUrl {
    return [[ServerReachability alloc] initWithServer:serverUrl];
}

- (instancetype)initWithServer:(NSString *)serverUrl{
    self = [super init];
    if (self) {
        self.serverUrl = serverUrl;
        self.isReachableChecked = nil;
    }
    return self;
}

- (BOOL)isReachable {
    if (!self.isReachableChecked) {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.isReachableChecked = [NSNumber numberWithBool:[self checkConnectionToServer:self.serverUrl]];
            dispatch_semaphore_signal(sem);
        });
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    return self.isReachableChecked.boolValue;
}

- (void) resetReachabilityStatus {
    self.isReachableChecked = nil;
}


- (BOOL)checkConnectionToServer:(NSString *)serverUrl {
    NSURL *url = [NSURL URLWithString:serverUrl];
    if (serverUrl.length && url) {
        BOOL status = NO;
        NSString *nodename = [url host];
        NSString *service = [url scheme];
        if ([url port]) {
            service = [url port].stringValue;
        }
        
        struct addrinfo hints, *servinfo, *p;
        int rv;
        
        memset(&hints, 0, sizeof hints);
        hints.ai_family = AF_UNSPEC; // use AF_INET6 to force IPv6
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = AI_CANONNAME;
        
        // Get server info
        if ((rv = getaddrinfo([nodename UTF8String], [service UTF8String], &hints, &servinfo)) != 0) {
            fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        } else if (servinfo == NULL) {
            // looped off the end of the list with no connection
            fprintf(stderr, "failed to connect\n");
        } else {
            // loop through all the results and connect to the first we can
            for(p = servinfo; p != NULL; p = p->ai_next) {
                if (p->ai_canonname) {
                    // print information about this host:
                    printf("Official name is: %s\n", p->ai_canonname);
                }
                // Try connect to current server info
                if (connect_w_to(p, kServerReachabilityTimeoutInterval)) {
                    status = YES;
                    break;
                }
            }
        }
        freeaddrinfo(servinfo); // all done with this structure
        return status;
    }
    return NO;
}
@end


bool connect_w_to(struct addrinfo *serverInfo, int timeout) {
    int res;
    long arg;
    fd_set myset;
    struct timeval tv;
    int soc;
    int valopt;
    socklen_t lon;
    bool status = YES;
    
    // Create socket
    soc = socket(serverInfo->ai_family, serverInfo->ai_socktype, serverInfo->ai_protocol);
    if (soc < 0) {
        fprintf(stderr, "Error creating socket (%d %s)\n", errno, strerror(errno));
        return false;
    }
    
    // Set non-blocking
    if( (arg = fcntl(soc, F_GETFL, NULL)) < 0) {
        fprintf(stderr, "Error fcntl(..., F_GETFL) (%s)\n", strerror(errno));
        return false;
    }
    arg |= O_NONBLOCK;
    if( fcntl(soc, F_SETFL, arg) < 0) {
        fprintf(stderr, "Error fcntl(..., F_SETFL) (%s)\n", strerror(errno));
        return false;
    }
    
    // Trying to connect with timeout
    res = connect(soc, serverInfo->ai_addr, serverInfo->ai_addrlen);
    if (res < 0) {
        if (errno == EINPROGRESS) {
            fprintf(stderr, "EINPROGRESS in connect() - selecting\n");
            tv.tv_sec = timeout;
            tv.tv_usec = 0;
            FD_ZERO(&myset);
            FD_SET(soc, &myset);
            res = select(soc+1, NULL, &myset, NULL, &tv);
            if (res < 0 && errno != EINTR) {
                fprintf(stderr, "Error connecting %d - %s\n", errno, strerror(errno));
                status = false;
            } else if (res > 0) {
                // Socket selected for write
                lon = sizeof(int);
                if (getsockopt(soc, SOL_SOCKET, SO_ERROR, (void*)(&valopt), &lon) < 0) {
                    fprintf(stderr, "Error in getsockopt() %d - %s\n", errno, strerror(errno));
                    status = false;
                } else if (valopt) { // Check the value returned...
                    fprintf(stderr, "Error in delayed connection() %d - %s\n", valopt, strerror(valopt));
                    status = false;
                }
            } else {
                fprintf(stderr, "Timeout in select() - Cancelling!\n");
                status = false;
            }
        } else {
            fprintf(stderr, "Error connecting %d - %s\n", errno, strerror(errno));
            status = false;
        }
    }
    // Set to blocking mode again...
    if( (arg = fcntl(soc, F_GETFL, NULL)) < 0) {
        fprintf(stderr, "Error fcntl(..., F_GETFL) (%s)\n", strerror(errno));
        status = false;
    }
    arg &= (~O_NONBLOCK);
    if( fcntl(soc, F_SETFL, arg) < 0) {
        fprintf(stderr, "Error fcntl(..., F_SETFL) (%s)\n", strerror(errno));
        status = false;
    }
    
    if (status) {
        // Connection was successfull!
        printf("Connection was successfull!\n");
    }
    return status;
}
