WiFi connectivity issue.
Trello ticket url: https://trello.com/c/iMyOnryA/101-chris-moore-connectivity-issue

Important: 
background modes available in iOS: Play audio, Receive location updates, Perform finite-length tasks, Process Newsstand Kit downloads, VoIP and work with bluetooth.
In test app "PubNubBackground" we using “location updates” mode for simulate background work.

For check:
1) pull "hotfix-t101" branch
2) open "pubnub" project (path - iOS/PubNubBackground)
3) connect and select iPad
4) Run (app doesn't have UI - you see black screen)
5) click "Ok" at "Use Your Current Location" alert (once)
6) move app to background (click at "Home" button in iPad)
7) turn off WiFi (or 3G), turn on 

Log for turned off Wifi:
2013-09-24 17:05:33.877 pubnub Background[318:60b] PubNub (0x15646880) CHANNEL DISCONNECTED: <PNServiceChannel: 0x1555b450> (STATE: 'disconnecting on network error')
2013-09-24 17:05:33.881 pubnub Background[318:60b] PubNub (0x15646880) CLIENT DISCONNECTED FROM ORIGIN: pubsub.pubnub.com (STATE: 'disconnecting on network error')
2013-09-24 17:05:33.883 pubnub Background[318:60b] PubNub (0x15646880) CLIENT SHOULD RESTORE CONNECTION. REACHABILITY CHECK COMPLETED (STATE: 'disconnected on error')
2013-09-24 17:05:33.895 pubnub Background[318:60b] PubNub (0x15646880) CONNECTION WILL BE RESTORED AS SOON AS INTERNET CONNECTION WILL GO UP (STATE: 'disconnected on error')
2013-09-24 17:05:33.898 pubnub Background[318:60b] PubNub (0x15646880) {DELEGATE} PubNub client closed connection because of error: Domain=com.pubnub.pubnub; Code=103; Description="PubNub client connection lost connection"; Reason="Looks like client lost connection"; Fix suggestion="There is no known solutions."; Associated object=(null)

Log for turned on Wifi:
2013-09-24 17:06:33.510 pubnub Background[318:60b] PNConnection (0x15681af0) {INFO}[CONNECTION::PNMessagingConnectionIdentifier::READ] HAS DATA FOR READ OUT (STREAM IS OPENED)(STATE: 33658880)
2013-09-24 17:06:33.514 pubnub Background[318:60b] PNConnection (0x15681af0) {INFO}[CONNECTION::PNMessagingConnectionIdentifier::READ] READING ARRIVED DATA... (STATE: 33658880)
2013-09-24 17:06:33.518 pubnub Background[318:60b] PNConnection (0x15681af0) {INFO}[CONNECTION::PNMessagingConnectionIdentifier::READ] READED 268 BYTES (STATE: 33658880)
2013-09-24 17:06:33.523 pubnub Background[318:60b] PNResponseDeserialize (0x15681d20) {INFO} RAW DATA: t_90758([13800315924600074])
2013-09-24 17:06:33.528 pubnub Background[318:60b] PNConnection (0x15681af0) {INFO}[CONNECTION::PNMessagingConnectionIdentifier::READ] {1} RESPONSE MESSAGES PROCESSED (STATE: 33658880)
2013-09-24 17:06:33.615 pubnub Background[318:60b] PNConnection (0x1555b5d0) {INFO}[CONNECTION::PNServiceConnectionIdentifier::READ] HAS DATA FOR READ OUT (STREAM IS OPENED)(STATE: 33658880)
2013-09-24 17:06:33.619 pubnub Background[318:60b] PNConnection (0x1555b5d0) {INFO}[CONNECTION::PNServiceConnectionIdentifier::READ] READING ARRIVED DATA... (STATE: 33658880)
2013-09-24 17:06:33.621 pubnub Background[318:60b] PNConnection (0x1555b5d0) {INFO}[CONNECTION::PNServiceConnectionIdentifier::READ] READED 268 BYTES (STATE: 33658880)
2013-09-24 17:06:33.624 pubnub Background[318:60b] PNResponseDeserialize (0x1555b620) {INFO} RAW DATA: t_f8419([13800315925048854])
2013-09-24 17:06:33.626 pubnub Background[318:60b] PNConnection (0x1555b5d0) {INFO}[CONNECTION::PNServiceConnectionIdentifier::READ] {1} RESPONSE MESSAGES PROCESSED (STATE: 33658880)
2013-09-24 17:06:33.628 pubnub Background[318:60b] PNServiceChannel (0x1555b450) {INFO} PARSED DATA: PNTimeTokenResponseParser (0x1564a670): <time token: 13800315925048854>
2013-09-24 17:06:33.633 pubnub Background[318:60b] PNServiceChannel (0x1555b450) {INFO} OBSERVED REQUEST COMPLETED: (null)

If you found identical message in the Xcode's log - app handle changing channels while in the background.
