# InstagramTwitterTrendAnalyzer

[Instagram](https://www.instagram.com) is the most popular photography application among all the social media networks. [Twitter](https://www.twitter.com/) is the most popular social media network in micro blogging platforms. Twitter trends are one of the key features in Twitter. The main idea of this project is to get the user's current location through an Instagram photo and identify the current trend cluster specific to that particular location.

The application consists of the following.

- Get the location of the most recent media of the user's Instagram profile.
- Find the current trends in Twitter according to the closest Twitter trend cluster and the latest tweets about that location.
- Then the details and the overall sentiment of the trends  are sent to the user as an email and a digest is sent as a SMS. 

> This is a typical cross-platform integration that uses Ballerina to send customized SMS messages via Twilio and email via Gmail to users stating the current trends and the sentiment analysis of those trends.


## Data flow

In this application, Instagram gives the location of the most recent media and Twitter is used to get the closest trend cluster and get the trends in that cluster. Then an email is sent with the information of the trends and related tweets. Twilio is used to send an information digest as SMS of main trends and a sentiment analysis value of those trends identified from the Instagram post location. This is a cross platform application which is ideal for the travelers to get to know about what is happening around them.

Ballerina Instagram connector is used to get the location parameters of the most recent post. Ballerina Twitter connector is used to get the trends. The third party Aylien API is used to generate the sentiment analysis of the trends identified and Ballerina Gmail connector is used to send the email and Ballerina Twilio connector is used to send digest SMS.
  
![alt text](https://github.com/kts-desilva/InstagramTwitterTrendAnalyzer/blob/master/InstaTwitterTrendAnalyzer.png)

## Prerequisites

* JDK 1.8 or later
* [Ballerina Distribution](https://github.com/ballerina-platform/ballerina-lang/blob/master/docs/quick-tour.md)
* A Text Editor or an IDE
* [Instagram Connector](https://github.com/ldclakmal/package-instagram) , [Twitter Connector](https://github.com/wso2-ballerina/package-twitter), [Twilio Connector](https://github.com/wso2-ballerina/package-twilio) , [Gmail Connector](https://github.com/wso2-ballerina/package-gmail) will be downloaded from `ballerinacentral` when running the Ballerina file.

### Before you begin

##### Understand the package structure

The following project structure is used for the integration.
```
BalInstaTrendAnalyzer
  └── trend-analyzer
  |    └── constants.bal
  |    └── service.bal
  |    └── lib.bal
  |	   └── Package.md
  |    └── sms_sender.bal
  |    └── tests
  |    	   └── hello_service_test.bal
  └── ballerina.conf
  └── README.md
```

Change the configurations in the `ballerina.conf` file. Replace "" with your data.

##### ballerina.conf
```
TWILIO_ACCOUNT_SID=""
TWILIO_AUTH_TOKEN=""
TWILIO_FROM_MOBILE=""
TWILIO_TO_MOBILE=""

GMAIL_ACCESS_TOKEN=""
GMAIL_CLIENT_ID=""
GMAIL_CLIENT_SECRET=""
GMAIL_REFRESH_TOKEN=""

TWITTER_CLIENT_ID=""
TWITTER_CLIENT_SECRET=""
TwITTER_ACCESS_TOKEN=""
TwITTER_ACCESS_TOKEN_SECRET=""

INSTAGRAM_ACCESS_TOKEN=""

AYLIEN_APPLICATION_ID=""
AYLIEN_APPLICATION_KEY=""

EMAIL_RECEPIENT=""
EMAIL_SENDER=""

```

Let's see how the configurations are done in Instagram, Twitter, Gmail and Twilio using Ballerina language.

#### Setup Instagram configurations
Create a Instagram account and create a connected application by visiting [Instagram](https://www.instagram.com). Obtain the Access Token for a client.

Set Instagram credentials in `ballerina.conf` (requested parameters are `INSTAGRAM_ACCESS_TOKEN`).


#### Setup Twitter configurations
Create a Twitter account and create a connected application by visiting [Twitter](https://www.twitter.com). Obtain the following credentials.

*  Client ID
*  Client Secret
*  Access Token
*  Access Token Secret

Set Twitter credentials in `ballerina.conf` (requested parameters are `TWITTER_CLIENT_ID,TWITTER_CLIENT_SECRET,TWITTER_ACCESS_TOKEN,TWITTER_ACCESS_TOKEN_SECRET`).


#### Setup Gmail configurations
Create a Twitter account and create a connected app by visiting [OAuth Playground](https://developers.google.com/oauthplayground). Obtain the following credentials selecting Gmail API options.

*  Client ID
*  Client Secret
*  Access Token
*  Refresh Token

Set Twitter credentials in `ballerina.conf` (requested parameters are `GMAIL_CLIENT_ID,GMAIL_CLIENT_SECRET,GMAIL_ACCESS_TOKEN,GMAIL_REFRESH_TOKEN`).

Now you are ready to deploy.

## Deployment

#### Deploying locally
The application can be deployed easily as follows.

**Building**

```
<SAMPLE_ROOT_DIRECTORY>$ ballerina build trend-analyzer/
```

After build is successful, the executable can be run as follows.

**Running**

```
<SAMPLE_ROOT_DIRECTORY>$ ballerina run trend-analyzer

```
This will start the service.

To trigger the operation a curl request can be sent as follows in a different terminal.

**Triggering**

```
<SAMPLE_ROOT_DIRECTORY>$ `curl -v -X POST -d '{"operation": "activate"}' "http://localhost:9090/trend-analyzer/operation" -H "Content-Type:application/json"`

```
