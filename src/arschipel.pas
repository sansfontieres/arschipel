program Arschipel;

uses SysUtils;

const 
  STRMEM = 4096 * 96;
  GLOMEM = 100;
  LEXMEM = 500;
  HORMEM = 3500;
  ITEMS = 64;
  EPOCH = 2019;

type 
  TBlock = record
    len : integer;
    data : array[0..(STRMEM)-1] of char;
  end;

  TList = record
    len : integer;
    routes : integer;
    name : string;
    keys : string;
    vals : string;
    bkey : string;
    bval : string;
  end;

  TTerm = record
    body_len : integer;
    gmni_len : integer;
    children_len : integer;
    incoming_len : integer;
    outgoing_len : integer;
    logs_len : integer;
    events_len : integer;
    ch : integer;
    fh : integer;
    name : ^char;
    host : ^char;
    bref : ^char;
    titl : ^char;
    _type : ^char;
    relm : ^char;
    date : ^char;
    updt : ^char;
    time : ^char;
    utim : ^char;
    filename : ^char;
    date_from : ^char;
    date_last : ^char;
    body : array[0..(ITEMS)-1] of ^char;
    gmni : array[0..(ITEMS)-1] of ^char;
    link : TList;
    bibl : TList;
    parent : ^TTerm;
    children : array[0..(ITEMS)-1] of ^TTerm;
    incoming : array[0..(ITEMS)-1] of ^TTerm;
  end;

  TLog = record
    code : integer;
    pict : integer;
    rune : char;
    date : ^char;
    ext : ^char;
    name : ^char;
    term : ^TTerm;
  end;

  TGlossary = record
    len : integer;
    lists : array[0..(GLOMEM)-1] of TList;
  end;

  TLexicon = record
    len : integer;
    terms : array[0..(LEXMEM)-1] of TTerm;
  end;

  TJournal = record
    len : integer;
    logs : array[0..(HORMEM)-1] of TLog;
  end;

var 
  Glossary, Lexicon, Journal: textfile;
  Block : TBlock;
  AllLists : TGlossary;
  AllTerms : TLexicon;
  AllLogs : TJournal;


(* Error Procedures *)
procedure Error(Message, Culprit: string);
begin
  WriteLn(stderr, '[ERROR] ', Message, ': ', Culprit);
  Halt(-1);
end;

procedure ErrorId(Message, Id: string; Value: integer);
begin
  WriteLn(stderr, '[ERROR] ', Message, ': ', Id, ' (', Value, ')');
  Halt(-1);
end;

procedure Warning(Message, Culprit: string);
begin
  WriteLn(stderr, '[Warning] ', Message, ': ', Culprit);
  Halt(-1);
end;

procedure IsWikiDir;
begin
  if DirectoryExists('database') <> True then
    Error('You are not in a wiki directory', 'arschipel');
  if FileExists('database/glossary.ndtl') <> True then
    Error('The Glossary file couldn’t be read', 'arschipel');
  if FileExists('database/lexicon.ndtl') <> True then
    Error('The Lexicon file couldn’t be read', 'arschipel');
  if FileExists('database/journal.tbtl') <> True then
    Error('The Journal file couldn’t be read', 'arschipel');
end;

procedure MakeList(var List: TList; ListName: string);
begin
  List.len := 0;
  List.routes := 0;
  List.name := LowerCase(ListName);
end;

(* String functions *)
function IndentCount(Line: string; CharIndex: integer): integer;
begin
  if Line[CharIndex + 1] = #9 then
    IndentCount := IndentCount(Line, CharIndex + 1)
  else
    IndentCount := CharIndex
end;

function SplitIndex(Line: string; Key: string; CharIndex: integer): integer;
begin
  if Line[CharIndex +1] <> Key then
    SplitIndex := SplitIndex(Line, Key, CharIndex + 1)
  else
    SplitIndex := CharIndex
end;

(* Wiki Parsing *)
procedure ParseGlossary(var GlossaryFile: TextFile; var block: TBlock; var glo: TGlossary);
var 
  Line: string;
  Depth, LineLength, LineCount, Split: integer;
  List: TList;
begin
  LineCount := 0;
  List := glo.lists[glo.len];
  Reset(GlossaryFile);
  while not Eof(GlossaryFile) do
    begin
      Inc(LineCount);
      ReadLn(GlossaryFile, Line);
      Depth := IndentCount(Line, 0);
      LineLength := Length(Line);
      if (LineLength < 4) or (Line[1] = ';') then
        continue;
      if LineLength > 400 then
        ErrorId('Line is too long', Line, LineLength);
      if Depth = 0 then
        begin
          MakeList(List, Line);
          WriteLn();
        end
      else if Depth = 1 then
             begin
               if List.len >= 5 then
                 ErrorId('Reached list item limit', List.name, List.len);
               Split := SplitIndex(Line, ':', 0);
               WriteLn(Split);
               Inc(List.len);
             end;
    end;
  Write( '(', LineCount, ') · ');
end;

procedure Parse(var Block: TBlock; var AllLists: TGlossary; var AllTerms: TLexicon; var AllLogs:
                TJournal);
var GlossaryFile, LexiconFile, JournalFile: TextFile;
begin
  Write('Parse'#9'|'#9'glossary');
  Assign(GlossaryFile, 'glossary.ndtl');
  ParseGlossary(GlossaryFile, Block, AllLists);
  Close(GlossaryFile);

  //Assign(Lexicon, 'database/lexicon.ndtl');
  //Reset(Lexicon);
  //Close(Lexicon);
  //Assign(Journal, 'database/journal.tbtl');
  //Reset(Journal);
  //Close(Journal);
end;

begin
  IsWikiDir;
  Parse(Block, AllLists, AllTerms, AllLogs);
end.
