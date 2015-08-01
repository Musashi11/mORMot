program mORMotBatchInsert;

// see http://stackoverflow.com/a/31523392/458259

{$APPTYPE CONSOLE}

uses
  {$I SynDprUses.inc} // includes FastMM4
  SysUtils,
  SynCommons,
  mORMot,
  mORMotSQLite3,
  SynSQLite3,
  SynSQLite3Static;

type
  TSQLIndy = class(TSQLRecord)
  private
    fdied: boolean;
    fhasdata: boolean;
    feventlinesneedprocessing: boolean;
    ftodo: integer;
    ffams: integer;
    flinkinfo: integer;
    ffirstancestralloop: integer;
    ffamc: integer;
    fnextreportindi: integer;
    fdeathdate: string;
    fchanged: string;
    fbirthdate: string;
    feventlines: string;
    fgedcomnames: string;
    fsex: string;
    findikey: string;
  published
    property indikey: string read findikey write findikey;
    property hasdata: boolean read fhasdata write fhasdata;
    property gedcomnames: string read fgedcomnames write fgedcomnames;
    property sex: string read fsex write fsex;
    property birthdate: string read fbirthdate write fbirthdate;
    property died: boolean read fdied write fdied;
    property deathdate: string read fdeathdate write fdeathdate;
    property changed: string read fchanged write fchanged;
    property eventlinesneedprocessing: boolean read feventlinesneedprocessing write feventlinesneedprocessing;
    property eventlines: string read feventlines write feventlines;
    property famc: integer read ffamc write ffamc;
    property fams: integer read ffams write ffams;
    property linkinfo: integer read flinkinfo write flinkinfo;
    property todo: integer read ftodo write ftodo;
    property nextreportindi: integer read fnextreportindi write fnextreportindi;
    property firstancestralloop: integer read ffirstancestralloop write ffirstancestralloop;
  end;

const COUNT = 1000000;

{
    Prepared 1000000 rows in 874.54ms
    Inserted 1000000 rows in 5.79s
}

procedure Test;
var db: TSQLRestServerDB;
    batch: TSQLRestBatch;
    i: Integer;
    indy: TSQLIndy;
    timer: TPrecisionTimer;
begin
  DeleteFile('test.db3');
  db := TSQLRestServerDB.CreateWithOwnModel([TSQLIndy],'test.db3');
  try
    db.DB.LockingMode := lmExclusive;
    db.DB.Synchronous := smOff;
    db.CreateMissingTables;
    timer.Start;
    batch := TSQLRestBatch.Create(db,TSQLIndy,10000);
    try
      indy := TSQLIndy.Create;
      try
        for i := 1 to COUNT do begin
          indy.indikey := IntToString(i);
          indy.hasdata := i and 1=0;
          indy.sex := 'Male';
          indy.famc := i;
          indy.fams := i*10;
          indy.todo := i+100;
          batch.Add(indy,true);
        end;
      finally
        indy.Free;
      end;
      writeln('Prepared ',COUNT,' rows in ',timer.Stop);
      timer.Start;
      db.BatchSend(batch);
      write('Inserted ',COUNT,' rows in ',timer.Stop);
      writeln(' i.e. ',timer.PerSec(COUNT),' per second');
    finally
      batch.Free;
    end;
  finally
    db.Free;
  end;
end;

begin
  try
    Test;
    readln;
  except
    on E: Exception do
      ConsoleShowFatalException(E);
  end;
end.
 
