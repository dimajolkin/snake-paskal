uses GraphABC, Events, Timers;

type TPoint = packed record
  public   
   X: integer;
   Y: integer;
   
   constructor Create(x0, y0: integer);
    begin
      X := x0; Y := y0;
    end;   
end;

type TWindow = packed record
  public   
   X: integer;
   Y: integer;
   blockSize: integer;
   
   constructor Create(x0, y0: integer; bs: integer);
    begin
      X := round(x0 / bs) - 1;
      Y := floor(y0 / bs) - 1;

      blockSize := bs;
      SetWindowSize(x0, y0);
    end;
    
    procedure drawPixel(x, y: integer; c: Color);
    begin
      SetBrushColor(c);
      FillRectangle(x * blockSize, y * blockSize, (x *blockSize) + blockSize, (y * blockSize) + blockSize);
//      DrawRectangle(x * blockSize, y * blockSize, (x *blockSize) + blockSize, (y * blockSize) + blockSize);
    end;
    
    procedure drawPixel(point: TPoint; c: Color);
    begin
      drawPixel(point.X, point.Y, c);
    end;
   
end;

type TKeyboard = auto class
  public
     const KEY_UP = 'w';
     const KEY_DOWN = 's';
     const KEY_LEFT = 'a';
     const KEY_RIGHT = 'd';
     key: Char;
     lastPressKey: Char;  
   constructor Create(last: Char);
    begin
      lastPressKey := last;
      onKeyPress := _onKeyPress;    
    end;
   private 
    procedure _onKeyPress(key: Char);
    begin
       if (key = KEY_UP) or (key = KEY_DOWN) or (key = KEY_RIGHT) or (key = KEY_LEFT) then begin
         lastPressKey := key;
       end;
    end;
end;

type TSnake = packed record
  private
   len: integer;
   die: boolean;
   body: array[0..10000] of TPoint;
  public 
    constructor Create(p: TPoint);
    begin
      len := 0;
      body[len] := p;
    end;
    function isDie(): boolean;
    begin
      Result := die;
    end;
    function GetTail(): TPoint;
    begin
      Result := body[0];
    end;
   
    function GetHeader(): TPoint;
    begin
      Result := body[len];
    end;
    
    procedure Append(p: TPoint);
    begin
      inc(len);
      body[len] := p;
    end;
    
    procedure Move(h: TPoint);
    begin      
      for var i:=0 to len do begin
        body[i] := body[i + 1 ];
      end;
      body[len] := h;
    end;
    
    procedure KeyPress(c: Char);
    var p: TPoint;
    begin
      p := getHeader();
      case c of
        TKeyboard.KEY_UP: p := TPoint.Create(p.X, p.Y - 1);
        TKeyboard.KEY_DOWN: p := TPoint.Create(p.X, p.Y + 1);
        TKeyboard.KEY_LEFT: p := TPoint.Create(p.X - 1, p.Y);
        TKeyboard.KEY_RIGHT: p := TPoint.Create(p.X + 1, p.Y);
      end;
      
      if Cross(p) then die := True else Move(p);
    end;
    
    function Cross(p: TPoint): Boolean;
    begin
      Result := False;
      for var i := 0 to len do begin
        if p.Equals(body[i]) then begin
           Result := True;
        end; 
      end;
    end;
end;

type TScene = auto class
  public
    window: TWindow;
    eat: TPoint;
    snake: TSnake;
    keyboard: TKeyboard;
    gameTimer: Timer;
    
   constructor Create(w: TWindow; s: TSnake; k: TKeyboard);
   begin
     window := w;
     keyboard := k;
     snake := s;
     updateEat();
   end;
   
   procedure updateEat();
   begin
     repeat
       eat := TPoint.Create(random(0, window.X),random(0, window.Y));
     until not snake.Cross(eat);
   end;
  
  procedure checkMirrov();
  begin
    if snake.GetHeader().Y > window.Y then begin
         snake.Move(TPoint.Create(snake.GetHeader().X, 0));
    end;
    if snake.GetHeader().Y < 0 then begin
         snake.Move(TPoint.Create(snake.GetHeader().X, window.Y));
    end; 
    
    if snake.GetHeader().X > window.X then begin
         snake.Move(TPoint.Create(0, snake.GetHeader().Y));
    end;
    if snake.GetHeader().X < 0 then begin
         snake.Move(TPoint.Create(window.X, snake.GetHeader().Y));
    end;
  end;
     
  procedure update();
  begin
     if not snake.isDie() then begin
       window.drawPixel(eat, clred);
       window.drawPixel(snake.GetTail(), clwhite);
       snake.KeyPress(keyboard.lastPressKey);
       checkMirrov();
       if snake.GetHeader().Equals(eat) then begin
         snake.Append(eat);
         updateEat();
       end;
       window.drawPixel(snake.GetHeader(), clgreen);
     end else begin
       die();
     end;
  end;
  
  procedure die();
  begin    
    writeln('Вы проиграли!');
    writeln('Счёт:', snake.len);
    gameTimer.Stop();
    
  end;
  procedure run(speed: integer);
  begin
    gameTimer := Timer.Create(speed, update);
    gameTimer.Start();
  end;
end;

procedure snakeGame();
var
  window: TWindow;
  keyboard: Tkeyboard;
  scene: TScene;
  snake: TSnake;
begin
  randomize;
  window := TWindow.Create(500, 500, 20);
  keyboard := TKeyboard.Create(TKeyboard.KEY_DOWN);  
  snake := TSnake.Create(TPoint.Create(10, 10));
  scene := TScene.Create(window, snake, keyboard);
  scene.run(150);
end;

begin
  snakeGame();
end.