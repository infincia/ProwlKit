//
//  AppDelegate.m
//  ProwlTest
//

//  Copyright (c) 2012 Stephen Oliver
//

/*
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the <organization> nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 
 */

#import "AppDelegate.h"
#import "ProwlKit.h"
#import <dispatch/dispatch.h>

@implementation AppDelegate

@synthesize status;
@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    prowl = [ProwlKit sharedProwl];
    testQueue = dispatch_queue_create("com.infincia.ProwlTest.testQueue", 0);
}


-(IBAction)sendMessage:(id)sender {
    dispatch_async(testQueue, ^{
        NSString *application = [[NSUserDefaults standardUserDefaults] objectForKey:@"application"];
        NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"apikey"];
        NSString *description = [[NSUserDefaults standardUserDefaults] objectForKey:@"description"];
        NSInteger priority = [[NSUserDefaults standardUserDefaults] integerForKey:@"priority"];
        NSError *error;
        if ([prowl sendMessage:description forApplication:application event:nil withURL:nil forKey:key priority:priority error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self.status setStringValue:@"Message sent"]; });
            
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{ [self.status setStringValue:[error localizedDescription]]; });
        } 
        NSLog(@"Calls remaining: %ld",prowl.remaining);
    });
}//7665411bfce31f4ef2f60db3b068ccb7f4ef6bc2

-(IBAction)checkKey:(id)sender {
    
    dispatch_async(testQueue, ^{
        NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"apikey"];
        
        NSError *error;
        if ([prowl verifyAPIKey:key error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self.status setStringValue:@"Key verified"]; });
            
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{ [self.status setStringValue:[error localizedDescription]]; });
            
        }
        NSLog(@"Calls remaining: %ld",prowl.remaining);

    });
}

@end
