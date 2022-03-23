# Changelog
## Fire Journal
![image Fire Journal Logo](Fire%20Journal/Assets.xcassets/AppIcon.appiconset/icon-with-flame1024x1024.png)
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 4.5.7 [3.3.9.1.7] - 2021-0223
### Ready for app store - awaiting feedback from Test Flight users
### Added disclosure buttons to Map Pins on Maps for Incidents, ARCForm, ICS214
### When button is tapped form is displayed.
### Although the form is pulled in as segue it was not unwinding properly, neither was use of AddObserver
### Used VCLaunch on all three forms with MapFormHeaderV as the buttons for the forms to make call and release.
### VCLaunch forces the map to reload with the correct modal type, also the list is updated.
### Made minor change in Store to fix the issue with crashing when Store was accessed while in Settings

## 4.5.6 [3.3.9.1.6] - 2021-0123
### Ready for app store - awaiting feedback from Test Flight users
### Made pdf api available for both ICS214 and ARCForm
### Minor changes

## 4.5.5 [3.3.9.1.4] - 2020-1028
### Ready for app store - awaiting feedback from Test Flight users
### Updated the edit mode for Fire Station Resources.
### Changed the keyboard for some fields in Edit Fire Station Resources
### Reported issues with ICS214 could not be replicated iPhone save on existing form or new failure
### Reported issues with ICS214 could not be replicated on iPad continue after choosing effort type
### Reported issue with Map navigation crashing. Could not replicate.

## 4.5.5 [3.3.9.1.3] - 2020-1028
### Ready for app store - awaiting feedback from Test Flight users
### Added 7 reload routines on the Settings page, in case the default lists go missing
### Personal Journal - My Journal area was saving each time there was an edit rendering use impossible.
### Personal Journal - Tags was not loading even thought saved
### ARCForm - Head was not getting the address loaded when map used, added ARC_Head to be updated
### ARCForm - Phone fields are now displaying a number keypad



## 4.5.5 [3.3.9.1.2] - 2020-1023
### Ready for app store - awaiting feedback from Test Flight users
### ARCForm on Maps was crashing need to make adjustment
### on Phone removed ARCForm from map

