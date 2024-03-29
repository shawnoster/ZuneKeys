unit uAppCommands;

interface

uses
  Windows;

const
  APPCOMMAND_BROWSER_BACKWARD                  = 1;
  APPCOMMAND_BROWSER_FORWARD                   = 2; 
  APPCOMMAND_BROWSER_REFRESH                   = 3; 
  APPCOMMAND_BROWSER_STOP                      = 4; 
  APPCOMMAND_BROWSER_SEARCH                    = 5; 
  APPCOMMAND_BROWSER_FAVORITES                 = 6; 
  APPCOMMAND_BROWSER_HOME                      = 7; 
  APPCOMMAND_VOLUME_MUTE                       = 8; 
  APPCOMMAND_VOLUME_DOWN                       = 9; 
  APPCOMMAND_VOLUME_UP                         = 10; 
  APPCOMMAND_MEDIA_NEXTTRACK                   = 11; 
  APPCOMMAND_MEDIA_PREVIOUSTRACK               = 12; 
  APPCOMMAND_MEDIA_STOP                        = 13;
  APPCOMMAND_MEDIA_PLAY_PAUSE                  = 14; 
  APPCOMMAND_LAUNCH_MAIL                       = 15; 
  APPCOMMAND_LAUNCH_MEDIA_SELECT               = 16; 
  APPCOMMAND_LAUNCH_APP1                       = 17; 
  APPCOMMAND_LAUNCH_APP2                       = 18; 
  APPCOMMAND_BASS_DOWN                         = 19; 
  APPCOMMAND_BASS_BOOST                        = 20; 
  APPCOMMAND_BASS_UP                           = 21; 
  APPCOMMAND_TREBLE_DOWN                       = 22; 
  APPCOMMAND_TREBLE_UP                         = 23; 
  APPCOMMAND_MICROPHONE_VOLUME_MUTE            = 24; 
  APPCOMMAND_MICROPHONE_VOLUME_DOWN            = 25; 
  APPCOMMAND_MICROPHONE_VOLUME_UP              = 26; 
  APPCOMMAND_HELP                              = 27; 
  APPCOMMAND_FIND                              = 28; 
  APPCOMMAND_NEW                               = 29; 
  APPCOMMAND_OPEN                              = 30; 
  APPCOMMAND_CLOSE                             = 31; 
  APPCOMMAND_SAVE                              = 32; 
  APPCOMMAND_PRINT                             = 33; 
  APPCOMMAND_UNDO                              = 34;
  APPCOMMAND_REDO                              = 35;
  APPCOMMAND_COPY                              = 36;
  APPCOMMAND_CUT                               = 37;
  APPCOMMAND_PASTE                             = 38;
  APPCOMMAND_REPLY_TO_MAIL                     = 39;
  APPCOMMAND_FORWARD_MAIL                      = 40;
  APPCOMMAND_SEND_MAIL                         = 41;
  APPCOMMAND_SPELL_CHECK                       = 42;
  APPCOMMAND_DICTATE_OR_COMMAND_CONTROL_TOGGLE = 43;
  APPCOMMAND_MIC_ON_OFF_TOGGLE                 = 44;
  APPCOMMAND_CORRECTION_LIST                   = 45;
  APPCOMMAND_MEDIA_PLAY                        = 46;
  APPCOMMAND_MEDIA_PAUSE                       = 47;
  APPCOMMAND_MEDIA_RECORD                      = 48;
  APPCOMMAND_MEDIA_FAST_FORWARD                = 49;
  APPCOMMAND_MEDIA_REWIND                      = 50;
  APPCOMMAND_MEDIA_CHANNEL_UP                  = 51;
  APPCOMMAND_MEDIA_CHANNEL_DOWN                = 52;

type

  TWMAppCommand = packed record
    Msg: Cardinal;
    Wnd: HWND;
    Flags: Word;
    Cmd  : Byte;
    Device: Byte;
    Result: Longint;
  end;

implementation

end.
