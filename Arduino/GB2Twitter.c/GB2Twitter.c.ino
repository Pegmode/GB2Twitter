// Daniel Chu 2019
// Based on Gautier Hattenberger's GB serial Work (2016)
// 

// Link Cable     Arduino      Desc (GB side)
// 6              GND          GND
// 5              3            SC
// 2              4            SI
// 3              5            SO
#define SI 5
//#define SO 4
#define CLK 3
#define CLK_INTERUPT 1
#define ByteLength 8
//Interupt Vars must be volatile
unsigned volatile long receiveTimer = 0;
int volatile SPIData = 0;
int volatile bitNum = 0;
int volatile currentBitVal = 0;
void setup() {
  pinMode(SI,INPUT);
  //pinMode(SO,OUTPUT);
  Serial.begin(9600);
  attachInterrupt(CLK_INTERUPT,GBSPIHandler,RISING);//mode 3

}

void loop() {
  // put your main code here, to run repeatedly:

}

void GBSPIHandler(){

  currentBitVal = digitalRead(SI);//read current bit

  if (currentBitVal == HIGH){
    SPIData |= (1 << (7 - bitNum));
    }

  if(bitNum == 7){
    Serial.println(SPIData, HEX);
    SPIData = 0;//reset
    }
  
  bitNum ++;
  //receiveTimer = micros();
  }
