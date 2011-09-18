import processing.net.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;    
import java.net.*;
import java.io.*;

//where we'll store the data
String energyFile = "/home/matthew/energy.data";
String host = "api.pachube.com";
String URL = "/v2/feeds/28462/datastreams/4.csv";
String key; //store your key in ./data/key
String interval = "0";
ArrayList data = new ArrayList();

void setup()
{
  size(200, 200);
  key = loadKey();
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
  Calendar calendar = new GregorianCalendar(2011,Calendar.SEPTEMBER,13);

  for( int i = 0; i <= 4; i ++ )
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
  println( "finished" );
  try {
    BufferedWriter out = new BufferedWriter(new FileWriter(energyFile));
    for(Iterator i = data.iterator();i.hasNext();)
    {
      out.write((String)(i.next()));
      out.write( "\n" );
    }
    out.close();
  } 
  catch (IOException e) 
  {
    println( e );
  }
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

