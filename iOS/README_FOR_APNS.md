# PubNub APNS Setup Guide and Walkthrough

This is a detialed guide on how to setup PubNub Push Notifications on iOS devices such as iPhones and iPads.  

You will need to follow each of these steps in order to issue APNs messages into your mobile device.  

**Note that APNS requires a real iOS Device and does not work on the iOS Simulators.**
This means that you __CANNOT__ simulate Push Notifications on the iOS simulator.  (However, you can of course receive PubNub native messages on the iOS simulator.)

## Four Step Process

This is a four step process that requires initial preparation steps and testing.  It is simple as we've organized the process for you.  Start by creating the iOS PEM Key for you App.  Send us your PEM key by emailing support@pubnub.com directly.  Add source code files to your project for registering and requesting user permission in your app.  Register Channels via our REST API with the Device ID that your user has been approved and accepted your Push Notification Request. Finally you will test the device by running the App on a real iOS device.

1. Create an APNS Certificate.  Submit the resulting PEM file via the web admin app, or email to support@pubnub.com if you encounter any difficulties.
2. Add Objective-C Delegates to your project to handle the inbound APNS messages.
3. Register Device ID to a PubNub Channel via REST API.
4. TEST IT: Run the iOS app on a Native Device.  Allow Push Notifications.  Click Home Button.  Issue a PubNub Publish() Request.

# Example workflow for APNS testing:

__See detailed instructions below__

1. Create certificate (and send to PubNub)
2. Register Device Token ID with a PubNub channel

    ```
    # Replace <sub_key> and <device> with actual values.
    curl apns.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device>?add=push_test_channel
    ```

3. Publish a simple push message

    Using http://pubnub.com/console enter:
  
        * channel = push_test_channel
        * subkey = your subkey
        * pubkey = your pubkey
        * message = "Hello World"

    Click __unsubscribe__ then __subscribe__ to use the new values

    Click __Publish__ to send the Push Notification


# Add Objective-C Delegates

https://gist.github.com/1aa012f61547fe512f84 - In your App, add in this file into your project and make sure to request for Push Notifications.  This allows you to get the Device Token ID and also to Register for User Permissions to receive Push Notifications.  Also it will allow you to handle and process the push notification when and where you need it the most.  By adding this source code file to your project you will automatically be requesting for user permissions to receive Push Notifications.  Also you will be declaring Callback methods that execute as function delegates when a Push Notification is Received by the device.  You can process the message payload with these functions and issue UI changes or signal the user to perform an action.


# APNS Push Certificate

#### Create iOS App ID

* Log in to the iOS Provisioning Portal - https://developer.apple.com/ios/manage/overview/index.action
* Go to __APP IDs__ in the sidebar and click the __New App ID__ button.
* Enter a description (e.g. PubnubPushTest) and a Bundle Identifier (reverse-domain style is recommended. e.g. com.pubnub.pubnubpushtest) and click __sumbit__.

#### Generate CSR Certificate

* In the App ID section find your application and click __configure__.
* Check __Enable for Apple Push Notification service__ and click the __Configure__ button for the Development Push SSL Certificate.
* Follow the instructions in the SSL Certificate Assistant, and download/save the resulting certificate.

#### Create PEM

* In the __Keys__ category of Keychain Access you will see a new public/private key pair that shares the common name entered when creating the Certificate Signing Request.
* Right-click on the private key, chooose __export__ and save the file. Optionally use a passphrase (for beta, no passphrase).

__In a terminal execute the following steps:__

* Navigate to where you stored the private key (__.p12__ file) and certificate (__.cer__ file)
```
cd /users/pubnub/Desktop
```

* Convert the private key to a .pem format (replace pnpush__key.p12 and pnpush__key.pem with the file names you used).

    * If you exported your private key __without a passphrase__ use the following command. Press enter when prompted for the import password.

        ```
        openssl pkcs12 -in pnpush_key.p12 -out pnpush_key.pem -nocerts -nodes
        ```

    * If you used a passphrase when exporting your password use the following command. The first password prompt is to decrypt, the second prompt is to encrypt the PEM file again.

        ```
        openssl pkcs12 -in pnpush_key.p12 -out pnpush_key.pem -nocerts
        ```

* Convert certificate to pem format
```
openssl x509 -in pnpush_cert.cer -inform der -out pnpush_cert.pem
```

