File Descriptions:
	XML to JSON:

		qldsmash-melee-xml-to-json.rb 			Melee version of the xml parser. Takes "SSBM.xml" as input and outputs "formattedSSBM.json"
		qldsmash-smash4-xml-to-json.rb 			Smash4 version of the parser. Takes "SSBU.xml" as input and outputs "formattedSSBU.json"
		helpers.rb 							 	Ruby File that contains some help functions used in both parser files
		smash4-end.json 						Workaround file to qldsmash dropping character and region data from the xml data. Will need updates if new regions or characters are added
		melee-end.json 							Workaround file to qldsmash dropping character and region data from the xml data. Will need updates if new regions or characters are added
		sample-xml-structure/xml 				Very basic documentation of qldsmash XML data structure and a smaller example of the XML.

	Database:

		Gemfile 								Has all the gem requirements, you probably already know what this is if you've done any ruby work before
		ssbm-db-migrate.rb 						SSBM version of migration. Requires a valid "formattedSSBM.json" file
		ssbu-db-migrate.rb 						SSBU version of migration. Requires a valid "formattedSSBU.json" file

Guide to having your very own qldsmash json file


1. Get the XML file for Smash 4 (https://qldsmash.com/Content/Elo/SSBU.xml) or Melee (https://qldsmash.com/Content/Elo/SSBM.xml). I suggest wget but you do you.
2. Run qldsmash-smash4-xml-to-json.rb or qldsmash-smash4-xml-to-json.rb from the same directory as the XML file (requires Ruby)
3. Wait awhile
4. There should now be a file called 'formattedSSBU.json' or 'formattedSSBM.json', you're done.




If you want to convert that file into a postgresql database, read on.

1. Make sure you have one of the files outputted in the json steps above.
2. bundle install the gemfile or make sure you have all the gems listed in the file
3. Create the database and username/pw you want to access the db using the respective postgresql commands (look up createdb and createuser or using the GUI manager that comes with postgresql)
3a. Adjust the shitty db schema I rushed out in a night to have the data you want (OPTIONAL)
4. Run the respective db-migrate file.
5. Wait awhile
6. You're done.
