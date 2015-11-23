//
//  ViewController.m
//  socket
//
//  Created by Yury on 20.11.15.
//  Copyright © 2015 ardas. All rights reserved.
//

#import "ViewController.h"

#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) launchButton:(id)sender{
    [self openSocketAndLogs];
}

- (void) openSocketAndLogs {
    
    int serverfd;
    struct sockaddr_in server_addr;
    struct sockaddr_in client_addr;
    serverfd = socket(AF_INET, SOCK_DGRAM, 0);
    bzero(&server_addr, sizeof(struct sockaddr_in));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(5555);
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    int res = bind(serverfd, (struct sockaddr *) &server_addr, sizeof(struct sockaddr_in));
    if (res < 0) {
        NSLog(@"Bind error %d", res);
    }
    
    socklen_t clisize = sizeof(struct sockaddr_in);
    bzero(&client_addr, clisize);
    
    
    unsigned int statisticLost = 0;
    unsigned int statisticReceived = 0;
    unsigned int lastseq = 0;
    
    NSLog(@"waiting a stream");
    
    
    while (1) {
        char buf[10000]; // this is a static buffer to receive raw bytes
        int bytesread = recvfrom(serverfd, buf, 10000, 0, (struct sockaddr *) &sin, &clisize);
        if ( bytesread > 0 )
        {
            //            NSString *string = [[NSString alloc] initWithBytes:buf length:bytesread encoding:NSUTF8StringEncoding];
            
            statisticReceived++;
            
            unsigned int seqnum = U16_AT(&buf[2]);
            
            if (0 != lastseq && (lastseq +1) != seqnum ) {
                int lost = seqnum - (lastseq + 1);
                NSLog(@"package lost, received %d lost %d", statisticReceived, lost);
                statisticLost += lost;
            }
            
            NSLog(@"message received, sn %d", seqnum);
            lastseq = seqnum;
            // for non-arc projects don't forget to release string
        }
    }
}

static unsigned short U16_AT (const void *p)
{
    unsigned short x;
    
    memcpy (&x, p, sizeof (x));
    return bswap16 (x);
}

static inline unsigned short bswap16 (unsigned short x)
{
    return (x << 8) | (x >> 8);
}

@end
