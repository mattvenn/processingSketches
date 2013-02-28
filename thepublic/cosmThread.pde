import cosm.*;
class SimpleThread extends Thread {
 
  boolean running;           // Is the thread running?  Yes or no?
  int wait;                  // How many milliseconds should we wait in between executions?
  String id;                 // Thread name
  int count;                 // counter
 private PApplet papplet;
  int [] beamCounter;
  DataOut feed;
  double uptime;
  int easter;

  String apiKey = "5engrOeZ2dTAlORPWHs59JiLXaiSAKwvOUJITlU5cmhEbz0g";
  String feedId = "103983";
  // Constructor, create the thread
  // It is not running by default
  
  SimpleThread (PApplet papplet,int [] beamCounter,int interval) {
    this.papplet=papplet;
    running = false;
    feed = new DataOut(this.papplet, apiKey, feedId);  //intantiate feed
  feed.setVerbose(false);  //optional debug info
  wait = interval;
  this.beamCounter = beamCounter;


    
  }
  
  
  void incEaster()
  {
    easter++;
  }

 void update()
{
   println( "sending to cosm" );
  for( int i = 0; i < beamCounter.length ; i ++ )
  {
    feed.setStream("dmx" + i,  beamCounter[i]); //send request (datastream id, new value)
     feed.setStream("easter",  easter); //send request (datastream id, new value)
      feed.setStream("uptime",millis()/1000); //send request (datastream id, new value)
    beamCounter[i] = 0;
  }
  
} 
  // Overriding "start()"
  void start () {
    // Set running equal to true
    running = true;
    count = 0;
    // Print messages
    println("Starting cosm update thread (will send every " + wait + " milliseconds.)"); 
    // Do whatever start does in Thread, don't forget this!
    super.start();
  }
 
 
  // We must implement run, this gets triggered by start()
  void run () {
    while (running) {
      // Ok, let's wait for however long we should wait
      try {
        sleep((long)(wait));
      } catch (Exception e) {
      }
            update();

    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
  }
}


