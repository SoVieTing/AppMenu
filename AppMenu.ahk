;~ Name:	AppMenu
;~ Desc:	
;~ Author:	劇終
;~ Lib:		
;~ Attention:	ini要自己改好了才能用, 否则报错
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#SingleInstance force
;~ #MaxThreads 255
SetWorkingDir, %A_ScriptDir%
;~ SetBatchLines -1 ;让脚本无休眠运行
;~ SetTimer, Timer, 1000
;Global ini===================================================================================
IniFile=.\AppMenu.ini
IniRead, HotKey, 			%IniFile%, Setting, HotKey				;自定义HotKey
Hotkey, %HotKey%, MenuShow
IniRead, IconStatus, 		%IniFile%, Setting, IconStatus			;显示/不显示 Icon
IniRead, IconSize, 			%IniFile%, Setting, IconSize			;Icon大小
IniRead, TrayIconPath, 		%IniFile%, Setting, TrayIconPath		;TrayIcon路径				;*****[编译的exe注释此项]*****
IniRead, TrayIconNumber, 	%IniFile%, Setting, TrayIconNumber		;TrayIcon图标组编号			;*****[编译的exe注释此项]*****
Menu, tray, icon, %TrayIconPath%, %TrayIconNumber%												;*****[编译的exe注释此项]*****
IniRead, TrayTip_Title, 	%IniFile%, Setting, TrayTip_Title		;TrayTip组
IniRead, TrayTip_Text, 		%IniFile%, Setting, TrayTip_Text		;TrayTip组
IniRead, TrayTip_Delay, 	%IniFile%, Setting, TrayTip_Delay		;TrayTip组
IniRead, TrayTip_Opt, 		%IniFile%, Setting, TrayTip_Opt			;TrayTip组
IniRead, EditorPath_TXT, 	%IniFile%, Setting, EditorPath_TXT		;文本编辑器路径
if EditorPath_TXT=													;如果为空,使用系统Notepad.exe
{
	EditorPath_TXT=Notepad.exe
}
IniRead, EditorPath_Script, %IniFile%, Setting, EditorPath_Script	;脚本编辑器路径				;*****[编译的exe注释此项]*****

