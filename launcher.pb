
;intro

UseJPEGImageDecoder() 
UseJPEG2000ImageDecoder() 
UsePNGImageDecoder() 
UsePNGImageEncoder()
UseTIFFImageDecoder() 
UseTGAImageDecoder() 
UseGIFImageDecoder()
UseFLACSoundDecoder()
UseOGGSoundDecoder()
InitSound()
InitMovie()
UseMD5Fingerprint()

EnableExplicit


#title="eXoDOS launcher"

Declare stopintro()
Declare Resize()
Declare updateMusic(*currentgame)
Declare DrawList()

Global imgLoading
Global imgQuestionmark
Global imgHeart
Global imgClose
Global imgEnglish
Global imgGerman

Global mainwindow 
Global moviewindow 
Global sidewidth
Global scr_width
Global scr_height

Global sbar_width
Global sidewidthout

Global gContainer

Global gBanner
Global iBanner
Global gPicture
Global iPicture

Global gTitle

Global gNote
Global gStart
Global gConfig

Global gOptScr
Global gOptBox
Global gOptAd
Global gOptDisk
Global gOptFan
Global glist

Global fbig
Global sSound=#Null,sMovie=#Null,sMusic=#Null
Global hideConsole

Global intro_win,intro_movie,intro_wait,intro_pic

