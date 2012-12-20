#import "SignInViewController.h"
#import "SignInHandler.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface SignInViewController ()

@property (nonatomic) BOOL isSignedIn;
@property (nonatomic) GTMOAuth2Authentication *authToken;

@end

@implementation SignInViewController

@synthesize isSignedIn = _isSignedIn;
@synthesize authToken = _authToken;

static NSString *kKeychainItemName = @"imeetingauth";
static NSString *kMyClientID = @"918644537696.apps.googleusercontent.com";
static NSString *kMyClientSecret = @"OH0beWXoas6VOKqWq6_SvM5i";

- (void)viewDidLoad
{
    [self authorizeUser];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    if(_isSignedIn) {
        [self performSegueWithIdentifier:@"appWorkflowSegue" sender:self];
    } else {
        [self presentAuthScreen];
    }
}

- (void)authorizeUser
{
    self.authToken = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                           clientID:kMyClientID
                                                                       clientSecret:kMyClientSecret];
    self.isSignedIn = [self.authToken canAuthorize];
    NSLog(@"Can Authorize: %@", self.isSignedIn ? @"YES" : @"NO");
    
    if (self.isSignedIn) {
        [SignInHandler instance].calendarService.authorizer = self.authToken;
        [SignInHandler instance].userEmail = self.authToken.userEmail;
        NSLog(@"%@", self.authToken.userEmail);
        return;
    }
}

- (void)presentAuthScreen
{
    NSString *scope = @"https://www.googleapis.com/auth/calendar";
    
    GTMOAuth2ViewControllerTouch *viewController = [[GTMOAuth2ViewControllerTouch alloc]
                                                    initWithScope:scope
                                                    clientID:kMyClientID
                                                    clientSecret:kMyClientSecret
                                                    keychainItemName:kKeychainItemName
                                                    completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"Authentication failed");
                                                        } else {
                                                            NSLog(@"Authentication succeeded");
                                                            [SignInHandler instance].userEmail = auth.userEmail;
                                                            [SignInHandler instance].calendarService.authorizer = auth;
                                                            _isSignedIn = true;
                                                            [self performSegueWithIdentifier:@"appWorkflowSegue" sender:self];
                                                        }
                                                    }];
    viewController.navigationItem.hidesBackButton = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end