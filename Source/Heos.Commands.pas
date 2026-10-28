// FactoryX
//
// Copyright: FactoryX. All rights reserved.
//
// Project: FactoryX HEOS CLI
// Project location: https://sourceforge.net/projects/MFPack
//                   https://github.com/FactoryXCode/MfPack
// Module: Heos.Commands.pas
// Kind: Pascal Unit
// Release date: 28-10-2026
// Language: ENU
//
// Revision Version: 1.0.0.1
// Description: Typed HEOS CLI command builders.
//
// Company: FactoryX
// Intiator(s): Tony (maXcomX), Carmen (carmenh).
// Contributor(s): Tony Kalf (maXcomX), Carmen (carmenh).
//
//------------------------------------------------------------------------------
// CHANGE LOG
// Date       Person              Reason
// ---------- ------------------- ----------------------------------------------
// 24/08/2026 All                 Moby release  SDK 10.0.28000.2705  (Windows 11)
//------------------------------------------------------------------------------
//
// Remarks: Requires Windows 10 or higher.
//
// Related objects: RDJ Pro
// Related projects: MfPackX400
// Known Issues: -
//
// Compiler version: 23 up to 35
// SDK version: 10.0.28000.2705
//
// Todo: -
//
// =============================================================================
// Source: FactoryX.Code - RDJ Pro
// =============================================================================
//
// LICENSE
//
// The contents of this file are subject to the Mozilla Public License
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/en-US/MPL/2.0/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// Non commercial users may distribute this sourcecode provided that this
// header is included in full at the top of the file.
// Commercial users are not allowed to distribute this sourcecode as part of
// their product.
//
//==============================================================================
unit Heos.Commands;

interface

uses

  System.SysUtils,
  Heos.Cli;