;-
;-{ MISC
;-

Procedure __MyLoadImage(id,file.s)
  Protected r=LoadImage(id,file)
  If r And (ImageFrameCount(r)>1 And LCase(GetExtensionPart(file))="gif") 
    Protected r2=CopyImage(r,#PB_Any)
    FreeImage(r)
    r=r2  
  EndIf
  ProcedureReturn r
EndProcedure

Macro LoadImage(a,b)
  __MyLoadImage(a,b)
EndMacro

Procedure.s FindJokerName(file.s)
  Protected n.s,a=ExamineDirectory(#PB_Any,GetPathPart(file),GetFilePart(file))
  If a
    While NextDirectoryEntry(a)
      n=DirectoryEntryName(a)
      FinishDirectory(a)
      ProcedureReturn GetPathPart(file)+n
    Wend
    FinishDirectory(a)
  EndIf
  ProcedureReturn ""
EndProcedure

Macro removeImage(id)
  If id
    FreeImage(id)
    id=#Null
  EndIf
EndMacro

Procedure min(a,b)
  If a<b
    ProcedureReturn a
  EndIf
  ProcedureReturn b
EndProcedure
Procedure max(a,b)
  If a>b
    ProcedureReturn a
  EndIf
  ProcedureReturn b
EndProcedure
Procedure SizeImageWidth(id,w)
  Protected iw=ImageWidth(id), ih=ImageHeight(id)
  If iw=w
    ProcedureReturn id
  EndIf
  If iw<w
    Protected fac=Round(w/iw, #PB_Round_Up)
    ResizeImage(id,iw*fac,ih*fac,#PB_Image_Raw)    
  EndIf
  Protected h=ih*w/iw
  ResizeImage(id,w,h,#PB_Image_Smooth)  
  ProcedureReturn id
EndProcedure

Procedure SizeImageBox(id,w,h)
  Protected iw=ImageWidth(id), ih=ImageHeight(id)
  Protected bw=iw,bh=ih
  
  bh=ih*w/iw
  bw=w  
  If bh>h
    bw=iw*h/ih
    bh=h
  EndIf
  
  If iw<bw And ih<bh
    Protected fac = max( Round(bw/iw,#PB_Round_Up), Round(bh/ih,#PB_Round_Up))
    If fac>1 
      ResizeImage(id,iw*fac,ih*fac,#PB_Image_Raw)
    EndIf
  EndIf
  
  ResizeImage(id,bw,bh,#PB_Image_Smooth)
EndProcedure
;}

;-
;-{ programm
;-
Global handlePRG
Procedure RunProgramEx(file.s,para.s,work.s)
  If handlePRG
    CloseProgram(handlePRG)
    handlePRG=#Null
  EndIf
  
  handlePRG=RunProgram(file,para,work,#PB_Program_Open)
  ProcedureReturn handlePRG
EndProcedure

Procedure isProgramRunning()
  If handlePRG
    If ProgramRunning(handlePRG)
      ProcedureReturn #True
    EndIf
    CloseProgram(handlePRG)
    handlePRG=#Null
  EndIf
  ProcedureReturn #False
EndProcedure
  

;}

;-
;-{ CONFIG
;-

#listview_detail=0
#listview_boxart=1

Structure sMainwindow
  x.i
  y.i
  w.i
  h.i
  maximize.i
EndStructure

Structure sConfigSize
  width.i
  height.i
EndStructure

Structure sConfigVolume
  noSound.i
  WAV.i
  MP3.i
  MOD.i
EndStructure

Structure sConfigColor
  listEntry.s
  listEntryInstalled.s
EndStructure
Structure sConfigColorVal
  listEntry.i
  listEntryInstalled.i
EndStructure

Structure sConfigDateSize
  size.i
  date.i
EndStructure
Structure sConfigBatch
  laucher.sConfigDateSize
  install.sConfigDateSize
  lang_laucher.sConfigDateSize
  lang_install.sConfigDateSize
EndStructure

Structure sConfig
  volume.sConfigVolume
  BoxArt.sConfigSize
  Color.sConfigColor
  maxBoxArt.i
  eXoDOSpath.s
  localInstall.i
  localMedias.i
  BoxArtCache.i
  lastGame.s
  nointro.i
  List headerSize.i()
  List headerFilter.s()
  window.sMainwindow
  batchs.sConfigBatch
  ListView.i
  AutomaticMinimize.i
EndStructure

Global config.sconfig
Global color.sConfigColorVal

Macro decolor(col)
  color\col= RGB(Val("$"+Left(config\color\col,2)),Val("$"+Mid(config\color\col,3,2)),Val("$"+Right(config\color\col,2)))
EndMacro

Procedure loadConfig()
  config\volume\WAV=100
  config\volume\MP3=100
  config\volume\MOD=60
  config\BoxArt\width=850*15/100
  config\BoxArt\height=850*15/100  
  config\maxBoxArt=500
  config\AutomaticMinimize=#True
  config\Color\listEntryInstalled="eeeeff"
  config\Color\listEntry="aaaaaa"
  config\BoxArtCache=#True
  
  ExamineDesktops()
  
  config\window\x=DesktopX(0)+10
  config\window\y=DesktopY(0)+10
  config\window\w=DesktopWidth(0)-100
  config\window\h=DesktopHeight(0)-100
  
  Protected id=LoadJSON(#PB_Any,"config.txt")
  If id
    ExtractJSONStructure(JSONValue(id), config,sConfig,#PB_JSON_NoClear)
    FreeJSON(id)
  EndIf
  
  
  
  decolor(listEntry)
  decolor(listEntryInstalled)
  
  
  
  If config\eXoDOSpath=""
    config\eXoDOSpath=PathRequester(#title+" - Choose eXoDOS path",".")
    If FileSize(config\eXoDOSpath+"Data\Platforms\MS-DOS.xml")<=0 
      MessageRequester(#title,"eXoDOS not found!")
      End
    EndIf
    config\localInstall=Bool(MessageRequester(#title,"Install games local?",#PB_MessageRequester_YesNo)=#PB_MessageRequester_Yes)
    If config\localInstall
      config\localMedias=Bool(MessageRequester(#title,"Install media (images,video,music) local?",#PB_MessageRequester_YesNo)=#PB_MessageRequester_Yes)
    EndIf
    config\BoxArtCache=Bool(MessageRequester(#title,"Cache Box art? (recommanded)",#PB_MessageRequester_YesNo)=#PB_MessageRequester_Yes)
       
  EndIf
EndProcedure

Procedure saveConfig()
  Protected id=CreateJSON(#PB_Any)
  If id
    InsertJSONStructure(JSONValue(id),@config,sConfig)
    SaveJSON(id,"config.txt",#PB_JSON_PrettyPrint)
    FreeJSON(id)
  EndIf
EndProcedure

Procedure.s findfile(file.s)
  If FileSize(file)>0
    ProcedureReturn GetCurrentDirectory()+file
  Else
    ProcedureReturn config\eXoDOSpath+file
  EndIf
EndProcedure

Global NewMap favorite()
Procedure loadFavorite()
  
  NewList f.s()
  Protected id=LoadJSON(#PB_Any,"favorite.txt")
  If id
    ExtractJSONList(JSONValue(id), f())
    FreeJSON(id)
  EndIf
  ForEach f()
    favorite(f())=#True
  Next
  
EndProcedure
Procedure saveFavorite()
  NewList f.s()
  ForEach favorite()
    If favorite()      
      AddElement( f() )
      f()=MapKey(favorite())
    EndIf
  Next
  Protected id=CreateJSON(#PB_Any)
  If id
    InsertJSONList(JSONValue(id), f())
    SaveJSON(id,"favorite.txt",#PB_JSON_PrettyPrint)
    FreeJSON(id)
  EndIf
EndProcedure

;}

;-
;-{ Hyperlink
;-

Enumeration
  #hl_none
  #hl_open
  #hl_genre
  #hl_series
  #hl_developer
  #hl_publisher
  
  #hl_ReleaseDate
  #hl_installed
  #hl_favorite
  #hl_toogleFavorite
  #hl_Source
  #hl_german
  #hl_adult
  
  #hl_play
  #hl_alternateLauncher
  #hl_config
  #hl_view
  
  #hl_introPic
  #hl_introVideo
  #hl_nomusic
  #hl_AutomaticMinimize
  
  #hl_openGameFolder
  #hl_openGameFolderGerman
  #hl_openNotGameFolder
  
EndEnumeration

Structure sHyperlink
  gadget.i
  type.i
  value.s
  short.i
EndStructure

Global NewList HyperLink.sHyperlink()

Procedure FreeHyperlink()
  ForEach HyperLink()
    FreeGadget(Hyperlink()\gadget)
  Next
  ClearList(Hyperlink())
EndProcedure

Procedure AddHyperlink(Txt.s,Type,Value.s,short=#False)
  AddElement(Hyperlink())
  hyperlink()\gadget=HyperLinkGadget(#PB_Any,0,0,10,10,Txt,#White)
  hyperlink()\type=Type
  hyperlink()\value=Value
  hyperlink()\short=short
  ResizeGadget(hyperlink()\gadget,#PB_Ignore,#PB_Ignore,#PB_Ignore,GadgetHeight(hyperlink()\gadget,#PB_Gadget_RequiredSize))
  SetGadgetColor(hyperlink()\gadget,#PB_Gadget_BackColor,#Black)
  SetGadgetColor(hyperlink()\gadget,#PB_Gadget_FrontColor,RGB(180,180,180)) 
EndProcedure
;}

;-
;-{ Hotlist
;-
Enumeration
  #action_none
  #action_header
  #action_edit
  #action_entry
  #action_scrollbar
  #action_headerSize

  
EndEnumeration

Structure sHotlist
  x1.i
  x2.i
  y1.i
  y2.i
  action.i
  value.i
EndStructure

Macro AddHotlist(xx1,yy1,xx2,yy2,act,val)
  AddElement(hotlist())
  hotlist()\action=act
  hotlist()\value=val
  hotlist()\x1=xx1
  hotlist()\y1=yy1
  hotlist()\x2=xx2
  hotlist()\y2=yy2
EndMacro

Global NewList hotlist.sHotlist()
Procedure inHotlist(x,y)
  ForEach hotlist()
    If hotlist()\x1<=x And x<=hotlist()\x2 And hotlist()\y1<=y And y<=hotlist()\y2
      ProcedureReturn hotlist()
    EndIf
  Next
  FirstElement(hotlist())
  ProcedureReturn #Null
EndProcedure
;}

;-
;-{ listgames / games / header
;-
Structure sImages
  List Image.s()
EndStructure

Structure sGame
  Title.s
  SortTitle.s
  
  Publisher.s
  ReleaseDate.s
  
  Developer.s
  
  Notes.s
  
  RootFolder.s
  
  ApplicationPath.s
  ApplicationPathGerman.s
  CommandLine.s
  ConfigurationPath.s
  
  ManualPath.s
  MusicPath.s
  MoviePath.s
  
  isAdult.i
  
  Source.s 
    
  WikipediaURL.s
  Series.s
  
  SortSeries.s
  
  ;installed.i
  installedGerman.i
  installedEnglish.i
  
  hasGerman.i
  
  Genre.s
  VideoUrl.s
  ID.s
  eXoID.s
  eXoName.s
  eXoNameGerman.s
  List Extras.s()
  List AlternateTitle.s()
  Map Images.sImages()

  
EndStructure

Structure sList
  *game.sGame
  sort.s
EndStructure

Structure sHeader
  text.s
  size.i
  offset.i
  filter.s
  PXStart.i
EndStructure

Structure sListGames
  List lgames.sList()
  position.i
  selected.i
  sort.i
  offset.i
  List header.sHeader()
  headerSize.i
  entryHeight.i
  entriesVisible.i
  entriesLines.i
  undercursor.sHotlist
  keyboarfocus.i
  drag.i
  dragInfo.i
  dragStart.i
  dragValue.i
  PictureType.s
  scrollbar_factor.f
EndStructure


Structure sOnce
  List Genre.s()
  List Series.s()
  List ReleaseDate.s()
  List Source.s()
  List installed.s()
EndStructure

Enumeration
  #offset_title
  #offset_developer
  #offset_publisher
  #offset_releasedate
  #offset_series
  #offset_genre
  #offset_installed
  #offset_source
  #offset_favorite
  #offset_german
  #offset_adult
EndEnumeration

Enumeration
  #drag_none
  #drag_sbar
  #drag_header
  #drag_sbarUp
  #drag_sbarDown
EndEnumeration

Global NewList games.sGame()
Global ListGames.sListGames 
Global Once.sOnce

Procedure addHeader(title.s,width,off) 
  AddElement(ListGames\header())
  ListGames\header()\text=title
  If SelectElement(config\headerSize(),ListIndex(ListGames\header()))
    ListGames\header()\size=config\headerSize()
  Else
    ListGames\header()\size=width
  EndIf
  
  If SelectElement(config\headerFilter(),ListIndex(ListGames\header()))
    ListGames\header()\filter=config\headerFilter()
  EndIf
  
  ListGames\header()\offset=off   
EndProcedure

Procedure loadOnce()
  Protected id=LoadJSON(#PB_Any,"media\once.json")
  If Not id
    ProcedureReturn #False
  EndIf
  ExtractJSONStructure(JSONValue(id),Once,sOnce)
  FreeJSON(id)
  
  AddElement(once\installed())
  once\installed()="X"
  AddElement(once\installed())
  once\installed()=" "
  
EndProcedure

Procedure unloadOnce()
  FreeList(once\Genre())
  FreeList(once\ReleaseDate())
  FreeList(once\Series())
  FreeList(once\Source())
  FreeList(once\installed())
EndProcedure

Procedure loadGamesList()
  Protected id=LoadJSON(#PB_Any,"media\games.json")
  If Not id 
    MessageRequester("launcher","Can't open games.json!"+#LF$+JSONErrorMessage()+#LF$+JSONErrorLine()+#LF$+JSONErrorPosition())
    End
  EndIf
  ExtractJSONList(JSONValue(id), games())
  FreeJSON(id)
  
  ListGames\sort=#PB_Sort_Ascending
  ListGames\offset=#offset_title
  ListGames\keyboarfocus=-1
  ListGames\PictureType="Screenshot"
  
  
  addHeader("Favorite",16,#offset_favorite)
  addHeader("Installed",36,#offset_installed)
  addHeader("Title",527,#offset_title)
  addHeader("German",16,#offset_german)
  addheader("Adult",16,#offset_adult)
  addHeader("Developer",200,#offset_developer)
  addHeader("Publisher",200,#offset_publisher)
  addHeader("Year",34,#offset_releasedate)
  addHeader("Series",160,#offset_series)
  addHeader("Genre",160,#offset_genre)  
  addHeader("Source",83,#offset_source)  
EndProcedure

Procedure findHeader(offset)
  ForEach ListGames\header()
    If ListGames\header()\offset=offset
      ProcedureReturn #True
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

Procedure updatePicture(*currentgame.sGame)
  
  removeImage(iPicture)
  If ListIndex(*currentgame\Images(ListGames\PictureType)\Image())>=0
    iPicture=LoadImage(#PB_Any,findfile(*currentgame\Images(ListGames\PictureType)\Image()) )
;     If Not iPicture And NextElement(*currentgame\Images(ListGames\PictureType)\Image())
;       iPicture=LoadImage(#PB_Any,findfile(*currentgame\Images(ListGames\PictureType)\Image()) )
;     EndIf
      
    If Not iPicture
      iPicture=CopyImage(imgQuestionmark,#PB_Any)
    EndIf
  
  
    If iPicture
      SizeImageBox(iPicture,scr_width,scr_height)
    EndIf
  Else
    iPicture=CopyImage(imgClose,#PB_Any)
    SizeImageBox(iPicture,scr_width/3,scr_height/3)
  EndIf
  
  
  Resize()
  
EndProcedure

Procedure.s exoDosFile(file.s)
  If FileSize(file)>0
    ProcedureReturn GetCurrentDirectory()+file
  Else
    ProcedureReturn config\eXoDOSpath+file
  EndIf
EndProcedure


Procedure updateGame(*currentgame.sGame)
  SetGadgetText(gTitle,*currentgame\Title)
  
  removeImage(iBanner)
  
  If FirstElement(*currentgame\Images("Banner")\Image())
    iBanner=LoadImage(#PB_Any, findfile(*currentgame\Images("Banner")\Image()) )
  EndIf
  
  If iBanner=#Null
    Protected w,h
    iBanner=CreateImage(#PB_Any,10,10,24,#PB_Image_Transparent)
    StartDrawing(ImageOutput(iBanner))
    DrawingFont(FontID(fbig))
    w=TextWidth(*currentgame\Title)
    h=TextHeight(*currentgame\Title)
    StopDrawing()
    ResizeImage(iBanner,w,h)
    StartDrawing(ImageOutput(iBanner))
    DrawingFont(FontID(fbig))
    DrawingMode(#PB_2DDrawing_AllChannels )
    DrawText(0,0,*currentgame\Title,RGBA(255,255,255,255),0)
    StopDrawing()
  EndIf
  
  If iBanner And ImageWidth(iBanner)>sidewidth-10
    SizeImageWidth(iBanner,sidewidth-10) 
  EndIf
  
  FirstElement(*currentgame\Images(ListGames\PictureType)\Image())
  updatePicture(*currentgame)
  
  Protected text.s=""
  ForEach *currentgame\AlternateTitle()
    If ListIndex(*currentgame\AlternateTitle())=0
      text+"aka "
    Else
      text+", "
    EndIf
    text+*currentgame\AlternateTitle()
  Next  
  If text<>""
    text+#LF$+#LF$
  EndIf
  
  SetGadgetText(gNote,text + *currentgame\Notes)
  
  
  FreeHyperlink()
  OpenGadgetList(gContainer)  
  
  If *currentgame\Developer
    AddHyperlink(*currentgame\Developer,#hl_developer,*currentgame\Developer,#True)
  EndIf
  If *currentgame\Publisher
    AddHyperlink(*currentgame\Publisher,#hl_publisher,*currentgame\Publisher,#True)
  EndIf
  If *currentgame\ReleaseDate
    AddHyperlink(*currentgame\ReleaseDate,#hl_ReleaseDate,*currentgame\ReleaseDate,#True)
  EndIf
  If *currentgame\Source
    AddHyperlink(*currentgame\Source,#hl_Source,*currentgame\Source,#True)
  EndIf
  
  
  Protected c,i
  If *currentgame\Genre
    c=CountString(*currentgame\Genre,";")
    For i=1 To c+1
      text=Trim(StringField(*currentgame\Genre,i,";"))
      AddHyperlink(text,#hl_genre,text,#True)
    Next
  EndIf
  
  If *currentgame\Series
    c=CountString(*currentgame\Series,";")
    For i=1 To c+1
      text=Trim(StringField(*currentgame\Series,i,";"))
      AddHyperlink(text,#hl_Series,text,#True)
    Next
  EndIf
  
  
  
  If *currentgame\WikipediaURL<>""
    AddHyperlink("Wikipedia",#hl_open,*currentgame\WikipediaURL)
  EndIf
  
  If *currentgame\VideoUrl<>""
    AddHyperlink("YouTube",#hl_open,*currentgame\VideoUrl)
  EndIf
  
  If *currentgame\MoviePath<>""
    AddHyperlink("Gameplay Movie",#hl_open,findfile(*currentgame\MoviePath) )
  EndIf
  
  If *currentgame\ManualPath<>""
    AddHyperlink("Manual",#hl_open,findfile(*currentgame\ManualPath) )
  EndIf
  
  ForEach *currentgame\Extras()
    AddHyperlink(GetFilePart(*currentgame\Extras()),#hl_open,exoDosFile(*currentgame\Extras()))    
  Next
  CloseGadgetList()
  
  Resize()
  
  SetGadgetAttribute(gContainer,#PB_ScrollArea_X,0)
  SetGadgetAttribute(gContainer,#PB_ScrollArea_Y,0)
  
  
  updateMusic(*currentgame)
  
  Protected symbol.s=""
  If sSound 
    symbol="♫ WAV ♫ - "
  ElseIf sMovie
    symbol="♫ MP3 ♫ - "
  ElseIf sMusic 
    symbol="♫ MOD ♫ - "
  EndIf
  
  If *currentgame\eXoID=""
    SetGadgetText(gStart,"Open")
  ElseIf *currentgame\installedEnglish Or *currentgame\installedGerman
    SetGadgetText(gStart,"Play")
  Else
    SetGadgetText(gStart,"Install")
  EndIf
  
  
  SetWindowTitle(mainwindow,#title+" - "+symbol+*currentgame\Title)
  
EndProcedure
;}




;-
;-{ window
;-
Procedure CreateWindow()
  mainwindow = OpenWindow(#PB_Any,config\window\x,config\window\y,config\window\w,config\window\h,#title,#PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_Invisible)
  If config\window\maximize
    SetWindowState(mainwindow,#PB_Window_Maximize)
  EndIf
  
  WindowBounds(mainwindow,800,400,#PB_Default,#PB_Default)
  
  
  moviewindow = OpenWindow(#PB_Any,0,0,10,10,#title+" Movie",#PB_Window_Invisible|#PB_Window_NoActivate|#PB_Window_NoGadgets,WindowID(mainwindow))
  SetWindowColor(mainwindow,RGB(30,30,30))
   sidewidth=400
   scr_width=sidewidth-10
   scr_height=scr_width*3/4
  
   sbar_width= GetSystemMetrics_(#SM_CXVSCROLL)
   sidewidthout=sidewidth+sbar_width
  
   gContainer=ScrollAreaGadget(#PB_Any,0,0,0,0,sidewidth,100,100,#PB_ScrollArea_BorderLess)
  SetGadgetColor(gContainer,#PB_Gadget_BackColor,#Black)
  
   gBanner=ImageGadget(#PB_Any,0,0,10,10,0)
   iBanner=#Null
  
   gPicture=ImageGadget(#PB_Any,0,0,10,10,0)
   iPicture=#Null
  
   gTitle=TextGadget(#PB_Any,0,0,0,0,"",#PB_Text_Center)
  SetGadgetColor(gTitle,#PB_Gadget_BackColor,#Black)
  SetGadgetColor(gTitle,#PB_Gadget_FrontColor,#White)
  SetGadgetFont(gTitle,FontID(fBig))
  
   gNote=EditorGadget(#PB_Any,0,0,10,10,#PB_Editor_ReadOnly|#PB_Editor_WordWrap)
  SetGadgetColor(gNote,#PB_Gadget_BackColor,#Black)
  SetGadgetColor(gNote,#PB_Gadget_FrontColor,#White)
  
  SetWindowTheme_(GadgetID(gNote), @"", @"")
  SetWindowLongPtr_(GadgetID(gNote), #GWL_EXSTYLE, 0)
  SetWindowPos_(GadgetID(gNote), 0, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE | #SWP_FRAMECHANGED)
  
   gStart=ButtonGadget(#PB_Any,0,0,0,0,"Play")
   gConfig=ButtonGadget(#PB_Any,0,0,0,0,"☰")
  SetGadgetFont(gStart,FontID(fBig))
  SetGadgetFont(gConfig,FontID(fBig))
  ResizeGadget(gConfig,#PB_Ignore,#PB_Ignore,GadgetWidth(gConfig,#PB_Gadget_RequiredSize),GadgetHeight(gConfig,#PB_Gadget_RequiredSize))
  ResizeGadget(gStart,#PB_Ignore,#PB_Ignore,10,GadgetHeight(gStart,#PB_Gadget_RequiredSize))
  
  
   gOptScr=HyperLinkGadget(#PB_Any,0,0,sidewidth/5,10,"Game",#White)
   gOptBox=HyperLinkGadget(#PB_Any,0,0,sidewidth/5,10,"Box",#White)
   gOptAd=HyperLinkGadget(#PB_Any,0,0,sidewidth/5,10,"Advertisement",#White)
   gOptDisk=HyperLinkGadget(#PB_Any,0,0,sidewidth/5,10,"Disc",#White)
   gOptFan=HyperLinkGadget(#PB_Any,0,0,sidewidth/5,10,"Fanart",#White)
  Macro setoption(g)
    ResizeGadget(g,#PB_Ignore,#PB_Ignore,GadgetWidth(g,#PB_Gadget_RequiredSize),GadgetHeight(g,#PB_Gadget_RequiredSize))
    SetGadgetColor(g,#PB_Gadget_BackColor,#Black)
    SetGadgetColor(g,#PB_Gadget_FrontColor,RGB(180,180,180))
  EndMacro
  setoption(gOptScr)
  setoption(gOptBox)
  setoption(gOptAd)
  setoption(gOptDisk)
  setoption(gOptFan)
  SetGadgetState(gOptScr,#True)
  
  
  CloseGadgetList()
  
   glist=CanvasGadget(#PB_Any,0,0,100,100,#PB_Canvas_Keyboard)  
EndProcedure
Procedure Resize()
  Protected x,y=5
  Protected w,h
  
  ResizeGadget(gContainer,WindowWidth(mainwindow)-sidewidthout,0,sidewidthout,WindowHeight(mainwindow))
  
  If iBanner
    w=ImageWidth(iBanner)
    h=ImageHeight(iBanner)
    SetGadgetState(gBanner,ImageID(iBanner))
    ResizeGadget(gBanner,(sidewidth-w)/2,y,w,h)  
    HideGadget(gBanner,#False)      
    y+(h+10)
    HideGadget(gTitle,#True)
  Else
    SetGadgetState(gBanner,#Null)
    HideGadget(gBanner,#True)
    h=GadgetHeight(gTitle,#PB_Gadget_RequiredSize)
    ResizeGadget(gTitle,0,y,sidewidth,h)
    y+(h+10)
    HideGadget(gTitle,#False)
  EndIf
  
  x=5
  ResizeGadget(gOptScr,x,y,#PB_Ignore,#PB_Ignore)
  x+GadgetWidth(gOptScr)+5
  ResizeGadget(gOptBox,x,y,#PB_Ignore,#PB_Ignore)
  x+GadgetWidth(gOptBox)+5
  ResizeGadget(gOptAd,x,y,#PB_Ignore,#PB_Ignore)
  x+GadgetWidth(gOptAd)+5
  ResizeGadget(gOptDisk,x,y,#PB_Ignore,#PB_Ignore)
  x+GadgetWidth(gOptDisk)+5
  ResizeGadget(gOptFan,x,y,#PB_Ignore,#PB_Ignore)
  x+GadgetWidth(gOptFan)+5
  
  
  y+GadgetHeight(gOptScr)
  
  If iPicture
    w=ImageWidth(iPicture)
    h=ImageHeight(iPicture)
    SetGadgetState(gPicture,ImageID(iPicture))
    ResizeGadget(gPicture,(sidewidth-w)/2,y,w,h)
    HideGadget(gPicture,#False)
    y+(h+5)
  Else
    SetGadgetState(gPicture,#Null)
    HideGadget(gPicture,#True)
    y+10
  EndIf
  
  
  ResizeGadget(gConfig,sidewidth-GadgetWidth(gConfig)-5,y,#PB_Ignore,#PB_Ignore)
  ResizeGadget(gStart,5,y,sidewidth-GadgetWidth(gConfig)-15,#PB_Ignore)
  y+(GadgetHeight(gStart)+5)  
  
  ResizeGadget(gNote,5,y,sidewidth-10,200)
  
  y+205
  
  x=5
  ForEach Hyperlink()
    w=sidewidth-10
    If HyperLink()\short
      w=GadgetWidth(HyperLink()\gadget,#PB_Gadget_RequiredSize)
    EndIf
    h=GadgetHeight(Hyperlink()\gadget)
    If x+w >= sidewidth
      x=5
      y+h
    EndIf
    ResizeGadget(Hyperlink()\gadget,x,y,w,#PB_Ignore)
    x+w+5    
  Next
  y+5+h
  
  ResizeGadget(glist,0,0,WindowWidth(mainwindow)-sidewidthout,WindowHeight(mainwindow))  
  DrawList()
  
  SetGadgetAttribute(gContainer,#PB_ScrollArea_InnerHeight,y)
  SetGadgetAttribute(gContainer,#PB_ScrollArea_InnerWidth,sidewidth)
  
  
EndProcedure
Procedure checkWindowPos(x,y,w,h)
  Dim co(3,2)
  co(0,0)=x
  co(0,1)=y
  co(0,2)=#False
  co(1,0)=x+w-1
  co(1,1)=y
  co(1,2)=#False
  co(2,0)=x+w-1
  co(2,1)=y+h-1
  co(2,2)=#False
  co(3,0)=x
  co(3,1)=y+h-1
  co(3,2)=#False
    
  Protected i,c,count=ExamineDesktops()
  Protected x1,y1,x2,y2
  For i=0 To count-1
    x1=DesktopX(i)
    y1=DesktopY(i)
    x2=x1+DesktopWidth(i)-1
    y2=y1+DesktopHeight(i)-1
    For c=0 To 3
      If x1<= co(c,0) And co(c,0)<=x2 And y1<= co(c,1) And co(c,1)<=y2
        co(c,2)=#True
      EndIf
    Next
  Next
  ProcedureReturn Bool( co(0,2) And co(1,2) And co(2,2) And co(3,2) )
EndProcedure
      
  
  
  
  
;}

;-
;-
;-






Procedure.s GetGameOffset(*game.sGame,offset,sort=#False)
  Select offset
    Case #offset_adult
      If *game\isAdult
        ProcedureReturn "X"
      Else
        ProcedureReturn " "
      EndIf
    Case #offset_german
      If *game\hasGerman
        ProcedureReturn "X"
      Else
        ProcedureReturn " "
      EndIf
    Case #offset_favorite
      If favorite(*game\ID)
        ProcedureReturn "X"
      Else
        ProcedureReturn " "
      EndIf
    Case #offset_installed
      If *game\installedEnglish Or *game\installedGerman
        ProcedureReturn "X"
      Else
        ProcedureReturn " "
      EndIf
    Case #offset_title
      If sort
        ProcedureReturn *game\SortTitle
      Else
        ProcedureReturn *game\Title
      EndIf
    Case #offset_developer
      ProcedureReturn *game\Developer
    Case #offset_publisher
      ProcedureReturn *game\Publisher
    Case #offset_releasedate
      ProcedureReturn *game\ReleaseDate
    Case #offset_series
      If sort
        ProcedureReturn *game\SortSeries
      Else
        ProcedureReturn *game\Series
      EndIf
    Case #offset_genre
      ProcedureReturn *game\Genre
    Case #offset_source
      ProcedureReturn *game\Source
  EndSelect
  ProcedureReturn "?"
EndProcedure





Declare ListEntryVisible()

Procedure CreateGameList()
  SelectElement(ListGames\lgames(),ListGames\selected)
  Protected *game.sGame = #Null
  If ListIndex(ListGames\lgames())>=0 
    *game= ListGames\lgames()\game    
  EndIf
  
  
  ClearList(ListGames\lgames())
  ForEach games()
    Protected filterd=#False
    
    ForEach listgames\header()
      If listgames\header()\filter <> "" 
        If ListGames\header()\offset=#offset_title
          Protected found=#False
          
          ForEach games()\AlternateTitle()
            If FindString(games()\AlternateTitle(),ListGames\header()\filter,0,#PB_String_NoCase)>0
              found=#True
              Break
            EndIf
          Next
          If found=#False And FindString(games()\Title,ListGames\header()\filter,0,#PB_String_NoCase)<=0
            filterd=#True
            Break
          EndIf
          
        Else
          If FindString(GetGameOffset(@games(),ListGames\header()\offset),ListGames\header()\filter,0,#PB_String_NoCase)<=0
            filterd=#True
            Break
          EndIf
        EndIf
      EndIf
    Next    
    
    
    
    If filterd=#False
      AddElement(ListGames\lgames())
      ListGames\lgames()\game=@games()
      ListGames\lgames()\sort=GetGameOffset(@games(),ListGames\offset,#True)+"|"+games()\SortTitle
    EndIf
  Next  
  SortStructuredList(ListGames\lgames(),ListGames\sort|#PB_Sort_NoCase,OffsetOf(slist\sort),#PB_String)  
  
  ForEach ListGames\lgames()
    If ListGames\lgames()\game = *game
      ListGames\selected=ListIndex(ListGames\lgames())
      ListEntryVisible()
      Break
    EndIf
  Next
  
EndProcedure






Procedure ListEntryVisible()
  ListGames\position=max(ListGames\selected-ListGames\entriesVisible+2,min(ListGames\selected-1,ListGames\position))
EndProcedure

Structure sImageCache
  time.i
  gameid.s
  imgid.i
EndStructure

Global NewList imageCache.sImageCache()
Global mutexImage=CreateMutex()

Structure stoloadImage
  file.s
  *imageCache.sImageCache
  gameid.s
EndStructure
Global NewList imageToLoad.stoloadImage()

#event_imageloaded = #PB_Event_FirstCustomValue
Global limitload
Global drawlist_needed
Global CanClearImageToLoad

Procedure thread_imageloadCache(*value)
  Protected *entry.stoloadImage
  Protected count=0
  Repeat
    If ListSize(imageToLoad())>0
      LockMutex(mutexImage)
      
      *entry=#Null
      ForEach imageToLoad()
        If imageToLoad()\imageCache\time>=limitload 
          *entry = @imageToLoad()
          Break
        EndIf
      Next
      CanClearImageToLoad = Bool( *entry=#Null )
      
      UnlockMutex(mutexImage)
      
      If *entry
        
        Protected img=LoadImage(#PB_Any, findfile(*entry\file) )
        If img=#Null
          img=imgQuestionmark
        EndIf
        
        LockMutex(mutexImage)
        *entry\imageCache\imgid=img    
        ChangeCurrentElement(imageToLoad(), *entry)
        DeleteElement(imageToLoad())      
        CanClearImageToLoad = Bool( ListSize(imageToLoad())=0 )
        UnlockMutex(mutexImage)      
        
        PostEvent(#event_imageloaded)
        
      Else
        Delay(1)
      EndIf
      
      
    Else
      
      Delay(1)
    EndIf
  ForEver
EndProcedure

Procedure ClearUnloadedBoxArt()
  LockMutex(mutexImage)
  If CanClearImageToLoad
    ClearList(imageToLoad())
    ForEach imageCache()
      If imageCache()\imgid=#Null 
        DeleteElement(imageCache())
      EndIf
    Next
    CanClearImageToLoad=#False
  EndIf
  
  UnlockMutex(mutexImage)
EndProcedure

Procedure LimitLoadedBoxArt()
  LockMutex(mutexImage)
  limitload=ElapsedMilliseconds()
  UnlockMutex(mutexImage)
EndProcedure


    
Procedure LoadBoxArt(*game.sGame)
  Protected file.s=""
  
  LockMutex(mutexImage)
  Protected img
  ForEach imageCache()
    If imageCache()\gameid = *game\ID
      imageCache()\time=ElapsedMilliseconds()
      img=imageCache()\imgid
       
      
      If img And img<>imgQuestionmark And (ImageWidth(img)>config\BoxArt\width Or ImageHeight(img)>config\BoxArt\height)
        SizeImageBox(img,config\BoxArt\width,config\BoxArt\height)
        If config\BoxArtCache          
          SaveImage(img,"BoxArt.Cache\"+ *game\id +".png",#PB_ImagePlugin_PNG)
        EndIf
      EndIf
      UnlockMutex(mutexImage)     
      
      ProcedureReturn img 
    EndIf
    
  Next
  
   While ListSize(imageCache())>config\maxBoxArt    
     Protected *oldest=#Null,oldtime=ElapsedMilliseconds()
     ForEach imageCache()      
       If imageCache()\imgid<>0 And imageCache()\time<oldtime
         *oldest=imageCache()
         oldtime=imageCache()\time
       EndIf      
     Next
     
     If *oldest
       ChangeCurrentElement(imageCache(),*oldest)
       DeleteElement(imageCache())
     Else
       Break
     EndIf    
   Wend
  
  
  UnlockMutex(mutexImage)
  
  
  
  LockMutex(mutexImage)
  AddElement(imageCache())
  imageCache()\gameid=*game\ID  
  imageCache()\time=ElapsedMilliseconds()
  
  file="BoxArt.Cache\"+*game\ID+".png"
  img=#Null
  If FileSize(file)>0 
    img=LoadImage(#PB_Any,file)
    If img 
      imageCache()\imgid=img        
   EndIf
  EndIf  
  
  If img=#Null  
    If FirstElement(*game\Images("Box 3D")\Image() )
      file=*game\Images("Box 3D")\Image()
    ElseIf FirstElement(*game\Images("Box")\Image() )
      file=*game\Images("Box")\Image()
    ElseIf FirstElement(*game\Images("Screenshot")\Image() )
      file=*game\Images("Screenshot")\Image()
    EndIf 
    
    AddElement(imageToLoad())
    imageToLoad()\file=file
    imageToLoad()\imageCache=@imageCache()
    imageToLoad()\gameid=*game\ID
    
  EndIf
  
  UnlockMutex(mutexImage)
  
  ProcedureReturn img
  
EndProcedure


Procedure DrawList()
  drawlist_needed=#False
  ListGames\position=max(0,min(ListSize(ListGames\lgames())-ListGames\entriesVisible,ListGames\position))
  
  ClearUnloadedBoxArt()
  LimitLoadedBoxArt()
  
  ClearList(hotlist())
  AddHotlist(-1,-1,-1,-1,#action_none,0)
  If StartDrawing(CanvasOutput(glist))
        
    Protected w=OutputWidth(),h=OutputHeight()
    Protected x,y
    Protected mx=GetGadgetAttribute(glist,#PB_Canvas_MouseX),my=GetGadgetAttribute(glist,#PB_Canvas_MouseY)
    Static oldx,oldy
    If mx=0 And my=0
      mx=oldx
      my=oldy
    Else
      oldx=mx
      oldy=my
    EndIf
    
    
    DrawingMode(#PB_2DDrawing_Gradient)    
    BackColor(RGB(30,30,30))
    FrontColor(RGB(40,40,40))
    LinearGradient(0,0,OutputWidth(),OutputHeight())
    Box(0,0,w,h)
    
    
    ;DrawingFont(FontID(fnormal))
    DrawingMode(#PB_2DDrawing_Transparent )
    
    Protected th=TextHeight("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")+2
    ListGames\entryHeight=th+2
    ListGames\headerSize=th*2+2+5
    
    If ImageWidth(imgHeart)>th-2 Or ImageHeight(imgHeart)>th*2
      SizeImageBox(imgHeart,th-2,th*2)
    EndIf
    If ImageWidth(imgEnglish)>th-2 Or ImageHeight(imgEnglish)>th*2
      SizeImageBox(imgEnglish,th-2,th*2)
    EndIf
    If ImageWidth(imgGerman)>th-2 Or ImageHeight(imgGerman)>th*2
      SizeImageBox(imgGerman,th-2,th*2)
    EndIf
    
    
    Protected size
    x=5
    ForEach ListGames\header()      
      y=5            
      size=ListGames\header()\size
      
      Protected symbol.s=""
      If ListGames\header()\offset = ListGames\offset
        If ListGames\sort=#PB_Sort_Ascending
          symbol.s="⮝"
        Else
          symbol.s="⮟"
        EndIf
      EndIf
      
      ListGames\header()\PXStart=x
      If x<w-sbar_width-10      
        AddHotlist(x,y,min(w-sbar_width-1,x+size-1),y+th-1,#action_header,ListIndex(ListGames\header()))
      EndIf
      ClipOutput(x,y,ListGames\header()\size,th)
      If mx>=x And mx<=min(w-sbar_width-1,x+size-1) And my>=y And my<=y+th-1
        FrontColor(RGB(60,60,60))
        BackColor(RGB(50,50,50))
        DrawingMode(#PB_2DDrawing_Gradient)
        Box(x,y,size,y+th)
        DrawingMode(#PB_2DDrawing_Transparent )
      EndIf
            
      DrawText(x,y,ListGames\header()\text+symbol,#White)
      y+th+1
      
      Protected off
      If x<w-sbar_width-10
        AddHotlist(x,y,min(w-sbar_width-1,x+size-1),y+th-1,#action_edit,ListIndex(ListGames\header()))
      EndIf
      ClipOutput(x,y,size,th)
      Box(x,y,size,th,#Black)
      off=DrawText(x,y,ListGames\header()\filter,RGB(180,180,180))
      If ListIndex(ListGames\header())=ListGames\keyboarfocus And GetActiveGadget()=glist
        Box(x+off,y,4,th,#Yellow)
      EndIf
      y+th+1
      
      
      If config\ListView=#listview_detail ;-- detail
        SelectElement(ListGames\lgames(),ListGames\position)
        
        Protected count=(h-ListGames\headerSize-5)/(th+2)
        ListGames\entriesVisible=count
        ListGames\entriesLines=1
        ;background
        
        If ListIndex(ListGames\header())=0 
          DrawingMode(#PB_2DDrawing_Gradient)      
          UnclipOutput()
          
          Protected dy=y
          Protected c=ListGames\position 
          While dy<h And count>0
            If c<ListSize(ListGames\lgames())
              AddHotlist(0,dy,w-sbar_width-1,dy+th,#action_entry,c)
              
              If ListGames\selected=c
                FrontColor(RGB(0,0,80))
                BackColor(RGB(0,0,70))
              ElseIf ListGames\drag=#drag_none And mx>=0 And mx<=w-sbar_width-1 And my>=dy And my<=dy+th
                FrontColor(RGB(60,60,60))
                BackColor(RGB(50,50,50))
              ElseIf c%2
                FrontColor(RGB(30,30,30))
                BackColor(RGB(40,40,40))
              Else
                FrontColor(RGB(20,20,20))
                BackColor(RGB(30,30,30))
              EndIf
              Box(x,dy+1,w-sbar_width,th+1)
            EndIf
            c+1
            dy+th+2
            count-1
          Wend
          
          
          
          DrawingMode(#PB_2DDrawing_Transparent )
        EndIf
        
        ;list
        count=ListGames\entriesVisible
        
        Protected text.s
        While ListIndex(ListGames\lgames())>=0 And y<h And count>0
          ClipOutput(x,y,ListGames\header()\size,th)
          If ListGames\header()\offset=#offset_series
            text=ListGames\lgames()\game\SortSeries
          Else
            text=GetGameOffset(ListGames\lgames()\game,ListGames\header()\offset)
          EndIf
          
          Protected xx
          If text<>"" 
            If ListGames\header()\offset=#offset_installed
              xx=x
              If ListGames\lgames()\game\installedEnglish And ListGames\lgames()\game\installedGerman
                xx+(ListGames\header()\size-ImageWidth(imgEnglish)-2-ImageWidth(imgGerman))/2
              ElseIf ListGames\lgames()\game\installedEnglish
                xx+(ListGames\header()\size-ImageWidth(imgEnglish))/2
              ElseIf ListGames\lgames()\game\installedGerman
                xx+(ListGames\header()\size-ImageWidth(imgGerman))/2
              EndIf
              
              If ListGames\lgames()\game\installedEnglish               
                DrawAlphaImage(ImageID(imgEnglish),xx,y+(th-ImageHeight(imgEnglish))/2)
                xx+ImageWidth(imgEnglish)+2
              EndIf
              If ListGames\lgames()\game\installedGerman
                DrawAlphaImage(ImageID(imgGerman),xx,y+(th-ImageHeight(imgGerman))/2)
                xx+ImageWidth(imgGerman)+2
              EndIf
              
            ElseIf ListGames\header()\offset=#offset_german
              If text="X"
                DrawAlphaImage(ImageID(imgGerman),x+(ListGames\header()\size-ImageWidth(imgGerman))/2,y+(th-ImageHeight(imgGerman))/2)
              EndIf
              
            ElseIf ListGames\header()\offset=#offset_favorite
              If text="X"
                DrawAlphaImage(ImageID(imgHeart),x+(ListGames\header()\size-ImageWidth(imgHeart))/2,y+(th-ImageHeight(imgHeart))/2)
              EndIf
            Else
              
              If ListGames\lgames()\game\installedEnglish Or ListGames\lgames()\game\installedGerman
                c=color\listEntryInstalled
              Else
                c=color\listEntry
              EndIf
              DrawText(x,y+1,text,c)
            EndIf
          EndIf
          
          If Not NextElement(ListGames\lgames())
            Break
          EndIf
          y+th+2
          count-1
        Wend
        
      EndIf
      
      x+ListGames\header()\size
      
      AddHotlist(x,5,x+4,5+ListGames\headerSize,#action_headerSize,ListIndex(ListGames\header()))
      
      x+5
      
    Next
    
    
    
    If config\ListView=#listview_boxart;-- boxview
      
      UnclipOutput()
      DrawingMode(#PB_2DDrawing_Transparent )
      
      Protected ww,hh,bw,bh
      ww=w-sbar_width
      hh=h-ListGames\headerSize
      bw=ww/(config\BoxArt\width+10)
      bh=hh/(config\BoxArt\height+10)
      
      count=bw*bh
      
      ListGames\entriesVisible=count
      ListGames\entriesLines=bw
      
      y=ListGames\headerSize
      x=(ww-(bw * (config\BoxArt\width+10)))/2
      y=ListGames\headerSize + (hh-(bh * (config\BoxArt\height+10)))/2
      Protected pos=(ListGames\position / bw)*bw
      SelectElement(ListGames\lgames(),pos)
      pos=pos%bw
      
      Protected hotx,hoty,hottxt.s
      
      While ListIndex(ListGames\lgames())>=0 And y<h And count>0
        
        xx=x+pos*(config\BoxArt\width+10)
        ClipOutput(xx,y,config\BoxArt\width+10,config\BoxArt\height+10)
        
        If ListGames\selected=ListIndex(ListGames\lgames())
          DrawingMode(#PB_2DDrawing_Gradient)
          FrontColor(RGB(0,0,80))
          BackColor(RGB(0,0,70))
          Box(xx,y,config\BoxArt\width+10,config\BoxArt\height+10)
          DrawingMode(#PB_2DDrawing_Transparent )
        ElseIf ListGames\drag=#drag_none And mx>=xx And mx<xx+config\BoxArt\width+10 And my>=y And my<y+config\BoxArt\height+10
          DrawingMode(#PB_2DDrawing_Gradient)
          FrontColor(RGB(60,60,60))
          BackColor(RGB(50,50,50))
          Box(xx,y,config\BoxArt\width+10,config\BoxArt\height+10)
          DrawingMode(#PB_2DDrawing_Transparent )
        EndIf
        
        If mx>=xx And mx<xx+config\BoxArt\width+10 And my>=y And my<y+config\BoxArt\height+10
          hotx=xx+config\BoxArt\width / 2+5
          hoty=y+config\BoxArt\height+10
          hottxt=ListGames\lgames()\game\Title          
        EndIf
        
        AddHotlist(xx,y,xx+config\BoxArt\width+9,y+config\BoxArt\height+9,#action_entry,ListIndex(ListGames\lgames()))
        
        Protected img=LoadBoxArt(ListGames\lgames()\game)
        If img=0 
          img=imgLoading
        EndIf        
        
        DrawAlphaImage(ImageID(img),xx+ (config\BoxArt\width+10 - ImageWidth(img))/2, y+(config\BoxArt\height+10-ImageHeight(img))/2)
        
        Protected dx=xx+5
        If favorite(ListGames\lgames()\game\id)
          DrawAlphaImage(ImageID(imgHeart),dx,y+5)
          dx+ImageWidth(imgHeart)+5
        EndIf
        If ListGames\lgames()\game\installedEnglish
          DrawAlphaImage(ImageID(imgEnglish),dx,y+5)
          dx+ImageWidth(imgEnglish)+5
        EndIf
        If ListGames\lgames()\game\installedGerman
          DrawAlphaImage(ImageID(imgGerman),dx,y+5)
          dx+ImageWidth(imgGerman)+5
        EndIf
        
                
        count-1
        pos=(pos + 1)% bw
        If pos=0
          y+config\BoxArt\height+10
        EndIf
        If NextElement(ListGames\lgames())=0
          Break
        EndIf
      Wend
      
      If hottxt<>""
        
        UnclipOutput()
        
        ww=TextWidth(hottxt)
        hh=TextHeight(hottxt)
        xx=min(w-sbar_width,max(0,hotx-ww/2))
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        Box(xx-2,hoty-hh-2,ww+4,hh+4,RGBA(0,0,0,150))
        DrawingMode(#PB_2DDrawing_Transparent )
        For dx=-1 To 1 Step 2
          DrawText(xx+dx,hoty-hh,hottxt,#Black)
          DrawText(xx,hoty-hh+dx,hottxt,#Black)
        Next
        DrawText(xx,hoty-hh,hottxt,#White)
        
        
      EndIf
      
      
    EndIf
  
    UnclipOutput()
    
    DrawingMode(#PB_2DDrawing_Transparent )
    Box(w-sbar_width,0,sbar_width,h,RGB(30,30,30))
    ListGames\scrollbar_factor= (h-10)  / ListSize(ListGames\lgames())
    
    Protected yy
    If ListGames\entriesVisible >= ListSize(ListGames\lgames())
      hh=h-10
      yy=5
    Else    
      hh=max(4, ListGames\entriesVisible*ListGames\scrollbar_factor)
      yy=min(h-10-hh, ListGames\position*ListGames\scrollbar_factor)+5
    EndIf
    
    Protected col
    If ListGames\drag=#drag_sbar
      col=RGB(255,255,255)
    ElseIf ListGames\drag=#drag_sbarDown Or ListGames\drag=#drag_sbarUp
      col=RGB(200,200,200)
    ElseIf ListGames\drag=#drag_none And mx>=w-sbar_width And mx<=w 
      If my<yy Or my>=yy+hh
        col=RGB(100,100,100)
      Else
        col=RGB(150,150,150)
      EndIf
    Else
      col=RGB(50,50,50)
    EndIf
    
    
    RoundBox(w-sbar_width+4,yy,sbar_width-8,hh,(sbar_width-8)/2, (sbar_width-8)/3,col)
    AddHotlist(w-sbar_width,    0,  w,yy-1   ,#action_scrollbar,0)
    AddHotlist(w-sbar_width,   yy,  w,yy+hh-1,#action_scrollbar,1)
    AddHotlist(w-sbar_width,yy+hh,  w,h      ,#action_scrollbar,2)
    
    StopDrawing()
  EndIf 
EndProcedure


;-
;-{ Musik
;-

Procedure unloadMusic()
  If sSound
    StopSound(sSound)
    FreeSound(sSound)
    sSound=#Null
  EndIf
  If sMovie
    StopMovie(sMovie)
    FreeMovie(sMovie)
    sMovie=#Null
  EndIf
  If sMusic
    StopMusic(sMusic)
    FreeMusic(sMusic)
    sMusic=#Null
  EndIf
EndProcedure
Procedure updateMusic(*currentgame.sGame)
  unloadMusic()
  
  If Config\volume\noSound
    ProcedureReturn #False
  EndIf
  
  Protected file.s= findfile(*currentgame\MusicPath)
  
  If *currentgame\MusicPath And FileSize(file)>0
    
    Select LCase(GetExtensionPart(file))
        
      Case "ogg","flac"    
        sSound=LoadSound(#PB_Any, file ,#PB_Sound_Streaming)
        
      Case "wav"    
        sSound=LoadSound(#PB_Any, file )
        
      Case "mp3","mp2"
        sMovie=LoadMovie(#PB_Any, file)
        
      Case "mod","amf","dsm","mo3","psm","s3m","sfx","xm"
        sMusic=LoadMusic(#PB_Any,file)
    EndSelect
    
    
    If sSound
      SoundVolume(sSound,config\volume\WAV)
      PlaySound(sSound,#PB_Sound_Loop)
      
    ElseIf sMovie
      MovieAudio(sMovie,config\volume\MP3,0)
      PlayMovie(sMovie,WindowID(moviewindow))
      
    ElseIf sMusic
      MusicVolume(sMusic,config\volume\MOD)
      PlayMusic(sMusic)
      
    EndIf
  EndIf 
  
EndProcedure

Procedure loopMusic()
  If sMovie
    If MovieStatus(smovie)=0
      PlayMovie(smovie,WindowID(moviewindow))
    EndIf
  EndIf
  
EndProcedure

Procedure pauseMusic()
  If sSound
    PauseSound(sSound)
  EndIf
  If sMovie
    PauseMovie(sMovie)
  EndIf
  If sMusic
    StopMusic(sMusic)
  EndIf
EndProcedure

Procedure resumeMusic()
  If sSound
    ResumeSound(sSound)
  EndIf
  If sMovie
    ResumeMovie(sMovie)
  EndIf
  If sMusic
    PlayMusic(sMusic)
  EndIf
EndProcedure  
;}







Structure sMenu
  id.i
  action.i
  value.s
EndStructure
Global NewList menu.sMenu()



Procedure _menuitem(text.s,action,value.s)
  AddElement(menu())
  menu()\id=ListIndex(menu())
  menu()\action=action
  menu()\value=value
  MenuItem(menu()\id,text)
  ProcedureReturn menu()\id
EndProcedure

Procedure popmenu(List values.s(),action,sep.s,onlymax)
  Protected mreturn=CreatePopupMenu(#PB_Any)
  Protected sub.s, lastsingle.s
  
  Protected forced
  ForEach values()
    Protected leftSide.s=Trim(StringField(values(),1,sep))
    Protected rightSide.s=Trim(StringField(values(),2,sep))
    
    If rightSide=""
      rightSide=leftSide
      forced=#False
      lastsingle=leftSide
    Else 
      forced=#True      
    EndIf
    
    If leftSide<>"Mission"
      
      If sub <> leftSide And sub<>""
        CloseSubMenu()
        sub=""
      EndIf
      
      If (forced ) And sub=""
        
        OpenSubMenu(leftSide)
        sub=leftSide
                        
        If leftSide<>rightSide
          _MenuItem(leftSide,action,leftSide)  
        EndIf
        
      EndIf
      
      
      If sub<>"" Or onlymax=#False
        _MenuItem(rightSide,action,values())  
      EndIf
    EndIf
    
  Next
  If sub
    CloseSubMenu()
  EndIf
  ProcedureReturn mreturn
EndProcedure

Procedure initPopupmenu()
  CreatePopupMenu(#PB_Any)
  Global popPlay=_menuitem("",#hl_play,"")
  Global popConfig=_menuitem("",#hl_config,"")
  Global popAlt=_menuitem("",#hl_alternateLauncher,"")
  
  Global popPlayGerman=_menuitem("",#hl_play,"!german\")
  Global popConfigGerman=_menuitem("",#hl_config,"!german\")
  Global popAltGerman=_menuitem("",#hl_alternateLauncher,"!german\")
  
  Global popViewDetails=_menuitem("",#hl_view,"Detail")
  Global popViewBoxArt=_menuitem("",#hl_view,"BoxArt")
  Global popEnglish=_menuitem("",#hl_none,"")
  Global popGerman=_menuitem("",#hl_none,"")
  Global popFavorite=_menuitem("",#hl_toogleFavorite,"")
  Global popIntroPic=_menuitem("",#hl_introPic,"")
  Global popIntroVideo=_menuitem("",#hl_introVideo,"")
  Global popNoMusic=_menuitem("",#hl_nomusic,"")
  Global popOpenGameFolder=_menuitem("",#hl_openGameFolder,"")
  Global popOpenGameFolderGerman=_menuitem("",#hl_openGameFolderGerman,"")
  Global popOpenNotGameFolder=_menuitem("",#hl_openNotGameFolder,"")
  Global popAutomaticMinimize=_menuitem("",#hl_AutomaticMinimize,"")
EndProcedure

Procedure DisplayGamePopup(*game.sgame,x=#PB_Ignore,y=#PB_Ignore)
  Static mpopup
  If mpopup
    FreeMenu(mpopup)
  EndIf
  
  mpopup=CreatePopupMenu(#PB_Any)
  
  If *game
    
    If *game\hasGerman
      MenuItem(popEnglish,"English")
      DisableMenuItem(mpopup,popEnglish,#True)
    EndIf
    
    If *game\eXoID=""
      MenuItem(popPlay,"Open")
      
    ElseIf *game\installedEnglish
      MenuItem(popPlay,"Play")
      MenuItem(popConfig,"Config/Deinstall")
      MenuItem(popAlt,"Alternate Launcher")
      
    Else
      MenuItem(popPlay,"Install and Play")
    EndIf
    
    If *game\hasGerman
      MenuBar()
      MenuItem(popGerman,"German")
      DisableMenuItem(mpopup,popGerman,#True)
      If *game\installedGerman
        MenuItem(popPlayGerman,"Play")
        MenuItem(popConfigGerman,"Config/Deinstall")
        MenuItem(popAltGerman,"Alternate Launcher")
        
      Else
        MenuItem(popPlayGerman,"Install and Play")
      EndIf
    EndIf
    MenuBar()
  
    MenuItem(popFavorite,"Favorite")
    SetMenuItemState(mpopup,popFavorite,favorite(*game\id))
    MenuBar()
  EndIf
  
  OpenSubMenu("View")
  MenuItem(popViewDetails,"List")
  MenuItem(popViewBoxArt,"Box Art")
  CloseSubMenu()
  
  
  
  If config\ListView=#listview_detail
    SetMenuItemState(mpopup,popViewDetails,#True)
  Else
    SetMenuItemState(mpopup,popViewBoxArt,#True)
  EndIf
  
  If x=#PB_Ignore Or y=#PB_Ignore
    DisplayPopupMenu(mpopup,WindowID(mainwindow))
  Else
    DisplayPopupMenu(mpopup,WindowID(mainwindow),x,y)
  EndIf
EndProcedure

Procedure DisplayGameStartPopup(*game.sgame,x=#PB_Ignore,y=#PB_Ignore)
  Static mpopup
  If mpopup
    FreeMenu(mpopup)
  EndIf
  
  mpopup=CreatePopupMenu(#PB_Any)
  
  If *game

    If *game\eXoID=""
      MenuItem(popPlay,"Open")      
    ElseIf *game\installedEnglish
      MenuItem(popPlay,"Play (english)")      
    Else
      MenuItem(popPlay,"Install and Play (english)")
    EndIf
    
    If *game\hasGerman
      If *game\installedGerman
        MenuItem(popPlayGerman,"Play (german)")
      Else
        MenuItem(popPlayGerman,"Install and Play (german)")
      EndIf
    EndIf
  EndIf
  
  If x=#PB_Ignore Or y=#PB_Ignore
    DisplayPopupMenu(mpopup,WindowID(mainwindow))
  Else
    DisplayPopupMenu(mpopup,WindowID(mainwindow),x,y)
  EndIf
EndProcedure


Procedure DisplayGameConfigPopup(*game.sgame,x=#PB_Ignore,y=#PB_Ignore)
  Static mpopup
  If mpopup
    FreeMenu(mpopup)
  EndIf
  
  mpopup=CreatePopupMenu(#PB_Any)
  
  If *game
    If *game\hasGerman
      MenuItem(popEnglish,"English")
      DisableMenuItem(mpopup,popEnglish,#True)
    EndIf
    
    If *game\eXoID=""
      MenuItem(popOpenNotGameFolder,"Open media folder")
      
    ElseIf *game\installedEnglish
      MenuItem(popConfig,"Config/Deinstall")
      MenuItem(popOpenGameFolder,"Open game folder")
      
    Else
      MenuItem(popPlay,"Install and Play")
    EndIf
    
    If *game\hasGerman
      MenuBar()
      MenuItem(popGerman,"German")
      DisableMenuItem(mpopup,popGerman,#True)
      If *game\installedGerman
        MenuItem(popConfigGerman,"Config/Deinstall")
        MenuItem(popOpenGameFolderGerman,"Open game folder")
        
      Else
        MenuItem(popPlayGerman,"Install and Play")
      EndIf
    EndIf
    MenuBar()
    MenuItem(popFavorite,"Favorite")
    SetMenuItemState(mpopup,popFavorite,favorite(*game\id))
    MenuBar()
  EndIf
  
  
  OpenSubMenu("View")
  MenuItem(popViewDetails,"List")
  MenuItem(popViewBoxArt,"Box Art")
  CloseSubMenu()
  OpenSubMenu("Intro")
  MenuItem(popIntroPic,"Picture")
  MenuItem(popIntroVideo,"Video")
  CloseSubMenu()
  MenuItem(popNoMusic,"Mute background music")
  MenuItem(popAutomaticMinimize,"Automatic minimize on game launch")
  
  SetMenuItemState(mpopup,popAutomaticMinimize,config\AutomaticMinimize)
  
  If config\nointro=1
    SetMenuItemState(mpopup,popIntroPic,#True)
  Else
    SetMenuItemState(mpopup,popIntroVideo,#True)
  EndIf
  
  SetMenuItemState(mpopup,popNoMusic, config\volume\noSound)
      
  If config\ListView=#listview_detail
    SetMenuItemState(mpopup,popViewDetails,#True)
  Else
    SetMenuItemState(mpopup,popViewBoxArt,#True)
  EndIf
  
  If x=#PB_Ignore Or y=#PB_Ignore
    DisplayPopupMenu(mpopup,WindowID(mainwindow))
  Else
    DisplayPopupMenu(mpopup,WindowID(mainwindow),x,y)
  EndIf
EndProcedure

Procedure ScanInstalled()
  Protected pfad.s=config\eXoDOSpath
  If config\localInstall
    pfad=""
  EndIf
  
  NewMap installedEnglish()
  NewMap installedGerman()
  
  Protected phase,dir
  For phase=1 To 2    
    dir=ExamineDirectory(#PB_Any,pfad+"eXo\eXoDOS"+StringField("|\!german",phase,"|"),"*" )
     If dir
      While NextDirectoryEntry(dir)
        If DirectoryEntryType(dir)=#PB_DirectoryEntry_Directory
          If phase=1
            installedEnglish(DirectoryEntryName(dir))=#True
          Else
            installedGerman(DirectoryEntryName(dir))=#True
          EndIf
          
        EndIf
      Wend
      FinishDirectory(dir)
    EndIf
  Next
    
  ForEach games()
    games()\installedEnglish=installedEnglish( games()\eXoID )
    games()\installedGerman=installedGerman( games()\eXoID )
  Next
  
      
EndProcedure

; Procedure isInstalledEnglish(*game.sGame)
;   Protected pfad.s=config\eXoDOSpath
;   If config\localInstall
;     pfad=""
;   EndIf
;   
;   ProcedureReturn Bool( *game\eXoID<>"" And (FileSize( pfad+"eXo\eXoDOS\"+*game\eXoID)=-2 Or FileSize( pfad+"eXo\eXoDOS\!german\"+*game\eXoID)=-2 ) )
; EndProcedure

; Procedure IsInstalledLanguage(*game.sgame,lan.s)
;   Protected pfad.s=config\eXoDOSpath
;   If config\localInstall
;     pfad=""
;   EndIf
;   If lan
;     ProcedureReturn Bool( *game\eXoID<>"" And FileSize( pfad+"eXo\eXoDOS\"+lan+*game\eXoID)=-2 )
;   Else
;     ProcedureReturn Bool( *game\eXoID<>"" And FileSize( pfad+"eXo\eXoDOS\"+*game\eXoID)=-2 )
;   EndIf
; EndProcedure

Procedure CheckInstalledEnglish(*game.sgame)
  Protected pfad.s=config\eXoDOSpath
  If config\localInstall
    pfad=GetCurrentDirectory()
  EndIf
  ProcedureReturn Bool( *game\eXoID<>"" And FileSize( pfad+"eXo\eXoDOS\"+*game\eXoID)=-2 )
EndProcedure
 
Procedure CheckInstalledGerman(*game.sgame)
  Protected pfad.s=config\eXoDOSpath
  If config\localInstall
    pfad=GetCurrentDirectory()
  EndIf
  ProcedureReturn Bool( *game\eXoID<>"" And FileSize( pfad+"eXo\eXoDOS\!german\"+*game\eXoID)=-2 )
EndProcedure

Procedure IsGame(*game.sGame)
  ProcedureReturn Bool(*game\eXoID<>"")
EndProcedure

Global _openconsole
Procedure ConPrint(txt.s)
  ;--- intro-hack
  If intro_movie And MovieStatus(intro_movie)=0
    stopintro()
  EndIf
  
  If Not hideConsole
    If Not _openconsole
      OpenConsole(#title)
      _openconsole=#True
    EndIf
    PrintN(txt)
  EndIf
  Debug txt
EndProcedure
Procedure ConClose()
  If _openconsole
    CloseConsole()
    _openconsole=#False
  EndIf
EndProcedure

Procedure __makedir(dest.s)
  Protected pfad.s,pos
  If Right(dest,1)<>"\"
    dest+"\"
  EndIf
  
  Repeat
    pos=FindString(dest,"\",pos+1)
    If pos=0
      Break
    EndIf
    pfad=Left(dest,pos)  
    
    If FileSize(pfad)<>-2
      ConPrint("create "+pfad)
      CreateDirectory(pfad)
    EndIf
  ForEver

EndProcedure

Procedure __copyfile(src.s,dest.s)
  If FileSize(src)<0
    ProcedureReturn #False
  EndIf
  
  If FileSize(src)<>FileSize(dest) Or GetFileDate(src,#PB_Date_Modified)<>GetFileDate(dest,#PB_Date_Modified)
    ConPrint("copy "+src)
    CopyFile(src,dest)
  EndIf
EndProcedure

Procedure __copydir(src.s, dest.s,black.s="",extrafilter.i=#False)
  Protected dir=ExamineDirectory(#PB_Any,src.s,"*.*")
  If dir=0 
    ProcedureReturn #False
  EndIf
  __makedir(Left(dest,Len(dest)-1))
 
  While NextDirectoryEntry(dir)
    Protected name.s=DirectoryEntryName(dir)
    
    If DirectoryEntryType(dir)=#PB_DirectoryEntry_File;----------------------------------------
      If config\localMedias Or extrafilter=#False Or LCase(name)=LCase("Alternate Launcher.bat")
        __CopyFile(src+name,dest+name)
      EndIf
      
    ElseIf name<>"." And name<>".." And name<>black
      __copydir(src+name+"\",dest+name+"\",black,Bool(name="Extras"))
    EndIf
  Wend
  FinishDirectory(dir)
EndProcedure

Structure sPatchInfo
  org.s
  replace.s  
EndStructure

Global NewList PatchInfo.sPatchInfo()
Macro addPatchInfo(a,b)
  AddElement(PatchInfo())
  PatchInfo()\org=a
  PatchInfo()\replace=b
EndMacro

addPatchInfo(#DQUOTE$+".\exodos\%GameName%.zip",
             #DQUOTE$+"%GPI_EXO%\exodos\%GameName%.zip")

addPatchInfo(#DQUOTE$+"exodos\%GameName%.zip",
             #DQUOTE$+"%GPI_EXO%\exodos\%GameName%.zip")

addPatchInfo(#DQUOTE$+".\Update\!dos\%GameName%.zip",
             #DQUOTE$+"%GPI_EXO%\Update\!dos\%GameName%.zip")

addPatchInfo(#DQUOTE$+"..\.\eXoDOS\%GameName%.zip",
             #DQUOTE$+"%GPI_EXO%\eXoDOS\%GameName%.zip")

addPatchInfo(#DQUOTE$+".\exodos\%languagefolder%\%GameName%.zip",
             #DQUOTE$+"%GPI_EXO%\exodos\%languagefolder%\%GameName%.zip")

addPatchInfo(#DQUOTE$+".\Update\%languagefolder%\!dos\%GameName%.zip",
             #DQUOTE$+"%GPI_EXO%\Update\%languagefolder%\!dos\%GameName%.zip")

addPatchInfo(#DQUOTE$+"..\..\.\eXoDOS\%languagefolder%\%GameName%.zip",
             #DQUOTE$+"%GPI_EXO%\eXoDOS\%languagefolder%\%GameName%.zip")

addPatchInfo(".\util\setconsole.exe /minimize",
             "rem .\util\setconsole.exe /minimize")

addPatchInfo("IF NOT EXIST .\emulators\dosbox\*.lang goto english",
             "goto english")

addPatchInfo("call install.bat",
             "set FOLDER=%VAR%"+#CRLF$+"call "+#DQUOTE$+"%GPI_INSTALL%"+#DQUOTE$)

addPatchInfo("if %lang_cnt% == 1 goto :skip_selection",
             "goto :skip_selection")

addPatchInfo("if %lang% == !english goto english",
             "goto english")

addPatchInfo("IF ERRORLEVEL 1 GOTO config",
             "IF ERRORLEVEL 1 GOTO config2")

addpatchinfo(":config",
             ":config"+#CRLF$+"goto end"+#CRLF$+":config2")

addPatchInfo(":none",
             ":none"+#CRLF$+"goto yes")

; addPatchInfo("if %lang_cnt% gtr 1 goto yes",
;              "goto yes")
; 
; addPatchInfo(".\util\choice /C:%line0006% /N %line0007%"+#CRLF$+#crlf,
;              "goto yes")

addPatchInfo(":start",
             ":start"+#CRLF$+".\util\setconsole.exe /minimize")



Procedure __patchBatch(file.s,outfile.s,*info.sConfigDateSize)  
  Protected basedir.s=config\eXoDOSpath+"exo\"
  Protected fin,fout,content.s
  
  Protected size=FileSize(file),moddate=GetFileDate(file,#PB_Date_Modified)
  
  If FileSize(outfile)>0 And *info\size=size And *info\date=moddate
    ProcedureReturn #True
  EndIf
  *info\size=size
  *info\date=moddate
    
  
  fin=ReadFile(#PB_Any,file)
  If fin=0 
    ProcedureReturn #False
  EndIf
  content.s=ReadString(fin,#PB_File_IgnoreEOL,Lof(fin))
  CloseFile(fin)
  
  ForEach PatchInfo()
    content=ReplaceString(content,PatchInfo()\org,PatchInfo()\replace,#PB_String_NoCase)
  Next
  
  ;ConPrint("Patch "+file)
  __makedir(GetPathPart(file))
  fout=CreateFile(#PB_Any,outfile)
  If fout
    WriteStringN(fout,"@echo off"+#CRLF$+"title %GPI_TITLE%"+#CRLF$+content);+#CRLF$+"pause")
    CloseFile(fout)
  EndIf

EndProcedure
Procedure PatchExodosBatch()
  __patchBatch(config\eXoDOSpath+"eXo\util\install.bat", "media\install.bat",config\batchs\install)
  __patchBatch(config\eXoDOSpath+"eXo\util\launch.bat", "media\launch.bat",config\batchs\laucher)

  __patchBatch(config\eXoDOSpath+"eXo\util\!languagepacks\install.bat", "media\lang_install.bat",config\batchs\lang_install)
  __patchBatch(config\eXoDOSpath+"eXo\util\!languagepacks\launch.bat", "media\lang_launch.bat",config\batchs\lang_laucher)
EndProcedure

Procedure InitLocalInstall()
  
  PatchExodosBatch()
  If config\localInstall=#False
    ProcedureReturn #False
  EndIf
  
  
  __makedir("eXo\eXoDOS\!dos\!german")
  __makedir("eXo\eXoDOS\!german\!save")
  __makedir("eXo\eXoDOS\!save")
  
  If FileSize("eXo\emulators")=-1
    __copydir(config\eXoDOSpath+"eXo\emulators\","eXo\emulators\")
  EndIf
  
  If FileSize("eXo\mt32")=-1
    __copydir(config\eXoDOSpath+"eXo\mt32\","eXo\mt32\")
  EndIf
  
  If FileSize("eXo\util")=-1
    __copydir(config\eXoDOSpath+"eXo\util\","eXo\util\")
  EndIf
  
EndProcedure


Procedure CopyGame(*game.sGame)
  If *game\eXoID="" 
    ProcedureReturn #False
  EndIf
  
  __copydir(config\eXoDOSpath+"eXo\eXoDOS\!dos\"+*game\eXoID+"\","eXo\eXoDOS\!dos\"+*game\eXoID+"\")
  __copydir(config\eXoDOSpath+"eXo\eXoDOS\!dos\!german\"+*game\eXoID+"\","eXo\eXoDOS\!dos\!german\"+*game\eXoID+"\")
  
  If config\localMedias
    ForEach *game\Images()
      ForEach *game\Images()\Image()
        __makedir(GetPathPart( *game\Images()\Image() ))
        __copyfile(config\eXoDOSpath+*game\Images()\Image(),*game\Images()\Image())
      Next
    Next
    
    If *game\MusicPath
      __makedir(GetPathPart(*game\MusicPath))
      __copyfile(config\eXoDOSpath+*game\MusicPath, *game\MusicPath)
    EndIf
    
    If *game\ManualPath
      __makedir(GetPathPart(*game\ManualPath))
      __copyfile(config\eXoDOSpath+*game\ManualPath, *game\ManualPath)
    EndIf
    
    If *game\MoviePath
      __makedir(GetPathPart(*game\MoviePath))
      __copyfile(config\eXoDOSpath+*game\MoviePath, *game\MoviePath)
    EndIf
    
  EndIf
  
  
  ConClose()
EndProcedure

Procedure DeleteFileEX(file.s)
  If LCase(Left(file,6))<>"media\" 
    DeleteFile(file)
  EndIf
EndProcedure

Procedure CheckRemoveGame(*game.sGame)
  If *game\eXoID=""
    ProcedureReturn
  EndIf
  
  Protected wasInstalled=Bool(*game\installedEnglish Or *game\installedGerman)
  *game\installedGerman=CheckInstalledGerman(*game)
  *game\installedEnglish=CheckInstalledEnglish(*game)
  
  
  If config\localInstall And wasInstalled And *game\installedEnglish=#False And *game\installedGerman=#False
    DeleteDirectory("eXo\eXoDOS\!dos\"+*game\eXoID+"\","*.*",#PB_FileSystem_Recursive|#PB_FileSystem_Force)
    DeleteDirectory("eXo\eXoDOS\!dos\!german\"+*game\eXoID+"\","*.*",#PB_FileSystem_Recursive|#PB_FileSystem_Force)    
    
    ForEach *game\Images()
      ForEach *game\Images()\Image()
        DeleteFileEx(*game\Images()\Image())
      Next
    Next  
    
    If *game\MusicPath
      DeleteFileEx(*game\MusicPath)
    EndIf
    If *game\ManualPath
      DeleteFileEx(*game\ManualPath)
    EndIf
    If *game\MoviePath
      DeleteFileEx(*game\MoviePath)
    EndIf
    
  EndIf
  
EndProcedure

Procedure StartGameOriginal(*currentgame.sGame,language.s="")
  Protected pfad.s=config\eXoDOSpath
  If *currentgame\eXoID<>"" And config\localInstall
    CopyGame(*currentgame)
    pfad=GetCurrentDirectory()
  EndIf    
  
  If *currentgame\eXoID<>""
    RunProgramEx(pfad+*currentgame\ApplicationPath,*currentgame\CommandLine,pfad+*currentgame\RootFolder)
  Else
    RunProgram(pfad+*currentgame\ApplicationPath,*currentgame\CommandLine,pfad+*currentgame\RootFolder)
  EndIf
EndProcedure

Procedure StartGameEnglish(*currentgame.sGame)
  If *currentgame\eXoID=""
    ProcedureReturn StartGameOriginal(*currentgame)
  EndIf
  
  Protected pfad.s=config\eXoDOSpath
  If *currentgame\eXoID<>"" And config\localInstall
    CopyGame(*currentgame)
    pfad=GetCurrentDirectory()
  EndIf    
  pfad+"exo"
  
  SetEnvironmentVariable("GPI_EXO",config\eXoDOSpath+"\exo")
  SetEnvironmentVariable("GPI_INSTALL",GetCurrentDirectory()+"media\install.bat")
  SetEnvironmentVariable("GPI_Title","eXoDOS - "+ReplaceString(*currentgame\Title,"&"," and ")+" (english)")
  
  
  SetEnvironmentVariable("var",pfad+"\eXoDOS\!dos\"+ *currentgame\eXoID )
  SetEnvironmentVariable("GameDir", *currentgame\eXoID )
  SetEnvironmentVariable("GameName", GetFilePart( *currentgame\ApplicationPath, #PB_FileSystem_NoExtension) )
  SetEnvironmentVariable("GameName2", GetFilePart( *currentgame\ApplicationPath) )
  SetEnvironmentVariable("IndexName",StringField( GetFilePart(*currentgame\ApplicationPath),1,"("))
  
     
  RunProgramEX(GetCurrentDirectory()+"media\launch.bat","",pfad)    
  
  RemoveEnvironmentVariable("GPI_EXO")
  RemoveEnvironmentVariable("GPI_INSTALL")
  RemoveEnvironmentVariable("GPI_TITLE")
  RemoveEnvironmentVariable("var")
  RemoveEnvironmentVariable("GameDir")
  RemoveEnvironmentVariable("GameName")
  RemoveEnvironmentVariable("GameName2")
  RemoveEnvironmentVariable("IndexName")
  
  
  
EndProcedure

Procedure StartGameGerman(*currentgame.sGame)
  If *currentgame\eXoID=""
    ProcedureReturn StartGameOriginal(*currentgame)
  EndIf
  
  Protected pfad.s=config\eXoDOSpath
  If *currentgame\eXoID<>"" And config\localInstall
    CopyGame(*currentgame)
    pfad=GetCurrentDirectory()
  EndIf    
  pfad+"exo"
  
  SetEnvironmentVariable("GPI_EXO",config\eXoDOSpath+"\exo")
  SetEnvironmentVariable("GPI_INSTALL",GetCurrentDirectory()+"media\lang_install.bat")
  SetEnvironmentVariable("GPI_TITLE","eXoDOS - "+ReplaceString(*currentgame\Title,"&"," and ")+" (german)")
    
  SetEnvironmentVariable("var",pfad+"\eXoDOS\!dos\!german\"+ *currentgame\eXoID )
  SetEnvironmentVariable("GameDir", *currentgame\eXoID )
  SetEnvironmentVariable("GameName", GetFilePart( *currentgame\ApplicationPathGerman, #PB_FileSystem_NoExtension) )
  SetEnvironmentVariable("GameName2", GetFilePart( *currentgame\ApplicationPathGerman) )
  SetEnvironmentVariable("IndexName",StringField( GetFilePart(*currentgame\ApplicationPathGerman),1,"("))
  
  SetEnvironmentVariable("languagefolder","!german")
  
  RunProgramEX(GetCurrentDirectory()+"media\lang_launch.bat","",pfad)
  
  RemoveEnvironmentVariable("GPI_EXO")
  RemoveEnvironmentVariable("GPI_INSTALL")
  RemoveEnvironmentVariable("GPI_TITLE")
  RemoveEnvironmentVariable("var")
  RemoveEnvironmentVariable("GameDir")
  RemoveEnvironmentVariable("GameName")
  RemoveEnvironmentVariable("GameName2")
  RemoveEnvironmentVariable("IndexName")
  RemoveEnvironmentVariable("languagefolder")
  
    
EndProcedure

Procedure StartAlternateGame(*currentgame.sGame,language.s="")
  Protected pfad.s=config\eXoDOSpath
  If *currentgame\eXoID<>"" And config\localInstall
    CopyGame(*currentgame)
    pfad=GetCurrentDirectory()
  EndIf
  pfad+ GetPathPart(*currentgame\ApplicationPath)
  If language
    pfad=ReplaceString(pfad,"\!dos\","\!dos\"+language)
  EndIf
  RunProgramEX(pfad+"Extras\Alternate Launcher.bat","",pfad+"Extras")
EndProcedure

Procedure IntellgentStartGame(*currentgame.sGame,x=#PB_Ignore,y=#PB_Ignore)  
  If *currentgame\HasGerman

    If *currentgame\installedGerman And Not *currentgame\installedEnglish
      StartGameGerman(*currentgame)
    ElseIf Not *currentgame\installedGerman And *currentgame\installedEnglish
      StartGameEnglish(*currentgame)
    Else
      DisplayGameStartPopup(*currentgame,x,y)
    EndIf
    
  Else
    StartGameEnglish(*currentgame)
  EndIf            
EndProcedure

Procedure ConfigGameOriginal(*currentgame.sgame,language.s="")
  If *currentgame\ConfigurationPath=""
    RunProgramEX(*currentgame\CommandLine,"",config\eXoDOSpath+*currentgame\RootFolder)              
  Else
    Protected pfad.s=config\eXoDOSpath
    If *currentgame\eXoID<>"" And config\localInstall
      CopyGame(*currentgame)
      pfad=GetCurrentDirectory()
    EndIf               
    
    RunProgramEX(pfad+*currentgame\ConfigurationPath,"",pfad+*currentgame\RootFolder)
  EndIf
EndProcedure

Procedure ConfigGameEnglish(*currentgame.sGame)
  If *currentgame\eXoID=""
    ProcedureReturn ConfigGameOriginal(*currentgame)
  EndIf
  
  Protected pfad.s=config\eXoDOSpath
  If *currentgame\eXoID<>"" And config\localInstall
    CopyGame(*currentgame)
    pfad=GetCurrentDirectory()
  EndIf
    
  SetEnvironmentVariable("GPI_EXO",config\eXoDOSpath+"\exo")
  SetEnvironmentVariable("GPI_INSTALL",GetCurrentDirectory()+"media\install.bat")
  SetEnvironmentVariable("GPI_TITLE","eXoDOS - "+ReplaceString(*currentgame\Title,"&"," and ")+" (english)")
  
  pfad+"exo\eXoDOS\!dos\"+ *currentgame\eXoID 
  
  SetEnvironmentVariable("FOLDER",pfad)
  
  RunProgramEX(GetCurrentDirectory()+"media\install.bat","",pfad)  
  
  RemoveEnvironmentVariable("GPI_EXO")
  RemoveEnvironmentVariable("GPI_INSTALL")
  RemoveEnvironmentVariable("GPI_TITLE")
  RemoveEnvironmentVariable("FOLDER")
  
EndProcedure

Procedure ConfigGameGerman(*currentgame.sGame)
  If *currentgame\eXoID=""
    ProcedureReturn ConfigGameOriginal(*currentgame)
  EndIf
  
  Protected pfad.s=config\eXoDOSpath
  If *currentgame\eXoID<>"" And config\localInstall
    CopyGame(*currentgame)
    pfad=GetCurrentDirectory()
  EndIf
    
  SetEnvironmentVariable("GPI_EXO",config\eXoDOSpath+"\exo")
  SetEnvironmentVariable("GPI_INSTALL",GetCurrentDirectory()+"media\install.bat")
  SetEnvironmentVariable("GPI_Title","eXoDOS - "+ReplaceString(*currentgame\Title,"&"," and ")+" (german)")
  
  pfad+"exo"
  
  SetEnvironmentVariable("GPI_EXO",config\eXoDOSpath+"\exo")
  SetEnvironmentVariable("GPI_INSTALL",GetCurrentDirectory()+"media\lang_install.bat")
  SetEnvironmentVariable("GPI_TITLE","eXoDOS - "+ReplaceString(*currentgame\Title,"&"," and ")+" (german)")
    
  SetEnvironmentVariable("var",pfad+"\eXoDOS\!dos\!german\"+ *currentgame\eXoID )
  SetEnvironmentVariable("FOLDER",pfad+"\eXoDOS\!dos\!german\"+ *currentgame\eXoID)
  
  SetEnvironmentVariable("GameDir", *currentgame\eXoID )
  SetEnvironmentVariable("GameName", GetFilePart( *currentgame\ApplicationPathGerman, #PB_FileSystem_NoExtension) )
  SetEnvironmentVariable("GameName2", GetFilePart( *currentgame\ApplicationPathGerman) )
  SetEnvironmentVariable("IndexName",StringField( GetFilePart(*currentgame\ApplicationPathGerman),1,"("))
  
  SetEnvironmentVariable("languagefolder","!german")
    
  RunProgramEX(GetCurrentDirectory()+"media\lang_install.bat","",pfad+"\eXoDOS\!dos\!german\"+ *currentgame\eXoID)  
  
  RemoveEnvironmentVariable("GPI_EXO")
  RemoveEnvironmentVariable("GPI_INSTALL")
  RemoveEnvironmentVariable("GPI_TITLE")
  RemoveEnvironmentVariable("FOLDER")
  RemoveEnvironmentVariable("var")
  RemoveEnvironmentVariable("GameDir")
  RemoveEnvironmentVariable("GameName")
  RemoveEnvironmentVariable("GameName2")
  RemoveEnvironmentVariable("IndexName")
  RemoveEnvironmentVariable("languagefolder")
  
  
  
  
EndProcedure



Procedure startintro()
  If config\nointro>0
    intro_pic=LoadImage(#PB_Any,"media\intro.png")
    If intro_pic
      intro_win=OpenWindow(#PB_Any,0,0,ImageWidth(intro_pic),ImageHeight(intro_pic), #title + " intro",#PB_Window_ScreenCentered|#PB_Window_BorderLess)
      ImageGadget(#PB_Any,0,0,WindowWidth(intro_win),WindowHeight(intro_win),ImageID(intro_pic))
    EndIf
    ProcedureReturn #False
  EndIf
  
  intro_movie= LoadMovie(#PB_Any, "media\intro.avi")

  If intro_movie
    intro_win=OpenWindow(#PB_Any, 0, 0, MovieWidth(intro_movie),MovieHeight(intro_movie) , #title + " intro",#PB_Window_ScreenCentered|#PB_Window_BorderLess)
    intro_wait=ElapsedMilliseconds()+5000
    PlayMovie(intro_movie, WindowID(intro_win))
    ResizeMovie(intro_movie,0,0,WindowWidth(intro_win),WindowHeight(intro_win))
    Repeat:Until WindowEvent()=#Null
    hideConsole=#True
    
    
  EndIf 

EndProcedure
Procedure stopintro()
  If intro_movie
    While MovieStatus(intro_movie)>0 
      WaitWindowEvent(1)
    Wend
    StopMovie(intro_movie)
    intro_movie=#Null
  EndIf
  If intro_win
    CloseWindow(intro_win)
    intro_win=#Null
  EndIf
  If intro_pic
    FreeImage(intro_pic)
    intro_pic=#Null
  EndIf
  hideConsole=#False
  
  If config\nointro=0
    config\nointro=1
  EndIf
  
EndProcedure

Procedure sanitycheck()
  NewList ignoreID.s()
  NewList germanID.s()
  Protected id=LoadJSON(#PB_Any,"ignore.txt")
  If id
    ExtractJSONList(JSONValue(id), ignoreID())
    FreeJSON(id)
    
    id=LoadJSON(#PB_Any,"german.txt")
    If id
      ExtractJSONList(JSONValue(id),germanID())
      FreeJSON(id)
    EndIf
        
    NewMap fastid()
    ForEach ignoreid()
      fastid(ignoreID())=#True
    Next
    NewMap fastGermanId()
    ForEach germanID()
      fastGermanId(germanID())=#True
    Next
    
    
    ForEach games()
      If fastid( games()\ID )
        DeleteElement(games())
      Else
        games()\hasGerman = fastGermanId(games()\ID)
      EndIf
    Next
    
  Else  
    ConPrint("Check available content...")
    Protected pro,oldpro
    ForEach games()
      pro=ListIndex(games())*10/ListSize(games())
      If pro<>oldpro
        oldpro=pro
        ConPrint(""+pro+"0%")
      EndIf
      
      Protected pfad.s=games()\RootFolder
      If pfad="eXo\emulators\audio\foobar2000"; Soundfiles hack
        pfad+"\"+ReplaceString(games()\CommandLine,#DQUOTE$,"")
      EndIf
      If FileSize(config\eXoDOSpath+pfad) = -1 ;not found
        AddElement(ignoreID())
        ignoreID()=games()\ID
        DeleteElement(games())
      ElseIf games()\eXoID<>"" And FileSize(config\eXoDOSpath+games()\ApplicationPathGerman)>0 
        games()\hasGerman=#True
        AddElement(germanID())
        germanID()=games()\ID
      Else
        games()\hasGerman=#False
      EndIf      
    Next
    
    id=CreateJSON(#PB_Any)
    If id
      InsertJSONList(JSONValue(id), ignoreID())
      SaveJSON(id,"ignore.txt",#PB_JSON_PrettyPrint)
      FreeJSON(id)
    EndIf
    
    id=CreateJSON(#PB_Any)
    If id
      InsertJSONList(JSONValue(id), germanID())
      SaveJSON(id,"german.txt",#PB_JSON_PrettyPrint)
      FreeJSON(id)
    EndIf
    
  EndIf
  
  

EndProcedure





;-------start



loadConfig()
startintro()
Define oldmusic=config\volume\noSound
config\volume\noSound=#True


If config\BoxArtCache
  CreateDirectory("BoxArt.Cache")
EndIf

imgLoading=LoadImage(#PB_Any,"Media\loading.png")
imgQuestionmark=LoadImage(#PB_Any,"Media\question-mark.png")
imgHeart=LoadImage(#PB_Any,"Media\heart.png")
imgClose=LoadImage(#PB_Any,"Media\close.png")
imgEnglish=LoadImage(#PB_Any,"Media\english-flag.png")
imgGerman=LoadImage(#PB_Any,"Media\german-flag.png")

fbig=LoadFont(#PB_Any,"Verdana",20)

InitLocalInstall()
loadGamesList()
sanitycheck()
ScanInstalled()
loadFavorite()
CreateWindow()
CreateGameList()
initPopupmenu()
loadOnce()

;find last game
Define *currentgame.sGame
ForEach ListGames\lgames()
  If ListGames\lgames()\game\ID = config\lastGame
    ListGames\selected=ListIndex(ListGames\lgames())
    ListGames\position=max(0,ListGames\selected-2)
    Break
  EndIf
Next

ListGames\selected=min(max(0,ListGames\selected),ListSize(listgames\lgames())-1)
If ListGames\selected>=0
  SelectElement(ListGames\lgames(),ListGames\selected)
  *currentgame=ListGames\lgames()\game
Else
 ListGames\selected=0
 FirstElement(games())
 *currentgame=games()
EndIf

updateGame(*currentgame)

Global mGenre=popmenu(Once\Genre(),#hl_genre,"/",#False)
Global mSeries=popmenu(once\Series(),#hl_series,":",#True)
Global mReleaseDate=Popmenu(once\ReleaseDate(),#hl_ReleaseDate,"/",#False)
Global mSource=popmenu(once\Source(),#hl_Source,"/",#False)
Global mInstalled=popmenu(once\installed(),#hl_installed,"/",#False)
Global mFavorite=popmenu(once\installed(),#hl_favorite,"/",#False)
Global mGerman=popmenu(once\installed(),#hl_favorite,"/",#False)
Global mAdult=popmenu(once\installed(),#hl_adult,"/",#False)

unloadOnce()

Global threadHandle=CreateThread(@thread_imageloadCache(),0)

config\volume\noSound=oldmusic

stopintro()
ConClose()
If Not checkWindowPos(WindowX(mainwindow),WindowY(mainwindow),WindowHeight(mainwindow),WindowWidth(mainwindow))
  ResizeWindow(mainwindow,DesktopX(0),DesktopY(0),min(WindowWidth(mainwindow),DesktopWidth(0)-100),min(WindowHeight(mainwindow),DesktopHeight(0)-100))
  HideWindow(mainwindow,#False,#PB_Window_ScreenCentered)
Else
  HideWindow(mainwindow,#False)
EndIf


Define autominimize=#False
Define autominimize_oldstate=0
Define ignoreclick

Define event,pfad.s,off,npos,nsize,m
Repeat
  
  If drawlist_needed Or ListGames\drag Or isProgramRunning()
    event=WaitWindowEvent(50)
  Else
    event=WaitWindowEvent()
  EndIf
  loopMusic()
  
  
  Select event
    Case #Null;- timed stuff     
      
      If ListGames\drag = #drag_sbarUp Or (config\AutomaticMinimize And ListGames\drag = #drag_sbarDown)
        
        If ListGames\dragInfo < ElapsedMilliseconds()
          ListGames\dragInfo =ElapsedMilliseconds()+150
          
          If ListGames\drag = #drag_sbarUp
            ListGames\position - ListGames\entriesVisible /2
          Else
            ListGames\position + ListGames\entriesVisible /2
          EndIf
          DrawList()
        Else
  
        EndIf
        
      EndIf  
      
      If drawlist_needed
        DrawList()
      EndIf
      
      If config\AutomaticMinimize
        If isProgramRunning()
          If Not autominimize
            autominimize=#True
            autominimize_oldstate=GetWindowState(mainwindow)
            SetWindowState(mainwindow,#PB_Window_Minimize)
          EndIf
        Else
          If autominimize
            autominimize=#False
            SetWindowState(mainwindow,autominimize_oldstate)
          EndIf
        EndIf
      EndIf
      
    Case #event_imageloaded
      drawlist_needed=#True
      
    Case #PB_Event_SizeWindow
      Resize()
      
    Case #PB_Event_ActivateWindow;- activate window
      resumeMusic()
      CheckRemoveGame(*currentgame)
      updateGame(*currentgame)
      DrawList()
      
    Case #PB_Event_DeactivateWindow; deactivate window
      pauseMusic()
            
    Case #PB_Event_Menu;-- menu
      SelectElement(menu(),EventMenu())      
      If ListIndex(menu())>=0
        
        Select menu()\action
            
          Case #hl_AutomaticMinimize
            config\AutomaticMinimize=1-config\AutomaticMinimize
            
          Case #hl_openNotGameFolder
            pfad.s=GetPathPart(config\eXoDOSpath + *currentgame\ApplicationPath)+ReplaceString(*currentgame\CommandLine,#DQUOTE$,"")
            RunProgram(pfad)            
            
          Case #hl_openGameFolder
            pfad.s=config\eXoDOSpath
            If *currentgame\eXoID<>"" And config\localInstall
              CopyGame(*currentgame)
              pfad=GetCurrentDirectory()
            EndIf    
            pfad+"exo\eXoDOS\"+*currentgame\eXoID
            RunProgram(pfad)
            
          Case #hl_openGameFolderGerman
            pfad.s=config\eXoDOSpath
            If *currentgame\eXoID<>"" And config\localInstall
              CopyGame(*currentgame)
              pfad=GetCurrentDirectory()
            EndIf    
            pfad+"exo\eXoDOS\!german\"+*currentgame\eXoID
            RunProgram(pfad)
            
          Case #hl_nomusic
            config\volume\noSound= 1- config\volume\noSound
            updateMusic(*currentgame)
            
          Case #hl_introPic
            config\nointro=1
            
          Case #hl_introVideo
            config\nointro=-1
            
          Case #hl_genre
            findHeader(#offset_genre)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            DrawList()
            
          Case #hl_ReleaseDate
            findHeader(#offset_releasedate)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            DrawList()
            
          Case #hl_installed
            findHeader(#offset_installed)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            drawlist()
            
          Case #hl_favorite
            findHeader(#offset_favorite)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            drawlist() 
            
          Case #hl_german
            findHeader(#offset_german)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            DrawList()
            
          Case #hl_adult
            findHeader(#offset_adult)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            DrawList()
            
          Case #hl_Source
            findHeader(#offset_source)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            DrawList()
            
          Case #hl_series
            findHeader(#offset_series)
            ListGames\header()\filter=menu()\value
            CreateGameList()
            DrawList()
            
          Case #hl_play
            If menu()\value=""
              StartGameEnglish(*currentgame)
            Else
              StartGameGerman(*currentgame)
            EndIf
            
          Case #hl_config
            If menu()\value=""
              ConfigGameEnglish(*currentgame)
            Else
              ConfigGameGerman(*currentgame)
            EndIf
            
          Case #hl_alternateLauncher
            StartAlternateGame(*currentgame,menu()\value)
            
          Case #hl_view
            config\ListView=Bool( menu()\value<>"Detail" )
            DrawList()
            
           Case #hl_toogleFavorite
             favorite(*currentgame\ID)= 1-favorite(*currentgame\id)
             DrawList()
        EndSelect
        
      EndIf
      
    Case #PB_Event_Gadget;-- gadget
      Select EventGadget()
        Case gOptAd;- options
          ListGames\PictureType="Advertisement"
          FirstElement(*currentgame\Images(ListGames\PictureType)\Image())
          updatePicture(*currentgame)
        Case gOptBox
          ListGames\PictureType="Box"
          FirstElement(*currentgame\Images(ListGames\PictureType)\Image())
          updatePicture(*currentgame)
        Case gOptDisk
          ListGames\PictureType="Medium"
          FirstElement(*currentgame\Images(ListGames\PictureType)\Image())
          updatePicture(*currentgame)
        Case gOptFan
          ListGames\PictureType="Fanart"
          FirstElement(*currentgame\Images(ListGames\PictureType)\Image())
          updatePicture(*currentgame)
        Case gOptScr
          ListGames\PictureType="Screenshot"
          FirstElement(*currentgame\Images(ListGames\PictureType)\Image())
          updatePicture(*currentgame)
          
          
        Case gPicture ;- gPicture
          If EventType()=#PB_EventType_LeftClick
            If Not NextElement(*currentgame\Images(ListGames\PictureType)\Image())
              FirstElement(*currentgame\Images(ListGames\PictureType)\Image())
            EndIf
            updatePicture(*currentgame)
            Resize()
          ElseIf EventType()=#PB_EventType_RightClick
            If ListIndex(*currentgame\Images(ListGames\PictureType)\Image())=>0
              RunProgram(config\eXoDOSpath+*currentgame\Images(ListGames\PictureType)\Image())
            EndIf
            
;              If Not PreviousElement(*currentgame\Images(ListGames\PictureType)\Image())
;                LastElement(*currentgame\Images(ListGames\PictureType)\Image())
;              EndIf
;              updatePicture(*currentgame)
;              Resize()
          EndIf
          
        Case glist ;- glist
          Select EventType()
            Case #PB_EventType_MouseWheel;--Wheel
              ListGames\position-GetGadgetAttribute(glist,#PB_Canvas_WheelDelta) * listgames\entriesLines
              DrawList()
              
            Case #PB_EventType_Input;--Input
              If ListGames\keyboarfocus>=0 
                SelectElement(ListGames\header(),ListGames\keyboarfocus)
                ListGames\header()\filter + Chr( GetGadgetAttribute(glist,#PB_Canvas_Input))
                
                If ListGames\header()\offset=#offset_installed Or ListGames\header()\offset=#offset_favorite Or ListGames\header()\offset=#offset_german Or ListGames\header()\offset=#offset_adult
                  ListGames\header()\filter=Right(ListGames\header()\filter,1)
                  If ListGames\header()\filter<>" " 
                    ListGames\header()\filter="X"
                  EndIf
                EndIf
                
                CreateGameList()
                DrawList()
              EndIf
              
            Case #PB_EventType_KeyDown;--Keydown
              If ListGames\keyboarfocus>=0
                SelectElement(ListGames\header(),ListGames\keyboarfocus)
                Select GetGadgetAttribute(glist,#PB_Canvas_Key)
                  Case #PB_Shortcut_Back,#PB_Shortcut_Delete
                    ListGames\header()\filter=Left(ListGames\header()\filter,Len(ListGames\header()\filter)-1)
                    CreateGameList()
                    DrawList()
                  Case #PB_Shortcut_Return
                    ListGames\keyboarfocus=-1
                    DrawList()
                  Case #PB_Shortcut_Escape
                    ListGames\header()\filter=""
                    ListGames\keyboarfocus=-1
                    CreateGameList()
                    DrawList()
                    
                EndSelect
              Else
                off=0
                Select GetGadgetAttribute(glist,#PB_Canvas_Key)
                  Case #PB_Shortcut_Up
                    off=-ListGames\entriesLines
                  Case #PB_Shortcut_Down
                    off=ListGames\entriesLines
                  Case #PB_Shortcut_Left
                    off=-1
                  Case #PB_Shortcut_Right
                    off=1
                  Case #PB_Shortcut_Return
                    IntellgentStartGame(*currentgame)
                EndSelect
                If GetGadgetAttribute(glist,#PB_Canvas_Modifiers) & #PB_Canvas_Control <>0
                  off*(ListGames\entriesVisible/2)
                EndIf
                If off
                  ListGames\selected=max(0,min(ListSize(ListGames\lgames())-1,ListGames\selected+off))
                  SelectElement(ListGames\lgames(),ListGames\selected)
                  *currentgame=ListGames\lgames()\game
                  ListEntryVisible()
                  updateGame(*currentgame)                                
                EndIf
              EndIf
              
            Case #PB_EventType_MouseEnter,#PB_EventType_MouseLeave,#PB_EventType_MouseMove;--Enter/leave/move    
                            
              Select listGames\drag
                Case #drag_sbar
                  npos= (GetGadgetAttribute(glist,#PB_Canvas_MouseY) - listgames\dragStart)/ListGames\scrollbar_factor + listgames\dragValue                                  
                  If ListGames\position <> npos
                    ListGames\position=npos
                    DrawList()
                  EndIf
                  
                  
                Case #drag_header
                  nsize=max(10,GetGadgetAttribute(glist,#PB_Canvas_MouseX) - listgames\dragStart + listgames\dragValue)
                  SelectElement(ListGames\header(),ListGames\dragInfo)        
                  If ListGames\header()\size <> nsize
                    ListGames\header()\size=nsize
                    DrawList()
                  EndIf
                  
                Case #drag_none
                  inHotlist(GetGadgetAttribute(glist,#PB_Canvas_MouseX),GetGadgetAttribute(glist,#PB_Canvas_MouseY))
                  If ListGames\undercursor\action <> hotlist()\action Or ListGames\undercursor\value <> hotlist()\value
                    ListGames\undercursor=hotlist()
                    DrawList()
                    
                    
                    Select ListGames\undercursor\action
                      Case #action_headerSize
                        SetGadgetAttribute(glist,#PB_Canvas_Cursor,#PB_Cursor_LeftRight)
                      Case #action_edit
                        SetGadgetAttribute(glist,#PB_Canvas_Cursor,#PB_Cursor_IBeam)
                      Default
                        SetGadgetAttribute(glist,#PB_Canvas_Cursor,#PB_Cursor_Default)
                    EndSelect
                  EndIf
              EndSelect
             
            Case #PB_EventType_LeftButtonUp;--lbuttonup
              If ListGames\drag ;=#drag_none
                ListGames\drag=#drag_none
                DrawList()
                ignoreclick=#True
              EndIf
              
            Case #PB_EventType_LeftButtonDown;--lbuttondown
              ignoreclick=#False

              If ListGames\drag = #drag_none
                inHotlist(GetGadgetAttribute(glist,#PB_Canvas_MouseX),GetGadgetAttribute(glist,#PB_Canvas_MouseY))
                ListGames\undercursor=hotlist()
                
                Select ListGames\undercursor\action 
                  Case #action_headerSize
                    ListGames\drag = #drag_header
                    ListGames\dragInfo = ListGames\undercursor\value
                    ListGames\dragStart = GetGadgetAttribute(glist,#PB_Canvas_MouseX)                  
                    SelectElement(ListGames\header(),ListGames\undercursor\value)                  
                    ListGames\dragValue = ListGames\header()\size
                    
                  Case #action_scrollbar
                    If ListGames\undercursor\value=0
                      ListGames\position - ListGames\entriesVisible /2
                      ListGames\drag = #drag_sbarUp
                      ListGames\dragInfo = ElapsedMilliseconds()+1000
                    ElseIf ListGames\undercursor\value=2
                      ListGames\position + ListGames\entriesVisible /2
                      ListGames\drag = #drag_sbarDown
                      ListGames\dragInfo = ElapsedMilliseconds()+1000
                    ElseIf ListGames\undercursor\value=1
                      ListGames\drag = #drag_sbar
                      ListGames\dragInfo = 0
                      ListGames\dragStart = GetGadgetAttribute(glist,#PB_Canvas_MouseY)                                      
                      ListGames\dragValue = ListGames\position
                    EndIf
                    
                    
                    
                    
                EndSelect
                DrawList()
              EndIf
              
            Case #PB_EventType_RightClick;--rightclick
              inHotlist(GetGadgetAttribute(glist,#PB_Canvas_MouseX),GetGadgetAttribute(glist,#PB_Canvas_MouseY))
              ListGames\undercursor=hotlist()              
              ListGames\keyboarfocus=-1
              Select ListGames\undercursor\action 
                  
                Case #action_edit
                  ListGames\keyboarfocus=ListGames\undercursor\value
                  SelectElement(ListGames\header(),ListGames\undercursor\value)
                  ListGames\header()\filter=""
                  CreateGameList()
                  
                Case #action_header
                  SelectElement(ListGames\header(),ListGames\undercursor\value)
                  m=0
                  Select ListGames\header()\offset
                    Case #offset_genre
                      m=mGenre
                    Case #offset_series
                      m=mSeries
                    Case #offset_releasedate
                      m=mReleaseDate
                    Case #offset_source
                      m=mSource
                    Case #offset_installed
                      m=mInstalled
                    Case #offset_favorite
                      m=mFavorite
                    Case #offset_german
                      m=mGerman
                    Case #offset_adult
                      m=mAdult
                  EndSelect
                  If m
                    DisplayPopupMenu(m,WindowID(mainwindow),GadgetX(glist,#PB_Gadget_ScreenCoordinate)+ListGames\header()\PXStart,GadgetY(glist,#PB_Gadget_ScreenCoordinate)+ListGames\headerSize+5)
                  EndIf
                  
                Case #action_entry
                  
                  ListGames\selected=ListGames\undercursor\value  
                  SelectElement(ListGames\lgames(), ListGames\selected)
                                  
                  If *currentgame <> ListGames\lgames()\game
                    *currentgame=ListGames\lgames()\game
                    ListEntryVisible()
                    updateGame(*currentgame)
                  EndIf
                  
                  Debug *currentgame
                  
                  DisplayGamePopup(*currentgame)
                Default
                  DisplayGamePopup(#Null)
              EndSelect
              DrawList()  
              
            Case #PB_EventType_LeftClick;--leftclick
              If ignoreclick
                ignoreclick=#False
                
              Else
                
                inHotlist(GetGadgetAttribute(glist,#PB_Canvas_MouseX),GetGadgetAttribute(glist,#PB_Canvas_MouseY))
                ListGames\undercursor=hotlist()
                
                ListGames\keyboarfocus=-1
                
                Select ListGames\undercursor\action 
                    
                    
                  Case #action_edit
                    ListGames\keyboarfocus=ListGames\undercursor\value
                                        
                  Case #action_header                      
                    SelectElement(ListGames\header(),ListGames\undercursor\value)
                    
                    If ListGames\header()\offset=#offset_installed Or ListGames\header()\offset=#offset_favorite Or ListGames\header()\offset=#offset_german Or ListGames\header()\offset=#offset_adult
                      If ListGames\header()\filter="X"
                        ListGames\header()\filter=""
                      Else
                        ListGames\header()\filter="X"
                      EndIf
  
                      
                    ElseIf ListGames\header()\offset = ListGames\offset 
                      If ListGames\sort=#PB_Sort_Ascending
                        ListGames\sort=#PB_Sort_Descending
                      Else
                        listgames\sort=#PB_Sort_Ascending
                      EndIf
                    Else
                      
                      ListGames\offset=ListGames\header()\offset
                      ListGames\sort=#PB_Sort_Ascending
                    EndIf
                    CreateGameList()
                    
                    ForEach ListGames\lgames()
                      If ListGames\lgames()\game = *currentgame
                        ListGames\selected = ListIndex(ListGames\lgames())
                        ListEntryVisible()
                        Break
                      EndIf
                    Next                
                    DrawList()
                    
                  Case #action_entry
                    ListGames\selected=ListGames\undercursor\value  
                    SelectElement(ListGames\lgames(), ListGames\selected)
                    If *currentgame <> ListGames\lgames()\game
                      *currentgame=ListGames\lgames()\game
                      ListEntryVisible()
                      updateGame(*currentgame)                      
                    EndIf
                    
                EndSelect
              EndIf
              DrawList()
              
            Case #PB_EventType_LeftDoubleClick;--doubleleftclick
              inHotlist(GetGadgetAttribute(glist,#PB_Canvas_MouseX),GetGadgetAttribute(glist,#PB_Canvas_MouseY))
              ListGames\undercursor=hotlist()
              
              ListGames\keyboarfocus=-1
              
              Select ListGames\undercursor\action 
                Case #action_entry
                  ListGames\selected=ListGames\undercursor\value  
                  SelectElement(ListGames\lgames(), ListGames\selected)
                  If *currentgame <> ListGames\lgames()\game
                    *currentgame=ListGames\lgames()\game
                    ListEntryVisible()
                    updateGame(*currentgame)
                    
                  EndIf
                  IntellgentStartGame(*currentgame)
                  
                  
              EndSelect
              DrawList()
              
              
          EndSelect
          
          
        Case gStart;-gStart
          If EventType()=#PB_EventType_LeftClick
            ;StartGame(*currentgame)
            IntellgentStartGame(*currentgame,GadgetX(gStart,#PB_Gadget_ScreenCoordinate),GadgetY(gStart,#PB_Gadget_ScreenCoordinate)+GadgetHeight(gStart))
            
            
          EndIf
          
        Case gConfig;-gConfig
          If EventType()=#PB_EventType_LeftClick
            ;ConfigGame(*currentgame)
            DisplayGameConfigPopup(*currentgame,GadgetX(gConfig,#PB_Gadget_ScreenCoordinate),GadgetY(gConfig,#PB_Gadget_ScreenCoordinate)+GadgetHeight(gConfig))
          EndIf
          
        Default
          If EventType()=#PB_EventType_LeftClick            
            ForEach Hyperlink();- gHyperlink
              If HyperLink()\gadget=EventGadget()
                Select HyperLink()\type                                      
                  Case #hl_open
                    RunProgram( HyperLink()\value,"",GetPathPart(HyperLink()\value) )
                  Case #hl_developer
                    If findHeader(#offset_developer)
                      If ListGames\header()\filter=HyperLink()\value
                        ListGames\header()\filter=""
                      Else
                        ListGames\header()\filter=HyperLink()\value
                      EndIf
                      CreateGameList()
                      DrawList()
                    EndIf
                  Case #hl_publisher
                    If findHeader(#offset_publisher)
                      If ListGames\header()\filter=HyperLink()\value
                        ListGames\header()\filter=""
                      Else
                        ListGames\header()\filter=HyperLink()\value
                      EndIf
                      CreateGameList()
                      DrawList()
                    EndIf
                  Case #hl_genre
                    If findHeader(#offset_genre)
                      If ListGames\header()\filter=HyperLink()\value
                        ListGames\header()\filter=""
                      Else
                        ListGames\header()\filter=HyperLink()\value
                      EndIf
                      CreateGameList()
                      DrawList()
                    EndIf
                  Case #hl_series
                    If findHeader(#offset_series)
                      If ListGames\header()\filter=HyperLink()\value
                        ListGames\header()\filter=""
                      Else
                        ListGames\header()\filter=HyperLink()\value
                      EndIf
                      CreateGameList()
                      DrawList()
                    EndIf
                    
                  Case #hl_ReleaseDate
                    If findHeader(#offset_releasedate)
                      If ListGames\header()\filter=HyperLink()\value
                        ListGames\header()\filter=""
                      Else
                        ListGames\header()\filter=HyperLink()\value
                      EndIf
                      CreateGameList()
                      DrawList()
                    EndIf
                    
                  Case #hl_Source
                    If findHeader(#offset_source)
                      If ListGames\header()\filter=HyperLink()\value
                        ListGames\header()\filter=""
                      Else
                        ListGames\header()\filter=HyperLink()\value
                      EndIf
                      CreateGameList()
                      DrawList()
                    EndIf
                      
                EndSelect
              EndIf
            Next
          EndIf
      EndSelect
      
      
      
  EndSelect
  
Until event=#PB_Event_CloseWindow
unloadMusic()

config\lastGame=*currentgame\ID

config\window\maximize=Bool(GetWindowState(mainwindow)=#PB_Window_Maximize)
SetWindowState(mainwindow,#PB_Window_Normal)
config\window\x=WindowX(mainwindow)
config\window\y=WindowY(mainwindow)
config\window\w=WindowWidth(mainwindow)
config\window\h=WindowHeight(mainwindow)

ClearList(config\headerSize())
ClearList(config\headerFilter())
ForEach ListGames\header()
  AddElement(config\headerSize())
  config\headerSize() = ListGames\header()\size
  AddElement(config\headerFilter())
  config\headerFilter() = ListGames\header()\filter
Next

ClearList( games() )
ClearList(ListGames\lgames())
CloseWindow(moviewindow)
CloseWindow(mainwindow)
saveConfig()
saveFavorite()
KillThread(threadHandle)

; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 2327
; FirstLine = 2319
; Folding = ------------------
; Optimizer
; EnableThread
; EnableXP
; EnableOnError
; UseIcon = exodos.ico
; Executable = eXeDOS_Launcher.exe
; CurrentDirectory = C:\Spiele\eXoDOS Launcher\