* Combine the certificate and key into a single PEM file
```
cat pnpush_cert.pem pnpush_key.pem > pnpush.pem
```

* Test the certificate (should leave a connection open, but will disconnect if you type/press enter)
```
openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert pnpush.pem -key pnpush.pem
```

# Register Devices with PubNub APNS API

Use this REST service End-point to begin subscribing your devices to the PubNub channel that is interesting to your app. Simply issue a REST request with your Device ID and the Channels you wish to be "Subscribed" to in order to receive APNs messages.

Note that you can not simulate Push Notifications on the iOS simulator.  This is different from PubNub Messages, as you CAN receive PubNub Real-time Messages via the iOS Simulator.  APNs requires a physical device.
Publish a Message

### Add channel(s) for a device
```
apns.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device>?add=channel,channel,...
```

### Remove channel(s) from a device
```
apns.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device>?remove=channel,channel,...
```

### Remove device (and all channel subscriptions)
```
apns.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device>/remove
```

### Get channels for a device
```
apns.pubnub.com/v1/push/sub-key/<sub_key>/devices/<device>
```


# PubNub Push Message format for APNS

#### Simple Alert Message

```
"Hello World"
```

#### Full APNS alert format

See APNS Push Notification Payload documentation: http://goo.gl/iU2Td

Example:
```

{
  "aps" : {
      "alert" : "You got your emails.",
      "badge" : 9,
      "sound" : "bingbong.aiff"
  },
  "acme1" : "bar",
  "acme2" : 42
}

```

#### Setting message TTL

Expire the message if it is undeliverable within the TTL window (e.g. device is off, or out of network).

Set using top level key of "pn_ttl", measured in seconds. Defaults to 3600 (one hour).

Example (one minute ttl):
```
{
  "aps" : {
      "alert" : "You got your emails."
  },
  "pn_ttl": 60
}

```

### Device Token Requirements
The Device Token ID may only have HEX Characters.

### Testing and Troubleshooting

Test your PEM Key by running this Python App by downloading and executing:

```
python ./debug_push.py
```

##### debug_push.py

```python
import json
import logging
import os
import socket
import ssl
import struct
import sys
import time
import uuid

APNS_HOST = 'gateway.sandbox.push.apple.com'
APNS_PORT = 2195

APNS_ERRORS = {
    1:'Processing error',
    2:'Missing device token',
    3:'missing topic',
    4:'missing payload',
    5:'invalid token size',
    6:'invalid topic size',
    7:'invalid payload size',
    8:'invalid token',
    255:'Unknown'
}

def push(cert_path, device):
    if not os.path.exists(cert_path):
        logging.error("Invalid certificate path: %s" % cert_path)
        sys.exit(1)

    device = device.decode('hex')
    expiry = time.time() + 3600

    try:
        sock = ssl.wrap_socket(
            socket.socket(socket.AF_INET, socket.SOCK_STREAM),
            certfile=cert_path
        )
        sock.connect((APNS_HOST, APNS_PORT))
        sock.settimeout(1)
    except Exception as e:
        logging.error("Failed to connect: %s" % e)
        sys.exit(1)

    logging.info("Connected to APNS\n")

    for ident in range(1,4):
        logging.info("Sending %d of 3 push notifications" % ident)

        payload = json.dumps({
            'aps': {
                'alert': 'Push Test %d: %s' % (ident, str(uuid.uuid4())[:8])
            }
        })

        items = [1, ident, expiry, 32, device, len(payload), payload]

        try:
            sent = sock.write(struct.pack('!BIIH32sH%ds'%len(payload), *items))
            if sent:
                logging.info("Message sent\n")
            else:
                logging.error("Unable to send message\n")
        except socket.error as e:
            logging.error("Socket write error: %s", e)

        # If there was an error sending, we will get a response on socket
        try:
            response = sock.read(6)
            command, status, failed_ident = struct.unpack('!BBI',response[:6])
            logging.info("APNS Error: %s\n", APNS_ERRORS.get(status))
            sys.exit(1)
        except socket.timeout:
            pass
        except ssl.SSLError:
            pass

    sock.close()

if __name__ == '__main__':
    if not sys.argv[2:]:
        print "USAGE %s <cert path> <device token>" % sys.argv[0]
        sys.exit(1)

    logging.basicConfig(level=logging.INFO)
    push(sys.argv[1], sys.argv[2])
    logging.info("Complete\n")
```
