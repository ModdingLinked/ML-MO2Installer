#include "innodependencyinstaller_config.iss"
#include "CodeDependencies.iss"

[Setup]
; downloading and installing dependencies will only work if the memo/ready page is enabled (default and current behaviour)
DisableReadyPage=no
DisableReadyMemo=no

; supported languages
#include "lang\english.iss"
;#include "lang\german.iss"
;#include "lang\french.iss"
;#include "lang\italian.iss"
;#include "lang\dutch.iss"

#ifdef UNICODE
;#include "lang\chinese.iss"
;#include "lang\polish.iss"
;#include "lang\russian.iss"
;#include "lang\japanese.iss"
#endif

[CustomMessages]
DependenciesDir=MyProgramDependencies
WindowsServicePack=Windows %1 Service Pack %2

; shared code for installing the products
#include "products.iss"

; helper functions
#include "products\stringversion.iss"
#include "products\winversion.iss"
#include "products\fileversion.iss"
#include "products\dotnetfxversion.iss"

; actual products
#ifdef use_iis
#include "products\iis.iss"
#endif

#ifdef use_kb835732
#include "products\kb835732.iss"
#endif

#ifdef use_msi20
#include "products\msi20.iss"
#endif
#ifdef use_msi31
#include "products\msi31.iss"
#endif
#ifdef use_msi45
#include "products\msi45.iss"
#endif

#ifdef use_ie6
#include "products\ie6.iss"
#endif

#ifdef use_dotnetfx11
#include "products\dotnetfx11.iss"
#include "products\dotnetfx11sp1.iss"
#ifdef use_dotnetfx11lp
#include "products\dotnetfx11lp.iss"
#endif
#endif

#ifdef use_dotnetfx20
#include "products\dotnetfx20.iss"
#include "products\dotnetfx20sp1.iss"
#include "products\dotnetfx20sp2.iss"
#ifdef use_dotnetfx20lp
#include "products\dotnetfx20lp.iss"
#include "products\dotnetfx20sp1lp.iss"
#include "products\dotnetfx20sp2lp.iss"
#endif
#endif

#ifdef use_dotnetfx35
;#include "products\dotnetfx35.iss"
#include "products\dotnetfx35sp1.iss"
#ifdef use_dotnetfx35lp
;#include "products\dotnetfx35lp.iss"
#include "products\dotnetfx35sp1lp.iss"
#endif
#endif

#ifdef use_dotnetfx40
#include "products\dotnetfx40client.iss"
#include "products\dotnetfx40full.iss"
#endif

#ifdef use_dotnetfx45
#include "products\dotnetfx45.iss"
#endif

#ifdef use_dotnetfx46
#include "products\dotnetfx46.iss"
#endif

#ifdef use_dotnetfx47
#include "products\dotnetfx47.iss"
#endif

#ifdef use_wic
#include "products\wic.iss"
#endif

#ifdef use_msiproduct
#include "products\msiproduct.iss"
#endif
#ifdef use_vc2005
#include "products\vcredist2005.iss"
#endif
#ifdef use_vc2008
#include "products\vcredist2008.iss"
#endif
#ifdef use_vc2010
#include "products\vcredist2010.iss"
#endif
#ifdef use_vc2012
#include "products\vcredist2012.iss"
#endif
#ifdef use_vc2013
#include "products\vcredist2013.iss"
#endif
#ifdef use_vc2015
#include "products\vcredist2015.iss"
#endif
#ifdef use_vc2017
#include "products\vcredist2017.iss"
#endif
#ifdef use_vc2015_2019
#include "products\vcredist2015_2019.iss"
#endif

#ifdef use_directxruntime
#include "products\directxruntime.iss"
#endif

#ifdef use_mdac28
#include "products\mdac28.iss"
#endif
#ifdef use_jet4sp8
#include "products\jet4sp8.iss"
#endif

#ifdef use_sqlcompact35sp2
#include "products\sqlcompact35sp2.iss"
#endif

#ifdef use_sql2005express
#include "products\sql2005express.iss"
#endif
#ifdef use_sql2008express
#include "products\sql2008express.iss"
#endif

[Code]
function InitializeSetup(): boolean;
begin
	// initialize windows version
	initwinversion();

#ifdef use_iis
	if (not iis()) then exit;
#endif

#ifdef use_msi20
	msi20('2.0'); // min allowed version is 2.0
#endif
#ifdef use_msi31
	msi31('3.1'); // min allowed version is 3.1
#endif
#ifdef use_msi45
	msi45('4.5'); // min allowed version is 4.5
#endif
#ifdef use_ie6
	ie6('5.0.2919'); // min allowed version is 5.0.2919
#endif

#ifdef use_dotnetfx11
	dotnetfx11();
