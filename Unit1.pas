unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,ActiveX, StdVCL,  MMSystem, StdCtrls, Vcl.ImgList, System.UITypes,
  Vcl.Menus, {IniFiles,} Registry, ShellApi,
  Vcl.Styles, Themes, Vcl.ExtCtrls;

const
  CLSID_MMDeviceEnumerator : TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';
  Class_PolicyConfigClient:TGUID ='{870af99c-171d-4f9e-af0d-e63df40c2bc9}';
  IID_IMMDeviceEnumerator : TGUID = '{A95664D2-9614-4F35-A746-DE8DB63617E6}';
  IID_IMMDevice : TGUID = '{D666063F-1587-4E43-81F1-B948E807363F}';
  IID_IMMDeviceCollection : TGUID = '{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}';
  IID_IAudioEndpointVolume : TGUID = '{5CDF2C82-841E-4546-9722-0CF74078229A}';
  IID_IAudioMeterInformation : TGUID = '{C02216F6-8C67-4B5B-9D00-D008E73E0064}';
  IID_IAudioEndpointVolumeCallback : TGUID = '{657804FA-D6AD-4496-8A60-352752AF4F89}';
  IID_IMMNotificationClient : TGUID = '{7991EEC9-7E89-4D85-8390-6C703CEC60C0}';
  IID_IPropertyStore: TGUID = '{886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}';

  DEVICE_STATE_ACTIVE = $00000001;
  DEVICE_STATE_UNPLUGGED = $00000002;
  DEVICE_STATE_NOTPRESENT = $00000004;
  DEVICE_STATEMASK_ALL = $00000007;

type
  EDataFlow = TOleEnum;
const
  eRender = $00000000;
  eCapture = $00000001;
  eAll = $00000002;
  EDataFlow_enum_count = $00000003;

type
  ERole = TOleEnum;
const
  eConsole = $00000000;
  eMultimedia = $00000001;
  eCommunications = $00000002;
  ERole_enum_count = $00000003;

  PKEY_Device_FriendlyName:TPropertyKey=(fmtid:(D1:$a45c254e;D2:$df1c;D3:$4efd;D4:($80,$20,$67,$d1,$46,$a8,$50,$e0));pid:14);

