program snake;

uses
   crt;

const
   n = 100;

const
   m = 10;

var
   key, k: char;               // нажатая клавиша
   xs, ys: array[1..n] of integer;  //змейка
   xm, ym, xm1, ym1: integer;   // доп. переменные к змейке
   xr, yr: integer;           // коорд "яблочка"
   i, j: integer;             //счетчик
   score, mscore: integer;    //очки
   fcnfg, fsave, fmap: text;        //файлы
   les, ris, ups, dos: char;    //клавиши
   lem, rim, upm, dom: integer; 
   fail, go: boolean;         //вспомогательные переменные 
   map: array[1..81, 3..27] of char;
   useless: char;
   speed: integer;  
   smap,smapbuf: string;
   fcount: integer;
   fcurent: integer;
   
procedure right();// пойти вправо
begin
   inc(xs[1]);
   go := true;
   gotoxy(1, 1);
   write(ord(key)); 
   writeln(' ', xs[1], ' ', ys[1], ' Score: ', score - 3, '    ');
end;

procedure left();// пойти влево
begin
   dec(xs[1]);
   go := true;
   gotoxy(1, 1);
   write(ord(key)); 
   writeln(' ', xs[1], ' ', ys[1], ' Score: ', score - 3, '    ');
end;

procedure up();// пойти вверх
begin
   dec(ys[1]);
   go := true;
   gotoxy(1, 1);
   write(ord(key)); 
   writeln(' ', xs[1], ' ', ys[1], ' Score: ', score - 3, '    ');
end;

procedure down();//пойти вниз
begin
   inc(ys[1]);
   go := true;
   gotoxy(1, 1);
   write(ord(key)); 
   writeln(' ', xs[1], ' ', ys[1], ' Score: ', score - 3, '    ');
end;

procedure nextturn();
var
   i: integer;
begin
   for i := 2 to score do 
   begin
      xm1 := xs[i];
      ym1 := ys[i];
      xs[i] := xm;
      ys[i] := ym;
      xm := xm1;
      ym := ym1;
   end; 
end;

procedure levelup();
var
   chek:boolean;
   i:integer;
begin
   inc(score);
   gotoxy(1, 1);
   write(ord(key));
   chek:=false;
   writeln(' ', xs[1], ' ', ys[1], ' Score: ', score - 3, '   ');
   repeat
      xr := random(78) + 2;
      yr := random(21) + 4;
      for i := 1 to score do begin
         if (xr = xs[i]) and (yr = ys[i]) then chek:=true
      end;
   until (map[xr,yr] = ' ') and (not chek);
   gotoxy(xr, yr);
   write(8);
   xs[score] := xm;
   ys[score] := ym;
end;

procedure game(); forward;
procedure mainmenu(); forward;

procedure endmenu();
var
   s:array[0..4] of string;
   i, j, c: integer;
   x, y: integer;
   bot: char;