## 4.5.5 [3.3.9.1.0] - 2020-1023
### Ready for app store - awaiting feedback from Test Flight users
### Moved iPhone version of ARCrossForm to a separate app named FJ ARC Plus
### Rebuilt the ARCrossForm for iPad to match the new format that the other forms used.
### Archived OldARCrossForm files
### Added new storyboards from the iPhone app FJ ARC Plus
### Due to secure coding wrote script that captures all entries in ARCrossForm, ICS214Form, Incident, Journal, FireJournalUser Location fields that have CLLocations stored and added new fields to each entity that mirrored those adding a suffix of SC. Operation grabs the CLLLocation and secure codes the CLLocation as Data and stores in new attributes that are transformable and have them using NSSecureUnarchiveFromDataTransformer
```
if theForm.arcLocationSC != nil {
    
        if let location = theForm.arcLocationSC {
            guard let  archivedData = location as? Data else { return cell }
            do {
                guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  cell }
                let location:CLLocation = unarchivedLocation
                cell.theCurrentLocation = location
            } catch {
                print("something's going on here")
            }
        }
}
```
### For cloudkit storage we can use Locaiton Type so unpack the data and save as location - meaning we don't have to change the CloudKit data structure. Coming back into the app from CloudKit need repack
```
if fjARCrossRecord["arcLocation"] != nil {
    let location = fjARCrossRecord["arcLocation"] as! CLLocation
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        fjuARCForm.arcLocationSC = data as NSObject
    } catch {
        print("got an error here")
    }
}

````
### Fixed the cell callout on incident Aditional Station Apparatus call
### Set the placeholders for Street Type and Street Prefix
### Set the Incident Number field on NewerIncidentModal to a number Keypad keyboard.

## 4.5.4 [3.3.9.0.8] - 2020-0804
### Ready for app store - awaiting feedback from Test Flight users
### Added ICS 214 has been updated adopting the form UI Journal, Personal, Incident, Start, Update and End Shift use.
### Added the ability to update each member of your crew with ICS Position, Home Agency, Phone and Email.
### Easier connection with your Contacts list.
### On the iPhone the list of ICS 214 and CRR forms are accessable from the form, no longer will you be sent back to the home menu when dismissing a form.
### The user experience for creating a new ICS 214 form has been updated to the new UI, and you can create a new Incident in the New ICS 214 form with the same interface that is used in the Dashboard, including Fire/EMS Resources.
### Sharing your ICS 214 has been added, the form is sent to our servers to be put in the proper ICS 214 format, and returned to you as a web link which you can share via, text message, email, facebook, twitter, evernote, etc.
### Campaigns can be closed and all of the associated campaign forms will be closed and marked in the menu list with the From and To Dates.

## 4.5.4 [3.3.9.0.5-7] - 2020-0728-0729
### Ready for app store - awaiting feedback from Test Flight users
### Fixed:
### 2 issues came up during testing
### The NSFetchResultControllerDelegate was breaking on the Assigned Resources TVC
### when a new name was added by the header delegate or when new crew were added
### from the contacts list.
### I knew that this sort of issue was working correctly on the ListTVC - so I grabbed that delegate
### pushed in to replace the broken area. This fixed the issue
### On testing for iPhone today, noted that the new incident and new ICS214 Form were
### getting squeezed in horizontal format, not very nice, so switched from delivering these
### as presenting ViewControllers, but rather wrapped them in a segue Detail seguing from
### NewICS214ModalTVC. It works nicely in both iPhone and iPad.

## 4.5.4 [3.3.9.0.4] - 2020-0727
### Ready for app store - awaiting feedback from Test Flight users
### Fixed:
### Actually transformed the ICS214 Form, Activity Log and Personnel forms
### replaced the first swift component I built for the app, with a better understanding of
### keeping the form structure and the data graph working well together
### not only do all of the cells now resemble the cells on the forms in Journal, Incident,
### start, update and end shift, new journal, new incident, new private journal
### The code is clean and I think much easier to read ad discern how it's made up
### Took considerable work to update the whole form process, the new form process has 
### five possible routes with creating a master form for a campaign and four possible routes
### for creating a member of a campaign.
### 1. Choose between first form (master) or Additional forms
### 2. Choose the type of form team - four choices Local Incident, Strike Team, FEMA, other
### 3. If local incident is chosen the user can choose to click Search and the list of available 
### Incidents are listed to be chosen as the incident to tie the campaign to, or the user can
### choose to create a new Incident, rebuilt to match the new incident form on the dashboard
### and then move onto the Master for the campaign.
### If FEMA, Strike Team or other are chosen the user then is asked to fill out The name of the
### strike team, give an name to the incident and pick an address
### 4. Returning for additional forms to add to a campaign the user is given the list of masters
### that are associated with the choice of open campaigns Local Incident, FEMA, Strike Team or Other.
### Additionally when a local incident is tied to a campaign it's Incident Notes are updated
### with the information about that ICS 214 Activity Log, and a journal entry is made with a
### summary added to the journal entry. If the choice is FEMA, Strike Team, Other an incident
### is not tied to the form, but a journal entry is.
### Also all three forms for a Local Incident are then saved and sent to Cloud Kit, and FEMA,
### Strike Team and other , journal, ics 214 are sent to the cloud.
### Additionally, Personnel was difficult to edit on the table view, so a separate view is
### is populated with the crew person to be edited, this makes for managing the crew easier
### when edited, CloudKit is also updated.
### Each time personnel is saved to the form, ICS214Personnel, is updated and sent to cloudkit
### Each time Activity Log is updated, or created ICS214Activity is saved and sent to cloudKit
### Signature is also working, saving and downloading to other devices being used.

## 4.5.3 [3.3.9.0.2] - 2020-0618
### Ready for app store - awaiting feedback from Test Flight users
### Fixed:
### Bug in Settings - My Fire Station Resources, adding information into a Resources info was causing the app to crash, this has been fixed.
### Bug adding a custom Resource in Settings - Fire/EMS Resources was not saving into the group and not being added to My Fire Station Resources list, this has been fixed.

## 4.5.2 [3.3.9.0.1] - 2020-06-04
### Ready for the app store - awaiting feedback from Test Flight users
### Fixed:
### The collectionview that is being used for the displaying the Fire/EMS Resources needed to have collectionView.reloadData applied to it when reloading.
### Also added saveTheIncident to each retrieval of either UserResources or Additional Station Apparatus delegate functions.

## 4.5.2 [3.3.9.0.0] - 2020-06-03
### Ready for the app store - awaiting feedback from Test Flight users
### Fixed:
### Added new tet to InfoBodyText for the info button on IncidentTVC to leave new instructions on how to work with Additional Station Apparatus sequence
### When user taps on Additional Station Apparatus - those apparatus already chosen are sent to the new Modal so that user knows which one they have already applied.

## 4.5.2 [3.3.8.9.9] - 2020-06-02
### Ready for the app store - awaiting feedback from Test Flight users
### Fixed:
### My fire station resources delete 
### Remove move up from update shift
### New incident inside incident doesn’t pick the newest to show
### Journal and incidents on phone go back to lists
### After incident created needs to add fire ems resources if necessary - added button on IncidentTVC
### Created new enum InfoBodyText - subject and body messages on all alerts - storing all text for these alerts in one place. Very helpful, but tedious to build

## 4.5.1 [3.3.8.9.8] - 2020-05-22
### Ready for the app store - submitted Wednesday 05/20/2020
### Fixed:
### LabelCell needed an identifier
### DetailViewController added var cellCount - weather was looking to update cell 6 when there were only 2 cells on the collectionView, setting it as 2 or 7
### fjUserTime.updateShiftSupervisor was not coming in as "" instead it was coming in as null and causing issue with filling in the supervisor name.
### In onboardForm changed getTheFireJournalUser()->FireJournalUser to getTheFireJournalUser()->Int then in buildFJUOnBoard() check to see if fju: FireJournalUser is not nil to add user to textfields.


## 4.5.1 [3.3.8.9.7] - 2020-05-20
### Ready for the app store - submitted Wednesday 05/20/2020
### Fixed:
### iPhone updates allow for 1st Incident and Personal Journal entries from the navigation menu.
### The Update Shift supervisor is now carried over from Start Shift and can be updated with a new supervisor.
### Updated the Journal Entry for Update Shift to include the supervisor in its report.
### Onboarding checks if the user has used the app before.
### Changed the way the Current Weather displays Wind, wind direction with speed mph.

## 4.5 [3.3.8.9.6] - 2020-05-16
### Ready for the app store - submitted Saturday 2020,05,16
### Final few fixes before pushing forward
### 'Learn More' button on data alert is now pointing to store for more info
### Update shift - supervisor is brought over from start shift, but may be changed
### Contacts list is correctly loading in - moved the tableview.reloadData out of the closure
### If there is only one incident for the day - both arrow buttons go on hidden, non enabled, alpha 0.0
### SettingsTVC Cloud was changed to About Membership, info bar for modal has been removed

## 4.3.4 [3.3.8.9.5] - 2020-05-15
### Ready for testing
### Once app is approved to go to store will change version # to 4.5 [3.3.8.9.4]
### David had a set of fixes and bugs he and others had run up against and I went through them systematically and checked off each, many of them were style driven, but others were problems with Core Data.
###[x]I would suggest reviewing ALL of the “info/help” pop-ups as some end with a “.” (period) and some do not. I think they should all end with a period. 
###[x]If you create an ICS-214 form, then close out the forms (after having two in place), the app quits. However, the closing out of the form collection for that incident does take. 
###[x]In the ICS 214, if you try to add an individual to #6 Resources Assigned, when you tap on ADD, the app quits (and the person is NOT saved).
###[x]Put off - In the Smoke Alarm form, just above the signature, the field “Resident’s Date is greyed out for both the resident and the installer. It may be that it is greyed out due to implementing the date comes from completion of the form. If so, it shouldn’t work that way. It may be that people make hand written notes and enter the data a day or two later, so they should have the ability to modify the date. 
###[x]If you create a new incident, the start screen shows you your available resources among other things. When you tap on SAVE and the main incident screen appears, what you selected in the start screen is NOT shown. Instead, you see ALL of the resources that are assigned to that station (as you set things up in Settings). AND - every piece of apparatus shows as available - even though in my case three out of six apparatus elements were not available.
###1. Upgrade notice
###[x]I think it would be useful if the options (buttons) on the upgrade the app notice were “Get it” and “Dismiss” - or similar, as “Okay” doesn’t really indicate that you’re going to open the store. 
###2. Incident and Support Notes “info” text (updated):
[###x]“Enter descriptive information regarding the incident for future use and to document what took place. You may add notes over time, and each will be time stamped. If you have personal comments, not intended for department or general distribution, you may tap on ‘Support Notes’ and add your personal thoughts or comments.”
###3. Text color in various options throughout “Incident” form. 
###[x]The action “Cancel” is in blue on Red. It’s harsh. Is it possible for this type of action text (button) to be in white? “Cancel” is in white for Fire/EMS Resources and looks good. 
###[x]4. The header “Tags” at the bottom of Incidents is a plain white header - different from every other header in Incidents. 
###5. Copy under “Choose a Form” when selecting “Forms” from the main nav menu:
###[x]Select the appropriate form for use when involved in campaign incidents, or when supporting the community. Additional functionality, including export in NIMS format is available when you opt to become a member. (link should go to Fire Journal Store - not to the website) DELETE the website link.
###6. Choose a Form
###[x]Question: Should the two available forms have a + somewhere in the description box to demonstrate a consistent method of starting something new?
###7. Cloud
###[x]Question: What happens when you select “Cloud” and you haven’t purchased a membership? I don’t have a non-membership environment, so don’t know if there are issues to note…
###8. Coud Sync Copy (updated)
###[x]“You’re about to access the Membership Cloud via your web browser. To get back to Fire Journal, tap on the little “return…” icon at the top left of the page.”
###9. Settings/My Fire Station Resources
###[x]There are no instructions or related header for My Fire Station Resources. Instead, there is the “Info” button. Should all Settings include this newer form of “help”???
###10. Fire Journal Terms and Conditions
###[x]The title is is in the header and again right below. Should it only be in the header? (black text over white). Also, no need for “Fire Journal” in the title.”
###NOTE: This appears to be the case in all of the Settings. Evaluate and update as you see fit.
###11. Fire Journal User Privacy
###[x]The same as #10, but also, this should be titled “User Privacy” - No need to include “Fire Journal” in the title.
###12. Settings/Fire Journal Cloud (updated) - Title should change to “Membership"
###[x]This copy should be replaced with the membership copy from the store. To include this would be confusing. We added this to avoid Apple rejecting the app. 
###12. Incidents/Fire-EMS Resources Help
###[x]Remove the word “Additional” from the title.
###13. Info buttons throughout the app
###[x]Some are bold, and some are not. Bold looks good.
###14. Info notes copy in Update Shift - we removed updating members, so we need to update the copy, as follows:
###[x]“If there are changes to your location (moving up to another fire station or location), or if the status of a piece of apparatus change, you may update the status here. If a supervisor changes (related to yoru move up, or replacement), make that change here as well. If a member changes, add that detail in the notes field.” 
###15. New Journal Entry / Choose Your Assignment (and Apparatus)
###[x]The CANCEL button is blue text on top of blue text. It’s hard to read.
###16. New Journal Entry / Choose Your Platoon
###[x]This model looks out of place with the others and the cancel is in the lower left at the bottom. I like the style, but it’s inconsistent with the other options.
###17. ARC Smoke Alarm Form (multiple items)
###[x]- The Cancel button is blue on the of blue.
###[x]- When selecting + the ARC Smoke Alarm Form should be deleted - just use the CRR Smoke Alarm Form in the Blue header. Keep the RED CROSS icon
###[x]- New Copy (and will more closely match ICS-214): Rebuild the New Form for CRR
###Purpose:
###[x]The CRR Smoke Alarm Form is for use when inspecting a single family residence (home or apartment) for working smoke alarms. This form will provide for tracking of distribution of smoke alarms, the impact on the family or persons living in the unit described, the location, and other relevant data that will impact Community Risk Reduction efforts.
###Preparation:
###[x]A CRR form can be implemented as a one-off individual form. Alternatively, you may create a “campaign” in the event you’re canvassing a neighborhood or a series of residences. Personnel should document as many items within the form as possible, and get each “head of household” to sign the form at the bottom. An installer or member in attendance should also sign the form. 
###Distribution:
###[x]Distrubtion is available via the Membership module (learn more about membership) and may be sent via email, or printed as a PDF form. The PDF form matches the format as established by the American Red Cross. 
###18. ICS-214 Activity Log (updated copy when + New Form is selected:
###Purpose:(no change)
###Preparation:(no change)
###Distribution:
###[x]Completed ICS-214s are stored in Fire Journal and may be referenced at any time. Once you become a Fire Journal Member (larn more about membership), ICS forms can also be printed as complete NIMS compliant documents. Completed PDF or printed documents should then be shared with supervisors, who forward them to the Documentation Unit. The Documentation Unit should maintain a file of all ICS 214 forms. You may search and share any ICS-214 that you’ve completed at any time (Membership required).
###NEW COPY:
###[x]When you select FIRST FORM, you’ll be able to record a series of ICS-214s as individual operational period journals, all linked to the same incident. Once you “close out” the last operational period for thta incident, Fire Journal will be ready to start another sequence. Note that below you have four different types of deployments to link your ICS-214 to. Select the one that’s appropriate for your deployment. 
###[ selection options ]
###NEW COPY BELOW:
###[x]Remember, you will have the option of sharing completed ICS-214 reports either electronically via PDF, or in print form, both appearing in the standard NIMS form [ Membership required for sharing ].
###[x]1. Tapping on the forms option in the menu does nothing. It doesn’t launch the form options.
###[x]2. if you attempt to create a personal journal entry, when you tap on save, the app quits, and the entry is not saved. I can repeat this consistently.
###[x]Forms works on the iPad.
###[x]Personal Journal entry does not.\n###[x]If you’re using an incident, and you are working with the Time and Date section (under notes), if you try to advance the time past the current time, or backwards to a previous time, those inputs are ignored and ONLY the current time will post. This becomes a problem if the officer is trying to complete a form after the fact.


## 4.3.4 [3.3.8.9.4] - 2020-05-06
### Ready for testing
### Once app is approved to go to store will change version # to 4.5 [3.3.8.9.4]
### Added detection script that checks if the version in the appstore is the same as the version being used. If they don't match a alert is presented. If the user chooses "Okay" the alert is dismissed and SKStoreProductViewController is loaded with a reference to the app, user can then download the app
### Right now as the app in the store is older 4.3.3. than the app being tested 4.3.4 it shows download - and when it's correctly lined with where the app would be 4.5 and user would have 4.3.4 it is supposed to show update.
### Dismiss will dismiss the alert and mark it as having been shown until the app is loaded again.

## 4.3.4 [3.3.8.9.3] - 2020-05-02
### Ready for testing
### Once app is approved to go to store will change version # to 4.5 [3.3.8.9.4]
### Forms button is working from the Menu
### Need new screen shots for the store
### Built for phone the new load procedures onto the MasterViewController
### Worked through the process of first time user experience making sure only parts of dashboard load until an incident is created
### Added new onboarding text
### Added in new subscription pricing and add new store text
### Added for first time user - after doing agreement - a modal is presented for the user to build their FDResources.
### Issues that are driving me a bit crazy - during rebuild with data - the UserFDResources do not load correctly until the app is reloaded and the same for weather. 
### This issue is related only to a user who has data in the cloud and deletes the app and now wants to reload the app.

## 4.3.4 [3.3.8.9.2] - 2020-04-25
### Ready for testing
### Dashboard changes from ScrollView To CollectionView
### New colors for Master Menu
### Adding Weather
### Adding Years of Incident
### Adding Todays Incidents
### Added Alert that app was going to download data from cloud
### Added Spin Indicator when first time downloading content from CloudKit
### Added numerous flags for preparing for first launch
### Added numerous notification Observers

## 4.3.2 [3.3.8.8.7-3.3.8.9.0] - 2020-03-29
### Ready for AppStore Release
### Fixed
- - - So this is what happens when you refactor the AppDelegate - you misplace the call to get the user only if the agreement has been agreed to, so of course the onboardingFormModal pops up empty - I was testing for if the cloud had been accessed and I was getting a true - it was only after the agreement was called, so there was nothing in the database for the user. Moved 
``` swift
_ = getTheUser(entity: "FireJournalUser", attribute: "userGuid", sortAttribute: "lastName")
```
from line to 143 to 150 AppDelegate.swift


## 4.3.2 [3.3.8.8.6] - 2020-03-2
### Ready for AppStore Release
### Fixed
- - - Added alert that let's me know if there was an error loading the data. Dismissing the form and pushing an alert so I can see what the error is as it's not showing on Xcode

## 4.3.2 [3.3.8.8.5] - 2020-03-27
### Ready for AppStore Release
### Fixed
- - - Added back in the context.descriptions - there has to be a reason why the persistant store is not loading I looked into the data and it's there and not registering. Fuck

## 4.3.2 [3.3.8.8.4] - 2020-03-27
### Ready for AppStore Release
### Fixed
- - - Errors still persist on downloading from TestFlight.
- - - Onboard Modal Form wrapped the fetch of the user from the Core Data with fetch count check as this mornings error report reported there was an error there so changed:
``` swift
var fetched:Array<Any>!
    //MARK: Changed to
