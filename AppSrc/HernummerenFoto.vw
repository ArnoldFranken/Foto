Use Windows.pkg
Use DFClient.pkg
Use BatchDD.pkg

Struct tFoto
    Integer iTeller
    String  sFile
    Integer iNieuw
    String  sFileNieuw
End_Struct

Deferred_View Activate_oHernummerenFoto for ;
Object oHernummerenFoto is a dbView

    Set Border_Style to Border_Thick
    Set Size to 99 300
    Set Location to 2 2
    Set Label to "Hernummeren foto's"

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

    Object oTellerVan is a Form
        Set Size to 12 37
        Set Location to 33 65
        Set Label to "Teller van:"
    End_Object

    Object oTellerTot is a Form
        Set Size to 12 37
        Set Location to 33 121
        Set Label to "t/m:"
        Set Label_Col_Offset to 0
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oInfo1 is a TextBox
        Set Size to 10 64
        Set Location to 56 7
        Set Label to "Hernummeren naar"
    End_Object

    Object oNieuwVan is a Form
        Set Size to 12 37
        Set Location to 69 65
        Set Label to "Teller van:"
    End_Object

    Object oBtnStart is a Button
        Set Location to 83 65
        Set Label to "Start"
    
        // fires when the button is clicked
        Procedure OnClick
            String sValue
            
            Get Value of oLocatie to sValue
            Set psLocatie of oHernummerenProcess to sValue
            
            Get Value of oAlbum to sValue
            Set psAlbum of oHernummerenProcess to sValue
            
            Get Value of oTellerVan to sValue
            Set piTellerVan of oHernummerenProcess to sValue
            
            Get Value of oTellerTot to sValue
            Set piTellerTot of oHernummerenProcess to sValue
            
            Get Value of oNieuwVan to sValue
            Set piNieuwVan of oHernummerenProcess to sValue
            
            Send DoProcess to oHernummerenProcess
        End_Procedure
    
    End_Object

    Object oHernummerenProcess is a BusinessProcess
    
        Property String  psLocatie
        Property String  psAlbum 
        Property Integer piTellerVan
        Property Integer piTellerTot
        Property Integer piNieuwVan

        Set Display_Error_State to True
        Set Process_Title to "Hernummeren foto"
        Set Process_Message to "Bestand"
    
        // Place your processing code into Procedure OnProcess
        Procedure OnProcess
            tFoto[] aFoto
            
            Set Error_Count to 0
            
            Get ScanAlbum to aFoto
            
            Get InitHernummeren aFoto to aFoto
            If (Error_Count(Self) > 0) ;
                Procedure_Return
            
            Send Hernummeren aFoto
        End_Procedure

        Function SortFoto tFoto Array1 tFoto Array2 Returns Integer
            If (Array1.iTeller > Array2.iTeller) Function_Return (GT)
            If (Array1.iTeller < Array2.iTeller) Function_Return (LT)
            Function_Return (EQ)
        End_Function
    
        Function ScanAlbum Returns tFoto[]
            Integer iTellerVan iTellerTot iPos iChnl iRow iTeller
            String  sLocatie sAlbum sFile
            tFoto[] aFoto

            Get psLocatie   to sLocatie
            Get psAlbum     to sAlbum
            Get piTellerVan to iTellerVan
            Get piTellerTot to iTellerTot
            
            If (iTellerTot = 0) ;
                Move 999 to iTellerTot
            
            Get Seq_New_Channel to iChnl
            
            Direct_Input channel iChnl ("DIR:" + sLocatie + "\" + sAlbum + "\*.jpg")
            Readln channel iChnl sFile
            While (not(SeqEof))
                Move (Pos("-", sFile)) to iPos                
                Move (Mid(sFile, 3, iPos+1)) to iTeller
                
                If ((iTeller >= iTellerVan) and (iTeller <= iTellerTot)) Begin
                    Move (sLocatie + "\" + sAlbum + "\" + sFile)    to aFoto[iRow].sFile
                    Move iTeller                                    to aFoto[iRow].iTeller
                    Increment iRow
                End
                
                Readln channel iChnl sFile
            Loop 
            Close_Input channel iChnl
            
            Send Seq_Release_Channel iChnl
        
            Move (SortArray(aFoto, Self, RefFunc(SortFoto))) to aFoto
            Function_Return aFoto
        End_Function
        
        Function InitHernummeren tFoto[] aFoto Returns tFoto[]
            String  sLocatie sAlbum sFile
            Integer iTellerVan iNieuwVan
            Integer iRow iNumRow
            Boolean bExist
            
            Get psLocatie   to sLocatie
            Get psAlbum     to sAlbum
            Get piTellerVan to iTellerVan
            Get piNieuwVan  to iNieuwVan
            
            Move (SizeOfArray(aFoto) - 1) to iNumRow
            for iRow from 0 to iNumRow
                Move (aFoto[iRow].iTeller - iTellerVan + iNieuwVan) to aFoto[iRow].iNieuw
                
                Move (sLocatie + "\" + sAlbum + "\" + sAlbum + "-" + Right("000"+String(aFoto[iRow].iNieuw), 3) + ".jpg") to sFile
                File_Exist sFile  bExist
                If (bExist) ;
                    Send UserError ('"' + sFile + '" bestaat al, hernummeren afgebroken.')
                Else ;
                    Move sFile to aFoto[iRow].sFileNieuw
            Loop
            
            Function_Return aFoto
        End_Function
        
        Procedure Hernummeren tFoto[] aFoto
            String  sLocatie sAlbum sFile
            Integer iRow iNumRow
            Boolean bExist

            Get psLocatie   to sLocatie
            Get psAlbum     to sAlbum

            Move (SizeOfArray(aFoto) - 1) to iNumRow
            For iRow from 0 to iNumRow
                Send Update_Status aFoto[iRow].sFile
                
                CopyFile aFoto[iRow].sFile to aFoto[iRow].sFileNieuw
                File_Exist aFoto[iRow].sFileNieuw bExist
                If (bExist) ;
                    EraseFile aFoto[iRow].sFile
            Loop
        End_Procedure
    
    End_Object

Cd_End_Object
