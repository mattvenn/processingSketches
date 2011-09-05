float[][] energyArray;
int numBuckets = 1440;
int day, bucket = 0;
int numDays =7;
int maxEnergy = 4000;
//globals

void setupData()
{
  energyArray = new float[numDays][numBuckets];
  readData();
}

void readData()
{
  int i = 0;
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
      energyArray[0][i] += energy;
     // if( lines % 10 == 0 )
        i ++;
//      if( i >= numBuckets )
  //      break;
    }
    in.close();
      println( "got " + lines + " rows, made " + i + "buckets" );

  } 
  catch (IOException e) 
  {
    println( e );
  }
}
void getData()
{

  for( int days = 0; days < numDays ; days ++ )
  {
    for( int i = 0; i < numBuckets ; i ++ )
    {
      energyArray[days][i] = random(1,maxEnergy );
    }
  }
}

