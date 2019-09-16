# Using Uploaded Lists Outside of Optimizely Web
---
Optimizely Web provides a feature called [List Attributes](https://help.optimizely.com/Target_Your_Visitors/Set_up_list_attributes) that allows you to upload a list of IDs for targeting that group of users.

The flow works like this:
1. Create a list attribute in Optimizely e.g. `vip_list_of_users`
2. Create an audience targeting that list of users
3. Experiment with only that list of users.

From there our JS web snippet will automatically determine if a user is in that list to target them with an experiment or personalization campaign.

However, there might be times when you wish to leverage the functionality of deciding if someone is in a list outside of using Optimizely Web. One example of this might be when you're using Full Stack server-side but still want to target based on the list you've previously created in Web.

## Technical Details
---
Behind the scenes Optimizely is uploading that list of IDs to DynamoDB, and then makes an API request to lookup if that user exists.

This is exposed via an API endpoint that can be called anywhere.

**Requesting the Targeting API**

*Endpoint*: `https://tapi.optimizely.com/api/js/odds/project/{$PROJECT_ID}`
*Method*: `GET`
*Query Params*: `productId={$YOUR WEB PROJECT ID}` & `{{SPECIAL PARAM={$USER_ID} }}`

**IMPORTANT NOTE ABOUT THE _SPECIAL PARAM_ Parameter**
When creating a List Attribute you create a *List Type* and define the name of the type.

INSERT IMAGE CONFIGURING LIST

The **List Type** and **Name** are used to form the required query parameters you wish to use to look up the list. 

*List Types*
- Cookies : c
	- If you set up a cookie targeting list, the query param is formed as `c_{$Cookie Name}={ID}`, eg `c_userId`
- Global JS Variables : j
	- If you set up a Global JS Variable targeting list, the query param is formed as `j_{$Variable Name}={ID}`, `j_userId`
- Query Params : q
	- If you set up a query param targeting list, the query param is formed as `q_{$Query Param Name}={ID}`

Example you can run in the terminal: `curl https://tapi.optimizely.com/api/js/odds/project/16347880103?project=16347880103&j_userId=123&q_userId=098&c_userId=456`


**Handling the response**

After you've made a request to with the formated URL based on your list upload type and name, you can determine if the specified user ID is in your list.

In the response object, there is object called `lists` that contains a set of key value pairs for if the user is in the list based on the parameters you request.

*Example Response*
```{"location":{"continent":"North America","country":"US"},"ip":"12.44.117.104","lists":{"test_list":false,"cookie_upload":true,"js_upload":true},"lists_metadata":{"test_list":[{"key":"q_userId","value":"098"}],"cookie_upload":[{"key":"c_userId","value":"456"}],"js_upload":[{"key":"j_userId","value":"123"}]},"projId":"16347880103"}%```

### Putting this together with Full Stack

In order to use List Upload with Full Stack, you will need to 1. Form the request to determine which lists a user is in, and 2. Pass the response in as attributes

How to setup a test with list targeting in Full Stack.

1. Register your lists as [attributes](https://docs.developers.optimizely.com/rollouts/docs/attributes) in your Full Stack project
2. Create [audiences](https://docs.developers.optimizely.com/rollouts/docs/audiences) with that attibute where the value is either true or false (boolean)
3. Create your feature flags/experiments using that audience
4. Before activating or checking if a feature is enabled, call the list targeting endpoint, and pass the ['lists'] object from the response into your activate/is_feature_enabled calls

