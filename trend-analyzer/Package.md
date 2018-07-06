# Instagram-Twitter Trend Analyzer

[Instagram](https://www.instagram.com) is the most famous photography application among the social media networks. [Twitter](https://www.twitter.com/) is the most popular social media network in micro blogging platforms. Twitter trends are one of the key features in Twitter. The main idea of this project is to get the user's current location through an Instagram photo and identify the current trend cluster specific to that particular location.

The application consists of the following.

- Get the location of the most recent media of the user's Instagram profile.
- Find the current trends in Twitter according to the closest Twitter trend cluster and the latest tweets about that location.
- Then the details and the overall sentiment of the trends  are sent to the user as an email and a digest is sent as a SMS. 

> This is a typical cross-platform integration that uses Ballerina to send customized SMS messages via Twilio and email via Gmail to users stating the current trends and the sentiment analysis of those trends.


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
