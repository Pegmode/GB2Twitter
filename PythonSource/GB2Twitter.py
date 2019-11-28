import serial,twitter
import GB2TKeys #not included in git
ser = serial.Serial('/dev/ttyUSB0')
print('Waiting for Packet:')
isWaiting = True
packet = ""
while isWaiting:
    msg = ser.readline()
    #print(chr(int(msg[0:2].decode("utf-8"),16)))
    if (int(msg,16) == 4):
        break
    packet += (chr(int(msg[0:2].decode("utf-8"),16)))
    #print(packet)
packet += "\nSent from my Game Boy!"
print("\nMessage:{}".format(packet))
api = twitter.Api(consumer_key=GB2TKeys.GB2T_consumer_key, consumer_secret=GB2TKeys.GB2T_consumer_secret,access_token_key=GB2TKeys.GB2T_access_token_key, access_token_secret=GB2TKeys.GB2T_access_token_secret)
api.PostUpdate(packet)
print("TWEET SENT!!")
