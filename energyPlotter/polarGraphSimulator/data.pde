 public int parseMinutes(String timestamp)
    throws Exception {
   /*
   ** we specify Locale.US since months are in english
   */
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
   Date d = sdf.parse(timestamp);
   Calendar cal = Calendar.getInstance();
   cal.setTime(d);
   return cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE); 

 }



