Uses Crt;
 Var ch :Char;
     kod :Integer;
 Begin
  ClrScr;
  WriteLn('ASCII');
  kod := 0;
  While(kod <> 27) Do
   Begin
    ch := ReadKey;
    kod := Ord(ch);
    WriteLn(ch,' = ',kod);
   End;
 End.