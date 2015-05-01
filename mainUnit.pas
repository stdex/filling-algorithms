unit mainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, XPMan;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    btn1: TBitBtn;
    btn3: TBitBtn;
    btn4: TBitBtn;
    btn5: TBitBtn;
    btn2: TBitBtn;
    Image1: TImage;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
type
  Pmas = array [1..4] of TPoint;
var
  a: Pmas; // Массив точек

procedure TForm1.btn1Click(Sender: TObject);
//нарисовать фигуру
begin
  a[1].x := 20;
  a[1].y := 100;
  a[2].x := 60;
  a[2].y := 50;
  a[3].x := 100;
  a[3].y := 50;
  a[4].x := 140;
  a[4].y := 100;
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.FillRect(Rect(0, 0, Image1.Width - 1, Image1.Height - 1));
  Image1.Canvas.Polygon(a);
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  //Application.Terminate;
  Close;
end;

procedure TForm1.btn3Click(Sender: TObject);
//Простой алгоритм с упорядоченным списком ребер
var
  Peres, Spisok, Versh: array [1..100] of TPoint;
  k, temp, N, ymin, ymax, i, j, y, M, MinY, MaxY: integer;

//Подпрограмма заполнения интервала между парой точек Peres
procedure Interval(xlev, xpr, y: integer);
var
  x: real;
begin
  //Определение x-координаты самого левого пикселя в строке,
  //удовлетворяющего условию xлев <= x + 0.5
  x := Round(xlev + 0.5);
  if x = xlev + 0.5 then x := x - 1;
  while (x + 0.5 <= xpr) do
    begin
      Image1.Canvas.Pixels[Round(x), y] := clRed;
      Sleep(1);
      {
      Для повышения быстродействия программы сообщения (Messages!), которые объект Application посылает объктам программы,
      этими объектами выполняются не сразу после получения, а по мере накопления некоторой очереди.
      }
      Application.ProcessMessages;
      x := x + 1;
    end;
end;
begin
  btn1Click(nil);
  //Инициализация переменных
  for i := 1 to 4 do
    Versh[i] := a[i];
  M := 4;
  Versh[M + 1] := Versh[1];
  MinY := Versh[1].y;
  MaxY := MinY;
  j := 0;
  //Определение точек с осями сканирующих строк; занесение их в список;
  //определение границ многоугольника по y
  for i := 1 to M do
    begin
      if Versh[i].y <> Versh[i + 1].y then
        begin
          if Versh[i].y < Versh[i + 1].y then
            begin
              ymin := Versh[i].y;
              ymax := Versh[i + 1].y;
            end
          else
            begin
              ymin := Versh[i + 1].y;
              ymax := Versh[i].y;
            end;
          for y := ymin to ymax - 1 do
            begin
              j := j + 1;
              Peres[j].x := Round((Versh[i + 1].x - Versh[i].x) /
                            (Versh[i + 1].y - Versh[i].y) *
                            (y + 0.5 - Versh[i].y) + Versh[i].x);
              Peres[j].y := y;
              if MinY > ymin then MinY := ymin;
              if MaxY < ymax then MaxY := ymax;
            end; //for y
      end;
    end;
  N := j;
  //Сортировка точек Peres по x
  for y := MaxY - 1 downto MinY + 1 do
    begin
      j := 0;
      for i := 1 to N do
        begin
          if Peres[i].y = y then
            begin
              j := j + 1;
              Spisok[j].x := Peres[i].x;
            end;
          if j = 1 then continue; 
          k := j;
          while (Spisok[k].x < Spisok[k - 1].x) do
            begin
              temp := Spisok[k].x;
              Spisok[k].x := Spisok[k - 1].x;
              Spisok[k - 1].x := temp;
              k := k - 1;
              if k = 1 then Break;
            end;
        end;
      //Заполнение интервалов между парами пересечений
      i := 1;
      while i <= j - 1 do
        begin
          Interval(Spisok[i].x, Spisok[i+1].x, y);
          i := i + 2;
        end;
    end;
end;

procedure TForm1.btn4Click(Sender: TObject);
//Простой алгоритм заполнения с  затравкой
type
  Stack = ^Zveno; //динамический стек
  Zveno = record
    pred: Stack;
    x, y: integer;
  end;
var
  S: Stack;
procedure InitS(var S: Stack);
//инициализация стека
begin
  S := nil;
end;
function EmptyS: boolean;
//проверка стека на пустоту
begin
  EmptyS := S = nil;
end;
procedure Push(x, y: integer);
//поместить пиксел в стек
var
  q: Stack;
begin
  New(q);
  q^.x := x;
  q^.y := y;
  q^.pred := S;
  S := q;
end;
Procedure Pop(var x, y: integer);
//извлечь пиксел из стека
var
  q: Stack;
begin
  x := S^.x;
  y := S^.y;
  q := S;
  S:= S^.pred;
  Dispose(q);
end;
procedure Pouralg(xx, yy: integer; CGr, CZ: TColor);
//простой алгоритм
var
  x, y: integer;
