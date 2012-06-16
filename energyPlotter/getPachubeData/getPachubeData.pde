import processing.net.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;    
import java.net.*;
import java.io.*;

//how much data do we get?

//interval, allows more sparse data
String interval = "0"; // "0"; //interval 0 == all data, 60 = one datapoint every 60 secs
//how many days data
int days = 90;
//when from?
Calendar calendar = new GregorianCalendar(2011,Calendar.NOVEMBER,16);


//where we'll store the data
String energyFile = "/home/matthew/energy.data";
String host = "api.pachube.com";
String URL = "/v2/feeds/28462/datastreams/1.csv";
//String URL = "/v2/feeds/28462/datastreams/4.csv";
String key; //store your key in ./data/key
ArrayList data = new ArrayList();
BufferedWriter out;
void setup()
{
  size(200, 200);
  key = loadKey();

  try {
    out = new BufferedWriter(new FileWriter(energyFile));
    
  } 
  catch (IOException e) 
  {
    println( e );
  }

}


String loadKey()
{
  try {
    BufferedReader in = new BufferedReader(new FileReader(sketchPath("./data/key")));
    String k = in.readLine();
    k.trim();
    return k;
  } 
  catch (IOException e) 
  {
    println( e );
    exit();
  }
  return "";
}

void draw() {
  String date, lastDate = "";
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");


  
  for( int i = 0; i <= 4 * days; i ++ )
  {
    date = sdf.format(calendar.getTime());
    println( "from " + lastDate + " to " + date );
    if( lastDate.length() >0)
    {
      int pageNum = 1; //1 indexed!
      while( true )
      {

        int linesGot = readURL( String.format( "http://%s%s?key=%s&start=%s&end=%s&interval=%s&page=%d", host, URL,key,lastDate,date,interval,pageNum ++) ) ; 
        if( linesGot != 100 )
          break;
      }
    
    
 
   
  }    
    lastDate = date;
    calendar.add(Calendar.HOUR,6);
  }
  //do nothing
  try
  {
    out.close();
  }
   catch (IOException e) 
  {
    println( e );
    exit();
  }
  println( "finished" );
  while(true)
  {
  }
}

int readURL( String urlString )
{
  try
  {
    URL url = new URL(urlString);
    println( url.getHost() );
    println( url );
    BufferedReader in = new BufferedReader(
    new InputStreamReader(
    url.openStream()));

    String inputLine;
    int lines = 0;
    while ((inputLine = in.readLine()) != null)
    {
      // System.out.println(inputLine);
      data.add( inputLine );
      lines ++;
      out.write((String)(inputLine));
      out.write( "\n" );
    
    }
    println( "got " + lines );
    println( "array size: " + data.size() );
    in.close();
    return lines;
  } 
  catch( MalformedURLException e )
  {
    println( e );
  }
  catch( IOException e )
  {
    println( e );
  }
  return -1;
}


void processData( String data )
{
  String[] dataArray = split( data, '\n' );
  println( data.length() );
  println( data );

  println(  dataArray.length );
}

