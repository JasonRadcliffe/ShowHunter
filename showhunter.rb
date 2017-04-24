
require 'net/http'
require 'json'
require 'date'
require 'mailgun'

def send_email(emailBody)

	#modified api key
  	mg_client = Mailgun::Client.new("key-297b8fb482fc51106e22e6d7c39")

	message_params =  {
	                   from: 'Mailgun Sandbox <postmaster@sandboxc2496bc8b5aa4482b13eef64e32ae0c7.mailgun.org>',
	                   to:   'Jason Radcliffe <jasonjradcliffe@gmail.com>',
	                   subject: 'TV Show report',
	                   text:    emailBody
	                  }

	#modified sandbox url
	result = mg_client.send_message('sandboxc2496bc8b5aa4482b13eef64e32ae0c7.mailgun.org', message_params).to_h!

	message_id = result['id']
	message = result['message']

end
puts "test"
showlist = [
'3341',		#fixer upper
'31',		#Agents of Shield
'13',		#The Flash
'2790',		#The Good Place
'5495',		#Lethal Weapon
'1850',		#Supergirl
'1864',		#Superstore
'49',		#Brooklyn Nine Nine
'9315',	 	#No Tomorrow
'2474', 	#Life in Pieces
'618',		#Better Call Saul
'3104',		#Trial & Error
'13638',	#Making History
'66',		#The Big Bang Theory
'17129',	#Imaginary Mary
'2793',		#Powerless
'44',		#Scorpion
'143'		#Silicon Valley
]

showCount = 0;
emailBody = ""

showlist.each do |show|

	url = 'http://api.tvmaze.com/shows/' + show
	uri = URI(url)
	response = Net::HTTP.get(uri)
	resultingHash = JSON.parse(response)
	name = resultingHash["name"]

	#make sure there is a next eposede listed before continuing
	if resultingHash["_links"].has_key?("previousepisode") 


		prevEpisodeURL =  resultingHash["_links"]["previousepisode"]["href"]
		uri = URI(prevEpisodeURL)
		response = Net::HTTP.get(uri)
		resultingHash = JSON.parse(response)
		airdate_str = resultingHash["airdate"]

		airdate = Date.parse(airdate_str)

		
		yesterday = Date.today.prev_day

		if airdate === yesterday
			showCount+=1

			emailBody += name + " - Season " + resultingHash['season'].to_s + " Episode " + resultingHash['number'].to_s + "\n"
			
			#puts "Show yesterday: " + name + "!!!!\n\n\n\n\n"
			seasonNum = resultingHash["season"]
			episodeNum = resultingHash["number"]
			gotOne = true
			while (gotOne && episodeNum > 1)
				episodeNum -= 1
				prevPrevEpisodeURL = 'http://api.tvmaze.com/shows/' +
					show + '/episodebynumber?season=' +
					seasonNum.to_s + '&number='+ episodeNum.to_s
				uri = URI(prevPrevEpisodeURL)
				response = Net::HTTP.get(uri)
				resultingHash = JSON.parse(response)
				airdate_str = resultingHash["airdate"]
				airdate = Date.parse(airdate_str)
				if airdate === yesterday
					showCount+=1
					emailBody += name + " - Season " + resultingHash["season"].to_s + " Episode " + resultingHash["number"].to_s + "\n"
				else
					gotOne = false
				end
			end
			
			
		end

		#puts airdate.year
		#puts airdate.month
		#puts airdate.day

	end
end

emailBody.insert(0, "There were " + showCount.to_s + " shows yesterday!\n");
puts emailBody
send_email(emailBody)






