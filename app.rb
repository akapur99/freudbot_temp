require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require 'twilio-ruby'
require 'json'
# require 'facebook/messenger'
require 'httparty'
require 'unsplash'
require 'twilio-ruby'


configure :development do
  require 'dotenv'
  Dotenv.load
end



enable :sessions

post "/signup" do
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

get "/" do
  401
end


error 401 do
  "Not allowed!!!"
end

#IBMWatson
# get "/test-nlp" do
#
#   text = "A hero can be anyone. Even a man doing something as simple and reassuring as
#   putting a coat around a little boy's shoulder to let him know that the world hadn't ended."
#
#   response = get_npl_for(text)
#
#   puts response.to_json

#   keywords = get_keywords_from_response response
#
#   keywords.to_s
# end
#
# def get_keywords_from_response resp
#
#   return [] if resp.nil?
#
#
#   keywords = []
#
#   resp["keywords"].each do |kw|
#     keywords << kw["text"]
#   end
#
#   return keywords
#
# end
#
#
# def get_npl_for text
#
#
#   features = {
#    sentiment: {}, keywords: {}, concepts: {}, emotion: {}, entities: {}
#   }
#
#   data = {
#    "features" => features,
#    "text" => text
#   }
#   params = {  "version" => "2018-03-19"  }
#
#   headers = {
#    "Content-Type"=>"application/json"
#   }
#
#   auth = { username: "apikey", password: ENV['WATSON_API_KEY'] }
#
#   data = data.to_json if data.instance_of?(Hash)
#
#   url = ENV["WATSON_URL"]
#   method = "/v1/analyze"
#
#
#  response = HTTParty.post(
#    url + method,
#    basic_auth: auth,
#    headers: headers,
#    query: params,
#    body: data
#    )
#
# end



#Unsplash

def search_unsplash_for response

  Unsplash.configure do |config|
    config.application_access_key = ENV['UNSPLASH_ACCESS_KEY']
    config.application_secret = ENV['UNSPLASH_SECRET']
    config.utm_source = "ExampleAppForClass"

  end

  # search for whatever search term, give 1 page of results, with 3 results per page
  search_results = Unsplash::Photo.search( response, 1, 1)

  puts search_results.to_json

  images = ""

  puts search_results.size

  search_results.each do |result|
    #puts result.to_json

    puts "Result"

    image_thumb = result["urls"]["thumb"]

    puts result["urls"]["thumb"].to_json
    image_description = result["description"].to_s
    images += "<img src='#{ image_thumb.to_s }' /><br/>"
    images += "<hr/>"
  end
  images
end

get '/incoming/sms' do
  "Hello World"
end

# get "/incoming/sms" do
#
#   session["last_intent"] ||= nil
#   session["counter"] ||= 1
#   count = session["counter"]
#
#   sender = params[:From] || ""
#   body = params[:Body] || ""
#   body = body.downcase.strip
#   message = " "
#   media = nil
#
# # thank_you = ["ddd"]
# # message=thank_you.sample.to_s
#
#    if session["counter"] == 1
#    message = "Hello curious soul, my name is Freud. I know you are one of those who seeks to deepen the knowledge about yourself.
#    <br />
#    Dream is the small hidden door in the deepest and most intimate sanctum of our souls. I am here to help you interpret and visualize your dreams.
#    <br />
#    How do I do that? Enter 🧐 to find out more. "
#    message.split('<br />')


# #future encouters greeting.
#    # elsif body.nil?
#    # message = "👋 Hi welcome back! What did you dream of last night?"
#
#
#    elsif body == "🧐"
#    message = "Right after you wake up every morning, I will remind you to log your dreams with me. I will analyze your dream and send you visual and verbal representations of major symbols in your dreams.
#    <br />
#    Your dreams will be kept securely in your personal dream collection. As your dream journal grows you can look back not just at your thoughts and feelings but spot patterns that will help you on your journey of self-discovery.
#    <br />
#    Ready for your first dream interpretation? Type 👍 to begin; or “menu” to get a list of things you can do. "
#    elsif body == 👍
#    message = "Tell me about your dream last night. Try to be as specific as possible. Since we cannot act on our unconscious desires in our waking life, we can explore these feelings in dreams. However, we tend to do this in hidden, symbolic forms. So try to share main symbols appeared in your dream. For example: “my mother”, “dark night”, etc. "
#    elsif body == "menu"
#    message = "To start logging and analyzing your dream, type “I dreamt” followed by your dreams.
#    <br />
#    📖 To search a particular dream from your dream journal. Enter “search: + keywords”. (e.x: search: mother)
#    <br />
#    To learn more about about. enter “Freud”
#    <br />
#    To learn common dreams and what supposedly mean, enter “common”
#    <br />
#    To hear interesting facts about dreams, enter “facts"
#
#    elsif body.include? "mother" or body.include? "mom"
#    message = "A mother in your dream may represent several things:
#
#    1. Your mother herself.
#
#    2. The feminine part of yourself, the nurturing aspect of your own character.
#
#    3. Your ideal woman.
#
#    4. Your relationship with an important female figure.
#    <br />
#    Pick a representation that you think may match up with your dream given your current real life situation.
#    <br />
#    Type in a number to see detailed explainations, or type 'mother' to see the whole list."
#
#    media = search_unsplash_for ("mom")
#    elsif body.include? "my dream was" or body.include? "I dreamt"
#    media = get_keywords_from_response get_npl_for(text)
#    elsif body == "2"
#    message = "As mothers offer shelter, comfort, life, guidance and protection, to see your mother in your dream also represents the nurturing aspect of your own character."
#    media = "https://unsplash.com/photos/Q1zMXEI9V8g"
#    elsif body == "3"
#    message = "..."
#    elsif body == "facts"
#    array_of_lines = IO.readlines("facts.txt")
#    message = array_of_lines.sample.to_s
#    elsif body == "common"
#    array_of_lines = IO.readlines("common.txt")
#    message = array_of_lines.sample.to_s
#    else
#    message = "Sorry I didn't recognize that. Type 'menu' to get a list of options."
#    end
#  end

# Build a twilio response object
  twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|

      # add the text of the response
      m.body(message)

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
