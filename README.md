# Georgia Election Protocols
This app takes the scanned protocol images from the CEC website and allows users to enter the data using a double-blind data entry verification process. Once a protocol's data is verified, it will be available to the public for viewing and download.

# Methodology

## TLDR
* Download the scanned protocol images from the CEC
* Users data enter the protocol data
* Upon double-blind data entry verification, the data is saved and is made public
* Users can view the public data on the site or they can download the data

## Scraping the CEC site
Two scrapers exist to download the scanned protocols from the CEC site. The scraper files are located in the `script` folder. 

One scraper looks for protocols that have not been downloaded yet. The scraper calls a json api method to get a list of all the districts and precincts for all active elections that are missing protocols. The scraper then looks for these protocols on the CEC site. If they are found, the images are downloaded and saved to the `public/system/protocols` folder.

The second scraper looks for supplementary documents that are attached to protocols. These documents may be added at any time and one protocol may have several documents. The scraper calls a json api method to get a list of all districts and precincts for all active elections. The scraper then looks through every single record to see if new supplementary documents exist. If so, they are downloaded and saved into the `public/system/protocols` folder.

The sole job of these scrappers is to download the images. That is all. A rake task is run periodically to check for new images in the `public/system/protocols` folder, and if found, the database is updated to indicate that these documents exist and data needs to be entered.

## Training
Before users can start entering protocol data, they must go through a training session with 5 sample protocols. Once they properly enter the 5 training protocols, they can start entering real protocol data.

## Deciding which protocol to show to the user
The `CrowdDatum.next_available_record` method is responsible for finding the next protocol to show to the user. This methods looks for 3 possible matches:
* a protocol has been entered by another user and needs verification
* a protocol has been entered by multiple users, but a matching set has not been created yet
* a protocol has no data entered for it yet

Zero or 1 records are found in each of the above methods. Out of this set, a random record is selected and assigned to the user through the `CrowdQueue` model.

## Validating the protocol data
Upon submitting data for a protocol, `CrowdDatum.match_and_validate` is called to look for a match with an existing data record for this protocol.
* If no record for this protocol is on file, nothing happens at this time
* If one or more records are found, the new record is compared to all existing records. 
  * If a match is found, the protocol is flagged as being complete and the data is saved and made public
  * If not match is found, then nothing happens at this time.

## Reporting issues
The protocols are filled out by hand and then scanned. This leaves a lot of room for human error and so the data entry form has the ability to flag issues.
* No protocol - the protocol image was not downloaded properly and needs to be re-downloaded
* Missing information - at least one part of the protocol was not filled in properly
* Can't read - It is not possible to read the handwritting
* Documents not clear - The instructions in the protocol supplemental documents are not clear, cannot be read, or do not match the data that is in the protocol
* Is annulled - The protocol has been marked as annulled and does not need to be data entered

The app has a moderation section that allows moderators to view these reports and take action.
* Re-download the protocol image
* Confirm that the protocol is annulled - protocol will not be given to a user to enter its data
* Follow-up an issue with the CEC - outside scope of this app
* New supplementary documents fix the issue - releases the protocol to be data entered again
* No problem - cancel the issue and releases the protocol to be data entered again

## The data entry form
The data entry form is built so that the protocol appears in the middle of the screen and the data entry fields appear down the right side in alignment with the protocol fields so data entry is as easy as possible.

Protocols are not always scanned in perfectly straight, so a control box is provided at the bottom of the screen to move the protocol up and down and to rotate it in order to better align the protocol to the form fields. 

This control box also contains a magnification box that shows a zoomed in view of the area under the mouse cursor. This is helpful when trying to read bad handwritting.

The bottom of the data entry form contains a logic check to help indicate if the numbers you entered are good. It takes the number of ballots signed for and subtracts it from the sum of the parties and invalid ballots. If this equation equals zero, the section will turn to green and if the equation is not zero, the section will be red. Due to protocol procedural errors, it is possible that the correct numbers are entered, but the logic check fails, or that you enter the wrong numbers and the logic check passes. The logic check is just there for guidance but is not perfect indicator of entering data correctly.

Finally, the form has a section to report problems. This is discussed about in the `Reporting issues` section above.

