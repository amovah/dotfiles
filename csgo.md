# Counter-Strike Global Offensive

## Personal Config

file: `personal.cfg`, location: `steamapps/common/Counter-Strike Global Offensive/csgo/cfg`
to run config you need to add this option to launch option, `+exec personal`

```
fps_max 90
rate "128000"

cl_hud_radar_scale "0.9"
cl_radar_scale "0.4"
cl_radar_always_centered "0"

volume "0.7"
voice_enable "1"
voice_scale "1"
windows_speaker_config "1"
snd_musicvolume "0.04"
snd_tensecondwarning_volume "0"
snd_menumusic_volume "0"
snd_roundend_volume "0"
snd_roundstart_volume "0"
snd_deathcamera_volume "0"
snd_mapobjective_volume "0"

alias "+jumpthrow" "+jump;-attack";alias "-jumpthrow" "-jump";bind "[key]" "+jumpthrow"

cl_crosshairalpha "255"
cl_crosshaircolor "5"
cl_crosshaircolor_b "0"
cl_crosshaircolor_r "0"
cl_crosshaircolor_g "250"
cl_crosshairdot "0"
cl_crosshairgap "-3"
cl_crosshairsize "3"
cl_crosshairstyle "4"
cl_crosshairusealpha "1"
cl_crosshairthickness "1"
cl_fixedcrosshairgap "-3"
cl_crosshair_outlinethickness "0"
cl_crosshair_drawoutline "0"
```

Additional Main Config:

```
bind "[key]" "buy flashbang; use weapon_knife; use weapon_flashbang"
bind "[key]" "buy smokegrenade; use weapon_knife; use weapon_smokegrenade"
bind "[key]" "buy hegrenade; use weapon_knife; use weapon_hegrenade"
bind "[key]" "buy incgrenade; buy molotov; use weapon_knife; use weapon_molotov; use weapon_incgrenade"
bind "[key]" "buy decoy; use weapon_knife; use weapon_decoy"
```

## Trainfield - Practice Grenade

name: `train.cfg`, location is like above.

```
sv_cheats 1
mp_limitteams 0
mp_autoteambalance 0
mp_roundtime 60
mp_roundtime_defuse 60
mp_maxmoney 60000
mp_startmoney 60000
mp_freezetime 0
mp_buytime 9999
mp_buy_anywhere 1
sv_infinite_ammo 1
ammo_grenade_limit_total 5
bot_kick
mp_warmup_end

// Practice
sv_grenade_trajectory 1
sv_grenade_trajectory_time 10
sv_showimpacts 1
sv_showimpacts_time 10

mp_restartgame 1

// Binds
bind "KEY" "noclip"
bind "KEY" "give weapon_hegrenade;give weapon_flashbang;give weapon_smokegrenade;give weapon_incgrenade;give weapon_molotov;give weapon_decoy”
bind "KEY" "cast_ray"
```