var fetched: [FireJournalUser]!
```
``` swift
do {
           self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
           fireJournalU = (self.fetched.last as? FireJournalUser)!
       } catch let error as NSError {
           // failure
           print("Fetch failed: \(error.localizedDescription)")
       }
       //MARK: -CHANGED TO
       do {
           self.fetched = try context.fetch(fetchRequest) as? [FireJournalUser]
           if !self.fetched.isEmpty {
               fju = self.fetched.last
               buildFJUOnBoard()
           }
       } catch let error as NSError {
           // failure
           print("Fetch failed: \(error.localizedDescription)")
       }
```
- - - made other changes to textViews that had formatting added such as phone, link, etc but were also editable - doesn't mix well
- - - TextFields that had adjust font dyamically to size turned off on those textfields that were marked with system font.
- - - SettingsProfile page - made changes to save directive as in Landscape on iPad and on iPhone if the fields were not visible they were causing a crash because the cell was not available and forcing to grab text from text field not available wasn't available. Fixed with making the tableview scroll to top or bottom before getting text.


## 4.3.2 [3.3.8.8.3] - 2020-03-26
### Ready for AppStore Release
### Fixed
- - - Put in place check for AgreementBeingAccepted before looking for subscription, any loads of CloudKit other than the user for the onboarding.
- - - Was seeing some logs where the persistant store was not loading correctly, fixed that
- - - Deprecations had been put on NSKeyedUnarchiver.init, so went through all operations that use the CKRecord.encodeSystemFields - which was considerable as it is used all the operations.

## 4.3.2 [3.3.8.8.2] - 2020-03-20
### Ready for AppStore Release
### Fixed
- - - Error checking picked up some background tasks not canceling
- - - Made sure if user chooses, Additional Form on CRR smoke alarm, only those campaigns that are still incomplete are shown for choosing.
- - - If Additional Form is added to CRR Campaign, Title is marked with count.


## 4.3.2 [3.3.8.8.1] - 2020-03-20
### Ready for AppStore Release
### Fixed
- - - New ARCrossForm was marking new forms as complete.
- - - When viewed the Campaign Closed was displayed, all fields, switches turned off until Campaign was again marked incomplete.

## 4.3.2 [3.3.8.7.9]-[3.3.8.8.0] - 2020-03-19
### Ready for AppStore Release
- - - Made considerable changes to the ARCFormDetailTVC to make it save and update correctly
### Changes
- - - Created ArcFormData to help manage the data from the ArcCrossForm Object.
- - - Took out all delegate work and put into an extension
- - - Added some checks on whether the campaign was closed or not
- - - If closed the fields, steppers and switches will inform the user with an alert that the user will need to open the campaign once again.
- - - Made sure that when campaign is closed that all members of the campaign are closed
- - - Made sure that the list menu is updated when the campaign status changes.
- - - Steppers needed to have some work done on insuring the correct number was showing.

## 4.3.2 [3.3.8.7.8] - 2020-03-12
### Ready for AppStore Release
- - - Final error check on UpDate Shift - TextView when empty was firing an error when saving - made sure there was at least and empty string to make sure something was saved during the save routine.
### Changes
- - - Working on mapping the year count of incidents broken up by 'Fire', 'EMS', 'Rescue'
- - - After building for one year how to do for all years that might be needed.
- - - Keep iteration time down and memory crunch down.
- - - Converting each incident instance down to for Incident.incidentCreationDate using Calendar.dateComponents - year, month and Incident.situationIncidentImage
- - - Build Array of tuples [(year, incident)] and [( year, month, situationIncidentImage )]

## 4.3.2 [3.3.8.7.6-3.3.8.7.7] - 2020-03-11
### Added
- - YearOfMonths.swift
- - GatherIncidents.swift
- - - Building the Incident Object to use when calculating all of the totals for the new dashboard. Still need to add a year component.
### Changes
- - Changed on New Incident Modal and Incident the placeholder text to UIColor.secondaryLabel and regular text to UIColor.systemRed
- - Changed JournalInfoCell Labels 1-6 to UIColor.labelColor
- - Update and End Shift were not populating the Journal Platoon, Apparatus and Assignment - fixed
- - Error bug when update shift change of Station Apparatus was saving back to the viewcontroller it was supposed to refresh the row that holds the collectionview - it was aimed at 8 instead of 5, as there weren't eight row it was crashing.
- - Added the hour/minutes to the three shift entries in overview.
### Forward
- - Discuss changing onboarding to more graphic approach
- - Discuss changing store to membership
- - How to change the cell on the CRR Form that holds the signatures so that date pickers can be added.


## 4.3.2 [3.3.8.7.4-3.3.8.7.5] - 2020-03-09
### Added
- New Shift Modals
- -  StartShiftDashbaordModalTVC
- -  UpdateShiftDashboardModalTVC
- -  EndShiftBashboardModalTVC
- -  RelieveSupervisorModalTVC
- -  RelieveSupervisorContactsTVC
### Changed
- - Maps Interface
- - Crew was updated in Journal, Incident
### Code Change
- - Modal Presentation on iPhone
- - Added following code to viewDidLoad changing the frame setup for tableView
- - - if Device.IS_IPHONE {
    let frame = self.view.frame
    let height = frame.height - 44
    self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
    self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
    }
### Removed
- -  StartShiftModalTVC
- -  UpdateShiftModalTVC
- -  EndShiftModalTVC


 