# Managing elections
To add a new election, some preperation work is required. There is a form to enter all of the necessary information. Migration tasks have also been used to load data quickly on the production server.

Below is an explanation of the election fields:
* election name - name of the election
* election date - date of the election
* can enter data - indicates if users are allowed to enter data for the election
* character between the district and precinct - typically, the format is district-precinct (i.e., 10-1), but the parliamentary elections have started to use dots (i.e., 10.1) so this fields indicates which character is being used. This value is used to properly create the file name in the CEC URL
* election portal event id - the id of the event in the Georgia Election Data site that corresponds to this election. See `Sending data to the Georgia Election Data site` below for more information.
* CEC scrapping settings used to create the URL to the protocol to download
  * domain - the domain to find the results, typically `results.cec.gov.ge`
  * election folder path to the - the folder path in the URL to the election, something like `/oqm/1/`
  * page pattern - the html name for the protocl page, something like `oqmi_{id}.html`, where {id} will be replaced with the appropriate id for the protocol which is typically the district_id-precinct_id (i.e., 10-1)
* data entry form settings
  * top box margin top - a number in pixels that the form fields at the top of the protocol should be shifted down so the form fields align with the fields on the protocol
  * party box margin top - a number in pixels that the party form fields should be shifted down so the form fields align with the fields on the protocol
* flags - boolean flags used in some part of the site
  * same parties for all districts - if each district has the same parties or if the parties vary by district (i.e., party list election vs. majoritarian election)
  * has regions - if the data that is to be created for the election data site should include regions; this should almost always be false since we stopped using region shapes
  * has district names - if the district name is text or and id; parliamentary elections have started using numbers, but all other elections use names
  * has custom shape levels - if the data that is to be created for the election data site should include special shape levels like Tbilisi (Tbilisi districts are too small to see so they are grouped into a generated Tbilisi district and clicking on this will show the districts in Tbilisi).
  * has independent parties - if the data that is to be created for the election data site contains independent parties; if yes, the results of each of these parties are merged into one independent party record for the election site
  * is local majoritarian election - local majoritarian elections contain an extra level between the district and precinct that no other elections have; this flag makes sure that this extra level is properly recorded and managed.
* CSV files - files used in past election can be found in the `db/data` folder
  * party - a list of all of the parties for this election; columns are:
    * party number
    * party name
    * independent party (boolean - leave blank if false)
  * districts/precincts - a list of all districts and their precincts for this election; columns are:
    * district - district id
    * precinct - precinct id
    * if is local majoritarian, then the major id should be inserted between the district and precinc
  * districts/parties - a list of the parties in each district; only needed if the parties are different in each district (same parties for each district is false); columns are:
    * district - district id
    * party - party number
    * if is local majoritarian, then the major id should be inserted between the district and party

# Special Cases 

## Local Majoritarian Elections
These elections have an extra layer of complexity. In addition to the district and precinct, there is now a majoritarian district in between the district and precinct. The ID of this district is of a different format: district_id.majoritarian_id, i.e., 01.02. It is also possible for there to be a sub-majoritarian district so in this case the ID will be 01.01.01.

This majoritarian ID is only needed for generating the data for the election data site. For this site, everything is still tied to the district and precinct which still works with local majoritarian elections.

# Sending data to the Georgia Election Data site
The admin section has a section called `Election Data Migration` that allows an admin to load the latest data from an election into the election data site. The protocol site keeps records of all data that is migrated to the election data site and uses this info to show how many new data records will be added to the election site if a migration is started.

# Techinical Details

## Databases
The protocols app uses two database: one to store the data entry records and one that summarizes all of the results for analysis. This means two databases need to be created and the user that has access to the first database also needs access to the second.

The second database name is hardcoded and should be called protocol_analysis.

You will need to grant access to this second database and make sure you include the ability to 'create view'.
GRANT select, insert, update, delete, create, alter, index, drop, create view, references ON `protocol_analysis`.* TO `username`@localhost IDENTIFIED BY 'password';



# TODO
* add scraper to get the data from CEC so it is possible to compare their party counts to ours
* add ability to flag unusual supplementary documents (i.e., too tired, singing, etc)
