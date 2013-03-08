
/**
 @mainpage Home
 
 @section Introduction
 CSSocial framework was built to make use of social services like
 Facebook, Twitter or Google plus safe and easy to implement by 
 the programmer. We were frustrated that every time we needed to integrate 
 a social service into the app, each programmer did it his own way and usually spent more than
 an hour doing so. The decision was to make a one line of code do magic solution
 which took only a couple of minutes to set up and run.
 
 @section Setup
 First, download the CSSocial.framework file from http://bla.com
 Drag&drop it into your project.
 
 @subsection Facebook
 
 Posting a message to Facebook wall can be done calling a single method like this:
 
 @code
 [CSFacebook postToWall:@"Test"
             completionBlock:^(CSSocialRequest *request, id response, NSError *error)
 {
 
 }];
 @endcode
 
 If you assign a handler block, you will receive a response or an error if one has occured during the posting process. For more information on errors, see here.
 
 Posting an image with a caption is done like this 
 
 @code
 [CSFacebook postPhoto:[UIImage imageNamed:@"test"]
             caption:@"test"
             completionBlock:^(CSSocialRequest *request, id response, NSError *error) {
 
 }];
 @endcode
 
 @subsection Twitter
 
 Posting a tweet to Twitter can be done calling a single method like this:
 
 @code
 [CSTwitter tweet:@"test"
            completionBlock:^(CSSocialRequest *request, id response, NSError *error) {
 }];
 @endcode
 
 */