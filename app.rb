require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require 'twilio-ruby'
require 'json'
# require 'facebook/messenger'
require 'httparty'

# require 'unsplash'


configure :development do
  require 'dotenv'
  Dotenv.load
end

require 'twilio-ruby'

# require 'ibm_watson'
# #IBM ibm_watson
# #API Key: 38Xw5RwE28WLF-vYJvQm-EAVkxZxOcpuCOeUFlMKMGhP
# #URL: https://gateway-wdc.watsonplatform.net/natural-language-understanding/api
# discovery = IBMWatson::DiscoveryV1.new(
#   version: "2018-03-16",
#   iam_apikey: "<38Xw5RwE28WLF-vYJvQm-EAVkxZxOcpuCOeUFlMKMGhP",
#   iam_url: "https://gateway-wdc.watsonplatform.net/natural-language-understanding/api" # optional - the default value is https://iam.ng.bluemix.net/identity/token
# )


enable :sessions

post "/signup" do
  # code to check parameters
	#...
  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  # Include a message here
  message = "Hi" + params[:first_name] + ", welcome to BotName! I can respond to who, what, where, when and why. If you're stuck, type help."

  # this will send a message from any end point
  client.api.account.messages.create(
    from: ENV["TWILIO_FROM"],
    to: params[:number],
    body: message
  )
	# response if eveything is OK
	"You're signed up. You'll receive a text message in a few minutes from the bot. "
end

#Facebook

#talk to facebook
# get '/webhook' do
#   params['hub.challenge'] if ENV["VERIFY_TOKEN"] == params['hub.verify_token']
# end

# get "/" do
#   401
# end
#
#
# error 401 do
#   "Not allowed!!!"
# end





#IBM NLU API

#   # If using IAM
#   natural_language_understanding = IBMWatson::NaturalLanguageUnderstandingV1.new(
#   iam_apikey: "38Xw5RwE28WLF-vYJvQm-EAVkxZxOcpuCOeUFlMKMGhP",
#   version: "2018-03-19"
# )
#
# response = natural_language_understanding.analyze(
#   text: "Bruce Banner is the Hulk and Bruce Wayne is BATMAN! " \
#         "Superman fears not Banner, but Wayne",
#   features: {
#     "entities" => {},
#     "keywords" => {}
#   }
# ).result
# puts JSON.pretty_generate(response)
#
# def search_IBM_NLU_for body
#
#
#   IBM.configure do |config|
#     config.key
#
#   end
#
#   response = natural_language_understanding.analyze(
#
#     puts response




#Unsplash

# def search_unsplash_for response
#
#   Unsplash.configure do |config|
#     config.application_access_key = ENV['UNSPLASH_ACCESS_KEY']
#     config.application_secret = ENV['UNSPLASH_SECRET']
#     config.utm_source = "ExampleAppForClass"
#
#   end
#
#   # search for whatever search term, give 1 page of results, with 3 results per page
#   search_results = Unsplash::Photo.search( search_term, 1, 1)
#
#   puts search_results.to_json
#
#   images = ""
#
#   puts search_results.size
#
#   search_results.each do |result|
#     #puts result.to_json
#
#     puts "Result"
#
#     image_thumb = result["urls"]["thumb"]
#
#     puts result["urls"]["thumb"].to_json
#     image_description = result["description"].to_s
#     images += "<img src='#{ image_thumb.to_s }' /><br/>"
#     images += "<hr/>"
#   end
#   return images
# end

#IBM
  # natural_language_understanding = IBMWatson::NaturalLanguageUnderstandingV1.new(
  #   iam_apikey: "38Xw5RwE28WLF-vYJvQm-EAVkxZxOcpuCOeUFlMKMGhP",
  #   iam_url: "https://gateway-wdc.watsonplatform.net/natural-language-understanding/api",
  #   version: "2018-03-16"
  # )
  #
  # response = natural_language_understanding.analyze(
  #   text: "some sample text",
  #   features: {
  #     "entities" => {},
  #     "keywords" => {}
  #   }
  # ).result
  #
  # response[:features][:keywords]
  # puts JSON.pretty_generate(response)

#IBM


get "/incoming/sms" do
  session["last_intent"] ||= nil
  session["counter"] ||= 1
  count = session["counter"]

  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip

  if session["counter"] == 1
  message = "Hello curious soul, my name is Freud. I know you are one of those who seeks to deepen the knowledge about yourself. Dream is the small hidden door in the deepest and most intimate sanctum of our souls. I am here to help you interpret and visualize your dreams.

You can ask me:
🧐 How do you do that?
👀 Tell me more about yourself."
  media = nil
  elsif body.include? "how can you help" or body.include? "how do you do"
  message = "First, I would like to ask you a few questions to get to know you better.

After that, you will start receiving vivid images and interpretations on your dreams.

Your dreams will be kept securely in your personal dream collection. As your dream journal grows you can look back not just at your thoughts and feelings but spot patterns that will help you on your journey of self-discovery.

Sound good?"
   media = nil
   elsif body.include? "tell me more about yourself"
   message = "....."
   media = nil
   elsif body.include? "sounds good" or body.include? "let's get started"
   message = "How often do you remember your dreams? You can say 'everyday','a few times a week', 'barely', 'sometimes', etc."
   media = nil
   elsif body.include? "everyday" or body.include? "few times a week" or body.include? "barely" or body.include? "rarely" or body.include? "sometimes"
   message = "Noted. People typically only remember their dreams right after they wake up. That’s why it’s important to keep a dream journal.
             Now you are all set to receive the verbal and visual interpretations of your dream. Are you ready for your first dream decoding session?"
   media = nil
   elsif body.include? "yes" or body.include? "i'm ready" or body.include? "i am ready"
   message = "Tell me about your dream last night."
   media = nil
   elsif body.include? "mother" or body.include? "mom"
   message = "A mother in your dream may represent several things:

   1. Your mother herself.

   2. The feminine part of yourself, the nurturing aspect of your own character.

   3. Your ideal woman.

   4. Your relationship with an important female figure.

Pick a representation that you think may match up with your dream given your current real life situation.

Type in a number to see detailed explainations, or 'mother' to see the whole list.

            "
   media = nil
   # media = search_unsplash_for ('mom')
   else
   message = "I don't understand you"
   media = nil
end

# Build a twilio response object
  twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|

      # add the text of the response
      m.body( message )

      # add media if it is defined
      unless media.nil?
        m.media(media)
      end
    end
  end
  # increment the session counter
  session["counter"] += 1



  # send a response to twilio
  content_type 'text/xml'
  twiml.to_s
 end
