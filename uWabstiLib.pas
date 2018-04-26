unit uWabstiLib;

interface

type
  TEinheit = class
  private
    fCode, fBez: string;
    fBFS: integer;
    fCode_zzkantone: string;
  published
    property Code: string read fCode write fCode;
    property Bez: string read fBez write fBez;
    property Code_zzkantone: string read fCode_zzkantone write fCode_zzkantone;
    property BFS: integer read fBFS write fBFS;
  end;

  TGeschaeft = class
  private
    fLfnr: integer;
    fBezHGOffiziell: string;
    fCodeGeschaefttyp: integer;
  published
    property Lfnr: integer read fLfnr write fLfnr;
    property BezHGOffiziell: string read fBezHGOffiziell write fBezHGOffiziell;
    property CodeGeschaefttyp: integer read fCodeGeschaefttyp write fCodeGeschaefttyp;
  end;

  THttpResponse = class
  private
    fText: string;
  published
    property Text: string read fText write fText;
  end;

const HK = '''';

implementation

end.
