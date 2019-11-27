import serial
ser = serial.Serial('/dev/ttyUSB0')
i = 1
print('Waiting for Packet:')
isWaiting = True
packet = ""
while isWaiting:
    i += 1
    msg = ser.readline()
    if(int(msg,16) == 4):
        break
    packet += (chr(int(msg[0:2].decode("utf-8"),16)))
    #print(packet)
print("Message:{}".format(packet))
