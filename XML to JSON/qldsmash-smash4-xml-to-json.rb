require 'JSON'
require 'nokogiri'
require 'date'
require './helpers.rb'

puts "Starting qldsmash XML -> JSON conversion process."

xml = Nokogiri::XML(File.read "SSBU.xml")
xml = xml.xpath("//EloXmlModel")


puts "SSBM.xml imported! Starting parser."

createDate 	= xml.xpath("CreatedDate").text
gameName 	= xml.xpath("GameName").text
gameShort 	= xml.xpath("GameShort").text

#puts "#{createDate}, #{gameName}, #{gameShort}" 

eloHash = {:createDate => createDate, :gameName => gameName, :gameShort => gameShort, :items => [], :players => [], :tourneys => [], :characters => [], :regions => []}

i = 0
eloItems = xml.xpath("Items//EloItemXmlModel")
totalMovements = eloItems.size

eloItems.each do |item|
	

	print "\r\tElo Movement Progress...#{(i/totalMovements.to_f * 100).round(2).to_s.ljust(4)}%"
	i+=1
	rank 				= item.xpath("Rank").text.to_i
	localRank 			= item.xpath("LocalRank").text.to_i
	score 				= item.xpath("Score").text.to_i
	rankMovement 		= item.xpath("RankMovement").text.to_i
	localRankMovement	= item.xpath("LocalRankMovement").text.to_i
	scoreMovement 		= item.xpath("ScoreMovement").text.to_i
	movements 			= []

	item.xpath("Movements/EloMovementXmlModel").each do |movement|

		oldScore 		= movement.xpath("OldScore").text.to_i
		newScore 		= movement.xpath("NewScore").text.to_i
		oppOldScore 	= movement.xpath("OpponentOldScore").text.to_i
		oppNewScore 	= movement.xpath("OpponentNewScore").text.to_i
		oppID 			= movement.xpath("OpponentID").text.to_i
		oppName 		= movement.xpath("OpponentName").text
		oppIsTagged		= movement.xpath("OpponentIsTagged").text
		tourneyID 		= movement.xpath("TourneyID").text.to_i
		eventName 		= movement.xpath("EventName").text
		playerCharImg 	= movement.xpath("PlayerCharImage").text
		isWin 			= movement.xpath("IsWin").text
		change 			= movement.xpath("Change").text.to_i
		winnerName 		= movement.xpath("WinnerName").text
		note 			= movement.xpath("Note").text


		movementHash = {:oldScore => oldScore, :newScore => newScore, :oppOldScore => oppOldScore, :oppNewScore => oppNewScore,
						:oppID => oppID, :oppName => oppName, :oppIsTagged => oppIsTagged, :tourneyID => tourneyID,
						:eventName => eventName, :playerCharImg => playerCharImg, :isWin => isWin, :change => change,
						:winnerName => winnerName, :note => note}
		#puts "#{oldScore}, #{newScore}, #{oppOldScore}, #{oppNewScore}, #{oppID}, #{oppName}, #{oppIsTagged}, #{tourneyID}"
		#puts "#{eventName}, #{playerCharImg}, #{isWin}, #{change}, #{winnerName}, #{note}"
		#puts movementHash.to_s

		movements.push movementHash

	end


	playerID 			= item.xpath("PlayerID").text.to_i
	characters 			= []


	item.xpath("Characters/int").each do |character|

		characterID 	= character.text.to_i
		characters.push characterID

	end


	hasCharacterData 	= item.xpath("HasCharacterData").text
	characterUsage 		= []


	item.xpath("CharacterUsage/EloItemCharacterUsageItem").each do |charUsage|
		
		overallCharUse 	= charUsage.xpath("OverallCharacterUsage").text.to_i
		relativeCharUse = charUsage.xpath("RelativeCharacterUsage").text.to_i
		characterID		= charUsage.xpath("CharacterID").text.to_i

		characterHash = {:overallCharUse => overallCharUse, :relativeCharUse => relativeCharUse, :characterID => characterID}
		characterUsage.push characterHash
		#puts characterHash.to_s
	end

	itemHash = {:rank => rank, :localRank => localRank, :score => score, :rankMovement => rankMovement, :localRankMovement => localRankMovement,
				:scoreMovement => scoreMovement, :movements => movements, :playerID => playerID, :characters => characters, 
				:hasCharacterData => hasCharacterData, :characterUsage => characterUsage}

	#puts itemHash.to_s

	eloHash[:items].push itemHash

end
print "\r\tElo Movement Progress...Done!\n"
players = xml.xpath("Players//XmlPlayerModel")
totalPlayers = players.size
i = 0

