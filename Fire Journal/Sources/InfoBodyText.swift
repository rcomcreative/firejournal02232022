//
//  InfoBodyText.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/2/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

enum InfoBodyText:String {
    case accessMembershipSubject = "Access Membership"
    case accessMembership = "You are about to access the Cloud Reporting module, which requires Membership."
    case accessMembershipMember = "You are about to access your Membership in the Cloud. To get back to Fire Journal, tap on the little “return…” icon at the top left of the page."
    case additionalFireEMSResourcesSubject = "Additional Fire/EMS Resources"
    case additionalFireEMSResourcesSubject2 = "Fire/EMS Resources"
    case additionalFireEMSResources = "Establish the fire and EMS apparatus in your fire station using the Fire/EMS option in Settings. Once saved, those resources will appear with each new incident.\n\nTap on the resource assigned to any incident. You’ll see a checkmark appear that indicates the apparatus is assigned and is part of the incident assignment.\n\nIf you need additional resources beyond what’s in your fire station, tap on the arrow button and a list of apparatus (as you have defined in Settings) will appear. Tap on the ones you want and they’ll be added. Note that any additional resources used will be saved to the incident, but will not change the apparatus you’ve assigned to your fire station."
    case additionalFireEMSResources2 = "You may need to add additional resources to your incident. To do so, slect Additional Station Resources using the + button, and then tap on the green available button to activate that apparatus to your incident. If you wish to add additional resources beyond that of your fire station, select Fire/EMS Resources, scroll through the list and tap next to each apparatus required for your incident. If you need to add a resource that isn’t in the list, you may update the list via Settings."
    case campaignSupportNotesSubject = "Campaign Support Notes"
    case campaignSupportNotes = "This campaign has been marked as complete, if you would like to change something on this campaign you need to go to the top of this form and change Campaign Closed to Campaign Started."
    case updateLocationSubject = "Update Data"
    case updateLocationMessage = "We're updating your data this will take a moment."
    case cloudDataSubject = "Cloud Data"
    case cloudData = "It looks like you might have data for Fire Journal on your iCloud account - it will start downloading now."
    case cloudDataSubject2 = "Data Backed Up"
    case cloudData2 = "Your data has been backed up. Access to backed up data requires a membership."
    case contactsSupportNotesSubject = "Contacts Support Notes"
    case contactsSupportNotes = "Choose those members of your contacts that you would like to add to your team members, you can make muliple selections."
    case deletionIncompleteSubject = "Deletion Incomplete"
    case deletionIncomplete = "There was an issue. The "
    case deletionIncomplete2 = "entry could not be deleted."
    case endShiftRecordedSubject = "End Shift Recorded"
    case endShiftRecorded = "When you’re about to end your shift, note the time (tap on the clock icon), indicate who is relieving you, and add any notes about the important issues from your shift that you’ve shared with your relief."
    case endShiftRecordedSubject2 = "End Shift Recorded Info"
    case endShiftRecorded2 = "Your End Shift has been recorded into your Journal Entries, you can add more information into the Discussion, Next Steps and Summary areas of the Journal."
    case fireEMSResourcesSubject = "Fire/EMS Resources Info"
    case fireEMSResources = "Fire Journal is set up to allow you to not only manage what you do in managing your fire station and incidents, but to also manage the apparatus (resources) within your fire station - using the ID assigned by your Departent. For example, BC1 may relate to Battalion Chief for the Battalion 1 district. You may edit the list below to better conform to your Department. Simply type in the resource in the field below, then tap on the + button. To delete a resource, swipe left.\n\nAdditionally you can choose up to 10 Resources for use in your Shift and Incident Assignments."
    case fireEMSResourcesSupportSubject = "Fire/EMS Resources Support"
    case fireEMSResourcesSupport = "At this time 10 resources are the default, in order to add"
    case arcFormSubject = "CRR Smoke Alarm Inspection Form"
    case arcFormDescription = "Use the Community Risk Reduction (CRR) Smoke Alarm Inspection Form when performing home fire safety inspections, including the installation of smoke alarms. You will have the option of creating a single form - or a campaign when, for example, conducting a neighborhood smoke alarm canvassing operation. This form conforms to that used by the nationally recognized fire safety organizations."
    case ics214SupportSubject = "ICS 214 Form Support"
    case ics214Subject = "ICS 214 Form"
    case ics214Description = "Use the ICS-214 to record your activities during any operational period in which you or your crew are on scene. Record activities such as resources, assignment, date, time, and what took place. Typically, and ICS-214 is used for each operational period. You may create a single form, or a master form and subsequent follow up forms (for multiple operational periods within a single extended incident)."
    case ics214SupportNotes = "Use this ICS-214 form as your daily operational period journal. This form should be used to record details of relevant activities at any ICS level, including single resources, equipment, Task Forces and so on. The logs provide incident activity history, and provides a reference for any after action report."
    case ics214ShareSupportSubject = "ICS 214 Form Share"
    case ics214ShareSupportNotes = "Your ICS 214 Activity Log is being prepared for sharing. This may take a moment."
    case ics214ResourceAssignedEditSubject = "Resource Assigned Edit Support"
    case ics214ResourceAssignedEditNotes = "Add ICS Position, Home Agency , phone and email for each of your Resources Assigned."
    case fireEMSResourcesSupport2 = "you'll need to deselect one of your other resources."
    case incidentAndSupportNotesSubject = "Incident and Support Notes"
    case incidentAndSupportNotes = "Enter descriptive information regarding the incident for future use and to document what took place. You may add notes over time, and each will be time stamped. If you have personal comments, not intended for department or general distribution, you may tap on ‘Support Notes’ and add your personal thoughts or comments."
    case incidentCrewSupportNotesSubject = "Incident Crew Support Notes"
    case incidentCrewSupportNotes = "You can add to your list of team members, either by choosing people listed in your contacts or by just typing in a name in the New Members field. Once added select that member from the list below, a checkmark will appear.  When you tap on save, that person will be put in your Crew field for the Incident Entry."
    case journalEntryErrorSubject = "Journal Entry Error"
    case journalEntryError = "Please enter a journal entry title."
    case journalCrewSupportNotesSubject = "Journal Crew Support Notes"
    case journalCrewSupportNotes = "You can add to your list of team members, either by choosing people listed in your contacts or by just typing in a name in the New Members field. Once added select that member from the list below, a checkmark will appear.  When you tap on save, that person will be put in your Crew field for the Journal Entry."
    case newICS214CrewSupportNotesSubject = "ICS214 Support Notes"
    case newICS214CrewSupportNotes = "Add resources to your ICS-214 for the current operational period. You may enter in any name of anyone from any agency, or you may select from your device’s contacts. As you add possible crew members, you then select them for inclusion in the current operational period by tapping on the far right of the contact line - and a checkmark will appear. Deselect by tapping again."
    case mapSupportNotesSubject = "Map Support Notes"
    case mapSupportNotes = "Track your incident and field operations activities by location using maps. Every time an incident or field activity associated with an address is created, a pin will appear on the master map. You may tap on any pin to get an overview of what was involved. There is a pin legend at the top of the map for your reference. The locator pin will center the map where you are. The Fire Station pin is aligned with the address of your fire station. If you need to make an adjustment to the location of any item, press your finger or Apple pencil onto the pin in question, then drag the pin to the location desired. You may view the map in street, Hybrid, or Satellite view."
    case myFireStationResourcesSupportNotesSubject = "My Fire Station Resources Support Notes"
    case myFireStationResourcesSupportNotes = "Each apparatus in your fire station should be included here. Add the manufacturer, assignment ID (such as Engine 1), shop number (serial), type of apparatus, and any specialty. Finally, you may add notes that include when it was assigned to your station, any issues to resolve, etc."
    case myFireStationResourcesSupportNotesSubject2 = "My Fire Station Resources Support Info"
    case myFireStationResourcesSupportNotes2 = "Use Fire/EMS Resources to set up your list of apparatuses for your fire station. Once this list is selected, you'll be able to access each apparatus here, where you can also add Shop Number, Description, Type, Manufacturer, Personnel Count and ID."
    case myProfileSupportNotesSubject = "My Profile Support Notes"
    case myProfileSupportNotes = "Your profile helps with keeping your journal, incidents, projects, and forms filled out correctly. As you change assignments, or promote, updating your profile will then automatically update any place where your name or assignment details are auto-loaded."
    case editIncidentSubject = "Edit Incident"
    case editIncidentDescription = "You can change the incident number, alarm time and the type of incident in this area."
    case newProjectSubject = "New Project Journal Entry"
    case newProjectDescription = "Create a Topic/Title, Date/Time, and then the content of your entry. The project journal is designed to be a private journal just for you - and can relate to promotional studies, union issues, drills, or anything that is not response or fire station related issues. Use the time stamp to separate each entry."
    case newIncidentSubject = "New Incident"
    case newIncident = "Start a new incident by indicating if this is an emergency or non-emergency response. Then, tap on the clock to set an Alarm time. Tap on the glove to locate an address on a map, or tap on the pin to select the location where you’re standing. You may update the address later, and you may use the microphone or keyboard to manually enter an address. Tap on the green dot under your resources to select the apparatus from your station that are resopnding."
    case newJournalEntrySubject = "New Journal Entry"
    case newJournalEntry = "Start a new journal entry by creating a topic/title, entering the date/time, and the type of activity. Next, add any notes about the topic/title. Is this related to the morning (line up) meeting? Training? A drill? Note you can timestamp each journal entry as well. You may add any number of notes to the journal throughout the day."
    case editJournalHeaderSubject = "Edit Journal"
    case editJournalHeaderDescription = "You can change the title, date and type of Journal entry here."
    case editProjectHeaderSubject = "Edit Project"
    case editProjectHeaderDescription = "You can change the title and date of the project entry here."
    case newPersonalEntrySubject = "New Personal Journal Entry"
    case newPersonalEntry = "Create a topic or title and manage a personal journal. These entries are separate from the main journal and are private. Create an overview here, and then save the topic. Once saved, you may enter your thoughts, either as a single entry, or as multiple entries on the same topic. Use the time stamp to separate each entry."
    case nfirsIncidentTypeSubject = "NFIRS Incident Type"
    case nfirsIncidentType = "You can type in the NFIRS Incident 3 digit number into the text field to add the correct NFIRS Incident Type or click on the red directional button to the left to bring up the whole list of NFIRS Incident Types."
    case nfirsIncidentTypeErrorSubject = "NFIRS Incident Type Info"
    case nfirsIncidentTypeError = "was not found to be part of the list of NFIRS Incident Type - please select from the NFIRS Incident Type list instead."
    case pureCommandSubject = "PureCommand"
    case pureCommand = "You’re about to access our website via your web browser. To get back to FireJournal, tap on the little “return…” icon at the top left of the page."
    case relievingSupportNotesSubject = "Relieving Support Notes"
    case relievingSupportNotes = "Add to your list possible relief officers, either by choosing people listed in your contacts, or by just typing in a name in the New Members field. Once added, select that member from the list below. A checkmark will appear. When you tap on SAVE, that member will be put in your Relief field for the Start Shift. If nobody is selected, there will be no relief listed. To delete, swipe left."
    case resourceSupportNotesSubject = "Resource Support Notes"
    case resourceSupportNotes = "You can use this area to update your Resource."
    case startShiftRecordedSubject = "Start Shift Recorded"
    case startShiftRecorded = "Your Start Shift entries have been recorded into your primary journal. You may access that entry via the Journal and add additional data. To add changes throughout the shift, tap on Update Shift."
    case startShiftSupportSubject = "Start Shift Support"
    case startShiftSupport = "Your Start Shift has been recorded into your Journal Entries, you can add more information into the Discussion, Next Steps and Summary areas of the Journal."
    case supervisorSupportNotesSubject = "Supervisor Support Notes"
    case supervisorSupportNotes = "Add to your list possible supervisors, either by choosing people listed in your contacts, or by just typing in a name in the New Members field. Once added, select that supervisor from the list below. A checkmark will appear. When you tap on SAVE, that member will be put in your supervisor field for the Start Shift. If nobody is selected, there will be no supervisor listed. To delete, swipe left."
    case syncWithCRMSubject = "Register for FREE Support"
    case syncWithCRM = "We would like to add you to our support center so you may open “help tickets” when you may need assistance. "
    case syncWithCRMSubject2 = "Sync with CRM"
    case syncWithCRM2 =  "You’re about to access our customer support portal via your web browser. To get back to FireJournal, tap on the little “return…” icon at the top left of the page."
    case syncedWithCRMSubject = "You’re all set!"
    case syncedWithCRM = "You are now registered for FREE customer support. Use the Support tab in navigation to open a ticket, if you need help."
    case updateShiftSupportNotesSubject = "Update Shift Support Notes"
    case updateShiftSupportNotes = "During your shift, whenever there are changes, you should record them here. If a supervisor changes over before the end of the shift, enter that change here. If the status of an apparatus changes (for example, a mechanical issue), use the Edit button for that apparatus and update its status. Use the Discussion to enter details about members working for you. You may update your shift as many times as is required."
    case updateShiftSupportNotesSubject2 = "Update Shift Support Info"
    case updateShiftSupportNotes2 = "Your Update Shift has been recorded into your Journal Entries, you can add more information into the Discussion, Next Steps and Summary areas of the Journal."
    case versionChangeSubject = "Fire Journal Version Change"
    case versionChange = "Updated version of Fire Journal now available! Update your app for improved performance and/or functionality."
    case tagsAreEmptySubject = "User Tags"
    case tagsAreEmpty = "The default tags are missing, shall we load them into the app? This may take a moment."
    case resourcesAreEmptySubject = "User Resources"
    case resourcesAreEmpty = "The default resources are missing, shall we load them into the app? This may take a moment."
    case rankAreEmptySubject = "User Ranks"
    case rankAreEmpty = "The default ranks are missing, shall we load them into the app? This may take a moment."
    case platoonAreEmptySubject = "User Platoons"
    case platoonAreEmpty = "The default platoons are missing, shall we load them into the app? This may take a moment."
    case streetTypeAreEmptySubject = "Street Types"
    case streetTypeAreEmpty = "The default street types are missing, shall we load them into the app? This may take a moment."
    case localIncidentTypesAreEmptySubject = "Local Incident Types"
    case localIncidentTypesAreEmpty = "The default local incident types are missing, shall we load them into the app? This may take a moment."
    case mapErrorSubject = "Location Error"
    case mapErrorDescription = "Experiencing some difficulty connecting the map with your location. Please try again."
    case newStaffSubject = "New Staff"
    case newStaffEntry = "Add new staff either manually or from your contact list. If there is a photo associated with the individual in your contacts, that photo will auto-populate on this staffing pop-over. Alternatively, you can add a new, separate photo just for use in Station Command. You can also manage their rank (by category), and assigned platoon."
    case tagsSubject = "Tags"
    case tagsDescription = "Add tags to the list of tags, this will available in any form using tags in Fire Journal."
    case projectOverviewSubject = "Project Overview Note"
    case projectOverviewDescription = "Create a note that covers an overview of this project. Hit the time stamp button to add your name and time, then tap the save button when you are finished"
    case projectClassNoteSubject = "Project Notes"
    case projectClassNoteDescription = "Create a note that covers all that you did during this project, you can come back and add more information as the project evolves, adding time stamps to each entry by tapping the time stamp button and then the save button to exit."
    case journalOverviewSubject = "Journal Overview"
    case journalOverviewDescription = "Create a note that relates to what the journal entry is about. It can be short - or as long as you need. Use the time stamp to indicate any specific time of day that you entered the note as well. "
    case journalDiscussionSubject = "Journal Discussion"
    case journalDiscussionDescription = "Create note that covers the discussion of this journal entry.  Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case journalNextStepSubject = "Journal Next Steps"
    case journalNextStepDescription = "Create note that covers the next steps of this journal entry.  Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case journalSummarySubject = "Journal Summary"
    case journalSummaryDescription = "Create note that covers the summary of this journal entry.  Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case incidentAlarmNoteSubject = "Alarm Notes"
    case incidentAlarmNoteDescription = "Create notes that pertain to the alarm time. Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case incidentArrivalNoteSubject = "Arrival Notes"
    case incidentArrivalNoteDescription = "Create notes that pertain to the arrival time. Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case incidentControlledNoteSubject = "Controlled Notes"
    case incidentControlledNoteDescription = "Create notes that pertain to the controlled time. Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case incidentLastUnitNoteSubject = "Last Unit Standing Notes"
    case incidentLastUnitNoteDescription = "Create notes that pertain to the last unit standing time. Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case incidentNotesSubject = "Incident Notes"
    case incidentNotesDescription = "Create notes that pertain to the incident. Hit the time stamp button to add your name and the time, then tap the save button when you are finished."
    case onboardUserSaveErrorMessage = "A good deal of Journal and Incident reporting is dependent on the following fields needing to be filled out:\n"
    case onboardInfoSubject = "Your Profile"
    case onboardInfoDescription = "Filling out your profile helps with ensuring Fire Journal is set up for your first shift."
    case onboardOneVCText = """
We’re delighted that you’ve chosen to manage your firefighting career with Fire Journal. Using this easy-to-use and informative app, you will have never before seen capabilities to manage and track important aspects of your career.
    The following screens will help explain how to get started.
"""
    case onboardTwoVCText = """
Because you may be using Fire Journal at any time of day or night, it’s important that you have access to answers when you need them. Start with our FAQs for common issue. Need more specific help? Fire Journal includes FREE 24/7 online support help. Open a support ticket, and we’ll get back to you quickly. Register at the conclusion of this presentation and you’ll be all set!
"""
    case onboardThreeVCText = """
The first thing you should do is create a profile for yourself. Once completed, many of your actions will pre-load into various sections of the app, including in journals, incidents, and other places. It should only take you a few minutes to get your Settings completely configured.
"""
    case onboardFourVCText = """
Fire Journal allows you to customize a number of functions within the app. As an example, we include three shift options (A, B, C), but if your department only uses two, then delete one. Or, if you use four platoons, add one. You’ll find this type of customization is available (typically via the Settings function) for a number of options. Fire Journal makes it easy to configure the app to be perfect for you and your department.
"""
    case onboardFiveVCText = """
Start each workday by tapping on the HOME button. That wil ltake you to the main dashboard for Fire Journal. Tap on “Start Shift” and enter in any data you feel would be important. Then, using the + buttons, add a new journal entry, or a new incident, etc. You may also use the main navigation column to make selections. When you’re done for the day, tap on “End Shift” and now the time, date, and any notes from the just completed workday.
"""
    case onboardSixVCText = """
Say goodbye to paper journals. You’ve seen those paper journals that track a fire company’s activities… Now, for the first time, you can track and manage your own career using Fire Journal. From morning line-up to fire prevention to shopping, union issues, or anything you would ordinarily write into a journal - Fire Journal provides it. Bonus: use the built-in mic on your smartphone to record each entry - no typing required.
"""
    case onboardSevenVCText = """
Once you clear an incident, you may enter a variety of data about that incident and use it as a historical record of your firefighting career. Enter as much or as little as you want, but note you can be pretty detailed about each response (emergency and non-emergency) as you’d like. Each response creates a tracking pin in the onboard map.
"""
    case onboardEightVCText = """
The maps function in Fire Journal is one of the most useful tools available for tracking your firefighting career. Create a historical map of every fire, EMS call, or rescue you participate in. Every time you enter incident data, a pin on the map is automatically created. Open maps and tap on any pin - and the details of that incident are displayed.
"""
    case onboardNineVCText = """
Now that you have a basic understanding of how Fire Journal works, it’s time to get started. Feel free to experiment, and remember that you may delete anything you don’t like, so you can’t do anything that is “wrong.” This is your chance to keep track of the things you do while on duty - protecting yourself with accurate accountability, and creating a useful history of the important work you do to save lives and property!
"""
    case theStoreMembershipText = """
    As a firefighter, you understand the importance of keeping track of important milestones in your life and career. Being a “member” of your department is something to be proud of - to know that you’re serving your community to the best of your ability.

    Fire Journal Membership brings a never before seen level of accountability and service history to firefighters everywhere. Once you become a member, the capabilities of Fire Journal (the iOS app) are extended, and you’ll gain important insight about your firefighting career.

    Fire Journal Members adds reporting and analysis to your career - how much are you working? What are the important fires or rescues you’ve participated in? How has your career evolved over time? If you’re working on promoting, track some or all of your study sessions, partners, and test results. There’s really no limit to the ways Fire Journal Membership can benefit you and your firefighting career.

    CAPABILITIES:
    Fire Journal Membership builds on the functions found in the free downoadable app. Some of the immediate benefits include:

    Automatic backup of your journal, projects, incidents, and form data
    Automatic sync between your iOS devices (for example, an iPhone and an iPad) - Fire Journal is a “universal app”
    Secure access to a private cloud environment, configured specifically for you (access the cloud from your iOS device, or from a Mac or PC computer)
    Track and review trends and reports related to journal entries and incidents
    Evaluate history of calls for service, types of incidents, and what took place from arrival to clearing the scene
    Review your journal and incident history via a map, highlighting key incidents and related activities while on scene
    Share form data from ICS-214 and other forms in Government approved formats (as PDF files)
    Utilize Journal and Incident calendaring
    Utilize search functions to find what you need, when you need it
    24/7 access to your own Fire Journal customer support portal

    As new capabilities are introduced to Fire Journal Membership, you’ll gain acces without having to change the status or longevity of your membership.

    Best of all, Fire Journal Membership is extremely affordable, and can be purchased as either a recurring monthly subscription, or as a single payment annual subscription (best savings). Every membership starts off with 60 days of FREE access to Fire Journal Cloud. If you decide its not for you, follow Apple’s guidelines and cancel your subscription. It’s that easy.

    INVESTMENT:
    With either plan, you get the first 60 days of Fire Journal Membership for free. During that time period, if you decide it’s not for you, simply cancel, no questions asked.

    SILVER PLAN: $7.99 per month, paid each month - no contract required

    GOLD PLAN: $3.33 per month, paid as a single annual payment

    The total annual subscription fee (GOLD PLAN) is $39.99. Try Fire Journal Membership for 60 days for FREE, then continue with either plan above. You may upgrade a SILVER PLAN to a GOLD PLAN at any time.

    NOTE: If you update your devices, you may re-connect your Fire Journal Membership using the “Restore Purchase” button below.
"""
    case theStoreMembershipText2 = """
TRY IT FOR 60 DAYS FREE, then automatically charged to your iTunes account every month. You may unsubscribe in System Preferences.
"""
    case theStoreMembershipText3 = """
GOLD PLAN: $3.33 per month, paid as a single annual payment

    The total annual subscription fee (GOLD PLAN) is $39.99. Try Fire Journal Membership for 60 days for FREE, then continue with either plan above. You may upgrade a SILVER PLAN to a GOLD PLAN at any time.
    TRY IT FOR 60 DAYS FREE, then automatically charged to your iTunes account.
"""
    case theStoreMembershipText4 = """
IMPORTANT MEMBERSHIP/SUBSCRIPTION INFORMATION:
    Fire Journal Membership is a recurring subscription. If you decide to purchase a membership subscription, you’ll receive an initial FREE 60 DAY TRIAL. Once the free trial  period concludes, your subscription will automatically engage and payment will be charged to the credit card that is part of your “dot Mac” or “iCloud” membership. You may disable “Auto renewal” at any time by going to “Settings” in the iOS app once you have completed downloading and installing the Fire Journal app into your smartphone device.

    For additional information, please see our terms of use via our website:
    http://purecommand.com/terms/

    You may also review our Private Policy by visiting our website:
    http://purecommand.com/privacy/

    To learn more about PureCommand and our support for the fire service, visit our website:
    http://www.purecommand.com/

    Thank you for becoming part of the Fire Journal family.
"""
}