type

  THeosPlayState = (hpsPlay,
                     hpsPause,
                     hpsStop);

  THeosRepeatMode = (hrOff,
                      hrAll,
                      hrOne);

  THeosAddMode = (haPlayNow,
                   haPlayNext,
                   haAddToEnd,
                   haReplaceAndPlay);

  THeosCommands = class
  public
    class function RegisterForChangeEvents(Enabled: Boolean): THeosCommand; static;
    class function CheckAccount(): THeosCommand; static;
    class function SignIn(const UserName: string;
                            const Password: string): THeosCommand; static;
    class function SignOut(): THeosCommand; static;
    class function HeartBeat(): THeosCommand; static;
    class function Reboot(): THeosCommand; static;
    class function PrettifyJsonResponse(Enabled: Boolean): THeosCommand; static;
    class function GetPlayers(): THeosCommand; static;
    class function GetPlayerInfo(PlayerId: Int64): THeosCommand; static;
    class function GetPlayState(PlayerId: Int64): THeosCommand; static;
    class function GetNowPlayingMedia(PlayerId: Int64): THeosCommand; static;
    class function GetPlayerVolume(PlayerId: Int64): THeosCommand; static;
    class function GetPlayerMute(PlayerId: Int64): THeosCommand; static;
    class function TogglePlayerMute(PlayerId: Int64): THeosCommand; static;
    class function GetPlayMode(PlayerId: Int64): THeosCommand; static;
    class function ClearQueue(PlayerId: Int64): THeosCommand; static;
    class function PlayNext(PlayerId: Int64): THeosCommand; static;
    class function PlayPrevious(PlayerId: Int64): THeosCommand; static;
    class function CheckUpdate(PlayerId: Int64): THeosCommand; static;
    class function SetPlayState(PlayerId: Int64;
                                  State: THeosPlayState): THeosCommand; static;
    class function SetPlayerVolume(PlayerId: Int64;
                                     Level: Integer): THeosCommand; static;
    class function PlayerVolumeUp(PlayerId: Int64;
                                    Step: Integer = 5): THeosCommand; static;
    class function PlayerVolumeDown(PlayerId: Int64;
                                      Step: Integer = 5): THeosCommand; static;
    class function SetPlayerMute(PlayerId: Int64;
                                   Muted: Boolean): THeosCommand; static;
    class function SetPlayMode(PlayerId: Int64;
                                 RepeatMode: THeosRepeatMode;
                                 Shuffle: Boolean): THeosCommand; static;
    class function GetQueue(PlayerId: Int64;
                              First: Integer = -1;
                              Last: Integer = -1): THeosCommand; static;
    class function PlayQueue(PlayerId: Int64;
                               QueueId: Int64): THeosCommand; static;
    class function RemoveFromQueue(PlayerId: Int64;
                                     const QueueIds: array of Int64): THeosCommand; static;
    class function SaveQueue(PlayerId: Int64;
                               const Name: string): THeosCommand; static;
    class function MoveQueueItem(PlayerId: Int64;
                                   const QueueIds: array of Int64;
                                   DestinationId: Int64): THeosCommand; static;
    class function SetQuickSelect(PlayerId: Int64;
                                    QuickSelectId: Integer): THeosCommand; static;
    class function PlayQuickSelect(PlayerId: Int64;
                                     QuickSelectId: Integer): THeosCommand; static;
    class function GetQuickSelects(PlayerId: Int64;
                                     QuickSelectId: Integer = 0): THeosCommand; static;
    class function GetGroups(): THeosCommand; static;
    class function GetGroupInfo(GroupId: Int64): THeosCommand; static;
    class function GetGroupVolume(GroupId: Int64): THeosCommand; static;
    class function GetGroupMute(GroupId: Int64): THeosCommand; static;
    class function ToggleGroupMute(GroupId: Int64): THeosCommand; static;
    class function SetGroup(const PlayerIds: array of Int64): THeosCommand; static;
    class function SetGroupVolume(GroupId: Int64;
                                    Level: Integer): THeosCommand; static;
    class function GroupVolumeUp(GroupId: Int64;
                                   Step: Integer = 5): THeosCommand; static;
    class function GroupVolumeDown(GroupId: Int64;
                                     Step: Integer = 5): THeosCommand; static;
    class function SetGroupMute(GroupId: Int64;
                                  Muted: Boolean): THeosCommand; static;
    class function GetMusicSources(): THeosCommand; static;
    class function GetSourceInfo(SourceId: Int64): THeosCommand; static;
    class function Browse(SourceId: Int64;
                            const ContainerId: string = '';
                            First: Integer = -1;
                            Last: Integer = -1): THeosCommand; static;
    class function GetSearchCriteria(SourceId: Int64): THeosCommand; static;
    class function Search(SourceId: Int64;
                            const SearchText: string;
                            const CriteriaId: string;
                            First: Integer = -1;
                            Last: Integer = -1): THeosCommand; static;
    class function PlayStation(PlayerId: Int64;
                                 SourceId: Int64;
                                 const MediaId: string;
                                 const ContainerId: string = '';
                                 const Name: string = ''): THeosCommand; static;
    class function PlayPreset(PlayerId: Int64;
                                Preset: Integer): THeosCommand; static;
    class function PlayInput(PlayerId: Int64;
                               const InputName: string): THeosCommand; static;
    class function PlayRemoteInput(PlayerId: Int64;
                                     SourcePlayerId: Int64;
                                     const InputName: string): THeosCommand; static;
    class function PlayUrl(PlayerId: Int64;
                             const Url: string): THeosCommand; static;
    class function AddContainerToQueue(PlayerId: Int64;
                                         SourceId: Int64;
                                         const ContainerId: string;
                                         Mode: THeosAddMode): THeosCommand; static;
    class function AddTrackToQueue(PlayerId: Int64;
                                     SourceId: Int64;
                                     const ContainerId: string;
                                     const MediaId: string;
                                     Mode: THeosAddMode): THeosCommand; static;
    class function GetPlaylists(const ContainerId: string = '';
                                  First: Integer = -1;
                                  Last: Integer = -1): THeosCommand; static;
    class function GetHistory(const ContainerId: string = '';
                                First: Integer = -1;
                                Last: Integer = -1): THeosCommand; static;
    class function GetFavorites(const ContainerId: string = '';
                                  First: Integer = -1;
                                  Last: Integer = -1): THeosCommand; static;
    class function RenamePlaylist(SourceId: Int64;
                                    const ContainerId: string;
                                    const Name: string): THeosCommand; static;
    class function DeletePlaylist(SourceId: Int64;
                                    const ContainerId: string): THeosCommand; static;
    class function RetrieveMetadata(SourceId: Int64;
                                      const AlbumId: string): THeosCommand; static;
    class function GetServiceOptions(SourceId: Int64): THeosCommand; static;
    class function SetServiceOption(OptionId: Integer;
                                      const Parameters: array of THeosParameter): THeosCommand; static;
  end;

