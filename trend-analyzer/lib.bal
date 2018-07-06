import ballerina/io;
import wso2/twilio;
import wso2/twitter;
import chanakal/instagram;
import wso2/gmail;
import ballerina/config;
import ballerina/log;
import ballerina/http;

documentation {
    Represents Twitter client endpoint.
}
endpoint twitter:Client twitter {
   clientId: config:getAsString(TWITTER_CLIENT_ID),
   clientSecret: config:getAsString(TWITTER_CLIENT_SECRET),,
   accessToken: config:getAsString(TWITTER_ACCESS_TOKEN),,
   accessTokenSecret: config:getAsString(TWITTER_TOKEN_SECRET),
};

documentation {
    Represents Instagram client endpoint.
}
endpoint instagram:Client instagramClient {
   clientConfig:{
       auth:{
           scheme:"OAuth2",
           accessToken:config:getAsString(INSTAGRAM_ACCESS_TOKEN),
       }
   }
};

documentation {
    Represents Gmail client endpoint.
}
endpoint gmail:Client gmailEP {
    clientConfig:{
        auth:{
            accessToken:config:getAsString(GMAIL_ACCESS_TOKEN),
            clientId:config:getAsString(GMAIL_CLIENT_ID),
            clientSecret:config:getAsString(GMAIL_CLIENT_SECRET),
            refreshToken:config:getAsString(GMAIL_REFRESH_TOKEN)
        }
    }
};

documentation {
    Represents Twilio client endpoint.
}
endpoint twilio:Client twilioClient {
    accountSId: config:getAsString(TWILIO_ACCOUNT_SID),
    authToken: config:getAsString(TWILIO_AUTH_TOKEN)
};

documentation {
    Represents Aylien client (Sentiment Analysis) endpoint.
}
endpoint http:Client aylienEndpoint {
    url: "https://api.aylien.com/api/v1/sentiment"
};

documentation {
    Main function to run the integration system.
}
function activate() returns boolean {
    log:printInfo("instagram-Twitter-Gmail-Twilio Integration -> Sending twitter trends through SMS and email to me");
    
    float latitude=filterInstagram("lat");
    float longitude=filterInstagram("lon");

    string locationName=filterInstagramLocationName();

    boolean result = filterTweets(latitude,longitude,locationName);

    return result;
    
}

documentation {

    Utility function to get the closest trends in twitter given location coordinates and location name seperetely

    P{{latitude}} from location coordinates
    P{{longitude}} from location coordinates
    P{{locName}} from location 
    R{{}} State of whether the information retrieval is done or not
}

function filterTweets(float latitude,float longitude,string locName)returns boolean{
    string emailBody="<html><h1>Instagram-Tweeter Trend Analyzer</h1><h3>The following tweets are selected according to your instagram picture location</h3>";

    twitter:Status[]  locationNameSts = check twitter->search(locName);

    int locationCount=0;

    foreach ls in locationNameSts {
        if(locationCount<5){
            emailBody+="<p>"+ls.text+"</p>";
        }else{
            break;
        }
        locationCount++;
    }

    twitter:Location []locs=check twitter->getClosestTrendLocations(latitude, longitude); 

    int lid=locs[0].woeid;

    twitter:Trends[] trends=check twitter->getTopTrendsByPlace(lid);

    string [] trenTexts=[];
    
    int trendCount=0;

    string trendText="These are trending rightnow.\n";

    emailBody+="<h2>Trending right now </h2>";

    float sentimentTrendValue=0.0;

    foreach t in trends{
        foreach r in t.trends{
            if(r.tweetVolume>100){
                twitter:Status[]  trend_sts = check twitter->search(r.name);

                if(trendCount<3){
                    if(trendCount<2){
                        trendText+=r.name+"\n";
                    }
                    
                    sentimentTrendValue+=analyzeTrends(r.name);

                    emailBody+="<h3>"+r.name+"</h3>";
                    emailBody+="<p>"+trend_sts[0].text+"</p>";
                    emailBody+="<p>"+trend_sts[1].text+"</p>";
                    emailBody+="<p>"+trend_sts[2].text+"</p>";
                    
                }else{
                    break;
                }
                trendCount++;
                
            }
        }
    }

    string trendResult="";

    if(sentimentTrendValue>0){
        trendResult="Postive";
    }else if(sentimentTrendValue==0.0){
        trendResult="Neutral";
    }else{
        trendResult="Negative";
    }

    io:println("Overall trend result : "+trendResult);

    trendText+="Trend Result: "+trendResult+"\n";
    trendText+="Check email for more info";

    emailBody+="</html>";
    boolean sendMailResult=sendMail(emailBody);

    io:println(trendText);
    io:println("Length of trend text :" +<string>lengthof trendText);

    boolean smsResult = sendSmsToUser(trendText);

    return sendMailResult && smsResult;

}


documentation {

    Utility function to analyze the sentiment of a text

    P{{trendT}} from twitter trends
    R{{}} The sentiment value (positive, negative  value or zero)
}

