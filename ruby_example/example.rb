require 'optimizely'
require 'optimizely/optimizely_factory'
require 'logger'
require 'httparty'

logger = Optimizely::SimpleLogger.new 

# FULL STACK IMPLEMENTATION

SDK_KEY='your_sdk_key'

optimizely_instance = Optimizely::OptimizelyFactory.custom_instance(
    SDK_KEY,
    logger
  )

# LIST UPLOAD STUFF

# The Web project we'll check the uploaded list for
web_project_id = 'your_web_project_id'

# the user id that we'll check in the uploaded list & use for bucketing
user_id = '123'

# The list type that we created in Optimizely web; c=cookie, j=js-variable, q=query-pararm
list_type = 'c'

# The name we gave in Optimizely web for where to get the id
list_item_name = 'user_id'

# The name we gave when creating the list in the first place, we'll use this to check if a user is in a list
list_name = 'cookie_upload'

# Endpoint we'll use to see if user is in a list - NOTE you can request from multiple lists at time by adding more query params eg &j_anotherList=456&q_queryList=523 etc
list_upload_endpoint = "https://tapi.optimizely.com/api/js/odds/project/#{web_project_id}?productI=#{web_project_id}&#{list_type}_#{list_item_name}=#{user_id}" 

# Making a request to list upload endpoint to get back what lists I'm in
is_in_lists = HTTParty.get(list_upload_endpoint)

p is_in_lists['lists']

# Putting it together!

# Example using an experiment
# I included is_in_lists response for targeting purposes
# This will return the string variation that I am assigned
variation = optimizely_instance.activate('experiment_example', user_id, is_in_lists)

if variation == 'variation_1'
  # execute code for variation_1
  p 'In variation 1'
elsif variation == 'variation_2'
  # execute code for variation_2
  p 'In variation 1'
else
  # execute default code
  p 'Didn\'t qualify for the experiment'
end

# Example using a Feature Test
enabled = optimizely_instance.is_feature_enabled('example_feature_test', user_id, is_in_lists)

# You can define diffeerent values that will be dynamically returned 
string_variable = optimizely_instance.get_feature_variable_string('example_feature_test', 'string_variable', user_id, is_in_lists)

p "Is this flag enabled? #{enabled}"
p "If so, what should the value of my variables be: #{string_variable}"

# TODO - how to configure list targeting variables (e.g. names, types, project Ids etc) using Full Stack features
