Structure sGame
  Title.s
  ID.s  
EndStructure

Procedure scanXML(xml.s,Map games.s())
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
            
            If GetXMLNodeName(*ChildNode)="Game"
              
              game.sgame
              ExtractXMLStructure(*ChildNode, @game, sGame)
              
              games(game\ID)=game\Title
              
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



NewMap all.s()
NewMap family.s()

scanxml("G:\eXoDOS\xml\all\MS-DOS.xml",all())
scanxml("G:\eXoDOS\xml\family\MS-DOS.xml",family())

NewList adult.s()

ForEach all()
  If family(MapKey(all()))=""
    Debug MapKey(all())+" "+all()
    AddElement(adult.s())
    adult()=MapKey(all())
  EndIf
Next

id=CreateJSON(#PB_Any)
If id
  InsertJSONList(JSONValue(id),adult())
  SaveJSON(id,"adult.json", #PB_JSON_PrettyPrint)
  FreeJSON(id)
EndIf
  
; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 85
; FirstLine = 43
; Folding = -
; EnableXP