Global basedir.s="G:\eXoDOS"
Global NewMap blacklist()
Global RegEx_Magazine= CreateRegularExpression(#PB_Any,"(Magazines.*\.pdf)")


blacklist("Alternate Launcher.bat")=#True

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

Procedure.s findPDF(file.s)
  Protected in, text.s,ret.s
  in=ReadFile(#PB_Any,file)
  text.s=ReadString(in,#PB_File_IgnoreEOL,Lof(in))
  CloseFile(in)
  
  If ExamineRegularExpression(RegEx_Magazine,text)
    While NextRegularExpressionMatch(RegEx_Magazine)
      ret= RegularExpressionMatchString(RegEx_Magazine)
    Wend
  EndIf
  
  If ret
    ; repair paths...
    ret=ReplaceString(ret,"\PC Spiel Special\","\PC Spiel\")
    ret=ReplaceString(ret,"\PC-Player - Sonderheft CD-Player\","\PC-Player\")
    ret=ReplaceString(ret,"\PC-Player Special\","\PC-Player\")
    
    ret=ReplaceString(ret,"\ASM Sonderheft\","\ASM\")
    ret=ReplaceString(ret,"\ASM Extra\","\ASM\")
    
    ; and filename
    ret=ReplaceString(ret,"ASM Sonderheft 1.pdf","ASM Sonderheft 01.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 2.pdf","ASM Sonderheft 02.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 3.pdf","ASM Sonderheft 03.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 4.pdf","ASM Sonderheft 04.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 5.pdf","ASM Sonderheft 05.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 6.pdf","ASM Sonderheft 06.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 7.pdf","ASM Sonderheft 07.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 8.pdf","ASM Sonderheft 08.pdf")
    ret=ReplaceString(ret,"ASM Sonderheft 9.pdf","ASM Sonderheft 09.pdf")
    
    ret="eXo\"+ret
  EndIf   
    
  
  ProcedureReturn ret
EndProcedure

Procedure checkImage(file.s)
  Protected r=LoadImage(#PB_Any,file)
  If r And (ImageFrameCount(r)>1 And LCase(GetExtensionPart(file))="gif") 
    Protected r2=CopyImage(r,#PB_Any)
    FreeImage(r)
    r=r2  
  EndIf
  
  If r
    FreeImage(r)
  EndIf
  
  ProcedureReturn r
EndProcedure

Procedure checkMusic(File.s)
  If FileSize(file)<=0
    ProcedureReturn #False    
  EndIf
  
  Select LCase(GetExtensionPart(file))
    Case "flac","ogg"  
      sSound=LoadSound(#PB_Any, file ,#PB_Sound_Streaming)
      If sSound
        FreeSound(sSound)
        ProcedureReturn #True
      EndIf
      
    Case "wav"  
      sSound=LoadSound(#PB_Any, file )
      If sSound
        FreeSound(sSound)
        ProcedureReturn #True
      EndIf
      
    Case "mp3","mp2"    
      sMovie=LoadMovie(#PB_Any, file)  
      If sMovie
        FreeMovie(sMovie)
        ProcedureReturn #True
      EndIf
      
    Case "mod","amf","dsm","mo3","psm","s3m","sfx","xm"
      sMusic=LoadMusic(#PB_Any,file)
      If sMusic
        FreeMusic(sMusic)
        ProcedureReturn #True
      EndIf
  EndSelect
  
  ProcedureReturn #False
EndProcedure


Procedure.s FindJokerName(file.s)
  Protected a=ExamineDirectory(#PB_Any,GetPathPart(file),GetFilePart(file))
  If a
    While NextDirectoryEntry(a)
      n.s=DirectoryEntryName(a)
      FinishDirectory(a)
      ProcedureReturn GetPathPart(file)+n
    Wend
    FinishDirectory(a)
  EndIf
  ProcedureReturn ""
EndProcedure

Structure sImages
  List Image.s()
EndStructure

Structure sAltername
  GameID.s
  Name.s
  Region.s
EndStructure

Structure sAdditionalAplication
  Id.s
  GameID.s
  ApplicationPath.s
  CommandLine.s
  Name.s
EndStructure

Structure sGame
  Title.s
  SortTitle.s
  
  TitleGerman.s
  SortTitleGerman.s
  
  Publisher.s
  ReleaseDate.s
  
  Developer.s
  
  CommandLine.s
  
  Notes.s
  
  isAdult.i
  
  RootFolder.s
  
  hasGerman.i
  hasEnglishInstallFiles.i
  hasExceptionBat.i
  hasGermanExceptionBat.i
  
  ApplicationPath.s
  ApplicationPathGerman.s
  ConfigurationPath.s
  
  ManualPath.s
  MusicPath.s
  MoviePath.s
  
  Source.s
  
  WikipediaURL.s
  Series.s
  
  Genre.s
  VideoUrl.s
  ID.s
  eXoID.s
  eXoName.s
  eXoNameGerman.s
  
  SortSeries.s
  
  List Extras.s()
  List AlternateTitle.s()
  Map Images.sImages()
  
EndStructure

Global NewMap *linkgame.sGame()

Global NewList games.sGame()







Procedure.s makeFilename(name.s)
  Protected forbidden.s = ~":*?<w>\"\\/'",i
  For i=1 To Len(forbidden)
    name=ReplaceString(name,Mid(forbidden,i,1),"_")
  Next
  ProcedureReturn LCase(ReplaceString(name,"  "," "))
EndProcedure


;UNKNOWN:Images\MS-DOS\Screenshot - Gameplay\The Pandora Directive-01.jpeg ### the pandora directive-


Macro addtype(cutname,type,pfad,name)
  If type="Movies"
    If *linkgame(cutname)\MoviePath<>""
      ;Debug "CONFLIKT:" + *linkgame(cutname)\MoviePath+" "+name
    Else
      *linkgame(cutname)\MoviePath=pfad+"\"+name
    EndIf
    
  ElseIf type="Music"
    If GetExtensionPart(name)="ogg"
      ;Debug "****"+pfad+name
    EndIf
    
    If *linkgame(cutname)\MusicPath<>""
      ;Debug "CONFLIKT:" + *linkgame(cutname)\MusicPath+" "+name
    Else
      If local         
        If checkMusic(pfad+"\"+name)
          *linkgame(cutname)\MusicPath=pfad+"\"+name
          ;Debug "Add music file"+pfad+"\"+name
        Else
          Debug "defekt music file:"+pfad+"\"+name
          CopyFile(pfad+"\"+name,"defekt\"+name)
        EndIf
      Else
        If checkMusic(basedir+"\"+pfad+"\"+name)
          *linkgame(cutname)\MusicPath=pfad+"\"+name
          ;Debug "Add music file"+pfad+"\"+name
        Else
          Debug "defekt music file:"+pfad+"\"+name
          CopyFile(basedir+"\"+pfad+"\"+name,"defekt\"+name)
        EndIf
      EndIf
      
    EndIf
    
  ElseIf type="Manuals"
    If *linkgame(cutname)\ManualPath<>""
      ;Debug "CONFLIKT:" + *linkgame(cutname)\ManualPath+" "+name
    Else
      *linkgame(cutname)\ManualPath=pfad+"\"+name
    EndIf
    
    
  Else
    file2.s="Media\"+ReplaceString(pfad,"\","_")+"_"+GetFilePart(name,#PB_FileSystem_NoExtension)+".png"
    If FileSize(file2)>0 And checkImage(basedir+"\"+pfad+"\"+name)=#False
      Debug "Replace: "+file+" >> "+file2
      AddElement(*linkgame(cutname)\Images(type)\Image())
      *linkgame(cutname)\Images(type)\Image()=file2
    Else
      ;Debug "ADD:"+cutname+" "+pfad+"\"+name
      AddElement(*linkgame(cutname)\Images(type)\Image())
      *linkgame(cutname)\Images(type)\Image()=pfad+"\"+name
    EndIf
    
    
;     If checkImage(basedir+"\"+pfad+"\"+name)    
;       AddElement(*linkgame(cutname)\Images(type)\Image())
;       *linkgame(cutname)\Images(type)\Image()=pfad+"\"+name
;     Else
;       Debug "DEFEKT IMAGE!"+pfad+"\"+name
;       CopyFile(basedir+"\"+pfad+"\"+name,"defekt\"+ReplaceString(pfad,"\","_")+"_"+name)
;     EndIf
    
  EndIf
EndMacro

Procedure ScanDir(pfad.s,type.s,local=#False,dosub=#True)
  ;Debug "SCAN "+basedir+"\"+pfad
  Protected dir
  
  If local    
    dir=ExamineDirectory(#PB_Any,pfad,"*.*")
  Else
    dir=ExamineDirectory(#PB_Any,basedir+"\"+pfad,"*.*")
  EndIf
  If Not dir 
    ProcedureReturn
  EndIf
  
  While NextDirectoryEntry(dir)
    Protected name.s=DirectoryEntryName(dir)
    If DirectoryEntryType(dir)=#PB_DirectoryEntry_Directory
      If name<>"." And name<>".." And dosub
        scandir(pfad+"\"+name,type,local)  
      EndIf
    Else
      Protected cutname.s=makeFilename(GetFilePart(name,#PB_FileSystem_NoExtension))
      If *linkgame(cutname)
        addtype(cutname,type,pfad,name)
      Else
        Protected ext.s=LCase(GetExtensionPart(name))
        cutname.s=makeFilename(GetFilePart(name,#PB_FileSystem_NoExtension))
        
        If Left(Right(cutname,3),1)="-" 
          cutname=Left(cutname,Len(cutname)-3)
        EndIf
        
        If Mid(cutname,Len(cutname)-36,1)="." And Mid(cutname,Len(cutname)-27,1)="-" And Mid(cutname,Len(cutname)-22,1)="-" And Mid(cutname,Len(cutname)-17,1)="-" And Mid(cutname,Len(cutname)-12,1)="-" 
          cutname= Right(cutname,36)
        EndIf
        
        
        If (ext="mp4" Or ext="ogg" Or ext="doc" Or ext="rtf" Or ext="mod" Or ext="wav" Or ext="mp3" Or ext="pdf" Or ext="txt" Or ext="tif" Or ext="jpeg" Or ext="jpg" Or ext="png" Or ext="gif")
          
          If *linkgame(cutname)
            addtype(cutname,type,pfad,name)
            ;Debug cutname
          Else
            ;Debug "NOT FOUND:"+ pfad + "\"+name+" ### "+cutname
          EndIf
          
        Else
          ;Debug "UNKNOWN:" + pfad + "\"+name+" ### "+cutname
        EndIf
      EndIf
    EndIf
  Wend
  
EndProcedure

Global NewMap LanguageGermanAlt.s()

Procedure scanXML(xml.s,magfilter=#False)
  Debug "OPEN "+xml
  id=LoadXML(#PB_Any,xml.s)
  
  count=0
  If id 
    If XMLStatus(id)=#PB_XML_Success
      *CurrentNode=MainXMLNode(id)
      
      If XMLNodeType(*CurrentNode) = #PB_XML_Normal
        ;Debug GetXMLNodeName(*CurrentNode)
        
        If ExamineXMLAttributes(*CurrentNode)
          *ChildNode = ChildXMLNode(*CurrentNode)
          
          While *ChildNode <> 0
            count+1
            If count % 100 = 0
              Debug "..."
            EndIf
            
            If GetXMLNodeName(*ChildNode)="Game" ;--game
              
              
              AddElement(games())
              ExtractXMLStructure(*ChildNode, @games(), sGame)
              
              
              If games()\Title="eXoDOS" Or games()\Title="eXoDOS German Language Pack"
                Debug "Remove "+games()\Title
                DeleteElement(games())
              Else
                
                games()\Title=ReplaceString( games()\Title, "[1993] The Sound Blaster Book (Axel Stolz)", "[1993] The Sound Blaster Book")
                games()\ApplicationPath=ReplaceString( games()\ApplicationPath, "[1993] The Sound Blaster Book (Axel Stolz)", "[1993] The Sound Blaster Book")
                
                ;Debug games()\title
                
                If magfilter
                  If LCase(GetExtensionPart(games()\ApplicationPath))="bat"
                    Protected pdf.s = findPDF(basedir+"\"+games()\ApplicationPath)
                    If pdf                      
                      If FileSize(basedir+"\"+pdf)>0
                        games()\ApplicationPath=pdf
                        ;Debug "replace with pdf:"+games()\Title+" #### "+pdf
                      Else
                        Debug "DEFEKT PDF:"+games()\Title+" ### "+pdf
                      EndIf
                    EndIf
                  EndIf
                EndIf
                
                
                If LCase(GetPathPart(games()\RootFolder))=LCase("eXo\eXoDOS\!dos\")
                  games()\eXoID=GetFilePart(games()\RootFolder)
                  games()\eXoName=GetFilePart(games()\ApplicationPath,#PB_FileSystem_NoExtension)
                  
                  games()\hasExceptionBat=Bool(FileSize(basedir+"\eXo\eXoDOS\!dos\"+ games()\eXoID+"\exception.bat")>0)
                  games()\hasGermanExceptionBat=Bool(FileSize(basedir+"\eXo\eXoDOS\!dos\!german\"+ games()\eXoID+"\exception.bat")>0)
                  
                  games()\hasEnglishInstallFiles=  Bool( FileSize(basedir+"\eXo\eXoDOS\"+ games()\eXoName+".zip")>0 )
                  name.s=Mid(FindJokerName(basedir+"\exo\exoDOS\!dos\!german\"+games()\eXoID+"\*).bat"),Len(basedir)+1)
                                 
                  
                  If name<>""
                    games()\eXoNameGerman=GetFilePart(name,#PB_FileSystem_NoExtension)
                    games()\ApplicationPathGerman=name
                    games()\hasGerman=#True                 
                  EndIf
                  
                  
                EndIf
                
                ;Debug  games()\Title
                ;If games()\SortTitle=""
                ;  games()\SortTitle=games()\Title
                ;EndIf
                
                games()\ReleaseDate=Left(games()\ReleaseDate,4)
                
                *linkgame(makeFilename(games()\SortTitle))=@games()
                *linkgame(makeFilename(games()\SortTitle+" ("+games()\ReleaseDate+")"))=@games()
                ;*linkgame(makeFilename(StringField(games()\SortTitle,1,":")))=@games()
                ;*linkgame(makeFilename(StringField(games()\SortTitle,1,":")+" ("+games()\ReleaseDate+")"))=@games()
                
                *linkgame(makeFilename(games()\Title))=@games()
                *linkgame(makeFilename(games()\Title+" ("+games()\ReleaseDate+")"))=@games()
                ;*linkgame(makeFilename(StringField(games()\Title,1,":")))=@games()
                ;*linkgame(makeFilename(StringField(games()\Title,1,":")+" ("+games()\ReleaseDate+")"))=@games()
                
                *linkgame(makeFilename(games()\ID))=@games()
                *linkgame(makeFilename(GetFilePart(games()\ApplicationPath,#PB_FileSystem_NoExtension)))=@games()
                If games()\ApplicationPathGerman<>""
                  *linkgame(makeFilename(GetFilePart(games()\ApplicationPathGerman,#PB_FileSystem_NoExtension)))=@games()
                EndIf
                
                For phase=1 To 5
                  
                  If phase=1
                    pfad.s=games()\RootFolder+"\Extras"
                  ElseIf phase=2
                    If  FindString(games()\RootFolder,"\!dos\")
                      pfad.s=ReplaceString(games()\RootFolder,"\!dos\","\!dos\!german\")+"\Extras"
                    Else
                      pfad=""
                    EndIf
                  ElseIf phase=3
                    pfad.s=games()\RootFolder+"\Magazines"
                  ElseIf phase=4
                    If  FindString(games()\RootFolder,"\!dos\")
                      pfad.s=ReplaceString(games()\RootFolder,"\!dos\","\!dos\!german\")+"\Magazines"
                    Else
                      pfad=""
                    EndIf
                  Else
                    pfad.s=games()\RootFolder+"\ADVEXP"
                  EndIf
                  
                  If pfad
                    dir=ExamineDirectory(#PB_Any,basedir+"\"+pfad,"*.*")
                    If dir
                      While NextDirectoryEntry(dir)
                        If DirectoryEntryType(dir)=#PB_DirectoryEntry_File
                          name.s=DirectoryEntryName(dir)
                          If Not blacklist(name) 
                            AddElement(games()\Extras())
                            games()\Extras()=pfad+"\"+name
                          EndIf
                        EndIf
                      Wend
                      FinishDirectory(dir)
                    EndIf
                  EndIf
                  
                  
                Next
                
              EndIf
              
              ;bücherpfad korrigieren
              If Left(games()\Genre,5)="Books"
                games()\RootFolder=GetPathPart(games()\ApplicationPath)
                games()\RootFolder= Left(games()\RootFolder,Len(games()\RootFolder)-1)
              EndIf
              
              ;music-pfad überprüfen
              If games()\MusicPath And Not checkMusic(basedir+"\"+games()\MusicPath)
                Debug "Unknown music!"
                Debug games()\Title+" ## "+games()\MusicPath
                games()\MusicPath=""
              EndIf
              
            ElseIf GetXMLNodeName(*ChildNode)="AdditionalApplication" ;-- additional application
              sapp.sAdditionalAplication
              ExtractXMLStructure(*ChildNode, @sapp, sAdditionalAplication) ;-- alternate title
              Debug "AdditionalApplication "+sapp\Name
              Debug "      "+sapp\ApplicationPath
              Debug "      "+sapp\CommandLine
              
            ElseIf GetXMLNodeName(*ChildNode)="AlternateName"
              aname.sAltername
              ExtractXMLStructure(*ChildNode, @aname, sAltername)
              aname\Name=ReplaceString(aname\Name,"Kreuzwortrātsel","Kreuzworträtsel")
              
              *game.sGame=*linkgame(makeFilename(aname\GameID))
              If *game=0 
                Debug "Alternatename 0:"+aname\GameID+" "+aname\Name
              Else 
                
                If FindString( aname\Region,"germany",0,#PB_String_NoCase ) >0 And *game\TitleGerman = ""
                  *game\TitleGerman=aname\Name                
                EndIf
                If FindString( aname\Region,"europe",0,#PB_String_NoCase ) >0 And LanguageGermanAlt.s(*game\id) = ""
                  LanguageGermanAlt.s(*game\id)=aname\Name                
                EndIf
                
                AddElement(*game\AlternateTitle())
                *game\AlternateTitle()=aname\Name
                
                
                name.s=makeFilename(aname\Name+" ("+*game\ReleaseDate+")")
                If *linkgame(name)=0
                  *linkgame(name)=*game
                EndIf            
                
                name.s=makeFilename(aname\Name)
                If *linkgame(name)=0
                  *linkgame(name)=*game
                EndIf    
              EndIf
              
            Else
              Debug "unknown:"+GetXMLNodeName(*ChildNode)
            EndIf
            
            *ChildNode=NextXMLNode(*ChildNode)
          Wend
          
        EndIf
        
        
        
      EndIf
      
      
      
      ;     ExtractXMLStructure(MainXMLNode(id), @LaunchBox, sLaunchBox)
      ;     Debug "loaded!"
      ;     Debug ListSize(LaunchBox\Game())
    Else
      Debug XMLError(id)
      Debug XMLErrorLine(id)
      Debug XMLErrorPosition(id)
    EndIf
    FreeXML(id)
  EndIf
  
EndProcedure

Structure sFile
  Platform.s
  FileName.s
  GameName.s
EndStructure


Debug "----------"

;-----------
Macro ListOnlyOnce( li )
  If FirstElement( li )
    While NextElement( li )
      DeleteElement( li )
      
    Wend
  EndIf
EndMacro
  

Procedure.s CreateSortName(txt.s)
  If LCase(Left(txt,4))="the "
    txt=Mid(txt,5)+", the"
  ElseIf LCase(Left(txt,4))="der "
    txt=Mid(txt,5)+", der"
  ElseIf LCase(Left(txt,4))="die "
    txt=Mid(txt,5)+", die"
  ElseIf LCase(Left(txt,4))="das "
    txt=Mid(txt,5)+", das"
  EndIf
  txt=ReplaceString(txt,"Ä","AE",#PB_String_NoCase)
  txt=ReplaceString(txt,"Ö","OE",#PB_String_NoCase)
  txt=ReplaceString(txt,"Ü","UE",#PB_String_NoCase)
  txt=ReplaceString(txt,"ß","SS",#PB_String_NoCase)
  txt=ReplaceString(txt,"ß","SS",#PB_String_NoCase)
  txt=ReplaceString(txt,"µ","my",#PB_String_NoCase)
  
  ProcedureReturn txt
EndProcedure



;-- magazines------------------------------------------------------------
 
If #True ;---------------------------- fast?
  
  ;-- games
  scanXML(basedir+"\Data\Platforms\MS-DOS.xml")
  ScanDir("Images\MS-DOS\Advertisement Flyer - Front","Advertisement")
  ScanDir("Images\MS-DOS\Advertisement Flyer - Back","Advertisement")
  
  ;########
  ScanDir("Images\MS-DOS\Box - 3D\United States","Box 3D",#False,#False)
  ScanDir("Images\MS-DOS\Box - 3D\North America","Box 3D",#False,#False)
  ScanDir("Images\MS-DOS\Box - 3D\United Kingdom","Box 3D",#False,#False)
  ScanDir("Images\MS-DOS\Box - 3D\World","Box 3D",#False,#False)
  ScanDir("Images\MS-DOS\Box - 3D","Box 3D",#False,#False)
  ScanDir("Images\MS-DOS\Box - 3D","Box 3D")
  ;##
  ScanDir("Images\MS-DOS\Box - 3D\Germany","Box 3D German",#False,#False)
  ScanDir("Images\MS-DOS\Box - 3D","Box 3D German",#False,#False)
  ScanDir("Images\MS-DOS\Box - 3D","Box 3D German")
  ;#########
  ScanDir("Images\MS-DOS\Box - Front\United States","Box Front",#False,#False)
  ScanDir("Images\MS-DOS\Box - Front\North America","Box Front",#False,#False)
  ScanDir("Images\MS-DOS\Box - Front\United Kingdom","Box Front",#False,#False)
  ScanDir("Images\MS-DOS\Box - Front\World","Box Front",#False,#False)
  ScanDir("Images\MS-DOS\Box - Front","Box Front",#False,#False)
  ScanDir("Images\MS-DOS\Box - Front","Box Front")
  ;##
  ScanDir("Images\MS-DOS\Box - Front\Germany","Box Front German",#False,#False)
  ScanDir("Images\MS-DOS\Box - Front","Box Front German",#False,#False)
  ScanDir("Images\MS-DOS\Box - Front","Box Front German")
  ;############
  ScanDir("Images\MS-DOS\Screenshot - Game Title\United States","Game Title",#False,#False)
  ScanDir("Images\MS-DOS\Screenshot - Game Title\North America","Game Title",#False,#False)
  ScanDir("Images\MS-DOS\Screenshot - Game Title\United Kingdom","Game Title",#False,#False)
  ScanDir("Images\MS-DOS\Screenshot - Game Title\World","Game Title",#False,#False)
  ScanDir("Images\MS-DOS\Screenshot - Game Title","Game Title",#False,#False)
  ScanDir("Images\MS-DOS\Screenshot - Game Title","Game Title")
  ;##
  ScanDir("Images\MS-DOS\Screenshot - Game Title\Germany","Game Title German",#False,#False)
  ScanDir("Images\MS-DOS\Screenshot - Game Title","Game Title German",#False,#False)
  ScanDir("Images\MS-DOS\Screenshot - Game Title","Game Title German")
  ;##############
  
  
  ScanDir("Images\MS-DOS\Box - Front","Box")
  ScanDir("Images\MS-DOS\Box - Front - Reconstructed","Box")
  ScanDir("Images\MS-DOS\Fanart - Box - Front","Box")
  
  ScanDir("Images\MS-DOS\Box - Back","Box")
  ScanDir("Images\MS-DOS\Fanart - Box - Back","Box")
  
  ScanDir("Images\MS-DOS\Box - Back - Reconstructed","Box")
  ScanDir("Images\MS-DOS\Box - Spine","Box")
  
  
  ScanDir("Images\MS-DOS\Cart - Front","Medium")
  ScanDir("Images\MS-DOS\Cart - Back","Medium")
  ScanDir("Images\MS-DOS\Disc","Medium")
  ScanDir("Images\MS-DOS\Fanart - Disc","Medium")
  
  ScanDir("Images\MS-DOS\Fanart - Background","Fanart")
  
  ScanDir("Images\MS-DOS\Screenshot - Gameplay","Screenshot")
  ScanDir("Images\MS-DOS\Screenshot - Game Title","Screenshot")
  ScanDir("Images\MS-DOS\Screenshot - Game Select","Screenshot")
  ScanDir("Images\MS-DOS\Screenshot - Game Over","Screenshot")
  ScanDir("Images\MS-DOS\Screenshot - High Scores","Screenshot")
  
  
  ScanDir("Images\MS-DOS\Banner","Banner")
  ScanDir("Images\MS-DOS\Clear Logo","Banner")
  
  ScanDir("Music","Music")
  ScanDir("Media","Music",#True)
  
  ScanDir("Videos","Movies")
  ScanDir("Manuals","Manuals")
  
  ;-- books
  ClearMap(*linkgame())
  scanXML(basedir+"\Data\Platforms\MS-DOS Books.xml")
  ;ScanDir("Images\MS-DOS Books","Screenshot")
  
  ScanDir("Images\MS-DOS Books\Box - Front","Box Front")  
  ScanDir("Images\MS-DOS Books\Box - Front","Box")
  ScanDir("Images\MS-DOS Books\Box - Back","Box")
  
  ;-- catalogs
  ClearMap(*linkgame())
  scanXML(basedir+"\Data\Platforms\MS-DOS Catalogs.xml")
  ScanDir("Images\MS-DOS Catalogs","Screenshot")
  
  
  ;-- magazines
  ClearMap(*linkgame())
  scanXML(basedir+"\Data\Platforms\MS-DOS Magazines & Newsletters.xml",#True)
  ScanDir("Images\MS-DOS Magazines & Newsletters\Box - Front","Box Front")
  ScanDir("Images\MS-DOS Magazines & Newsletters\Screenshot - Game Title","Game Title")
  
  
  ScanDir("Images\MS-DOS Magazines & Newsletters\Box - Front","Box")
  ScanDir("Images\MS-DOS Magazines & Newsletters\Box - Back","Box")
  ScanDir("Images\MS-DOS Magazines & Newsletters\Disc","Medium")
  ScanDir("Images\MS-DOS Magazines & Newsletters\Cart - Front","Medium")
  ScanDir("Images\MS-DOS Magazines & Newsletters\Screenshot - Game Title","Screenshot")
  
  
  ;-- soundtrack
  ClearMap(*linkgame())
  scanXML(basedir+"\Data\Platforms\Soundtracks.xml")
  ;ScanDir("Images\Soundtracks","Screenshot")
  
  ScanDir("Images\Soundtracks\Box - Front","Box Front")  
  ScanDir("Images\Soundtracks\Box - Front","Box")
  ScanDir("Images\Soundtracks\Box - Back","Box")
  ScanDir("Images\Soundtracks\Disc","Medium")
  ScanDir("Images\Soundtracks\Cart - Front","Medium")
  ScanDir("Images\Soundtracks\Screenshot - Game Select","Screenshot")
  ScanDir("Images\Soundtracks\Screenshot - Gameplay","Screenshot")

  
  
  Debug "---------------------------"
  
  Debug "sortnames"
  ForEach games()
    
    If FirstElement(games()\Images("Box 3D German")\Image()) And FirstElement(games()\Images("Box 3D")\Image()) And games()\Images("Box 3D German")\Image()=games()\Images("Box 3D")\Image()
      games()\Images("Box 3D German")\Image()=""
    EndIf
    
    If FirstElement(games()\Images("Box Front German")\Image()) And FirstElement(games()\Images("Box Front")\Image()) And games()\Images("Box Front German")\Image()=games()\Images("Box Front")\Image()
      games()\Images("Box Front German")\Image()=""
    EndIf
    
    If FirstElement(games()\Images("Game Title German")\Image()) And FirstElement(games()\Images("Game Title")\Image()) And games()\Images("Game Title German")\Image()=games()\Images("Game Title")\Image()
      games()\Images("Game Title German")\Image()=""
    EndIf
    
    
    ListOnlyOnce( games()\Images("Box 3D")\Image() )
    ListOnlyOnce( games()\Images("Box Front")\Image() )
    ListOnlyOnce( games()\Images("Game Title")\Image() )
      
    ListOnlyOnce( games()\Images("Box 3D German")\Image() )
    ListOnlyOnce( games()\Images("Box Front German")\Image() )
    ListOnlyOnce( games()\Images("Game Title German")\Image() )  
    
    ListOnlyOnce( games()\Images("Banner")\Image() )
    
    ForEach games()\Images()
      If ListSize(games()\Images()\image())<=0
        DeleteMapElement(games()\Images())
      EndIf
    Next
    
    
    txt.s=games()\Series
    
    If txt
      c=CountString(txt,";")
      For i=1 To c+1
        text.s= Trim(StringField(txt,i,";"))
        If FindString(text,":")=0
          If games()\SortSeries<>""
            games()\SortSeries+"; "
          EndIf
          games()\SortSeries+text
        EndIf
      Next
    EndIf
    
    If games()\SortTitle="" 
      txt=CreateSortName(games()\Title)
      
      If games()\Title <> txt
        games()\SortTitle=txt
      EndIf
    EndIf
    
    If games()\TitleGerman=games()\Title
      games()\TitleGerman=""
      games()\SortTitleGerman=""
    EndIf
    
    If games()\TitleGerman=""
      games()\TitleGerman=LanguageGermanAlt(games()\id)
    EndIf
       
    
    If games()\TitleGerman<>"" And games()\SortTitleGerman="" 
      txt=CreateSortName(games()\TitleGerman)
      If txt <> games()\TitleGerman
        games()\SortTitleGerman=txt
      EndIf
    EndIf
    
    
  Next
  
  
  
  Debug "save json"
  
  id=CreateJSON(#PB_Any)
  If id
    InsertJSONList(JSONValue(id),games())
    SaveJSON(id,"games.json", #PB_JSON_PrettyPrint)
    FreeJSON(id)
  EndIf
  
  
Else
  
  id=LoadJSON(#PB_Any,"games.json")
  ExtractJSONList(JSONValue(id), games())
  FreeJSON(id)
EndIf
    

;--------- Adult
Debug "Add Adult"


NewList adult.s()
id=LoadJSON(#PB_Any,"adult.json")
ExtractJSONList(JSONValue(id), adult())
FreeJSON(id)

NewMap fastadult()
ForEach adult()
  fastadult(adult())=#True
Next


ForEach games()
  games()\isAdult=fastadult(games()\ID)  
Next


id=CreateJSON(#PB_Any)
  If id
    InsertJSONList(JSONValue(id),games())
    SaveJSON(id,"games.json", #PB_JSON_PrettyPrint)
    FreeJSON(id)
  EndIf
  
  ;--------- once
Debug "Create once"


NewMap hgenre()
NewMap hseries()
NewMap hReleaseDate()
NewMap hSource()
;NewMap hPublisher()
;NewMap hDeveloper()

Structure sOnce
  List Genre.s()
  List Series.s()
  List ReleaseDate.s()
  List Source.s()
  ;List Publisher.s()
  ;List Developer.s()
EndStructure


once.sOnce

Macro scanList(what,opt)
  For i=1 To CountString(games()\what,";")+1
    t.s=Trim(StringField(games()\what,i,";"))    
    If t<>"" And t<>"Mission: Impossible games" And h#what(t) = #False
      If opt="" Or FindString(t,opt)>0
        AddElement(once\what())
        once\what()=t
        h#what(t) = #True
      EndIf
    EndIf
  Next
EndMacro

ForEach games()  
  scanList(Series,":")
  scanlist(ReleaseDate,"")
  scanlist(Genre,"")
  scanlist(Source,"")
  ;  scanlist(Publisher)
  ;  scanlist(Developer)
Next




SortList(once\Genre(),#PB_Sort_Ascending|#PB_Sort_NoCase)
SortList(once\Series(),#PB_Sort_Ascending|#PB_Sort_NoCase)
SortList(once\ReleaseDate(),#PB_Sort_Ascending|#PB_Sort_NoCase)
SortList(once\Source(),#PB_Sort_Ascending|#PB_Sort_NoCase)
;SortList(once\Publisher(),#PB_Sort_Ascending|#PB_Sort_NoCase)
;SortList(once\Developer(),#PB_Sort_Ascending|#PB_Sort_NoCase)


last.s=""
ForEach(once\Genre())
  lside.s = Trim(StringField(once\Genre(),1,"/"))
  rside.s = Trim(StringField(once\Genre(),2,"/"))
  
  If lside=last
    PreviousElement(once\Genre())
    DeleteElement(once\Genre())
  EndIf
  
  last=once\Genre()  
  
Next

id=CreateJSON(#PB_Any)
If id
  InsertJSONStructure(JSONValue(id),once,sOnce)
  SaveJSON(id,"media\once.json", #PB_JSON_PrettyPrint)
  FreeJSON(id)
EndIf

;bugs
; eXo\\Books\\[1993] The Sound Blaster Book (Axel Stolz)
;Kreuzwortrātsel
;.......



Debug "done"














; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 450
; FirstLine = 368
; Folding = -4-
; EnableXP