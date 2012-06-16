

float rads(int n) {
  // Return an angle in radians
  return (n/180.0 * PI);
}                                                                        

void moveTo(int x2, int y2) {
  
  // Turn the stepper motors to move the marker from the current point (x1,
  // y1) to (x2, y2)
  // Note: This only moves in a perfectly straight line if 
  // the distance is the same in both dimensions; this should be fixed, but it
  // works well
  
  // a2 and b2 are the final lengths of the left and right strings
  int a2 = (int)sqrt(pow(x2,2)+pow(y2,2));
  int b2 = (int)sqrt(pow((w-x2),2)+pow(y2,2));
  int stepA = 0;
  int stepB = 0;
  if (a2>a1) { 
    stepA=1; 
  }
  if (a1>a2) { 
    stepA=-1;
  }
  if (a2==a1) {
    stepA=0; 
  }
  if (b2>b1) { 
    stepB=1; 
  }
  if (b1>b2) { 
    stepB=-1;
  }
  if (b2==b1) {
    stepB=0; 
  }

  // Change the length of a1 and b1 until they are equal to the desired length
  while ((a1!=a2) || (b1!=b2)) {
    if (a1!=a2) { 
      a1 += stepA;
      if( debug )
      {
         debugSteps ++;
      }
      //StepperA.step(stepA); 
      lString += stepA;
    }
    if (b1!=b2) { 
      b1 += stepB;
   //      StepperB.step(-stepB);
       rString += stepB;
       if( debug)
       {
         debugSteps ++;
       }
    }
    drawPoint();
  }
  x1 = x2;
  y1=y2;
}

void drawCurve(float x, float y, float fx, float fy, float cx, float cy) {
  // Draw a Quadratic Bezier curve from (x, y) to (fx, fy) using control pt
  // (cx, cy)
  float xt=0;
  float yt=0;
  int skipDistance = 5; //how far we have to move until we bother actually trying to move the pen
  for (float t=0; t<=1; t+=.0025) {
    xt = pow((1-t),2) *x + 2*t*(1-t)*cx+ pow(t,2)*fx;
    yt = pow((1-t),2) *y + 2*t*(1-t)*cy+ pow(t,2)*fy;
     if( abs(xt - x1) > skipDistance || abs( yt - y1 ) > skipDistance )
    moveTo((int)xt, (int)yt);
  }  
}
                                                     

              
void drawCircles(int number, int centerx, int centery, int r) {
   // Draw a certain number of concentric circles at the given center with
   // radius r
   int dr=0;
   if (number > 0) {
     dr = r/number;
     for (int k=0; k<number; k++) {
       drawCircle(centerx, centery, r);
       r=r-dr;
     }
   }
}
          
void drawCircleSegment(int centerx, int centery, int radius, int startSeg, int endSeg) {
  
    // Estimate a circle using 20 arc Bezier curve segments
//  println( centerx + "," + centery + ", " + radius + ", " + startSeg + ", " + endSeg );
  int segments = 20;
  int angle1 = 360/segments*startSeg;
  int midpoint=0;
  
  //little bit of limit handling
  if( endSeg > 20 )
   endSeg = 20;
   
  for (float angle2=360/segments*startSeg; angle2<=360/segments*endSeg; angle2+=360/segments) {

    midpoint = (int)(angle1+(angle2-angle1)/2);

    float startx=centerx+radius*cos(rads(angle1));
    float starty=centery+radius*sin(rads(angle1));
    float endx=centerx+radius*cos(rads((int)angle2));
    float endy=centery+radius*sin(rads((int)angle2));
    
    int t1 = (int)rads(angle1)*1000 ;
    int t2 = (int)rads((int)angle2)*1000;
    int t3 = angle1;
    int t4 = (int)angle2;

    drawCurve(startx,starty,endx,endy,
              centerx+2*(radius*cos(rads(midpoint))-.25*(radius*cos(rads(angle1)))-.25*(radius*cos(rads((int)angle2)))),
              centery+2*(radius*sin(rads(midpoint))-.25*(radius*sin(rads(angle1)))-.25*(radius*sin(rads((int)angle2))))
    );
    
    angle1=(int)angle2;
  }  
}

void drawCircle(int centerx, int centery, int radius) {

  moveTo(centerx+radius, centery);
//  debug = true;
  drawCircleSegment(centerx,centery,radius,0,20);
  debug = false;
  if( debug )
  {
    println( "took " + debugSteps ); debugSteps = 0;
  }
}