type
  IAudioEndpointVolumeCallback = interface(IUnknown)
  ['{657804FA-D6AD-4496-8A60-352752AF4F89}']
  end;

  IAudioEndpointVolume = interface(IUnknown)
  ['{5CDF2C82-841E-4546-9722-0CF74078229A}']
  function RegisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): Integer; stdcall;
  function UnregisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): Integer; stdcall;
  function GetChannelCount(out PInteger): Integer; stdcall;
  function SetMasterVolumeLevel(fLevelDB: single; pguidEventContext: PGUID): Integer; stdcall;
  function SetMasterVolumeLevelScalar(fLevelDB: single; pguidEventContext: PGUID): Integer; stdcall;
  function GetMasterVolumeLevel(out fLevelDB: single): Integer; stdcall;
  function GetMasterVolumeLevelScaler(out fLevelDB: single): Integer; stdcall;
  function SetChannelVolumeLevel(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): Integer; stdcall;
  function SetChannelVolumeLevelScalar(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): Integer; stdcall;
  function GetChannelVolumeLevel(nChannel: Integer; out fLevelDB: double): Integer; stdcall;
  function GetChannelVolumeLevelScalar(nChannel: Integer; out fLevel: double): Integer; stdcall;
  function SetMute(bMute: Boolean; pguidEventContext: PGUID): Integer; stdcall;
  function GetMute(out bMute: Boolean): Integer; stdcall;
  function GetVolumeStepInfo(pnStep: Integer; out pnStepCount: Integer): Integer; stdcall;
  function VolumeStepUp(pguidEventContext: PGUID): Integer; stdcall;
  function VolumeStepDown(pguidEventContext: PGUID): Integer; stdcall;
  function QueryHardwareSupport(out pdwHardwareSupportMask): Integer; stdcall;
  function GetVolumeRange(out pflVolumeMindB: double; out pflVolumeMaxdB: double; out pflVolumeIncrementdB: double): Integer; stdcall;
  end;

  IAudioMeterInformation = interface(IUnknown)
  ['{C02216F6-8C67-4B5B-9D00-D008E73E0064}']
  end;

  IPropertyStore = interface(IUnknown)
  ['{886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}']
  function GetCount(out cProps: LongWord): HResult; stdcall;
  function GetAt(iProp: LongWord; out pkey: _tagpropertykey): HResult; stdcall;
  function GetValue(const key: TPropertyKey; out pv: TPROPVARIANT): HResult; stdcall;
  function SetValue(const key: TPropertyKey; out propvar: TPROPVARIANT): HResult; stdcall;
  function Commit: HResult; stdcall;
  end;

  IMMDevice = interface(IUnknown)
  //[IID_IMMDevice]
  function Activate(const refId: TGUID; dwClsCtx: DWORD; pActivationParams: PInteger; out pEndpointVolume: IAudioEndpointVolume): HRESULT; stdCall;
  function OpenPropertyStore(stgmAccess: DWORD; out ppProperties: IPropertyStore): HRESULT; stdcall;
  function GetId(out ppstrId: PWideChar): HRESULT; stdcall;
  end;

  IMMDeviceCollection = interface(IUnknown)
  //[IID_IMMDeviceCollection]
  function GetCount(out pcDevices: UINT): HRESULT; stdcall;
  function Item(nDevice: UINT; out ppDevice: IMMDevice): HRESULT; stdcall;
  end;

  IMMNotificationClient = interface(IUnknown)
  //[IID_IMMNotificationClient]
  end;

  IMMDeviceEnumerator = interface(IUnknown)
  //[IID_IMMDeviceEnumerator]
  function EnumAudioEndpoints(dataFlow: EDataFlow; deviceState: SYSUINT; out DevCollection: IMMDeviceCollection): HRESULT; stdcall;
  end;


  IPolicyConfig = interface(IUnknown)
    ['{f8679f50-850a-41cf-9c72-430f290290c8}']
    // �� ������ � ������������ ����������, �� ��� �������� ��������
  function GetMixFormat(a: PWideChar; var b: TWAVEFORMATEX): HRESULT; // stdcall?
  function GetDeviceFormat(a: PWideChar; b: integer; var c: TWAVEFORMATEX): HRESULT; stdcall;
  function ResetDeviceFormat(a: PWideChar): HRESULT; stdcall;
  function SetDeviceFormat(a: PWideChar; var b: TWAVEFORMATEX; var c: TWAVEFORMATEX): HRESULT; stdcall;
  function GetProcessingPeriod(a: PWideChar; b: integer; c: PINT64; d: PINT64): HRESULT; stdcall;
  function SetProcessingPeriod(a: PWideChar; b: PINT64): HRESULT; stdcall;
  function GetShareMode(a: PWideChar; b: pointer{struct DeviceShareMode *}): HRESULT; stdcall;
  function SetShareMode(a: PWideChar; b: pointer{struct DeviceShareMode *}): HRESULT; stdcall;
  function GetPropertyValue(devID: PWideChar; const Key: _tagpropertykey; V: TPROPVARIANT): HRESULT; stdcall;
  function SetPropertyValue(devID: PWideChar; const Key: _tagpropertykey; V: TPROPVARIANT): HRESULT; stdcall;
// � ��� � ������ �����
  function SetDefaultEndpoint(wszDeviceID: PWideChar; ARole: ERole):Hresult; stdcall;
  end;

