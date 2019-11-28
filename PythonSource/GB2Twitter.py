import serial,twitter
ser = serial.Serial('/dev/ttyUSB0')
i = 1
print('Waiting for Packet:')
isWaiting = True
packet = ""
while isWaiting:
    i += 1
    msg = ser.readline()
    print(chr(int(msg[0:2].decode("utf-8"),16)))
    if (int(msg,16) == 4):
        break
    packet += (chr(int(msg[0:2].decode("utf-8"),16)))
    #print(packet)
print("\nMessage:{}".format(packet))

packet += "\nSent from my Game Boy!"
# api = twitter.Api(consumer_key=consumer_key, consumer_secret=consumer_secret,access_token_key=access_key, access_token_secret=access_secret,input_encoding=encoding)
