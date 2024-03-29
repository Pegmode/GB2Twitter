# GB2Twitter
Project trying to interface GB link cable with RPi/Microcontroller for a Gameboy twitter client. Winning entry for the [University of Alberta Student Innovation Center idea fund 2019](https://www.ualberta.ca/student-innovation-centre/idea-fund).

[Demo Video](https://www.youtube.com/watch?v=k0U-M86C37E)

[python-twitter](https://github.com/bear/python-twitter)

![Preview](/notes/GB2Twitter.gif)
![Preview](/notes/twitter.png)

<img src="notes/79959290_10216417212685277_7443546913766375424_n.jpg" width="500"/>



###### Current Progress
Only sends a tweet to twitter. Basically an overglorified GB serial terminal and simple python script. I may clean it up and add some more features later.


##### Requirements
- python3
  - [python-twitter](https://github.com/bear/python-twitter)
  - [pySerial](https://pythonhosted.org/pyserial/)
- [RGBDS (Rednex Game Boy Development System)](https://github.com/rednex/rgbds)
- Arduino Nano/Uno
- Spliced Game Boy Link cable (See: notes for wiring)
- Twitter Developer account and keys

##### Topology 
![Preview](/notes/GB2TwitterFlow.png)

#### Bugs
- Removing a character at the edge of the screen bugs the screen

##### Special Thanks
- Brendan Gluth
- Taylor Knopp
- Edward "DevEd" Whalen
- University of Alberta Student innovation Center
- "The Shack" at the University of Alberta
- GB Dev Discord