implementation

const

  PlayStateText: array[THeosPlayState] of string = ('play',
                                                    'pause',
                                                    'stop');
  RepeatText: array[THeosRepeatMode] of string = ('off',
                                                  'on_all',
                                                  'on_one');

function OnOff(Value: Boolean): string;
begin

  if Value then
    Result := 'on'
  else
    Result := 'off';
end;


procedure CheckRange(Value: Integer;
                       Minimum: Integer;
                       Maximum: Integer);
begin

  if (Value < Minimum) or (Value > Maximum) then
    raise EArgumentOutOfRangeException.Create('HEOS parameter is outside the allowed range');
end;


procedure CheckPositive(Value: Int64);
begin

  if (Value < 1) then
    raise EArgumentOutOfRangeException.Create('HEOS queue, preset or option ID must be positive');
end;


procedure CheckName(const Name: string);
begin

  if (Name = '') or (Length(Name) > 128) then
    raise EArgumentException.Create('HEOS playlist names must contain 1 to 128 characters');
end;


function JoinIds(const Ids: array of Int64;
                   PositiveOnly: Boolean): string;
var
  Id: Int64;

begin

  if (Length(Ids) = 0) then
    raise EArgumentException.Create('HEOS requires at least one ID');
  Result := '';
  for Id in Ids do
    begin
      if PositiveOnly then
        CheckPositive(Id);
      if (Result <> '') then
        Result := Result + ',';
      Result := Result + IntToStr(Id);
    end;
end;


procedure AddRange(var Command: THeosCommand;
                     First: Integer;
                     Last: Integer);
begin

  if (First = -1) and (Last = -1) then
    Exit;
  if (First < 0) or (Last < First) then
    raise EArgumentException.Create('HEOS range must be an inclusive, zero-based interval');
  Command.Add('range', IntToStr(First) + ',' + IntToStr(Last));
end;


class function THeosCommands.RegisterForChangeEvents(Enabled: Boolean): THeosCommand;
begin

  Result := THeosCommand.Create('system/register_for_change_events');
  Result.Add('enable', OnOff(Enabled));
end;


class function THeosCommands.CheckAccount(): THeosCommand;
begin

  Result := THeosCommand.Create('system/check_account');
end;


class function THeosCommands.SignIn(const UserName: string;
                                      const Password: string): THeosCommand;
begin

  Result := THeosCommand.Create('system/sign_in');
  Result.Add('un', UserName);
  Result.Add('pw', Password);
end;


class function THeosCommands.SignOut(): THeosCommand;
begin

  Result := THeosCommand.Create('system/sign_out');
end;


class function THeosCommands.HeartBeat(): THeosCommand;
begin

  Result := THeosCommand.Create('system/heart_beat');
end;


class function THeosCommands.Reboot(): THeosCommand;
begin

  Result := THeosCommand.Create('system/reboot');
end;


class function THeosCommands.PrettifyJsonResponse(Enabled: Boolean): THeosCommand;
begin

  Result := THeosCommand.Create('system/prettify_json_response');
  Result.Add('enable', OnOff(Enabled));
end;


class function THeosCommands.GetPlayers(): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_players');
end;


