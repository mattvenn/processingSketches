
class Fader
{
  boolean debug =false;
  int toValue;
  float currentValue;
  boolean completed = false;
  int delay;
  int now;
  float attackIncrement;
  float releaseIncrement;
  int sustainT;
  boolean release = false;
  boolean attack = false;
  boolean sustain = false;
  boolean endSustain = false;
  Fader()
  {
  }
  void debug()
  {
    debug = true;
  }
  
  void fade(int toValue, int attackT,  int releaseT)
  {
    attack = true;
    sustain =false;
    release = false;
    endSustain =false;
    this.toValue = toValue;
    attackIncrement = float(toValue)/attackT;
    releaseIncrement = - float(toValue)/releaseT;
  }
  //allow jump to release
  void release()
  {
    endSustain = true;
  }
  void finish()
  {
    attack = false;
    sustain = false;
    release = false;
    currentValue = 0;
  }
  int update()
  {
   if( debug )
     println( "cur: " + currentValue);
    now++;
    if( attack )
    {
    if( debug )
    {
      println("attack");
     println( "inc: " + attackIncrement );
     println( "to value" + toValue );
    }

       if(int(currentValue)>=toValue)
       {
        attack = false;
        sustain = true;
       }
      else
      {
        currentValue+=attackIncrement;
      }
    }
    else if( sustain )
    {
      if( endSustain )
      {
        sustain = false;
        release = true;
      }
     if( debug )
       println("sustain");
    }
    else if( release)
    {
      if ( debug )
      {  println("release");
         println("cur:" + currentValue);
       }
        
        if(currentValue<=0)
       {
         release = false;
       }
       else
       {
         if( debug ) 
           println( "inc: " + releaseIncrement );

          currentValue+=releaseIncrement;
       }
    }
    if( currentValue < 0 )
      currentValue = 0;
    if( currentValue > 255 )
      currentValue = 255;
    return int(currentValue);
  
  }
}