;Menu Creator==================================================================================
Menu, TempMenu, add, TempItem, CMD_Handle	;创建临时菜单，便于下面使用Category
IniRead, WholeList, %IniFile%, AppList	;读Applist
StringSplit, Row_List, WholeList, `n	;用换行符分割为各行，并存入数组函数
;Main=====================================================
loop, %Row_List0%
{
	a+=1
	StringSplit, Row_Parse, Row_List%a%, =	;分割行字段
	if Row_Parse1=	;如果=左边是空值，进行主菜单分割线和Category识别
	{
		if Row_Parse2=-	;如果=右边是-，则主菜单添加分隔线
		{
			Menu, AppMenu, Add
			;~ Menu, Tray, Add	;同时写入托盘菜单
		}
		else
		{
			CategoryName:=Row_Parse2
			gosub, Category_Handle	;否则，本行识别为Category，并跳到Category_Handle进行处理
		}
	}
	else	;否则，进入子菜单创建
	{
		if Row_List%a% = -	;识别符为“-”，添加子菜单分隔符
		{
			Menu, %CategoryName%, Add
		}
		else	;否则，创建子菜单
		{
			Var_Waiting_Parse:= Row_Parse2
			gosub, Var_Parse
			if y=1	;分析是否包含"~"包含则添加到主菜单中
			{
				App_Name%a%:= Row_Parse1
				App_Path%a%:= cmd
				Menu, AppMenu,	Add, % App_Name%a%, CMD_Handle	;生成App条目，为App条目定义CMD，并写入主菜单
				;~ Menu, Tray, 	Add, % App_Name%a%, CMD_Handle	;同时写入托盘菜单
				if IconStatus=1			;是否显示图标
				{
					if defined_ico=		;定义图标
					{
						Menu, AppMenu,	Icon, % App_Name%a%, % App_Path%a%, %num_ico%, %IconSize%
						;~ Menu, Tray,		Icon, % App_Name%a%, % App_Path%a%, %num_ico%, %IconSize%		;同时为托盘
					}
					else
					{
						Menu, AppMenu,	Icon, % App_Name%a%, %defined_ico%, %num_ico%, %IconSize%
						;~ Menu, Tray,		Icon, % App_Name%a%, %defined_ico%, %num_ico%, %IconSize%		;同时为托盘
					}
					y=0		;写入主菜单的标识归0
				}
			}
			else
			{
				App_Name%a%:= Row_Parse1
				App_Path%a%:= cmd
				Menu, %CategoryName%,	Add, % App_Name%a%, CMD_Handle			;生成App条目，为App条目定义CMD
				Menu, AppMenu,			Add, %CategoryName%, :%CategoryName%	;子菜单写入Category菜单，Category写入主菜单
				;~ Menu, Tray, 			Add, %CategoryName%, :%CategoryName%	;同时写入托盘菜单
				if IconStatus=1			;是否显示图标
				{
					if defined_ico=
					{
						Menu, %CategoryName%, Icon, % App_Name%a%, % App_Path%a%, %num_ico%, %IconSize%
					}
					else
					{
						Menu, %CategoryName%, Icon, % App_Name%a%, %defined_ico%, %num_ico%, %IconSize%
					}
				}
			}
		}
	}
}
Menu, AppMenu,	Add
Menu, Option,	Add, Setting,	Setting		;Setting	写入Option菜单
Menu, Option,	Add, Edit,		Edit		;Edit		写入Option菜单			;*****[编译的exe注释此项]*****
Menu, Option,	Add							;分隔符		写入Option菜单
Menu, Option,	Add, Reload,	Reload		;Reload		写入Option菜单
Menu, Option,	Add, Exit,		Exit		;Exit		写入Option菜单
Menu, AppMenu,	Add, Option,	:Option		;Option写入AppMenu最下面
;--------------------------
Menu, Tray, NoStandard				;删除托盘标准菜单
Menu, Tray, Add, AppMenu, MenuShow	;将AppMenu作为一个MenuItemName写入托盘菜单
Menu, Tray, Default, AppMenu		;将其设为默认菜单
Menu, Tray, Click, 1				;设定为单击(默认值为2，即双击)
;--------------------------
Menu, Tray, Add
Menu, Tray,	Add, Setting,	Setting		;Setting	写入Tray右键菜单
Menu, Tray,	Add, Edit	,	Edit		;Edit		写入Tray右键菜单			;*****[编译的exe注释此项]*****
Menu, Tray,	Add							;分隔符		写入Tray右键菜单
Menu, Tray,	Add, Reload,	Reload		;Reload		写入Tray右键菜单
Menu, Tray,	Add, Exit,		Exit		;Exit		写入Tray右键菜单
;--------------------------
ii=1	;关闭Timer的标记
TrayTip, %TrayTip_Title%, %TrayTip_Text%, %TrayTip_Delay%, %TrayTip_Opt%
return
;Main end===================================================

;Label===========================================================================================
Category_Handle:
Menu, AppMenu,	Add, %CategoryName%, :TempMenu 	;借用临时菜单将Category画入主菜单
;~ Menu, Tray, 	Add, %CategoryName%, :TempMenu 	;同时写入托盘菜单
return

CMD_Handle:
IniRead, Var_Waiting_Parse, %IniFile%, AppList, %A_ThisMenuItem%
gosub, Var_Parse
Run, %cmd% %parameter%, %start_path%, %start_mod%
return

Var_Parse:
Var_Parse1:=
Var_Parse2:=
Var_Parse3:=
Var_Parse4:=
Var_Parse5:=
Var_Parse6:=
StringSplit, Var_Parse, Var_Waiting_Parse, |
cmd:=Var_Parse1
StringLeft, LeftParse, cmd, 1
if LeftParse=~
{
	StringTrimLeft, cmd, cmd, 1
	y=1	;返回数字1，表示该行为添加到主菜单的App
}
parameter:=		Var_Parse2
start_path:=	Var_Parse3
start_mod:=		Var_Parse4
defined_ico:=	Var_Parse5
num_ico:=		Var_Parse6
return

MenuShow:
Menu, AppMenu, Show
return

Setting:
Run, %EditorPath_TXT% %A_ScriptDir%\AppMenu.ini
return

Edit:
Run, %EditorPath_Script% %A_ScriptFullPath%
return

Reload:
Reload
return

Exit:
ExitApp
return

Timer:
Critical
if ii<>1
{
i+=1
TrayTip, AppMenu, parsing %i%s.....,,2
}
else SetTimer,, off
return