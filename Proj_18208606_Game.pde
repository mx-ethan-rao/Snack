PImage apple;
PImage bk;
PImage bomb;
PImage wel;
PImage level;
int time;
int unitSize=13;
int toolSize=30;
int bombNum;
int track_length;
int page; //record the page that players choosed
int barSize=20; //size of barriers
int direction;
  /*only for level 3 to keep a distance between snack and reseted bombs for reaction, 
    reactionTime=54 means players have 3*60/54=0.3s for reaction at least */
int reactionSpace=54;
int[] barDirection= new int[2];
float[] x_track= new float[10000];
float[] y_track= new float[10000];
float[] x_bar= new float[2]; //x of barriers
float[] y_bar= new float[2];
float unit;  // snack increases by one unit
float x_head,y_head;
float x_apple,y_apple;
float m;
float[] x_bomb= new float[7];
float[] y_bomb= new float[7];
float[] speed={1.5, 2.5, 3};
boolean replay;
boolean p;  //to generate a proper apple position without overlaping
boolean gameFail;
void setup()
{
  background(255);
  size(600,600);
  apple= loadImage("apple.png");
  bk= loadImage("background.png");
  bomb= loadImage("bomb.png");
  wel= loadImage("welcome.jpg");
  level= loadImage("levelSelect.png");
  x_head=random(width-unitSize); y_head=random(height-unitSize);
  for(int i=0; i<x_bomb.length; i++){
    x_bomb[i]=random(width-toolSize); y_bomb[i]=random(height-toolSize);
  }
       //check if apple and bombs are overlap
  do{
    p=true;
    x_apple=random(width-toolSize); y_apple=random(height-toolSize);
    for(int i=0; i<x_bomb.length;i++)
      if(x_apple+toolSize>x_bomb[i]&&x_apple<x_bomb[i]+toolSize&&y_apple+toolSize>y_bomb[i]&&y_apple<y_bomb[i]+toolSize)
        {p=false; break;}
  }while(!p);
    //initial all variables for restarting the game
  for(int i=0;i<x_track.length;i++)
    {x_track[i]=-300; y_track[i]=-300;}
  barDirection[0]=barDirection[1]=0;
  track_length=3; 
  page=1;
  x_bar[0]=x_bar[1]=y_bar[0]=y_bar[1]=-300;
  m=0;
  time=0;
  replay=true;
  gameFail=false;
  smooth();
}
void draw()
{
  if(page==1) welcomePage();
  else if(page==2) instructionPage();
  else if(page==3) levelSelectPage();
  else if(page==4) gamePlayPage(unit,bombNum);

}
void welcomePage()
{
  image(wel, 0, 0, width, height);
  
}
void instructionPage()
{
  image(bk, 0, 0, width, height); textSize(25); fill (255,50,50); 
  text("Use direction key to control the snack",50,200);
  text("Eat apple, you will earn scores",50,250);
  text("Eat bombs, collide with barriers or track,\nyou will lose the game",50,300);
  text("Press 'P' to pause the game and 'r' to resume",50,320);
  text("\nClick 'r' to return back to the welcome page...",50,350);
}
void levelSelectPage()
{
  image(level,0,200,600,200);
  textSize(25); fill(255,50,50);
  text("Please select a level...",10,42);
}
void gamePlayPage(float speed, int bombNum)
{
  gameFail=failure(x_head,y_head,bombNum);  //check if the game is over
  image(bk,0,0,width,height);
  image(apple,x_apple,y_apple,toolSize,toolSize);
      // seven bombs and two barriers will be reseted a random position in intervel of 5s
  if(bombNum==7&&time/60%5==0&&time%60==0) {bombActive(); barrierCheck(bombNum);}
  for(int i=0; i<bombNum; i++) image(bomb,x_bomb[i],y_bomb[i],toolSize,toolSize);
  if(replay) barrierCheck(bombNum); //check overlap of tools
  stroke(0);
  strokeWeight(2);
  fill(252,252,5); 
  rectMode(CORNER);
       // put the barriers at vertical or horizental position within the window simultanously
  for(int i=0;i<=1;i++){
    if(replay) m=random(0,2);
    if(m<1)
      if(x_bar[i]+barSize*6<width)
        for(int n=0; n<=5; n++) {rect(x_bar[i]+n*barSize,y_bar[i],barSize,barSize); barDirection[i]=1;}
      else
        for(int n=0; n<=5; n++) {rect(x_bar[i],y_bar[i]+n*barSize,barSize,barSize); barDirection[i]=2;}
    else
      if(y_bar[i]+barSize*6<height)
        for(int n=0; n<=5; n++) {rect(x_bar[i],y_bar[i]+n*barSize,barSize,barSize); barDirection[i]=2;}
      else
        for(int n=0; n<=5; n++) {rect(x_bar[i]+n*barSize,y_bar[i],barSize,barSize); barDirection[i]=1;}
   }
  strokeWeight(1);
  replay=false;
  fill(255,125,125);
      // stop the snack when game fails
  if(!gameFail){
    if(direction==UP) y_head -= speed;
    else if(direction==DOWN) y_head += speed;
    else if(direction==LEFT) x_head -= speed;
    else if(direction==RIGHT) x_head += speed;
  }
     //appear at another side when snack is going to go outside the window
  x_head= x_head>width+unitSize/2?-unitSize/2:x_head;
  x_head= x_head<-unitSize/2?width+unitSize/2:x_head;
  y_head= y_head>height+unitSize/2?-unitSize/2:y_head;
  y_head= y_head<-unitSize/2?height+unitSize/2:y_head;
     //different levels are given the same track-increasing length when eats apple
  int n=0;
  if(bombNum==3) n=30;
  else if(bombNum==5) n=18;
  else if(bombNum==7) n=15;
  x_track[0]=x_head; y_track[0]=y_head;
  //when eat apples 
  if(x_head+unitSize/2>x_apple&&x_head-unitSize/2<x_apple+toolSize&&y_head+unitSize/2>y_apple&&y_head-unitSize/2<y_apple+toolSize){ // when snack eats apple
    track_length += n;
    do{
    p=true;
    x_apple=random(width-toolSize); y_apple=random(height-toolSize);
    for(int i=0; i<x_bomb.length;i++)
      if(x_apple+toolSize>x_bomb[i]&&x_apple<x_bomb[i]+toolSize&&y_apple+toolSize>y_bomb[i]&&y_apple<y_bomb[i]+toolSize)
        {p=false; break;}
    }while(!p);
  }
  noStroke();
      //display the current snack position each frame
  for(int i=0; i<=track_length;i++) if(i!=0) ellipse(x_track[i],y_track[i],unitSize,unitSize);
  stroke(50);
  ellipse(x_head,y_head,unitSize,unitSize);
      // draw the eyes
  fill(0);
  switch(direction){
    case UP: case DOWN:
      {ellipse(x_head-3,y_head,2,3); ellipse(x_head+3,y_head,2,3); break;}
    case LEFT: case RIGHT:
      {ellipse(x_head,y_head-3,3,2); ellipse(x_head,y_head+3,3,2); break;}
  }
  if(gameFail==true){
    fill(255,0,0);
    textSize(25);
    text("press ENTER to restart the game...",10,42);
    text("Press ESC to exit...",10,70);
    textSize(80);
    text("Game Over!!",50,200);
    textSize(50);
    fill(82,10,242);
    text("LEVEL"+(bombNum-1)/2,170,300);
    text("TIME:"+time/60+"s",170,360);
    text("LENGTH:"+int(3+(track_length-3)/(45/speed)),170,420);
       //when game fialed, point out the place of collision
    stroke(random(255),random(255),random(255)); strokeWeight(2);
    for(int i=0; i<=1; i++)
    switch(direction){
      case UP:
        line(x_head+10*cos((i==0?-1:-5)*PI/6),y_head+10*sin((i==0?-1:-5)*PI/6),x_head+22*cos((i==0?-1:-5)*PI/6),y_head+22*sin((i==0?-1:-5)*PI/6));
        line(x_head+10*cos((i==0?-1:-2)*PI/3),y_head+10*sin((i==0?-1:-2)*PI/3),x_head+22*cos((i==0?-1:-2)*PI/3),y_head+22*sin((i==0?-1:-2)*PI/3));
        line(x_head+10*cos(-PI/2),y_head+10*sin(-PI/2),x_head+22*cos(-PI/2),y_head+22*sin(-PI/2));
        break;
      case DOWN:
        line(x_head+10*cos((i==0?1:5)*PI/6),y_head+10*sin((i==0?1:5)*PI/6),x_head+22*cos((i==0?1:5)*PI/6),y_head+22*sin((i==0?1:5)*PI/6));
        line(x_head+10*cos((i==0?1:2)*PI/3),y_head+10*sin((i==0?1:2)*PI/3),x_head+22*cos((i==0?1:2)*PI/3),y_head+22*sin((i==0?1:2)*PI/3));
        line(x_head+10*cos(PI/2),y_head+10*sin(PI/2),x_head+22*cos(PI/2),y_head+22*sin(PI/2));
        break;
      case LEFT:
        line(x_head+10*sin((i==0?-1:-5)*PI/6),y_head+10*cos((i==0?1:5)*PI/6),x_head+22*sin((i==0?-1:-5)*PI/6),y_head+22*cos((i==0?1:5)*PI/6));
        line(x_head+10*sin((i==0?-1:-2)*PI/3),y_head+10*cos((i==0?1:2)*PI/3),x_head+22*sin((i==0?-1:-2)*PI/3),y_head+22*cos((i==0?1:2)*PI/3));
        line(x_head+10*sin(-PI/2),y_head+10*cos(PI/2),x_head+22*sin(-PI/2),y_head+22*cos(PI/2));
        break;
      case RIGHT:
        line(x_head+10*sin((i==0?1:5)*PI/6),y_head+10*cos((i==0?1:5)*PI/6),x_head+22*sin((i==0?1:5)*PI/6),y_head+22*cos((i==0?1:5)*PI/6));
        line(x_head+10*sin((i==0?1:2)*PI/3),y_head+10*cos((i==0?1:2)*PI/3),x_head+22*sin((i==0?1:2)*PI/3),y_head+22*cos((i==0?1:2)*PI/3));
        line(x_head+10*sin(PI/2),y_head+10*cos(PI/2),x_head+22*sin(PI/2),y_head+22*cos(PI/2));
        break;
    }
    strokeWeight(1);
  }
  else{
    textSize(20);
    fill(255,0,0);
    text("TIME:"+time/60+"s",10,20);
    text("LENGTH:"+int(3+(track_length-3)/(45/speed)),10,45);
      //update the position of the snack
    for(int i=track_length;i>0;i--){
      x_track[i]=x_track[i-1];
      y_track[i]=y_track[i-1];
    }
    time++;
  }
}
boolean failure(float x,float y,int bombNum){
  boolean collision=true;
  int a=0,b=0;
  if(direction==UP) {a=0; b=-unitSize/2;}
  else if(direction==DOWN) {a=0; b=unitSize/2;}
  else if(direction==LEFT) {a=-unitSize/2; b=0;}
  else if(direction==RIGHT) {a=unitSize/2; b=0;}
        //check collision of bomb
  for(int i=0;i<bombNum;i++)
   if(x+a>x_bomb[i] && x+a<x_bomb[i]+toolSize && y+b>y_bomb[i] && y+b<y_bomb[i]+toolSize)
     return collision;
        // check collision of barrier
  for(int j=0; j<=1 ;j++){
    if(barDirection[j]==1){
      for(int i=0; i<6;i++) 
        if(x+a>x_bar[j]+i*barSize && x+a<x_bar[j]+i*barSize+barSize && y+b>y_bar[j] && y+b<y_bar[j]+barSize)
          return collision;
    }
    else if(barDirection[j]==2){
      for(int i=0; i<6;i++) 
        if(x+a>x_bar[j] && x+a<x_bar[j]+barSize && y+b>y_bar[j]+i*barSize && y+b<y_bar[j]+i*barSize+barSize)
          return collision;
    }
  }
     //check if collision of itself
  for(int i=4; i<=track_length;i++)
    if(x+a>x_track[i]-unitSize/2&&x+a<x_track[i]+unitSize/2&&y+b>y_track[i]-unitSize/2&&y+b<y_track[i]+unitSize/2)
      return collision;
  return !collision;
}
void bombActive()
{
    //all bombs will be reseted a new position without overlaping with snack and apple
  for(int j=0; j<=6;j++){
    float x=random(width-toolSize),y=random(height-toolSize);
    boolean s=true;
      // check if the bombs will overlap with snack or apple
    do{
      x=random(0,500-toolSize); y=random(0,500-toolSize);
      s=true;
      if(x+toolSize>x_apple && x<x_apple+toolSize && y+toolSize>y_apple && y<y_apple+toolSize)
        {s=false; break;}
      for(int i=0;i<=track_length;i++)
        if(x+reactionSpace+toolSize>x_track[i]-unitSize/2&&x-reactionSpace<x_track[i]+unitSize/2&&y+reactionSpace+toolSize>y_track[i]-unitSize/2&&y-reactionSpace<y_track[i]+unitSize/2)
          {s=false; break;}
    }while(!s);
    x_bomb[j]=x; y_bomb[j]=y;
  }
}
void barrierCheck(int level)
{
       //check if barrier,bomb and apples will overlap
  for(int j=0; j<=1;j++)
    if(level!=3){
    float x=random(0,500),y=random(0,500);
    boolean s=true;
    do{
      x=random(0,500);y=random(0,500);
      s=true;
      for(float i=x;i<=x+120;i += 20){
        if(i+barSize>x_apple && i<x_apple+toolSize && y+barSize>y_apple && y<y_apple+toolSize)
           {s=false; break;}
      }
      for(float q=y;q<=y+120;q += 20){
        if(x+barSize>x_apple && x<x_apple+toolSize && q+barSize>y_apple && q<y_apple+toolSize)
           {s=false; break;}
      }
      for(float i=x;i<=x+120;i += 20){
        if(s==false) break;
        for(int n=0;n<bombNum;n++)
          if(i+barSize>x_bomb[n] && i<x_bomb[n]+toolSize && y+barSize>y_bomb[n] && y<y_bomb[n]+toolSize)
             {s=false; break;}
      }
      for(float q=y;q<=y+120;q += 20){
        if(s==false) break;
        for(int n=0;n<bombNum;n++)
          if(x+barSize>x_bomb[n] && x<x_bomb[n]+toolSize && q+barSize>y_bomb[n] && q<y_bomb[n]+toolSize)
             {s=false; break;}
      }
      //only for level 3 to check the overlap with snack head
      if(level==7&&time/60%5==0&&time%60==0){
        for(float i=x;i<=x+120;i += 20){
        if(s==false) break;
        for(int n=0;n<bombNum;n++)
          if(i+barSize>x_head-unitSize/2 && i<x_head+unitSize/2 && y+barSize>y_head-unitSize/2 && y<y_head+unitSize/2)
             {s=false; break;}
      }
        for(float q=y;q<=y+120;q += 20){
        if(s==false) break;
        for(int n=0;n<bombNum;n++)
          if(x+barSize+reactionSpace>x_head-unitSize/2 && x-reactionSpace<x_head+unitSize/2 && q+reactionSpace+barSize>y_head-unitSize/2 && q-reactionSpace<y_head+unitSize/2)
             {s=false; break;}
      }
      }
    }while(!s);
    x_bar[j]=x; y_bar[j]=y; //change the global value
   }
}
void mousePressed()
{
  if(page==1){
    if(mouseX>273 && mouseX<454 && mouseY>304 && mouseY<361) page=3;
    else if(mouseX>273 && mouseX<454 && mouseY>400 && mouseY<459) page=2;
  }
  else if(page==3){
      if(mouseX>23 && mouseX<163 && mouseY>222 && mouseY<375){
        unit=speed[0]; bombNum=3;
      }
      else if(mouseX>227 && mouseX<367 && mouseY>226 && mouseY<380){
        unit=speed[1]; bombNum=5;
      }
      else if(mouseX>427 && mouseX<567 && mouseY>228 && mouseY<374){
        unit=speed[2]; bombNum=7;
      }
      int i= int(random(0,4));
      if(i==0){ direction=UP;} else if(i==1){ direction=DOWN;}
      else if(i==2){ direction=LEFT;} else if(i==3){ direction=RIGHT;}
      page=4;
  }
}
void keyPressed()
{
  if(page==2&&key=='r') page=1;
  else if(keyCode==ENTER) setup();
  else if(keyCode==ESC) exit();
  else if(page==4&&key=='p') noLoop();
  else if(page==4&&key=='r') loop();
  else if(!gameFail&&page==4&&(keyCode==UP||keyCode==DOWN||keyCode==LEFT||keyCode==RIGHT)) direction=keyCode;
}