class function THeosCommands.GetPlayerInfo(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_player_info');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.GetPlayState(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_play_state');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.GetNowPlayingMedia(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_now_playing_media');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.GetPlayerVolume(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_volume');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.GetPlayerMute(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_mute');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.TogglePlayerMute(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/toggle_mute');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.GetPlayMode(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_play_mode');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.ClearQueue(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/clear_queue');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.PlayNext(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/play_next');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.PlayPrevious(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/play_previous');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.CheckUpdate(PlayerId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/check_update');
  Result.Add('pid', IntToStr(PlayerId));
end;


class function THeosCommands.SetPlayState(PlayerId: Int64;
                                            State: THeosPlayState): THeosCommand;
begin

  Result := THeosCommand.Create('player/set_play_state');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('state', PlayStateText[State]);
end;


class function THeosCommands.SetPlayerVolume(PlayerId: Int64;
                                               Level: Integer): THeosCommand;
begin

  CheckRange(Level, 0, 100);
  Result := THeosCommand.Create('player/set_volume');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('level', IntToStr(Level));
end;


class function THeosCommands.PlayerVolumeUp(PlayerId: Int64;
                                              Step: Integer): THeosCommand;
begin

  CheckRange(Step, 1, 10);
  Result := THeosCommand.Create('player/volume_up');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('step', IntToStr(Step));
end;


class function THeosCommands.PlayerVolumeDown(PlayerId: Int64;
                                                Step: Integer): THeosCommand;
begin

  CheckRange(Step, 1, 10);
  Result := THeosCommand.Create('player/volume_down');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('step', IntToStr(Step));
end;


class function THeosCommands.SetPlayerMute(PlayerId: Int64;
                                             Muted: Boolean): THeosCommand;
begin

  Result := THeosCommand.Create('player/set_mute');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('state', OnOff(Muted));
end;


class function THeosCommands.SetPlayMode(PlayerId: Int64;
                                           RepeatMode: THeosRepeatMode;
                                           Shuffle: Boolean): THeosCommand;
begin

  Result := THeosCommand.Create('player/set_play_mode');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('repeat', RepeatText[RepeatMode]);
  Result.Add('shuffle', OnOff(Shuffle));
end;


class function THeosCommands.GetQueue(PlayerId: Int64;
                                        First: Integer;
                                        Last: Integer): THeosCommand;
begin

  Result := THeosCommand.Create('player/get_queue');
  Result.Add('pid', IntToStr(PlayerId));
  AddRange(Result, First, Last);
end;


class function THeosCommands.PlayQueue(PlayerId: Int64;
                                         QueueId: Int64): THeosCommand;
begin

  CheckPositive(QueueId);
  Result := THeosCommand.Create('player/play_queue');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('qid', IntToStr(QueueId));
end;


class function THeosCommands.RemoveFromQueue(PlayerId: Int64;
                                               const QueueIds: array of Int64): THeosCommand;
begin

  Result := THeosCommand.Create('player/remove_from_queue');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('qid', JoinIds(QueueIds, True));
end;


class function THeosCommands.SaveQueue(PlayerId: Int64;
                                         const Name: string): THeosCommand;
begin

  CheckName(Name);
  Result := THeosCommand.Create('player/save_queue');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('name', Name);
end;


class function THeosCommands.MoveQueueItem(PlayerId: Int64;
                                             const QueueIds: array of Int64;
                                             DestinationId: Int64): THeosCommand;
begin

  CheckPositive(DestinationId);
  Result := THeosCommand.Create('player/move_queue_item');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('sqid', JoinIds(QueueIds, True));
  Result.Add('dqid', IntToStr(DestinationId));
end;


class function THeosCommands.SetQuickSelect(PlayerId: Int64;
                                              QuickSelectId: Integer): THeosCommand;
begin

  CheckRange(QuickSelectId, 1, 6);
  Result := THeosCommand.Create('player/set_quickselect');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('id', IntToStr(QuickSelectId));
end;


class function THeosCommands.PlayQuickSelect(PlayerId: Int64;
                                               QuickSelectId: Integer): THeosCommand;
begin

  CheckRange(QuickSelectId, 1, 6);
  Result := THeosCommand.Create('player/play_quickselect');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('id', IntToStr(QuickSelectId));
end;


class function THeosCommands.GetQuickSelects(PlayerId: Int64;
                                               QuickSelectId: Integer): THeosCommand;
begin

  CheckRange(QuickSelectId, 0, 6);
  Result := THeosCommand.Create('player/get_quickselects');
  Result.Add('pid', IntToStr(PlayerId));
  if (QuickSelectId <> 0) then
    Result.Add('id', IntToStr(QuickSelectId));
end;


class function THeosCommands.GetGroups(): THeosCommand;
begin

  Result := THeosCommand.Create('group/get_groups');
end;


class function THeosCommands.GetGroupInfo(GroupId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('group/get_group_info');
  Result.Add('gid', IntToStr(GroupId));
end;


class function THeosCommands.GetGroupVolume(GroupId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('group/get_volume');
  Result.Add('gid', IntToStr(GroupId));
end;


class function THeosCommands.GetGroupMute(GroupId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('group/get_mute');
  Result.Add('gid', IntToStr(GroupId));
end;


class function THeosCommands.ToggleGroupMute(GroupId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('group/toggle_mute');
  Result.Add('gid', IntToStr(GroupId));
end;


class function THeosCommands.SetGroup(const PlayerIds: array of Int64): THeosCommand;
begin

  Result := THeosCommand.Create('group/set_group');
  Result.Add('pid', JoinIds(PlayerIds, False));
end;


class function THeosCommands.SetGroupVolume(GroupId: Int64;
                                              Level: Integer): THeosCommand;
begin

  CheckRange(Level, 0, 100);
  Result := THeosCommand.Create('group/set_volume');
  Result.Add('gid', IntToStr(GroupId));
  Result.Add('level', IntToStr(Level));
end;


class function THeosCommands.GroupVolumeUp(GroupId: Int64;
                                             Step: Integer): THeosCommand;
begin

  CheckRange(Step, 1, 10);
  Result := THeosCommand.Create('group/volume_up');
  Result.Add('gid', IntToStr(GroupId));
  Result.Add('step', IntToStr(Step));
end;


class function THeosCommands.GroupVolumeDown(GroupId: Int64;
                                               Step: Integer): THeosCommand;
begin

  CheckRange(Step, 1, 10);
  Result := THeosCommand.Create('group/volume_down');
  Result.Add('gid', IntToStr(GroupId));
  Result.Add('step', IntToStr(Step));
end;


class function THeosCommands.SetGroupMute(GroupId: Int64;
                                            Muted: Boolean): THeosCommand;
begin

  Result := THeosCommand.Create('group/set_mute');
  Result.Add('gid', IntToStr(GroupId));
  Result.Add('state', OnOff(Muted));
end;


class function THeosCommands.GetMusicSources(): THeosCommand;
begin

  Result := THeosCommand.Create('browse/get_music_sources');
end;


class function THeosCommands.GetSourceInfo(SourceId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('browse/get_source_info');
  Result.Add('sid', IntToStr(SourceId));
end;


class function THeosCommands.Browse(SourceId: Int64;
                                      const ContainerId: string;
                                      First: Integer;
                                      Last: Integer): THeosCommand;
begin

  Result := THeosCommand.Create('browse/browse');
  Result.Add('sid', IntToStr(SourceId));
  if (ContainerId <> '') then
    Result.Add('cid', ContainerId);
  AddRange(Result, First, Last);
end;


class function THeosCommands.GetSearchCriteria(SourceId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('browse/get_search_criteria');
  Result.Add('sid', IntToStr(SourceId));
end;


class function THeosCommands.Search(SourceId: Int64;
                                      const SearchText: string;
                                      const CriteriaId: string;
                                      First: Integer;
                                      Last: Integer): THeosCommand;
begin

  Result := THeosCommand.Create('browse/search');
  Result.Add('sid', IntToStr(SourceId));
  Result.Add('search', SearchText);
  Result.Add('scid', CriteriaId);
  AddRange(Result, First, Last);
end;


class function THeosCommands.PlayStation(PlayerId: Int64;
                                           SourceId: Int64;
                                           const MediaId: string;
                                           const ContainerId: string;
                                           const Name: string): THeosCommand;
begin

  Result := THeosCommand.Create('browse/play_stream');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('sid', IntToStr(SourceId));
  Result.Add('mid', MediaId);
  if (ContainerId <> '') then
    Result.Add('cid', ContainerId);
  if (Name <> '') then
    Result.Add('name', Name);
end;


class function THeosCommands.PlayPreset(PlayerId: Int64;
                                          Preset: Integer): THeosCommand;
begin

  CheckPositive(Preset);
  Result := THeosCommand.Create('browse/play_preset');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('preset', IntToStr(Preset));
end;


class function THeosCommands.PlayInput(PlayerId: Int64;
                                         const InputName: string): THeosCommand;
begin

  Result := THeosCommand.Create('browse/play_input');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('input', InputName);
end;


class function THeosCommands.PlayRemoteInput(PlayerId: Int64;
                                               SourcePlayerId: Int64;
                                               const InputName: string): THeosCommand;
begin

  Result := THeosCommand.Create('browse/play_input');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('spid', IntToStr(SourcePlayerId));
  Result.Add('input', InputName);
end;


class function THeosCommands.PlayUrl(PlayerId: Int64;
                                       const Url: string): THeosCommand;
begin

  Result := THeosCommand.Create('browse/play_stream');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('url', Url);
end;


class function THeosCommands.AddContainerToQueue(PlayerId: Int64;
                                                   SourceId: Int64;
                                                   const ContainerId: string;
                                                   Mode: THeosAddMode): THeosCommand;
begin

  Result := THeosCommand.Create('browse/add_to_queue');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('sid', IntToStr(SourceId));
  Result.Add('cid', ContainerId);
  Result.Add('aid', IntToStr(Ord(Mode) + 1));
end;


class function THeosCommands.AddTrackToQueue(PlayerId: Int64;
                                               SourceId: Int64;
                                               const ContainerId: string;
                                               const MediaId: string;
                                               Mode: THeosAddMode): THeosCommand;
begin

  Result := THeosCommand.Create('browse/add_to_queue');
  Result.Add('pid', IntToStr(PlayerId));
  Result.Add('sid', IntToStr(SourceId));
  Result.Add('cid', ContainerId);
  Result.Add('mid', MediaId);
  Result.Add('aid', IntToStr(Ord(Mode) + 1));
end;


class function THeosCommands.GetPlaylists(const ContainerId: string;
                                            First: Integer;
                                            Last: Integer): THeosCommand;
begin

  Result := THeosCommand.Create('browse/browse');
  Result.Add('sid', '1025');
  if (ContainerId <> '') then
    Result.Add('cid', ContainerId);
  AddRange(Result, First, Last);
end;


class function THeosCommands.GetHistory(const ContainerId: string;
                                          First: Integer;
                                          Last: Integer): THeosCommand;
begin

  Result := THeosCommand.Create('browse/browse');
  Result.Add('sid', '1026');
  if (ContainerId <> '') then
    Result.Add('cid', ContainerId);
  AddRange(Result, First, Last);
end;


class function THeosCommands.GetFavorites(const ContainerId: string;
                                            First: Integer;
                                            Last: Integer): THeosCommand;
begin

  Result := THeosCommand.Create('browse/browse');
  Result.Add('sid', '1028');
  if (ContainerId <> '') then
    Result.Add('cid', ContainerId);
  AddRange(Result, First, Last);
end;


class function THeosCommands.RenamePlaylist(SourceId: Int64;
                                              const ContainerId: string;
                                              const Name: string): THeosCommand;
begin

  CheckName(Name);
  Result := THeosCommand.Create('browse/rename_playlist');
  Result.Add('sid', IntToStr(SourceId));
  Result.Add('cid', ContainerId);
  Result.Add('name', Name);
end;


class function THeosCommands.DeletePlaylist(SourceId: Int64;
                                              const ContainerId: string): THeosCommand;
begin

  Result := THeosCommand.Create('browse/delete_playlist');
  Result.Add('sid', IntToStr(SourceId));
  Result.Add('cid', ContainerId);
end;


class function THeosCommands.RetrieveMetadata(SourceId: Int64;
                                                const AlbumId: string): THeosCommand;
begin

  Result := THeosCommand.Create('browse/retrieve_metadata');
  Result.Add('sid', IntToStr(SourceId));
  Result.Add('cid', AlbumId);
end;


class function THeosCommands.GetServiceOptions(SourceId: Int64): THeosCommand;
begin

  Result := THeosCommand.Create('browse/get_service_options');
  Result.Add('sid', IntToStr(SourceId));
end;


class function THeosCommands.SetServiceOption(OptionId: Integer;
                                                const Parameters: array of THeosParameter): THeosCommand;
var
  Item: THeosParameter;

begin

  CheckPositive(OptionId);
  Result := THeosCommand.Create('browse/set_service_option');
  Result.Add('option', IntToStr(OptionId));
  for Item in Parameters do
    Result.Add(Item.Name, Item.Value, Item.Encoded);
end;

end.