begin
   x := 30;
   y := 11;
   c := 2;
   s[0]:='Заново';
   s[1]:='Главное меню';
   s[2]:='Выйти из игры';
   i:=0;
   for j:=0 to c do begin
      gotoxy(x,y+j);
      write(s[j]);
   end;
   gotoxy(x-2,y);
   write('*');
   while (true) do begin
      bot:= readKey;
      if (bot = dos) then begin
         gotoxy(x-2,y+i);
         write(' ');
         if (i < c) then 
         begin
            inc(i);
            gotoxy(x-2,y+i);
            write('*');
         end else begin
            i := 0;
            gotoxy(x-2,y);
            write('*');
         end;
      end;
      if (bot = ups) then begin
         gotoxy(x-2,y+i);
         write(' ');
         if (i > 0) then begin
            dec(i);
            gotoxy(x-2,y+i);
            write('*');
         end else begin
            i := c;
            gotoxy(x-2,y+c);
            write('*');
         end;
      end;
      if (bot = #13) then begin
         case i of
         0: begin
               fail:=false;
               game();
               exit;
            end;
         1: begin
               mainmenu();
               fail:=false;
               exit;
            end;
         2: begin
               exit;
            end;
         end;
      end;
   end;
end;

procedure endturn();
var sbuf:string;
    buf:integer;
begin
   if (score - 3 > mscore) then begin
      rewrite(fsave);
      write(fsave, score - 3);
      close(fsave);
   end;
   clrscr;
   gotoxy(25, 10);
   write('Ваш результат: ');
   write(score - 3);
   fail := true;
   endmenu();
   exit;
end;

procedure settings();
begin
   rewrite(fcnfg);
   clrscr;
   gotoxy(20, 10);
   write('Нажмите клавишу влево');
   key := readkey;
   if (key = #0) then key := readkey;
   writeln(fcnfg, ord(key));
   clrscr;
   gotoxy(20, 10);
   write('Нажмите клавишу вправо');
   key := readkey;
   if (key = #0) then key := readkey;
   writeln(fcnfg, ord(key));
   clrscr;
   gotoxy(20, 10);
   write('Нажмите клавишу вверх');
   key := readkey;
   if (key = #0) then key := readkey;
   writeln(fcnfg, ord(key));
   clrscr;
   gotoxy(20, 10);
   write('Нажмите клавишу вниз');
   key := readkey;
   if (key = #0) then key := readkey;
   writeln(fcnfg, ord(key));
   close(fcnfg);
   mainmenu();
   exit;
end;

procedure game();
var j,i:integer;
begin
      clrscr;                                     // приветствие
      
      reset(fcnfg);                    //настройка управления
      read(fcnfg, lem, rim, upm, dom);
      close(fcnfg);  
      les := chr(lem);
      ris := chr(rim);
      ups := chr(upm);
      dos := chr(dom);
      
      reset(fsave);              
      read(fsave, mscore);
      close(fsave);
      smapbuf:='';            //считывание карты
      str(fcurent,smapbuf);
      smap:='maps\map' + smapbuf + '.txt';
      assign(fmap, smap);
      
      reset(fmap);
      for j := 3 to 25 do 
      begin
         for i := 1 to 80 do 
         begin
            read(fmap, map[i, j]);
         end;
         readln(fmap, useless);
      end;
      close(fmap);
      
      fail := false;
      
      gotoxy(35, 10);
      write('игра началась');
      gotoxy(10, 12);
      write('Для того чтобы начать играть\n нажмите клавишу ^, v или <');
      delay(3000);
      clrscr;
      xs[1] := 45;
      ys[1] := 10;
      xs[2] := 46;
      ys[2] := 10;
      xs[3] := 47;
      ys[3] := 10;
      score := 3;
      repeat
         xr := random(78) + 2;
         yr := random(21) + 4;
      until (map[xr, yr] = ' ');
      gotoxy(1, 3);
      for j := 3 to 25 do           //вывод карты
      begin
         for i := 1 to 80 do 
         begin
            write(map[i, j]);
         end;
         gotoxy(1, j + 1);
      end;
      gotoxy(1, 1);
      write(ord(key));                                   //вывод данных
      writeln(' ', xs[1], ' ', ys[1], ' Score: ', score - 3);
      write('         Max Score: ', mscore);
      gotoxy(xs[1], ys[1]);
      write('###');
      gotoxy(xr, yr);
      write('8');
      key:=#1;
      while(true ) do 
      begin// окно со змейкой
         if KeyPressed then
         begin
            key := readKey;
            if (key = #0) then key := readKey;
         end;
         if (k = les) and (key = ris)  then key := k;    // проверка на правильность кнопки
         if (key = les) and (k = ris)  then key := k;
         if (k = dos) and (key = ups)  then key := k;
         if (key = dos) and (k = ups)  then key := k;
         k := key;
         if (key = #27) then begin
            endturn();
            exit;
         end;
         xm := xs[1];
         ym := ys[1];
         
         if (key = les) then left();    // частичный ход
         if (key = ris) then right();
         if (key = ups) then up();
         if (key = dos) then down();
         
         if (xs[1] = 0)  then xs[1] := 80;
         if (xs[1] = 81) then xs[1] := 1;
         if (ys[1] = 2)  then ys[1] := 25;
         if (ys[1] = 26) then ys[1] := 3;
         if go then nextturn();                   // конец хода 
         go := false;
         
         if(map [xs[1], ys[1]] = '*') then endturn();
         for i := 2 to score do 
         begin
            if(xs [1] = xs[i]) and (ys[1] = ys[i]) then begin
               endturn();
               exit;
            end;
         end;
         if fail then exit;
         if (xr = xs[1]) and (yr = ys[1]) then levelup();
         
         delay(20);
         gotoxy(xm, ym);
         write(' ');
         gotoxy(xs[1], ys[1]);
         write('#');
         delay(speed);
      end;
      if fail then exit;
   end;

procedure info();
begin
   clrscr;
   gotoxy(15,9);
   write('Игра создана по мотивам легендарной игры "Змейка"');
   gotoxy(15,11);
   write('Играйте, устанавливайте свои рекорды и веселитесь');
   gotoxy(15,13);
   write('Игра создана Нестором Владимиром в мае 2015 года');
   gotoxy(24,14);
   write('при помощи языка PascalABC.NET');
   readkey;
end;

procedure mapeditor(); forward;

procedure editormenu();
var
   s:array[0..2] of string;
   i, j, c: integer;
   x, y: integer;
   bot: char;
begin
   clrscr;
   x := 30;
   y := 12;
   c := 2;
   s[0]:='Новая карта';
   s[1]:='Редактировать выбранную';
   s[2]:='Выйти из игры';
   i:=0;
   for j:=0 to c do begin
      gotoxy(x,y+j);
      write(s[j]);
   end;
   gotoxy(x-2,y);
   write('*');
   while (true) do begin
      bot:= readKey;
      if (bot = dos) then begin
         gotoxy(x-2,y+i);
         write(' ');
         if (i < c) then 
         begin
            inc(i);
            gotoxy(x-2,y+i);
            write('*');
         end else begin
            i := 0;
            gotoxy(x-2,y);
            write('*');
         end;
      end;
      if (bot = ups) then begin
         gotoxy(x-2,y+i);
         write(' ');
         if (i > 0) then begin
            dec(i);
            gotoxy(x-2,y+i);
            write('*');
         end else begin
            i := c;
            gotoxy(x-2,y+c);
            write('*');
         end;
      end;
      if (bot = #13) then begin
         case i of
         0: begin
               smapbuf:='';   
               inc(fcount);
               str(fcount,smapbuf);
               smap:='maps\map' + smapbuf + '.txt';
               assign(fmap, smap);
               rewrite(fmap);
               for j := 3 to 25 do        //запись карты
               begin
                  for i := 1 to 80 do 
                  begin
                     write(fmap, ' ');
                  end;
                  writeln(fmap);
               end;
               fcurent:=fcount;
               close(fmap);
               mapeditor();
               exit;
            end;
         1: begin
               mapeditor();
               fail:=false;
               exit;
            end;
         2: begin
               exit;
            end;
         end;
      end;
   end;
end;

procedure mapeditor();
var
   x, y: integer;
   i, j: integer;
begin
   x:=1;
   y:=3;
   smapbuf:='';            
   str(fcurent,smapbuf);
   smap:='maps\map' + smapbuf + '.txt';
   assign(fmap, smap);
   reset(fmap);
   for j := 3 to 25 do        //считывание карты
   begin
      for i := 1 to 80 do 
      begin
         read(fmap, map[i, j]);
      end;
      readln(fmap, useless);
   end;
   close(fmap);
   gotoxy(x,y);
   for j:=3 to 25 do          //вывод карты
   begin
      for i := 1 to 80 do 
      begin
         write(map[i, j]);
      end;
      gotoxy(1, j + 1);
   end;
   key:=readkey;
   while key <> #27 do begin
      gotoxy(x,y);
      if (key = #13) then 
         if (map[x,y] = ' ') then map[x,y]:='*' else map[x,y]:=' ';
      write(map[x,y]);
      if (key = les) then 
         if (x = 1) then x:=80 else dec(x);
      if (key = ris) then 
         if (x = 80) then x:=1 else inc(x);
      if (key = ups) then 
         if (y = 3) then y:=25 else dec(y);
      if (key = dos) then 
         if (y = 25) then y:=3 else inc(y);
      gotoxy(x,y);
      write('o');
      key:=readkey;
   end;
   rewrite(fmap);
   for j := 3 to 25 do        //запись карты
   begin
      for i := 1 to 80 do 
      begin
         write(fmap, map[i, j]);
      end;
      writeln(fmap);
   end;
   close(fmap);
   clrscr;
   mainmenu();
   exit;
end;

procedure mainmenu();
var
   s:array[0..6] of string;
   i, j, c: integer;
   x, y: integer;
   bot: char;
begin
   x := 20;
   y := 10;
   c := 5;
   s[0]:='Начать играть';
   s[1]:='Поменять управление';
   s[2]:='Cкорость : ';
   s[3]:='Редактор карты';
   s[4]:='Выбор карты : ';
   s[5]:='Информация об игре';
   s[6]:='Выйти из игры';
   i:=0;
   clrscr;
   for j:=0 to c do begin
      gotoxy(x,y+j);
      write(s[j]);
   end;
   fcurent:=1;
   gotoxy(x + 11,y + 2);
   write(500 - speed);
   gotoxy(x + 15, y + 4);
   write(fcurent,'   ');
   
   gotoxy(x-2,y);
   write('*');
   while (true) do begin
      bot:= readKey;
      if (bot = dos) then begin   //передвижение курсора
         gotoxy(x-2,y+i);
         write(' ');
         if (i < c) then 
         begin
            inc(i);
            gotoxy(x-2,y+i);
            write('*');
         end else begin
            i := 0;
            gotoxy(x-2,y);
            write('*');
         end;
      end;
      if (bot = ups) then begin
         gotoxy(x-2,y+i);
         write(' ');
         if (i > 0) then begin
            dec(i);
            gotoxy(x-2,y+i);
            write('*');
         end else begin
            i := c;
            gotoxy(x-2,y+c);
            write('*');
         end;
      end;
      if (i = 2) then begin      //кнопка speed
         if(bot = les) and ( speed < 500) then begin
            speed:=speed + 20;
            gotoxy(x + 11, y + 2);
            write(500 - speed,'   ');
         end;
         if(bot = ris) and ( speed > 20) then begin
            speed:=speed - 20;
            gotoxy(x + 11, y + 2);
            write(500 - speed,'   ');
         end;
      end;
      if (i = 4) then begin      //выбор карты
         if(bot = les) and ( fcurent > 1) then begin
            dec(fcurent);
            gotoxy(x + 15, y + 4);
            write(fcurent,'   ');
         end;
         if(bot = ris) and ( fcurent < fcount) then begin
            inc(fcurent);
            gotoxy(x + 15, y + 4);
            write(fcurent,'   ');
         end;
      end;
      if (bot = #13) then begin //действие
         case i of
         0: begin
               game();
               exit;
            end;
         1: begin
               settings();
               exit;
            end;
         3: begin
               editormenu();
               exit;
            end;
         5: begin
               info();
               exit;
            end;
         6: begin
               exit;
            end;
         end;
      end;
   end;
end;

begin
   assign(fcnfg, 'config.txt');
   assign(fsave, 'save.txt');
   
   fcount:=1;
   smap:='maps\map1.txt';
   
   
   while FileExists(smap) do begin
      smapbuf:='';
      inc(fcount);
      str(fcount,smapbuf);
      smap:='maps\map' + smapbuf + '.txt';
   end;
   dec(fcount);
   
   reset(fcnfg);                 //настройка управления
   read(fcnfg, lem, rim, upm, dom);
   close(fcnfg);  
   les := chr(lem);
   ris := chr(rim);
   ups := chr(upm);
   dos := chr(dom);
   
   speed:=100;
   Window(1, 1, 200, 100);
   textbackground(15);
   textcolor(1);
   clrscr;
   
   mainmenu();
   clrscr;                                                 // Выход из игры
   gotoxy(35, 10);
   writeln('До свидания');
   delay(1000);
end.