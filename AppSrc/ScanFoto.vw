Use Windows.pkg
Use DFClient.pkg
Use cSelectFolderDialog.pkg
Use cTimer.pkg

Activate_View Activate_oScanFoto for oScanFoto
Object oScanFoto is a dbView

    Set Border_Style to Border_Thick
    Set Size to 68 300
    Set Location to 2 2
    Set Label to "Scan foto's"
    Set pbAutoActivate to True
    Set piMaxSize to 68 300
    Set piMinSize to 68 300

    Object oFotoVerwerker is a cTimer
        Set pbEnabled to False
        
        Procedure OnTimer
            String  sLocatie sFile sAlbum sTeller
            Integer iChnl iTeller
            Number  nTeller
            Boolean bExist
            
            Get Value of oLocatie to sLocatie
            Move (Trim(sLocatie)) to sLocatie
            
            Get Value of oAlbum   to sAlbum
            Move (Trim(sAlbum))   to sAlbum
            
            Get Value of oTeller  to iTeller
            Move iTeller          to nTeller
            If ((nTeller / 2.0) = (iTeller / 2)) ;
                Set Label of oInfo to "Scan achterkant"
            Else ;
                Set Label of oInfo to "Scan voorkant"
                       
            Get Seq_New_Channel to iChnl
            
            Direct_Input channel iChnl ("DIR:" + sLocatie + "\IMG*.jpg")
            Readln channel iChnl sFile
            While (not(SeqEof))
                Move (Right("000"+String(iTeller), 3)) to sTeller
                
                File_Exist (sLocatie + "\" + sAlbum) bExist
                If not (bExist) ;
                    Make_Directory (sLocatie + "\" + sAlbum)

                CopyFile (sLocatie + "\" + sFile) to (sLocatie + "\" + sAlbum + "\" + sAlbum + "-" + sTeller + ".jpg")
                Increment iTeller
                Set Value of oTeller to iTeller
                EraseFile (sLocatie + "\" + sFile)
                
                Readln channel iChnl sFile
            Loop
            Close_Input channel iChnl
            
            Send Seq_Release_Channel iChnl
        End_Procedure
    End_Object

    Object oLocatie is a Form
        Set Location to 5 65
        Set Size to 12 229
        Set Label to "Locatie:"
        Set Prompt_Button_Mode to PB_PromptOn
        Set Value to "C:\Fotoboek"
        
        Procedure Prompt
            String sFolder
            Handle hoDialog
            
            // dynically create a cSelectFolderDialog object
            Get Create (RefClass(cSelectFolderDialog)) to hoDialog
            
            Get SelectFolder of hoDialog "Choose Folder" "C:\" to sFolder
            If (sFolder <> "") ;
                Set Value to  sFolder
            Else ;
                Send Info_Box "No Folder Selected"
            
            // destroy the dialog object
            Send Destroy of hoDialog
        End_Procedure
    End_Object
    
    
    Object oAlbum is a Form
        Set Size to 12 229
        Set Location to 19 65
        Set Label to "Album:"
    End_Object

    Object oTeller is a Form
        Set Size to 12 45
        Set Location to 33 65
        Set Label to "Teller"
    End_Object

    Object oInfo is a TextBox
        Set Auto_Size_State to False
        Set Size to 10 174
        Set Location to 34 118
        Set Label to ''
    End_Object

    Object oBtnStart is a Button
        Set Location to 51 65
        Set Label to "Start"
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bEnabled
        
            Get pbEnabled of oFotoVerwerker to bEnabled
            If (bEnabled) Begin
                Set Label to "Start"
                Set pbEnabled of oFotoVerwerker to False
                
                Set Enabled_State of oLocatie to True
                Set Enabled_State of oAlbum to True
                Set Enabled_State of oTeller to True
                Set Label of oInfo to ""
            End
            Else Begin
                Set Label to "Stop"
                Set pbEnabled of oFotoVerwerker to True

                Set Enabled_State of oLocatie to False
                Set Enabled_State of oAlbum to False
                Set Enabled_State of oTeller to False
                Set Label of oInfo to ""
            End
        End_Procedure
    
    End_Object


End_Object
