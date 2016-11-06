# blackbox
blackBox project:
TouchID and using AES-256

1 - Detect if new fingerprint added/removed to/from iPhone setting 

2 - After detection, app should send a message to server (could be a typical JSON message). App needs to encrypt the JSON message before sending to the server with AES 256 (the key should be randomly generated not from user input) server endpoint is http://requestb.in/1mja26u1

3 - store & get AES256 key in keychain