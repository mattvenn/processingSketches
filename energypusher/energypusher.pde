ArrayList dataList = new ArrayList();
int minDelay = 10;
int maxDelay = 500;
int delayTime = 500;
BufferedWriter fifo;
Iterator i;
int count = 0;
void setup()
{
  size(600,100);
  background(0);
  fill(255);
  println( "opening fifo" );
  try {
    fifo = new BufferedWriter(new FileWriter("/tmp/fifo"));
      } 
  catch (IOException e) 
  {
    println( e );
  }
  println( "ok" );
  readData();
  i = dataList.iterator();
  println( "starting to send data..." );
}

void mousePressed()
{
    delayTime = (int) map( mouseX, 0, width, minDelay, maxDelay );
    
  //  println( delayTime );
}  
void draw()
{
  background(0);
  if(i.hasNext() )
  {
    fill(255);
    rect(0,0,delayTime,height);
    println( i.next() );
    try
    {
       fifo.write(i.next().toString());
       fifo.write("," + count ++ );
       fifo.write( "\n" );
       fifo.flush();
    }
    catch( IOException e )
    {
      println( "caught IOexception: " + e );
      exit();
    }
    delay( delayTime );
  }
  else
  {
  println( "finished" );
  try{
    
  fifo.close();
  
  }
   catch( IOException e )
    {
      println( "caught IOexception: " + e );
      exit();
    }
  while( true )
  {
    ;;
  }
  }
}
void readData()
{
  try {
    BufferedReader in = new BufferedReader(new FileReader("/tmp/t2"));
    String s;
    int lines = 0;
    while((  s = in.readLine()) != null )
    {
      lines ++;
    //  println( s );
      String [] datum = s.split(",");
      String data = datum[0];
      float energy = 0;
      try
      {
         energy = Float.valueOf(datum[1].trim()).floatValue();
 //        System.out.println("float f = " + energy);
      }
      catch (NumberFormatException nfe)
      {
        System.out.println("NumberFormatException: " + nfe.getMessage());
      }
      dataList.add( energy );
    }
    in.close();
      println( "got " + lines + " lines" );

  } 
  catch (IOException e) 
  {
    println( e );
  }
}
