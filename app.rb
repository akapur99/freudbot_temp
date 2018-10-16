require 'sinatra'
require "sinatra/reloader" if development?
#require 'sinatra/activerecord'
require 'twilio-ruby'
require 'json'
# require 'facebook/messenger'
require 'httparty'
require 'unsplash'
#require 'twilio-ruby'


configure :development do
  require 'dotenv'
  Dotenv.load
end



enable :sessions


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

# get '/incoming/sms' do
#   "Hello World"
# end

greetings = ["<h1>Hello ", "<h1>Hey ","<h1>Hi "]
goodbye = ["<h1>Great. Happy dreaming! I will talk to you later.", "<h1>Awesome, hope it's helpful. Have a great day!"]


get "/incoming/sms" do

  session["last_intent"] ||= nil
  session["counter"] ||= 1
  count = session["counter"]

  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip
  message = " "
  media = nil
# thank_you = ["ddd"]
# message=thank_you.sample.to_s
#==============================ONBOARDING======================================#
   if session["counter"] == 1
   message = "Hello curious soul, my name is Freud. What's your name?"
   # elsif body.include?"hi"
   # # session[:name]= body
   # message = "What's your name?"
   elsif body.include? "jo"
   # /or body.include? "I'm" or body.include? "I am"
   session[:name]= body
   message = greetings.sample.to_s + session[:name] + ". I know you are one of those who seeks to deepen the knowledge about yourself.
   <br />
   Dream is the small hidden door in the deepest and most intimate sanctum of our souls. I am here to help you interpret and visualize your dreams.
   <br />
   How do I do that? Enter 🧐 to find out more. "
   # message.split('<br />')

#======================FUTURE GREETINGS DOES NOT WORK!!!=======================#
   # elsif body.nil?
   # message = "👋 Hi welcome back! What did you dream of last night?"


   elsif body == "🧐"
   message = "Right after you wake up every morning, I will remind you to log your dreams with me. I will analyze your dream and send you visual and verbal representations of major symbols in your dreams.
   <br />
   Your dreams will be kept securely in your personal dream collection. As your dream journal grows you can look back not just at your thoughts and feelings but spot patterns that will help you on your journey of self-discovery.
   <br />
   Ready for your first dream interpretation? Type 👍 to begin; or “menu” to get a list of things you can do. "
   message.split('<br />')

   elsif body == '👍'
   message = "Tell me about your dream last night. Try to be as specific as possible.
   <br />
   Since we cannot act on our unconscious desires in our waking life, we can explore these feelings in dreams. However, we tend to do this in hidden, symbolic forms.
   <br />
   Try sharing main symbols appeared in your dream. For example: “my mother”, “dark night”, etc. "

#===============================DREAM ANALYZING================================#
#----------------demo--------------#
   elsif body.include? "water"
   message = "A large body of water is a symbol in your dream. Is that correct?"
   elsif body.include? "that's correct"
   message = ["Great, let's get started with interpretation of your dream.Water represents...........","Here is a visual representation of your dream: "]
   media = [nil,"https://unsplash.com/photos/sLAk1guBG90"]
   elsif body.include? "not correct"
   message = "Sorry, let’s try again. I identified that you mentioned" + "sea" + "and" + "beach" + "as key symbols in your dream, type in a symbol to see its interpretation."
   elsif body == "large body of water"
   session[:symbol]= body
   message = ["Great, let's get started with interpretation of your dream." + session[:symbol] + "represents/..........", "Here is a visual representation of your dream"]
   media = [nil,"https://unsplash.com/photos/sLAk1guBG90"]
   elsif body.include? "thank you"
   message = ["You are very welcome. I have saved logged this dream in " + session[:name] + "’s dream journal.", "You can always type “search: symbol” to read your past dreams related to this symbol. Is there anything else I can help you with today?"]
   elsif body.include? "that's it"
   message = goodbye.sample.to_s

#----------------API--------------#
    # elsif body.include? "I dreamt of" or body.include? "In my dream"
    # message = IBM + " is a symbol in your dream. Is that correct?"
    # elsif body == "Yes, that's correct."
    # message = "Great, let's get started with interpretation of your dream.
    # <br />
    # Water represents...........
    # <br />
    # Here is a visual representation of your dream"
    # media = search_unsplash_for ("IBM")
    # elsif body == "Cool. Thank you Freud."
    # message = "You are very welcome. I have saved logged this dream in " + session["name"] + "’s dream journal. You can always type “search: symbol” to read your past dreams related to this symbol. Is there anything else I can help you with today?"
    # elsif body == "Nope, that's it."
    # message = goodbye.sample.to_s


#-------------------------------HOUSEKEEPING-----------------------------------#
    elsif body == "menu"
    message = "To start logging and analyzing your dream, type “I dreamt” followed by your dreams.
    <br />
    📖 To search a particular dream from your dream journal. Enter “search: + keywords”. (e.x: search: mother)
    <br />
    To learn more about about. enter “Freud”
    <br />
    To learn common dreams and what supposedly mean, enter “common”
    <br />
    To hear interesting facts about dreams, enter “facts"
    elsif body == "facts"
    array_of_lines = IO.readlines("facts.txt")
    message = array_of_lines.sample.to_s
    elsif body == "common"
    array_of_lines = IO.readlines("common.txt")
    message = array_of_lines.sample.to_s
    else
    message = "Sorry I didn't recognize that. Type 'menu' to get a list of options."
    end

#Test
# Build a twilio response object
  if message.class==String
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
  puts twiml.to_s
  return twiml.to_s
  end


  if message.class==Array
    twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|
    message.each_with_index do |element,i|
      puts i
      # add the text of the response
      m.body(message[i])
      # add media if it is defined
      # unless media.nil?
      #   m.media(media[i])
      # end
    end
  end
  # increment the session counter
  session["counter"] += 1
  # send a response to twilio
  end
  content_type 'text/xml'
  return twiml.to_s
  end

 end
