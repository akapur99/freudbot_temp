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
get "/test-nlp" do

  text = "A hero can be anyone. Even a man doing something as simple and reassuring as
  putting a coat around a little boy's shoulder to let him know that the world hadn't ended."

  response = get_npl_for(text)

  puts response.to_json

  keywords = get_keywords_from_response response

  keywords.to_s
end

def get_keywords_from_response resp

  return [] if resp.nil?


  keywords = []
  puts resp
  resp["keywords"].each do |kw|
    keywords << kw["text"]
  end

  return keywords

end


def get_npl_for text


  features = {
   sentiment: {}, keywords: {}, concepts: {}, emotion: {}, entities: {}
  }

  data = {
   "features" => features,
   "text" => text
  }
  params = {  "version" => "2018-03-19"  }

  headers = {
   "Content-Type"=>"application/json"
  }

  auth = { username: "apikey", password: ENV['WATSON_API_KEY'] }

  data = data.to_json if data.instance_of?(Hash)

  url = ENV["WATSON_URL"]
  method = "/v1/analyze"


 response = HTTParty.post(
   url + method,
   basic_auth: auth,
   headers: headers,
   query: params,
   body: data
   )

end



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

    return image_thumb.to_s
  end
  images
end


def search_answer_for body
message = " "
array_of_lines = IO.readlines("symbols.txt")
array_of_lines.each do |line|

  items=[ ]
  items=line.split ("=")
  symbols=items[0]
  answers=items[1]


  if body.include?symbols.to_s
     message = items[1]
  else
     message= items[1]
  end

  end

  return message.to_s
end


greetings = ["Hello ", "Hey ","Hi "]
goodbye = ["Alright. Happy dreaming! I will talk to you later.", "Hope this was helpful. Have a great day!"]


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
   elsif body.include? "jo"
   session[:name]= body
   message = greetings.sample.to_s + session[:name].capitalize + ". I know you are one of those who seeks to deepen the knowledge about yourself.

Dream is the small hidden door in the deepest and most intimate sanctum of our souls. I am here to help you interpret and visualize your dreams.

How do I do that? Enter 🧐 to find out more. "
   # message.split('<br />')


   elsif body.include? "hi" or body.include? "hey" or body.include? "hello"
   message = "👋 Hi welcome back! What did you dream of last night?"


   elsif body == "🧐"
   message = "Right after you wake up every morning, I will remind you to log your dreams with me. I will analyze your dream and send you visual and verbal representations of major symbols in your dreams.

Your dreams will be kept securely in your personal dream collection. As your dream journal grows you can look back not just at your thoughts and feelings but spot patterns that will help you on your journey of self-discovery.

Ready for your first dream interpretation? Type 👍 to begin; or “menu” to get a list of things you can do. "

   elsif body == '👍'
   message = "Tell me about your dream last night. Try share main symbols appeared in your dream. For example: “mother”, “dark night”, etc. "

#===============================DREAM ANALYZING================================#
#----------------demo--------------#
   elsif body.include? "a lot of water"
   message = "Water was a symbol in your dream. Is that correct?"
   elsif body.include? "that's correct"
   message = "Great. Water represents your subconscious thoughts and emotions. Type 'image' to visualize your dream."
   elsif body == "image"
   message = "This is the visual representation of your dream."
   media = "https://images.unsplash.com/photo-1505142468610-359e7d316be0?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=689dc19dacb860a85a79530515114632&auto=format&fit=crop&w=562&q=80"
   elsif body.include? "not correct"
   message = "Sorry, let’s try again. I identified that you mentioned" + "sea" + "and" + "beach" + "as key symbols in your dream, type in a symbol to see its interpretation."
   elsif body == "large body of water"
   session[:symbol]= body
   message = "Great" + session[:symbol] + "represents/.........." + "Here is a visual representation of your dream"
   media = "https://unsplash.com/photos/sLAk1guBG90"
   elsif body.include? "pic" or body.include? "picture" or body.include? "photo"
   message = "I have logged this dream and image in " + session[:name].capitalize + "’s dream journal. You can always type “search: symbol” to read your past dreams related to this symbol.

Is there anything else I can help you with today? To interpret another dream, type 'I dreamt...', or enter 'menu' to get a list of things you can do."

#You can always type “search: symbol” to read your past dreams related to this symbol.
   elsif body.include? "that's it" or body.include? "nope" or body.include? "goodbye" or body.include? "bye" or body.include? "ttyl"
   message = goodbye.sample.to_s
   elsif body.include? "thank you" or body.include? "thanks"
   message = "My pleasure."

#----------------API--------------#
      elsif body.include? "i dreamt"
      session[:dream] = body
      response = get_npl_for( body )

      keywords = get_keywords_from_response( response )
      puts keywords
      answer = search_answer_for (keywords[0])
      image = search_unsplash_for( keywords.join( ", ") )
      media = image
      message = keywords[0].capitalize + " was a symbol in your dream. " + answer

    # elsif body == "yep"
    #   response = get_npl_for( body )
    #   puts response
    #   keywords = get_keywords_from_response( response )
    #   puts keywords
    #
    # # message = "Great, let's get started with interpretation of your dream." + keywords[0].capitalize + "represents..... Type 'image' to visualize your dream."
    # # elsif body == "image"
    #
    # image = search_unsplash_for( keywords.join( ", ") )
    # media = image
    # message = "Great. Here is the visual representation of " + session[:dream]



#-------------------------------HOUSEKEEPING-----------------------------------#
    elsif body == "menu"
    message = "📖 To search a particular dream from your dream journal. Enter 'search: + keywords'. (e.x: search: mother).

To learn more about Freud, enter 'Freud'.

To learn common dreams and what supposedly mean, enter 'common'.

To hear interesting facts about dreams, enter 'facts'."

    elsif body.include? "fact"
    array_of_lines = IO.readlines("facts.txt")
    message = array_of_lines.sample.to_s
    elsif body.include? "common"
    array_of_lines = IO.readlines("common.txt")
    message = array_of_lines.sample.to_s
    elsif body== "search: water"
    message = "There was a lot of water in my dream. I saw myself on a beach. The waves were turbulent."
    media = "https://images.unsplash.com/photo-1505142468610-359e7d316be0?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=689dc19dacb860a85a79530515114632&auto=format&fit=crop&w=562&q=80"
    else
    array_of_lines = IO.readlines("error.txt")
    message = array_of_lines.sample.to_s
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
    message.each_with_index do |element,i|
      r.message do |m|
      puts i
      # add the text of the response
      m.body(message[i])
      # add media if it is defined
      unless media.nil?
        m.media(media[i])
      end
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