#ifdef use_dotnetfx11lp
	dotnetfx11lp();
#endif
	dotnetfx11sp1();
#endif

	// install .netfx 2.0 sp2 if possible; if not sp1 if possible; if not .netfx 2.0
#ifdef use_dotnetfx20
	// check if .netfx 2.0 can be installed on this OS
	if not minwinspversion(5, 0, 3) then begin
		MsgBox(FmtMessage(CustomMessage('depinstall_missing'), [FmtMessage(CustomMessage('WindowsServicePack'), ['2000', '3'])]), mbError, MB_OK);
		exit;
	end;
	if not minwinspversion(5, 1, 2) then begin
		MsgBox(FmtMessage(CustomMessage('depinstall_missing'), [FmtMessage(CustomMessage('WindowsServicePack'), ['XP', '2'])]), mbError, MB_OK);
		exit;
	end;

	if minwinversion(5, 1) then begin
		dotnetfx20sp2();
#ifdef use_dotnetfx20lp
		dotnetfx20sp2lp();
#endif
	end else begin
		if minwinversion(5, 0) and minwinspversion(5, 0, 4) then begin
#ifdef use_kb835732
			kb835732();
#endif
			dotnetfx20sp1();
#ifdef use_dotnetfx20lp
			dotnetfx20sp1lp();
#endif
		end else begin
			dotnetfx20();
#ifdef use_dotnetfx20lp
			dotnetfx20lp();
#endif
		end;
	end;
#endif

#ifdef use_dotnetfx35
	//dotnetfx35();
	dotnetfx35sp1();
#ifdef use_dotnetfx35lp
	//dotnetfx35lp();
	dotnetfx35sp1lp();
#endif
#endif

#ifdef use_wic
	wic();
#endif

	// if no .netfx 4.0 is found, install the client (smallest)
#ifdef use_dotnetfx40
	if (not netfxinstalled(NetFx40Client, '') and not netfxinstalled(NetFx40Full, '')) then
		dotnetfx40client();
#endif

#ifdef use_dotnetfx45
	dotnetfx45(50); // min allowed version is 4.5.0
#endif

#ifdef use_dotnetfx46
	dotnetfx46(50); // min allowed version is 4.5.0
#endif

#ifdef use_dotnetfx47
	dotnetfx47(50); // min allowed version is 4.5.0
#endif

#ifdef use_vc2005
	vcredist2005('6'); // min allowed version is 6.0
#endif
#ifdef use_vc2008
	vcredist2008('9'); // min allowed version is 9.0
#endif
#ifdef use_vc2010
	vcredist2010('10'); // min allowed version is 10.0
#endif
#ifdef use_vc2012
	vcredist2012('11'); // min allowed version is 11.0
#endif
#ifdef use_vc2013
	//SetForceX86(true); // force 32-bit install of next products
	vcredist2013('12'); // min allowed version is 12.0
	//SetForceX86(false); // disable forced 32-bit install again
#endif
#ifdef use_vc2015
	vcredist2015('14'); // min allowed version is 14.0
#endif
#ifdef use_vc2017
	vcredist2017('14'); // min allowed version is 14.0
#endif
#ifdef use_vc2015_2019
	vcredist2015_2019('14.20'); // min allowed version is 14.20 (VS Redist 2019)
#endif


#ifdef use_directxruntime
	// extracts included setup file to temp folder so that we don't need to download it
	// and always runs directxruntime installer as we don't know how to check if it is required
	directxruntime();
#endif

#ifdef use_mdac28
	mdac28('2.7'); // min allowed version is 2.7
#endif
#ifdef use_jet4sp8
	jet4sp8('4.0.8015'); // min allowed version is 4.0.8015
#endif

#ifdef use_sqlcompact35sp2
	sqlcompact35sp2();
#endif

#ifdef use_sql2005express
	sql2005express();
#endif
#ifdef use_sql2008express
	sql2008express();
#endif

// Installs all VC versions through InnoDependencyInstaller (ML 1.3)
// https://github.com/DomGries/InnoDependencyInstaller/blob/master/LICENSE.md
  Dependency_ForceX86 := True; // force 32-bit install of next dependencies
  Dependency_AddVC2005;
  Dependency_AddVC2008;
  Dependency_AddVC2010;
  Dependency_AddVC2012;
  Dependency_AddVC2013;
  Dependency_AddVC2015To2022;
  Dependency_ForceX86 := False; // disable forced 32-bit install again
  Dependency_AddVC2005;
  Dependency_AddVC2008;
  Dependency_AddVC2010;
  Dependency_AddVC2012;
  Dependency_AddVC2013;
  Dependency_AddVC2015To2022;

	Result := true;
end;