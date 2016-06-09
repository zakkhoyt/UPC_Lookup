//
//  ViewController.m
//  XMLRPC
//
//  Created by Zakk Hoyt on 6/8/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

#import "ViewController.h"
#import <WPXMLRPC/WPXMLRPC.h>

NSString *ZH_ZH_UPC_DATABASE_URL = @"https://www.upcdatabase.com/xmlrpc";
NSString *ZH_RPC_KEY = @"535f92a89b1a145fd80e7be45d14eacf1ed0599c";
NSString *ZH_UPC = @"016000264793";
NSString *ZH_METHOD_LOOKUP = @"lookup";
NSString *ZH_METHOD_HELP = @"help";
NSString *ZH_PARAM_RPC_KEY = @"rpc_key";
NSString *ZH_PARAM_UPC = @"upc";

@interface ViewController ()
@property (nonatomic, strong) NSURLSession *session;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) IBOutlet UITextField *upcTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _responseTextView.text = @"";

    [self setupSession];
}

#pragma mark Helpers
- (void)setupSession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue new]];
}

- (void)lookupProduct:(NSString *)upc {

    NSURL *URL = [NSURL URLWithString:ZH_ZH_UPC_DATABASE_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"POST"];

    NSDictionary *dictionary = @{
        ZH_PARAM_RPC_KEY : ZH_RPC_KEY,
        ZH_PARAM_UPC : ZH_UPC
    };
    NSArray *parameters = @[ dictionary ];

    WPXMLRPCEncoder *encoder = [[WPXMLRPCEncoder alloc] initWithMethod:ZH_METHOD_LOOKUP andParameters:parameters];
    NSError *encodeError = nil;
    [request setHTTPBody:[encoder dataEncodedWithError:&encodeError]];
    if (encodeError) {
        NSLog(@"EncodeError: %@", encodeError.localizedDescription);
    }

    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            self.responseTextView.text = error.localizedDescription;
        } else {
            NSString *xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"xml: %@", xml);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSString *output = [NSString stringWithFormat:@"Response for %@\n\n"
                                                              @"TODO: Parse XML into a data structure\n\n"
                                                               "%@",
                                             upc,
                                             xml];
                self.responseTextView.text = output;
                self.upcTextField.text = @"";
            }];
        }
    }];

    [task resume];
}

#pragma mark IBActions

- (IBAction)lookupButtonTouchUpInside:(UITextField *)sender {
    NSString *upc = _upcTextField.text;
    [self lookupProduct:upc];
    self.responseTextView.text = [NSString stringWithFormat:@"Requesting info for UPC %@", upc];
}

@end
