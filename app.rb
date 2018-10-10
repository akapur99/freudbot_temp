require 'sinatra'
require "sinatra/reloader" if development?
require 'twilio-ruby'

configure :development do
  require 'dotenv'
  Dotenv.load
end

require 'twilio-ruby'

#twilio number
#9738334107

enable :sessions

get "/" do
	"Hello world!"
end



get "/" do
 	     redirect '/about'
end



get "/incoming/sms" do
  session["last_intent"] ||= nil

  session["counter"] ||= 1
  count = session["counter"]

  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip

  if session["counter"] == 1
    message = "It's Bear here 🐻. I'm a fun-loving, caring and insightful bear. Try talk to me and see what I say 😉 . Type in 'questions' to get a list of questions you can ask me."
    media = "https://media.giphy.com/media/xNQTp4xqjY22I/giphy.gif"
  # elsif body.include? "bear" or body.include? "hey" or body.include? "hi" or body.include? "hello"
  #   message = "Hey you! Bear here 🐻. What do you want to know about me today? Type in 'questions' to get a list of questions you can ask me."
  elsif body.include? "like to do" or body.include? "like doing" #when user ask what do you like to do
    message = "I like to eat honey, and read! I'm a well-read bear. Ask me about my favorite books."
    media = "https://media.giphy.com/media/84ZzhsJZWlE3e/giphy.gif"
  elsif body.include? "quote" #"what's your favorite quote?"
    message = "A well-read bear is a dangerous creature.🤓"
  elsif body.include? "questions"
    message = "You can ask me questions such as:

    \"what's your favorite quote?\"

    \"what do you like the most?\"

    \"what do you do for fun?\"

    \"what are bear's favorite books?\"

    \"what do you like to do?\"

    "

  elsif body.include? "favorite books"
    message = "You just picked my favorite question! Hummm but I can only share it if you feed me with honey 🍯😎...alright alright here you go:

    \"Man's Search for Meaning\"

    \"Sapiens: A Brief History of Humankind\"

    \"Walden\"

    \"The Unbearable Lightness of Being\"

    \"The Wisdom of Life\"

    Try type in the title of the book and I will let you know what I think about the book!"
    media ="https://media.giphy.com/media/126BrhLh4YgwkE/giphy.gif"
  elsif body.include? "like the most"
    message = "Food...and honey! "
    media = "https://media.giphy.com/media/fdWVI1op6wi88/giphy.gif"
  elsif body.include? "do for fun"
    message = "Cuddle with my pillow."
    media = "https://media.giphy.com/media/2QIbGQ1WEVF6M/giphy.gif"
  elsif body == "man's search for meaning"
    message = "After I read this book, which I finished many, many years ago, I had become self-critical of any future endeavours which would take up a lot of my time.I would ask myself 'is this or will this be meaningful to me?', and if the answer was 'no', I wouldn't do it. It was this book that influenced me to consciously live as meaningful a life as possible, to place a great value on the journey and not just the destination, while knowing that 'meaningful' doesn't always mean 'enjoyable', 'Meaningful' should be equated with 'fulfilling'.

    🐻 Now...type another book title or just say goodbye to me."

  elsif body == "sapiens: a brief history of humankind"
    message = "I believe I am relatively familiar with history in general, and I'm usually not very excited about reading more about it. But this book was something else. Beautifully written and easy to read, this book just made me want to know more and more about how the author thinks the world evolved to what it is today. Revolution by revolution, religion by religion, conception by conception, things were simplified and yet still maintained valid points - and it was never boring.

    🐻 Now...type another book title or just say goodbye to me."

  elsif body == "walden"
    message = "Thoreau makes us an apology for a healthy life away from the bustle of cities and constraints of modern society and castrating. Life as it should savor with nothing and everything around you and beyond us when we want others through profit prohibit enjoyment. Unlike many philosophers understandable for a pretentious intellectual minority, Thoreau speaks true to all of the original life that we live simply and 'naturally poetic.' An indispensable bible!

    🐻 Now...type another book title or just say goodbye to me."

  elsif body == "the unbearable lightness of being"
    message = "Kundera observes the stuff that goes on internally amongst the characters; he intellectualizes it, and tells you about it. He’s quite philosophical, and you feel like the narrator is talking to you, offering very insightful observations about the characters and life in general. This is one reason why reading is often more valuable than watching TV or a movie: when reading a good book you get direct psychological explanations, and you get to go inside the heads of characters.

    🐻 Now...type 'more' to learn see more of my thoughts on this book, another book title or just say goodbye to me."

  elsif body == "more"
    message = "Taken as a whole, I found this novel to be profound, but in unusual ways. It’s not a direct novel, but rather one that represents, and lets one feel, disconnections and various glimpses of perceptions. And it wasn’t a smooth novel, either. It even felt choppy on occasion. But the chapters are short, which fits its feel, and also gives you time to think about the penetrating thoughts that Kundera puts across. Kundera strikes me as a craftsman of sorts. He switches timelines deftly and effectively – even when I thought he was crazy to do so; when I thought he gave up the climax of the novel towards its middle, he proved me dead wrong. He proved to me that he knew exactly what he was doing because he’s a master of the craft. This novel is not full of sweeping, pounding paragraphs of poignant, soul-hitting, philosophical depth, but rather offers up constant glimpses; nuggets of insightful observations on almost every page, that when added up together, reveal an impressive, heartfelt, and real work. 🐻 Now...type another book title or just say goodbye to me."


  elsif body == "the wisdom of life"
    message = "Beginning with the assumption that one's life will be essentially painful and miserable, Schopenhauer proceeds to offer thoughts about how we can eke out a bit of pleasure for ourselves during our brief time on this earth. Underlying much of his advice is the notion one should proceed cautiously, with restraint, curbing one's desires to avoid falling into situations, social or consumptive that will only make us more miserable. Don't desire too much, he implies, let happiness rest on small simple elements.

    Much of Schopenhauer's advice resonates with our modern sensibilities. Maintaining physical and mental health through exercise of body and mine is, he says, essential to happiness.

    Much of the advice offered is familiar to us but the thoroughness of his insights into how one best live one's life is definitely worth reading and rereading.

    🐻 Now...type another book title or just say goodbye to me."
  elsif body.include? "bye" or body.include? "goodbye" or body.include? "ttyl" or body.include? "see you"
    message = "Bye. Ttyl!"
    media = "https://media.giphy.com/media/JPbZwjMcxJYic/giphy.gif"
  else
    message = "Hmmmm...I didn't understand that 🧐. Try type in 'questions' to get a list of questions you can ask me."
end
#

  #try ask what do you do everyday, selecting among giphy" "this is what i like to do" "want to see more?"
  #'tell me a little bit more about yourself, and i will tell you more'

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