players.each do |player|

	print "\r\tPlayer Progress...#{(i/totalPlayers.to_f * 100).round(2).to_s.ljust(4)}%   "
	i+=1

	playerID 			= player.xpath("ID").text.to_i
	name 				= player.xpath("Name").text
	siteLink 			= player.xpath("SiteLink").text
	siteLinkTitle 		= player.xpath("SiteLinkTitle").text
	regionID 			= player.xpath("RegionID").text

	playerHash = {:playerID => playerID, :name => name, :siteLink => siteLink, :siteLinkTitle => siteLinkTitle, :regionID => regionID}
	#puts playerHash.to_s
	eloHash[:players].push playerHash

end
print "\r\tPlayer Progress...Done!\n"
tourneys = xml.xpath("Tourneys//XmlTourneyModel")
totalEvents = players.size
i = 0

xml.xpath("Tourneys//XmlTourneyModel").each do |tourney|

	print "\r\tTourney Progress...#{(i/totalEvents.to_f * 100).round(2).to_s.ljust(4)}%   "
	i+=1
	tourneyID 			= tourney.xpath("ID").text.to_i
	name 				= tourney.xpath("Name").text
	displayName 		= tourney.xpath("DisplayName").text
	regionID 			= tourney.xpath("RegionID").text.to_i
	tourneyDate 		= tourney.xpath("TourneyDate").text
	siteLink 			= tourney.xpath("SiteLink").text
	siteLinkTitle 		= tourney.xpath("SiteLinkTitle").text

	tourneyHash =	{:tourneyID => tourneyID, :name => name, :displayName => displayName, :regionID => regionID, :tourneyDate => tourneyDate,
					 :siteLink => siteLink, :siteLinkTitle => siteLinkTitle}
	#puts tourneyHash.to_s
	eloHash[:tourneys].push tourneyHash
end
print "\r\tTourney Progress...Done!\n"



regionCharData = JSON.parse(File.read('smash4-end.json'))

eloHash[:characters] = regionCharData["characters"]
eloHash[:regions]	 = regionCharData["regions"]

print "\tCharacter and Regions Progress...Done!\n"
puts "Parsing complete! Starting data format."
newFormatHash = {:lastUpdated => eloHash['createDate'], :game => eloHash['gameShort'], :players => []}



playerIDHash 	= Helpers.getPlayerIDHash eloHash
tourneyIDHash 	= Helpers.getTourneyIDHash eloHash
charIDHash 		= Helpers.getCharIDHash eloHash
regionIDHash 	= Helpers.getRegionIDHash eloHash

#puts playerIDHash.to_s
#puts tourneyIDHash.to_s
#puts charIDHash.to_s
#puts regionIDHash.to_s

playerDataItems = eloHash[:items]


totalItems = playerDataItems.size
i = 0

playerDataItems.each do |item|

	print "\r\tReformat Progress...#{(i/totalItems.to_f * 100).round(2).to_s.ljust(4)}%   "
	playerID 	= item[:playerID].to_i
	regionID 	= playerIDHash[playerID][:regionID].to_i
	region 		= regionIDHash[regionID][:short]
	playerName	= playerIDHash[playerID][:name]
	currentElo	= item[:score].to_i
	mains 		= item[:characters].map {|char| charIDHash[char][:short]}

	playerInfo = {:playerName => playerName, :id => playerID, :region => region, :currentElo => currentElo, :mains => mains, :matches => []}

	matchData = item[:movements]

	matchData.each do |match|

		opponentName 	= match[:oppName]
		opponentID 		= match[:oppID].to_i
		tournamentID 	= match[:tourneyID].to_i
		tournamentName	= tourneyIDHash[tournamentID][:name]
		date 			= tourneyIDHash[tournamentID][:date]
		win 			= match[:isWin]
		eloChange 		= match[:change].to_i
		elo 			= match[:oldScore].to_i
		opponentElo 	= match[:oppOldScore].to_i


		matchInfo = {:opponentName => opponentName, :opponentID => opponentID, :tournamentName => tournamentName,
					 :tournamentID => tournamentID, :date => date, :win => win, :eloChange => eloChange, :elo => elo,
					 :opponentElo => opponentElo}

		playerInfo[:matches].push matchInfo
	end

	newFormatHash[:players].push playerInfo
end
print "\r\tReformat Progress...Done!\n"
puts "Outputting completed file to 'formattedSSBU.json"
File.open("formattedSSBU.json", 'w') { |file| file.write(JSON.pretty_generate(newFormatHash))}
puts "Finished!"
