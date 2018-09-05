module GameTools
	def get_new_word
		dict = load_dict
		return dict[rand(dict.length - 1)]
	end

	def load_dict
		dict = []
		#picks words between 5 and 12 chars in length
		File.foreach('./dict.txt') do |line|
			if line.length >= 7 && line.length <= 14
				dict << (line.gsub(/\n\r/, ' ').strip.downcase)
			end
		end
		return dict
	end

	
end