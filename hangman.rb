require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader'

require_relative 'GameTools.rb'

set :sessions, true

use Rack::Session::Pool

module Tools
	extend GameTools
end

include Tools

title = 'Hangman'
blank = '__'
letter_bank = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
			   'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
			   'y', 'z']

class Game
	def create_slots(word, length)
		open_slots = {}
		length.times do |index|
			letter = word[index]
			open_slots[letter] = false
		end
		return open_slots
	end

	attr_reader :secret_word
	attr_reader :guess_slots
	attr_reader :guessed_letters
	attr_reader :turns_left

	def initialize(secret_word)
		@secret_word = secret_word
		@guess_slots = create_slots(secret_word, secret_word.length)
		@guessed_letters = []
		@turns_left = (secret_word.length/2 + 2)
	end

	def guess(letter)
		if @guess_slots.keys.include? letter
			@guess_slots[letter] = true
		end

		if !(@guess_slots.keys.include? letter) &&
		   !(@guessed_letters.include? letter)
		   		@turns_left -= 1
		end

		if !(@guessed_letters.include? letter)
		   		@guessed_letters << letter
		end
	end

	def solved?
		@guess_slots.values.all? true ? true : false
	end
end

get '/' do 
	redirect '/newgame'
end

get '/gameover' do 
	erb :gameover, layout: :index, :locals => {:title => title, :game => session[:game]}
	#prompt, new game option yielded
end

get '/newgame' do 
	word = Tools::get_new_word
	session[:game] = Game.new(word)
	erb :play, layout: :index, :locals => {:title => title, :game => session[:game], :blank => blank, :letter_bank => letter_bank}
end

get '/guess' do 
	letter = params["char"]
	session[:game].guess(letter)
	if session[:game].turns_left > 0 && !(session[:game].solved?)
		erb :play, layout: :index, :locals => {:title => title, :game => session[:game], :blank => blank, :letter_bank => letter_bank}
	else
		redirect '/gameover'
	end	
end

