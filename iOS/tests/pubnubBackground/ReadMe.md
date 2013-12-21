# PubNub test app for iOS
An application that runs in the background, and extensively uses PubNub while in the background and foreground.

The app is built against the libs from the branch 3.5.1b

## App test flow
- The app will init and connect to the PubNub service
- You can choose the names to be random or enter custom names. The app will subscribe to 3 channels when in auto mode.
- The app will then continuously publish messages to these channels after a pause for the idle time (10 secs by default).
- The app matches the sent message with the received message on all the channels.
- Logs are written for each event/action.
- The channels will be unsubscribed when the tests are stopped.
- If the app goes into background mode the current GPS coordinates of the user will be sent as a message to all subscribed channels.

## App Interface:
- The first text field is used to enter channel names, multiple channel names can be entered using a comma separator. On Launch this field is disabled. This field can be enabled by switching "off" the UI switch named "Auto Names". The white spaces in channel name fields will be omitted.
- When the "Auto names" UI switch is "On", the user cannot enter the custom channel names. The application will choose 3 random names and subscribe to these channels.
- The app has a text field where the user can enter the idle time (in seconds). This is the time the app sleeps in between sending multiple messages. Default is 10s.
- 'Start test' starts the testing. When this is touched the button is disabled and the title is changed to 'running', indicating that the tests are running.
- 'Stop test' stops the tests. On load this is disabled. When the 'Start test' button is touched this button is enabled. Using this button we can stop the tests. On stopping the tests all the subscribed channels will be unsubscribed. The title of the button will be changed to 'unsubscribing' and the button will be disabled. When all the channels will be unsubscribed the 'Start test' button will be enabled.
- Using the switch 'Show all logs' all the logs will be disabled in the text view on the main screen. By default this is in 'Off' state. Only essential logs will be displayed.
- Logs text view shows the logs for the actions/events.
- The text field labeled "CH" will display the currently subscribed channels.

## Known issues:
- When running the tests, if there is a network disconnection and you touch 'Stop tests' button the button will be disabled and will wait till all the channels are unsubscribed. Unsubscribe won't happen unit we get connectivity again. You won't be able to use 'start tests' or 'stop tests'. Currently there is no way to get out of this situation apart from force closing the app.