function analyzeTrends(string trendT)returns float{

    string newText="";
    int i=0;
    float trendValue=0.0;

    newText=trendT.replaceAll(" ","+");

    http:Request req = new;
    
    req.addHeader("X-AYLIEN-TextAPI-Application-ID",config:getAsString(AYLIEN_APPLICATION_ID));
    req.addHeader("X-AYLIEN-TextAPI-Application-Key",config:getAsString(AYLIEN_APPLICATION_KEY));

    string link="?text="+newText;
    var response = aylienEndpoint->get(link,message=req);

    match response {
        http:Response resp => {
            var msg = resp.getJsonPayload();

            match msg {
                json jsonPayload => {
                    string resultSentiment = check <string>jsonPayload["polarity"];
                    float resultConfidence = check <float>jsonPayload["polarity_confidence"];

                    if(resultSentiment=="neutral"){
                        trendValue=0.0;
                    }else if (resultSentiment=="positive"){
                        trendValue=resultConfidence;
                    }else if(resultSentiment=="negative"){
                        trendValue=-1*resultConfidence;
                    }

                    io:println(resultSentiment);
                }
                error err => {
                    log:printError(err.message,  err=err);
                }
            }
        }
        error err => { log:printError(err.message, err = err); }
    }

    return trendValue;
}


documentation {

    Utility function to send a mail

    P{{body}} from message to be wriiten in the email body
    R{{}} The location coordinates
    If successful, returns the message ID and thread ID.
    Unsuccessful attempts return a Gmail error.
}

function sendMail(string body) returns boolean{
    gmail:MessageRequest messageRequest;
    messageRequest.recipient = config:getAsString(EMAIL_RECEPIENT);
    messageRequest.sender = config:getAsString(EMAIL_SENDER);
    messageRequest.subject = "Insta-Twitter Trend Analyzer with Ballerina";
    messageRequest.messageBody = body;
    messageRequest.contentType = gmail:TEXT_HTML;

    var sendMessageResponse = gmailEP -> sendMessage("me", messageRequest);

    match sendMessageResponse {
    (string, string) sendStatus => {
        string messageId;
        string threadId;
        (messageId, threadId) = sendStatus;
        io:println("Sent Message ID: " + messageId);
        io:println("Sent Thread ID: " + threadId);
        
        return true;
    }
        gmail:GmailError e => io:println(e); 

    }

    return false;
}


documentation {

    Utility function to get the location coordinates of the most recent media in instagram

    P{{ltype}} from location coordinates ( longitude and latitude)
    R{{}} The location coordinates
}

function filterInstagram(string ltype) returns float{
    var details = instagramClient->getOwnerInfo();
    match details {
        instagram:Account account => io:println();
        instagram:InstagramError instagramError => io:println( instagramError.message);
    }

    var mostRecentMedia = instagramClient->getMostRecentMedia();
    float val=0;
    match mostRecentMedia {
        
        json response => {
            if(ltype=="lat"){
                val=check <float>  response["data"][0]["location"]["latitude"]; 
            
            }else if(ltype=="lon"){
                val=check <float>  response["data"][0]["location"]["longitude"];
                
            }else{
                io:println("Invalid paramter type");
            }
        }
        instagram:InstagramError instagramError => io:println(instagramError.message);
    }

    return val;
}

documentation {

    Utility function to get the location of the most recent media in Instagram.
    R{{}} The location name
}

function filterInstagramLocationName() returns string{

    var mostRecentMedia = instagramClient->getMostRecentMedia();
    string val="";
    match mostRecentMedia {
        
        json response => {
            val= check<string>response["data"][0]["location"]["name"];
        }
        instagram:InstagramError instagramError => io:println(instagramError.message);
    }

    return val;
}


documentation {
    Utility function integrate Twitter and Twilio connectors.
    R{{}} State of whether the process of sending SMS to leads are success or not
}
function sendSmsToUser(string message) returns boolean {

    string fromMobile = config:getAsString(TWILIO_FROM_MOBILE);
    string toMobile = config:getAsString(TWILIO_TO_MOBILE);

    boolean isSuccess = sendTextMessage(fromMobile, toMobile, message);
        
    return isSuccess;
}


documentation {

    Utility function to send SMS.

    P{{fromMobile}} from mobile number
    P{{toMobile}} to mobile number
    P{{message}} sending message
    R{{}} The status of sending SMS success or not
}

function sendTextMessage(string fromMobile, string toMobile, string message) returns boolean {
    var details = twilioClient->sendSms(fromMobile, toMobile, message);
    match details {
        twilio:SmsResponse smsResponse => {
            if (smsResponse.sid != EMPTY_STRING) {
                io:println("SMS successfully sent to " + toMobile);
                return true;
            }
        }
        twilio:TwilioError err => {
            io:println("SMS failed sent to " + toMobile);
            io:println(err.message);
        }
    }
    return false;
}