type
  TfrmMain = class(TForm)
    btnOK: TButton;
    Combo_Source1: TComboBox;
    Combo_Source2: TComboBox;
    ImageList1: TImageList;
    TrayI: TTrayIcon;
    radHeadphones: TRadioButton;
    radSpeakers: TRadioButton;
    mnuPopup: TPopupMenu;
    mnuSettings: TMenuItem;
    mnuQuit: TMenuItem;
    mnuSwitch: TMenuItem;
    N1: TMenuItem;
    chkAutorun: TCheckBox;
    cmbLocale: TComboBox;
    mnuAbout: TMenuItem;
    cmbStyles: TComboBox;
    btnRefresh: TButton;
    chkVerbose: TCheckBox;
    mnuDevices: TMenuItem;
    procedure Button_Find_SoundClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuQuitClick(Sender: TObject);
    procedure mnuSettingsClick(Sender: TObject);
    procedure TrayIDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TrayIBalloonClick(Sender: TObject);
    procedure radHeadphonesClick(Sender: TObject);
    procedure radSpeakersClick(Sender: TObject);
    procedure mnuSwitchClick(Sender: TObject);
    procedure cmbLocaleChange(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure cmbStylesChange(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure Combo_Source2Change(Sender: TObject);
    procedure Combo_Source1Change(Sender: TObject);
    procedure mnuDevicesClick(Sender: TObject);
    procedure WMQUERYENDSESSION(var Msg: TMessage); message WM_QUERYENDSESSION;
  private
    function LoadSettings(): Boolean;
    function SaveSettings(): Boolean;
    procedure ShowBalloon(Text: String; Icon: TBalloonFlags );
    procedure ApplySound;
    procedure SetLocalisation;
    function GetMyVersion: string;
  public
    { Public declarations }
  end;

var
  intLocale: Integer = 0;
  frmMain: TfrmMain;
  const APPNAME: PWideChar = 'SoundSwitcher';
  const cURL ='https://github.com/Mrgnstrn/SoundSwitcher/releases';
  const cFrmClientHeight: Integer = 118;

  mnuQuit_loc: array [0..1] of String = ('Quit', '�����');
  mnuDevices_loc: array [0..1] of String =('Playback devices', '���������� ���������������');
  mnuSettings_loc: array [0..1] of String = ('Settings...', '���������...');
  mnuSwitch_loc: array [0..1] of String = ('Switch!', '�����������!');
  mnuAbout_loc: array [0..1] of String = ('About', '� ���������');
  radSpeakers_loc: array [0..1] of String = ('Speakers', '��������');
  radHeadphones_loc: array [0..1] of String = ('Headphones', '��������');
  btnRefresh_loc: array [0..1] of String = ('Refresh', '��������');
  btnApply_loc: array [0..1] of String = ('Apply', '���������');
  chkVerbose_loc: array [0..1] of String = ('No messages', '��� ���������');
  chkAuto_loc: array [0..1] of String = ('Autorun','������������');
  msgErr1_loc: array [0..1] of String = ('Program isn''t configured yet', '��������� ��� �� ���������');
  trayHint_loc: array [0..1] of String = ('SoundSwitcher'+#13#10+'Double click for switching', 'SoundSwitcher'+#13#10+'������� ������ ��� ������������');
  msgErr2_loc: array [0..1] of String = ('Wrong configuration', '������������ ������������');
  msgInfo1_loc: array [0..1] of String = ('Settings are saved', '��������� ���������');
  msgInfo2_loc: array [0..1] of String = ('Switched to ', '����������� �� ');
  msgAbout_loc: array [0..1] of String = ('SoundSwitcher v %s'+ chr(13) +
                                          'Author: Nazarov Timur (www.vk.com/id1669165)' + chr(13) +
                                          'Last updates on:'+chr(13) +
                                          cURL + chr(13) +
                                          'OK - open link'
                                          ,
                                          'SoundSwitcher v %s' + chr(13) +
                                          '�����: ������� ����� (www.vk.com/id1669165)' + chr(13) +
                                          '��������� ���������� ����� �� ������:' + chr(13) +
                                          cURL + chr(13) +
                                          'OK - ������� ������' );

implementation

{$R *.dfm}

procedure TfrmMain.btnApplyClick(Sender: TObject);
begin
ApplySound;
end;

procedure TfrmMain.btnRefreshClick(Sender: TObject);
begin
Button_Find_SoundClick(nil);
end;

procedure TfrmMain.Button_Find_SoundClick(Sender: TObject);
var
  AudioEndpoints:IMMDeviceEnumerator;
  Collection:IMMDeviceCollection;
  Device:IMMDevice;
  Id_Dev:PWideChar;
  I:Integer;
  Count_Dev:UINT;
  DId:WideString;
  Prop:IPropertyStore;
  DeviceName:PROPVARIANT;

begin
Combo_Source1.Items.Clear;
Combo_Source2.Items.Clear;
CoCreateInstance (CLSID_MMDeviceEnumerator,nil,CLSCTX_INPROC_SERVER,IID_IMMDeviceEnumerator,AudioEndpoints);
AudioEndpoints.EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE, &Collection);
Collection.GetCount(Count_Dev);

for I := 0 to Count_Dev-1 do begin
  Collection.Item(i,Device);
  If Succeeded(Device.GetId(Id_Dev)) and (Id_Dev<>nil) then begin
    DId:=Widestring(Id_Dev);

    Device.OpenPropertyStore(STGM_READ,Prop);
    Prop.GetValue(PKEY_Device_FriendlyName,DeviceName);
    CoTaskMemFree(Id_Dev);
    Combo_Source1.Items.Append({DId+' '+}PROPVARIANT(DeviceName).pwszVal);
    Combo_Source2.Items.Append({DId+' '+}PROPVARIANT(DeviceName).pwszVal);
    end;
  end;
end;

procedure TfrmMain.cmbLocaleChange(Sender: TObject);
begin
intLocale:=cmbLocale.ItemIndex;
SetLocalisation;
end;

procedure TfrmMain.cmbStylesChange(Sender: TObject);
begin
TStyleManager.TrySetStyle(cmbStyles.Text, true);
end;

procedure TfrmMain.Combo_Source1Change(Sender: TObject);
begin
ApplySound;
end;

procedure TfrmMain.Combo_Source2Change(Sender: TObject);
begin
ApplySound;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
CanClose:=false;
frmMain.Hide;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var i: Integer;
begin
try
	With TStyleManager.Create do begin
		for i := 0 to Length(StyleNames)-1 do
    		cmbStyles.Items.Add(StyleNames[i]);
end;
	cmbStyles.ItemIndex:=0;
finally end;

Button_Find_SoundClick(nil);
if not LoadSettings then
  ShowBalloon(msgErr1_loc[intLocale], TBalloonFlags.bfError)
else
  ApplySound;
end;

procedure TfrmMain.mnuSwitchClick(Sender: TObject);
begin
 TrayIDblClick(nil);
end;

procedure TfrmMain.mnuDevicesClick(Sender: TObject);
begin
//ShellExecute(Handle, nil, 'control', 'mmsys.cpl,,1', nil, SW_SHOW)
ShellExecute(Handle, nil, 'rundll32.exe', 'shell32.dll,Control_RunDLL mmsys.cpl,,0', nil, SW_SHOW)
end;

procedure TfrmMain.mnuAboutClick(Sender: TObject);
begin
//if MessageBox(Application.Handle, PwideChar(Format(msgAbout_loc[intLocale],[GetMyVersion])), APPNAME,
//MB_OKCANCEL + MB_ICONINFORMATION + MB_DEFBUTTON2)= IDOK then
//ShellExecute(Handle, 'open', PChar(cURL), nil, nil, SW_SHOW);
if MessageDLG(PwideChar(Format(msgAbout_loc[intLocale],[GetMyVersion])), mtInformation, [mbOK, mbCancel], 0 ) = mrOK then
ShellExecute(Handle, 'open', PChar(cURL), nil, nil, SW_SHOW);
end;

procedure TfrmMain.mnuQuitClick(Sender: TObject);
begin
SaveSettings;
Application.Terminate;
end;

procedure TfrmMain.mnuSettingsClick(Sender: TObject);
begin
frmMain.Show;
end;

procedure TfrmMain.radHeadphonesClick(Sender: TObject);
begin
TrayI.IconIndex:= Integer(not radSpeakers.Checked);
ApplySound;
end;

procedure TfrmMain.radSpeakersClick(Sender: TObject);
begin
TrayI.IconIndex:= Integer(not radSpeakers.Checked);
ApplySound;
end;

procedure TfrmMain.TrayIBalloonClick(Sender: TObject);
begin
if (TrayI.BalloonFlags = bfError) then frmMain.Show;
end;

procedure TfrmMain.TrayIDblClick(Sender: TObject);
begin
if radSpeakers.Checked then radHeadphones.Checked:= true
else if radHeadphones.Checked then radSpeakers.Checked:= true;
end;

Procedure TfrmMain.ShowBalloon(Text: String; Icon: TBalloonFlags);
begin
  if chkVerbose.Checked and (Icon<> bfError) then Exit; //�����
  TrayI.BalloonFlags:= Icon;
  TrayI.BalloonTitle:=APPNAME;
  TrayI.BalloonHint:=Text;
  TrayI.ShowBalloonHint;
end;

procedure TfrmMain.btnOKClick(Sender: TObject);
begin
frmMain.Hide;
if SaveSettings then ShowBalloon(msgInfo1_loc[intLocale], bfInfo)
else ShowBalloon(msgErr2_loc[intLocale], TBalloonFlags.bfError);
end;

/////////////////////////////////////////////////////////////////Settings///////
function TfrmMain.LoadSettings(): Boolean;
var Reg:TRegistry;
begin
Result:= False;
Reg := TRegistry.Create;
Reg.RootKey := HKEY_CURRENT_USER;
Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
chkAutorun.Checked:= Reg.ValueExists(APPNAME);
Reg.CloseKey;
if not Reg.KeyExists('\SOFTWARE\SoundSwitcher\') then Exit;
Reg.OpenKeyReadOnly('\SOFTWARE\SoundSwitcher\');
intLocale:= Reg.ReadInteger('Locale');
cmbLocale.ItemIndex:=intLocale;
SetLocalisation;
chkVerbose.Checked:= Reg.ReadBool('NoMsg');
Combo_Source1.ItemIndex:= Reg.ReadInteger('ChSp');
Combo_Source2.ItemIndex:= Reg.ReadInteger('ChHp');
if Reg.ReadInteger('DefCh') = 0 then
    radSpeakers.Checked:=True
  else radHeadphones.Checked:=True;
cmbStyles.ItemIndex:= Reg.ReadInteger('Style');
cmbStylesChange(nil);
Reg.CloseKey;
Reg.Free;
if (Combo_Source1.ItemIndex <0) or
   (Combo_Source2.ItemIndex <0) then
     result:= false
     else result:= true
end;

function TfrmMain.SaveSettings(): Boolean;
var Reg:TRegistry;
begin
if (Combo_Source1.ItemIndex <0) or
   (Combo_Source2.ItemIndex <0) then begin
      result:=false;
      Exit;
end;
Reg := TRegistry.Create;
Reg.RootKey := HKEY_CURRENT_USER;
Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
if chkAutorun.Checked then begin
     Reg.WriteString(APPNAME, Application.ExeName);
end else begin
     Reg.DeleteValue(APPNAME);
end;
  Reg.CloseKey;
  Reg.OpenKey('\SOFTWARE\SoundSwitcher', True);
  Reg.WriteInteger('ChSp', Combo_Source1.ItemIndex);
  Reg.WriteInteger('ChHp', Combo_Source2.ItemIndex);
  if radSpeakers.Checked then Reg.WriteInteger('DefCh', 0)
  else Reg.WriteInteger('DefCh', 1);
  Reg.WriteInteger('Locale', intLocale);
  Reg.WriteBool('NoMsg', chkVerbose.Checked);
  Reg.WriteInteger('Style', cmbStyles.ItemIndex);
  Reg.CloseKey;
  Reg.Free;
result:= true;
end;

{$REGION 'OldCode'}
    {function TfrmMain.LoadSettings(): Boolean;
    var Reg:TRegistry;
    begin
    Reg := TRegistry.Create;
         Reg.RootKey := HKEY_CURRENT_USER;
         Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
         chkAutorun.Checked:= Reg.ValueExists(APPNAME);
         Reg.Free;

    if not FileExists(ExtractFilePath(ParamStr(0)) + 'Config.ini') then begin
      Result:= False;
      Exit;
    end;
    With TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
      begin
      intLocale:= ReadInteger('Main', 'Locale', 0);
      cmbLocale.ItemIndex:=intLocale;
      SetLocalisation;
      chkVerbose.Checked:= ReadBool('Main', 'NoMsg', false);
      cmbStyles.ItemIndex:= ReadInteger('Main', 'Style', 0);
      cmbStylesChange(nil);
      Combo_Source1.ItemIndex:= ReadInteger('Main', 'ChSp', 0);
      Combo_Source2.ItemIndex:= ReadInteger('Main', 'ChHp', 1);
      if ReadInteger('Main', 'DefCh', 0) = 0 then
           radSpeakers.Checked:=True
      else radHeadphones.Checked:=True;

      Free;
      end;
      if (Combo_Source1.ItemIndex <0) or
         (Combo_Source2.ItemIndex <0) then
           result:= false
      else result:= true
    end; }

    {function TfrmMain.SaveSettings(): Boolean;
    var Reg:TRegistry;
    begin
    if (Combo_Source1.ItemIndex <0) or
       (Combo_Source2.ItemIndex <0) then begin
          result:=false;
          Exit;
    end;
    if chkAutorun.Checked then begin
         Reg := TRegistry.Create;
         Reg.RootKey := HKEY_CURRENT_USER;
         Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
         Reg.WriteString(APPNAME, Application.ExeName);
         Reg.Free;
         //ShowBalloon('������������ ��������', bfInfo);
    end else begin
         Reg := TRegistry.Create;
         Reg.RootKey := HKEY_CURRENT_USER;
         Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
         Reg.DeleteValue(APPNAME);
         Reg.Free;
         //ShowBalloon('������������ ���������', bfInfo);
    end;
    with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do begin
      WriteInteger('Main', 'ChSp', Combo_Source1.ItemIndex);
      WriteInteger('Main', 'ChHp', Combo_Source2.ItemIndex);
      if radSpeakers.Checked then WriteInteger('Main', 'DefCh', 0)
      else WriteInteger('Main', 'DefCh', 1);
      WriteInteger('Main', 'Locale', intLocale);
      WriteBool('Main', 'NoMsg', chkVerbose.Checked);
      WriteInteger('Main', 'Style', cmbStyles.ItemIndex);
      Free;
    end;
    result:= true;
    end;}
{$ENDREGION}
/////////////////////////////////////////////////////////////////Settings_End///

procedure TfrmMain.SetLocalisation();
begin
  mnuQuit.Caption:=       mnuQuit_loc[intLocale];
  mnuSettings.Caption:=   mnuSettings_loc[intLocale];
  mnuDevices.Caption:=    mnuDevices_loc[intLocale];
  mnuSwitch.Caption:=     mnuSwitch_loc[intLocale];
  mnuAbout.Caption:=      mnuAbout_loc[intLocale];
  radSpeakers.Caption:=   radSpeakers_loc[intLocale];
  radHeadphones.Caption:= radHeadphones_loc[intLocale];
  chkAutorun.Caption:=    chkAuto_loc[intLocale];
  chkVerbose.Caption:=    chkVerbose_loc[intLocale];
  //btnApply.Caption:=      btnApply_loc[intLocale];
  TrayI.Hint:=            trayHint_loc[intLocale];
  btnRefresh.Caption:=    btnRefresh_loc[intLocale];
end;

procedure TfrmMain.ApplySound;

var
  SelDevice: Integer;
  AudioEndpoints:IMMDeviceEnumerator;
  Collection:IMMDeviceCollection;
  Device:IMMDevice;
  Def_Dev_Ch:IPolicyConfig;
  Id_Dev:PWideChar;
  DevUName: String;
begin

if (Combo_Source1.ItemIndex <0) or
   (Combo_Source2.ItemIndex <0) then begin
      ShowBalloon(msgErr2_loc[intLocale], TBalloonFlags.bfError);
      Exit;
end;

CoCreateInstance (CLSID_MMDeviceEnumerator,nil,CLSCTX_INPROC_SERVER,IID_IMMDeviceEnumerator,AudioEndpoints);
AudioEndpoints.EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE, Collection);

if radSpeakers.Checked then SelDevice:= Combo_Source1.ItemIndex
else SelDevice:= Combo_Source2.ItemIndex;

Collection.Item(SelDevice,Device);
Device.GetId(Id_Dev);

if Succeeded(CoCreateInstance (Class_PolicyConfigClient,nil,CLSCTX_INPROC_SERVER,IPolicyConfig,&Def_Dev_Ch)) then
begin
  if Succeeded(Def_Dev_Ch.SetDefaultEndpoint(Id_Dev,eConsole)) then
  begin
  //showmessage ('eConsole')
  end
  else begin
  showmessage (IntToStr(HResult (Def_Dev_Ch.SetDefaultEndpoint(Id_Dev,eConsole))));
  end;

  if Succeeded(Def_Dev_Ch.SetDefaultEndpoint(Id_Dev,eMultimedia)) then
  begin
  //showmessage ('eMultimedia')
  end
  else begin
  showmessage (IntToStr(HResult (Def_Dev_Ch.SetDefaultEndpoint(Id_Dev,eMultimedia))));
  end;

  if Succeeded(Def_Dev_Ch.SetDefaultEndpoint(Id_Dev,eCommunications)) then
  begin
  //showmessage ('eCommunications')
  end
  else begin
  showmessage (IntToStr(HResult (Def_Dev_Ch.SetDefaultEndpoint(Id_Dev,eCommunications))));
  end;
end;
If radSpeakers.Checked then DevUName:=radSpeakers.Caption else DevUName:=radHeadphones.Caption;
ShowBalloon(msgInfo2_loc[intLocale] + AnsiLowerCase(DevUName), bfInfo);
end;

function TfrmMain.GetMyVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of byte; // �������� ��� 48 ����
    Minor,Major,Build,Release: word; // � ��� ������
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION); // ������ ������
    if s.Size>0 then begin
      s.Read(v,SizeOf(v)); // ������ ������ ��� �����
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+ // ��� � ������...
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
   s.Free;
  except; end;
end;

procedure TfrmMain.WMQUERYENDSESSION(var Msg: TMessage);
begin
  SaveSettings;
  inherited;
end;

end.