begin
  InitS(S);
  Push(xx, yy); //инициализируем стек
  while (not EmptyS) do
    begin
      Pop(x, y); //извлекаем пиксел из стека
      if Image1.Canvas.Pixels[x, y] <> CZ then
        begin
          Application.ProcessMessages;
          Image1.Canvas.Pixels[x, y] := CZ;
          Sleep(1);
        end;
      //проверим, надо ли помещать соседние пикселы в стек
      if (Image1.Canvas.Pixels[x + 1, y] <> CZ) and
         (Image1.Canvas.Pixels[x + 1, y] <> CGr) then
           Push(x + 1, y);
      if (Image1.Canvas.Pixels[x, y + 1] <> CZ) and
         (Image1.Canvas.Pixels[x, y + 1] <> CGr) then
           Push(x, y + 1);
      if (Image1.Canvas.Pixels[x - 1, y] <> CZ) and
         (Image1.Canvas.Pixels[x - 1, y] <> CGr) then
           Push(x - 1, y);
      if (Image1.Canvas.Pixels[x, y - 1] <> CZ) and
         (Image1.Canvas.Pixels[x, y - 1] <> CGr) then
           Push(x, y - 1);
    end;
end;
begin
  btn1Click(nil);
  Pouralg(80, 75, clBlack, clRed);
end;

procedure TForm1.btn5Click(Sender: TObject);
//Построчный алгоритм заполнения с затравкой.
var
  beg, _end: integer;//границы стека
  sx, sy: array [0..100000] of integer; //стек с массивами
procedure Push(x, y: integer);
//поместить пиксел в стек
begin
  sx[_end] := x;
  sy[_end] := y;
  _end := _end + 1;
end;
procedure Pop(var x, y: integer);
//извлечь пиксел из стека
begin
  x := sx[beg];
  y := sy[beg];
  beg := beg + 1;
end;
procedure PourLine(xx, yy: integer; CGr, CZ: TColor);
//построчный алноритм
var
  x, y, F, xv, xr, xleft, t_x: integer;
  CF: TColor;
begin
  Push(xx, yy);
  CF := Image1.Canvas.Pixels[xx, yy];
  while (beg <> _end) do
    begin
      Pop(x, y);
      Image1.Canvas.Pixels[x, y] := CZ;
      Sleep(1);
      Application.ProcessMessages;
      t_x := x;
      x := x + 1;
      while (Image1.Canvas.Pixels[x, y] = CF) do
        begin
          Image1.Canvas.Pixels[x, y] := CZ;
          Sleep(1);
          Application.ProcessMessages;
          x := x + 1;
        end;
      xr := x - 1;
      x := t_x;
      x := x - 1;
      while (Image1.Canvas.Pixels[x, y] = CF) do
        begin
          Image1.Canvas.Pixels[x, y] := CZ;
          Sleep(1);
          Application.ProcessMessages;
          x := x - 1;
        end;
      xleft := x + 1;
      //ищем затравку на строке выше
      x := xleft;
      y := y + 1;
     while (x <= xr) do
       begin
         F := 0;
         while (Image1.Canvas.Pixels[x, y] <> CGr) and
         (Image1.Canvas.Pixels[x, y] <> CZ) and (x < xr) do
           begin
             if (F = 0) then F := 1;
             x := x + 1;
           end;
         if (F = 1) then
           if (x = xr) and (Image1.Canvas.Pixels[x, y] <> CGr) and
           (Image1.Canvas.Pixels[x, y] <> CZ) then
             Push(x, y)
           else
             Push(x - 1, y);
         xv := x;
         while (Image1.Canvas.Pixels[x, y] = CGr) or
         (Image1.Canvas.Pixels[x, y] = CZ) and (x < xr) do
           x := x + 1;
         if (x = xv) then
           x := x + 1;
       end;
    end;
  push(xx, yy - 1);
  while (beg <> _end) do
    begin
      Pop(x, y);
      Image1.Canvas.Pixels[x, y] := CZ;
      Application.ProcessMessages;
      Sleep(1);
      t_x := x;
      x := x + 1;
      while (Image1.Canvas.Pixels[x, y] = CF) do
        begin
          Image1.Canvas.Pixels[x, y] := CZ;
          Sleep(1);
          Application.ProcessMessages;
          x := x + 1;
        end;
      xr := x - 1;
      x := t_x;
      x := x - 1;
      while (Image1.Canvas.Pixels[x, y] = CF) do
        begin
          Image1.Canvas.Pixels[x, y] := CZ;
          Sleep(1);
          Application.ProcessMessages;
          x := x - 1;
        end;
      xleft := x + 1;
      //ищем затравку на строке ниже
      x := xleft;
      y := y - 1;
      while (x <= xr) do
        begin
          F := 0;
          while (Image1.Canvas.Pixels[x, y] <> CGr) and
          (Image1.Canvas.Pixels[x, y] <> CZ) and (x < xr) do
            begin
              if (F = 0) then F := 1;
              x := x + 1;
            end;
          if (F = 1) then
            if (x = xr) and (Image1.Canvas.Pixels[x, y] <> CGr) and
            (Image1.Canvas.Pixels[x, y] <> CZ) then
              Push(x, y)
            else
              Push(x - 1, y);
          xv := x;
          while (Image1.Canvas.Pixels[x, y] = CGr) or
          (Image1.Canvas.Pixels[x, y] = CZ) and (x < xr) do
             x := x + 1;
           if (x = xv) then
             x := x + 1;
        end;
      end;
end;
begin
  beg := 0;
  _end := 0;
  btn1Click(nil);
  PourLine(80, 75, clBlack, clRed);
end;

end.
