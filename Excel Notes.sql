
############################################################
# Part #1 Excel formulae notes :

# Copied from D:\Simon\MMC\Misc\Work\Notes\Notes.txt

### NEW SECTION 2021 - merge to other versions

Prefix before (FIRST instance of) a seperator char (eg. "_") :
=LEFT(A4,FIND("_",A4)-1)

Suffix after (FIRST instance of) a seperator char (eg. "_"):
=RIGHT(A3,LEN(A3)-FIND("_",A3)) 

Suffix after (LAST instance of) a seperator char (eg. "_"):
=TRIM(RIGHT(SUBSTITUTE(A4,"_",REPT(" ",100)),100))

##

=XLOOKUP(F751,$F$98:$F$114,$G$98:$G$114,"[NONE]",1,1)
- v useful that return_array (2nd)  can be to the left of lookup_array, unlike VLOOKUP!
- "[NONE]",1,1 are good defaults here. 
- First 1:  match mode = 1 (exact) / OR 2 allows wildcard ? or * matches in the lookup_array (first)  
- 2nd 1:  search mode = 1 -> forwards in lookup_array not backwards (upwards) / not sure how useful that may be.
 
##

Column grouping:
select column A, and then hold Shift + Alt + Right arrow 
https://www.educba.com/grouping-columns-in-excel/

###  Carriage returns in formulae:
Add a carriage return in a formula: & CHAR(10)
Search / replace for carriage return: CTRL + J
BUT can`t get this working in the SEARCH function eg. =SEARCH("_ID"&CHAR(10),G3)

### array formulae
https://support.microsoft.com/en-us/office/guidelines-and-examples-of-array-formulas-7d94a64e-3fF3-4686-9372-ecfd5caa57c7
 
An array formula is a formula that can perform multiple calculations on one or more items in an array. You can think of an array as a row or column of values, or a combination of rows and columns of values. Array formulas can return either multiple results, or a single result.

Beginning with the September 2018 update for Microsoft 365, any formula that can return multiple results will automatically spill them either down, or across into neighboring cells. This change in behavior is also accompanied by several new dynamic array functions. Dynamic array formulas, whether they’re using existing functions or the dynamic array functions, only need to be input into a single cell, then confirmed by pressing Enter. Earlier, legacy array formulas require first selecting the entire output range, then confirming the formula with Ctrl+Shift+Enter. They’re commonly referred to as CSE formulas.

=IFERROR(INDEX($D$3:$D$1550, SMALL(IF($H3=$F$3:$F$1550, ROW($F$3:$F$1550)-MIN(ROW($F$3:$F$1550))+1, ""), K$2)),0)

=IFERROR(INDEX($F$2:$F$555, MATCH(0, COUNTIF($G$1:G1, $F$2:$F$555), 0)),0)
-> Ctrl+Shift+Enter for array {}, then drag down until stops giving values

PK: A->F , Unique list: C->G, Sample data: B->D , New seq: D1->h1
=IFERROR(INDEX($B$1:$B$9,   SMALL(IF($C2=$A$1:$A$9, ROW($A$1:$A$9)-MIN(ROW($A$1:$A$9))+1, ""), D$1)),0)
=IFERROR(INDEX($D$2:$d$555, SMALL(IF($G2=$f$2:$f$555, ROW($f$2:$f$555)-MIN(ROW($f$2:$f$555))+1, ""), h$1)),0)

PK: A->F , Unique list: C->H, Sample data: B->D , New seq: D1->K2
=IFERROR(INDEX($D$3:$D$556, SMALL(IF($H3=$F$3:$F$556, ROW($F$3:$F$556)-MIN(ROW($F$3:$F$556))+1, ""), K$2)),"")
=IFERROR(INDEX($D$3:$D$556, SMALL(IF($H3=$F$3:$F$556, ROW($F$3:$F$556)-MIN(ROW($F$3:$F$556))+1, ""), K$2)),0)
-> Ctrl+Shift+Enter for array {}, then drag down until stops giving values


Merge columns (Filtered) inserting a separator:
=TEXTJOIN(" | ";1; FILTER(K3:T3; K3:T3 <> 0))

## How to get-a-list-of-all-worksheet-names-in-an-excel-workbook

Formulas -> Names -> ListSHeets :
=REPLACE(GET.WORKBOOK(1),1,FIND("]",GET.WORKBOOK(1)),"")
- now saved on ING - all Workbooks?

Then A1:A10 =1..10 and 
B1..B10 = =INDEX(ListSheets,A1)
https://www.datanumen.com/blogs/3-quick-ways-to-get-a-list-of-all-worksheet-names-in-an-excel-workbook/

https://support.microsoft.com/en-us/office/create-custom-functions-in-excel-2f06c10b-3622-40d6-a1b2-b6748ae8231f?ui=en-us&rs=en-us&ad=us


--######### SQL Build notes - see Notes.xlsx (in same folder as this?) for templates ##########

--### SQL Build 1 - Union of table counts grouped by a set value in $N$1
 - that can also be like: to_char(AVAIL_FROM_TMS,'YYYY') ||'-'|| to_char(AVAIL_FROM_TMS,'WW') 

=CONCATENATE("UNION ALL SELECT '",E120,"' as SCHEMA_NAME, '",F120,"'",REPT(" ",20-LEN(F120))," as TABLE_NAME, '", SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE($N$1,"||'-'||","#"),"'YYYY-MM-DD'",""),"(","#"),",","#"),")",""),"' as GROUP_NAME, ",$N$1," as GROUP_VALUE", ", count(*) as ROW_COUNT FROM ",E120,".",F120,REPT(" ",20-LEN(F120))," GROUP BY  ",$N$1)

--### SQL Build 2 - Union of table SUM(CASE( counts defined in $0$1
 - $0$1 eg.: 'as TABLE_NAME  , SUM(CASE WHEN  to_char(AVAIL_FROM_TMS,'YYYY-MM-DD') < '2022-06-22'       AND  .. '
 
 
--###' SQL Build 3 - constraint DDL with line breaks' :

 =CONCATENATE(
CHAR(10),",    CONSTRAINT FEC_",F97,"_LND_PK PRIMARY KEY (",F97,"_ID, EXTRACT_DT)
USING INDEX ( CREATE INDEX DM_COMPL.FEC_",F97,"_LND_",F97,"_ID_IDX 
  ON DM_COMPL.FEC_",F97,"_LND (",F97,"_ID,EXTRACT_DT) )
 )
PCTFREE 0 ;
GRANT ALL ON DM_COMPL.FEC_",F97,"_LND TO PUBLIC ;
")
 
=CONCATENATE("UNION ALL SELECT '",E97,"' as SCHEMA_NAME, '",F97,"'",REPT(" ",20-LEN(F97)),$O$1,E97,".",F97)

--### SQL Build 4 - Summary data SQL

=CONCAT("SELECT '",D4,"' as table_name, '",C4,"' as column_name,  max(length(TRIM(",C4,"))) as max_length , min(length(TRIM(",C4,"))) as min_length, count(1) as row_count , SUM(CASE WHEN (",C4," IS NULL) THEN 1 END) as null_count FROM ",D4," UNION")


--### SQL Build 5 - Insert .. values

INSERT INTO TIP_BRNCH (ODS_BUSINESS_DATE, BRANCH_CD, BRANCH_COUNTRY_CODE, NAME_ADDRESS_LINE1) VALUES 
, ('20220301000000', 'AT', 'AT', 'ING Bank')

--INSERT bit :
=CONCATENATE("INSERT INTO ",$B$4," (",C3,", ",D3,", ",E3,", ",F3,") VALUES ")
--VALUES bit, with C$2 being optional ' for non-numerics only :
=CONCATENATE(", (",C$2,C4,C$2,", ",D$2,D4,D$2,", ",E$2,E4,E$2,", ",F$2,F4,F$2,")")


--OR .. UPDATE option:
=CONCATENATE("UPDATE ",$B$4," SET ",D$3," = ",D$2,D4,D$2,", ",E$3," = ",E$2,E4,E$2,", ",F$3," = ",F$2,F4,F$2," WHERE ODS_ID = ",C4,";")


=CONCATENATE("INSERT INTO ",$B$4," (",C3,", ",D3,", ",E3,", ",F3,") VALUES ")

#### Run a macro from a Hyperlinked cell that detectc when the cell area is clicked

Private Sub Worksheet_FollowHyperlink(ByVal Target As Hyperlink)
    'Check if the Target Address is same as you have given
    'In the above example i have taken D1 Cell, so I am
         
    If Target.Range.Address = "$D$1" Then
        'Call the function or Macro which you have written or recorded.
     Select Case MsgBox("Rule rows will now be generated. Make sure to save before running. Then if not happy with results close without saving and re-open unsaved version!", vbOKCancel, "Confirm if you want generator macro to run?")
    Case vbOK
       ' MsgBox "Your Code here to be executed"
       Call CopyData
    Case vbCancel
        MsgBox "Macro not run."
      End Select
        Exit Sub
    End If
End Sub


'MsgBox (" Column to hide/unhide: " + CStr(hideValue) + " ")'
    If hideValue = "hideAll" Then
       hideColumn = "True"
      ' MsgBox "True"
    ElseIf hideValue = "unHideAll" Then
       hideColumn = "False"
      ' MsgBox "false"
    Else: hideColumn = "Not c.EntireColumn.Hidden"
       MsgBox "Toggle"
    End If

##### Excel hide columns based cell value - investigate?
https://www.excelcampus.com/vba/vba-macro-hide-columns-containing-value/


Private Sub Worksheet_FollowHyperlink(ByVal Target As Hyperlink)
   Select Case Target.Range.Address
       Case "$B$4"
         Call Hide_Columns_Containing_Value("A4")
       Case "$B$5"
         Call Hide_Columns_Containing_Value("A5")
       Case "$B$6"
         Call Hide_Columns_Containing_Value("A6")
       Case "$B$7"
         Call Hide_Columns_Containing_Value("A7")
    ' If Target.Range.Address = "$B$4" Then '
     End Select
End Sub

Sub Hide_Columns_Containing_Value(hideValueCell As String)
'Description: This macro will loop through a row and hide the column if the cell in row 1 of the column has the value of X.
'Author: Jon Acampora, Excel Campus
    
Dim c As Range
Dim hideValue, hideColumn As String
hideValue = Range(hideValueCell).Value

    For Each c In Range("C4:BZ4").Cells
        If c.Value = hideValue Then
            c.EntireColumn.Hidden = Not c.EntireColumn.Hidden
            'You can change the property above to True / False to hide / unhide the columns.'
            ElseIf IsNumeric(c.Value) And hideValue = "unHideAll" Then
              c.EntireColumn.Hidden = False
            ElseIf IsNumeric(c.Value) And hideValue = "hideAll" Then
              c.EntireColumn.Hidden = True
        End If
    Next c
End Sub

usage:
A4-A7:
1
2
hideAll
unHideAll

B4-B7: Hide/unhide (hyper linked to same cell which then has behind it with this:)

Private Sub Worksheet_FollowHyperlink(ByVal Target As Hyperlink)
     If Target.Range.Address = "$B$4" Then Hide_Columns_Containing_Value(A4)

--#######################

OR Array approach to get a list of columns from a cell:
https://stackoverflow.com/questions/21268383/put-entire-column-each-value-in-column-in-an-array
https://www.educba.com/vba-string-array/

Sub Column_Hide_Cell_Value()
    Dim k As Integer
    For k = 6 To 11
        If Cells(1, k).Value = "H" Then
           Columns(k).Hidden = False
        End If
    Next k
End Sub


--############## Part #2 - Older

# If using conditional formatting, to have a list of values, use "Formula is" :
= IF(D5="Manual",1,IF(D5="REMOVE",1, IF(D5="On Hold",1,0 ) ))

# if doing a row by row diff and you want to check if a cell is different to the cell above,
# do this in conditional formatting and then copy formats to all cells! +++++
= IF(a2<>a3,1,0)

# Given cell C8 which is the CURRENT day number of the month ( =TEXT(TODAY(),"dd") ), work out

= IF(WEEKDAY(TODAY()-C8,2)>=6,
         TEXT(TODAY()-C8-WEEKDAY(TODAY()-C8,2)+5,"yyyymmdd"),
               TEXT(TODAY()-C8-0,"yyyymmdd"))

# Or all in one cell / calculation:
= IF(WEEKDAY(TODAY()-TEXT(TODAY(),"dd"),2)>=6,
         TEXT(TODAY()-TEXT(TODAY(),"dd")-WEEKDAY(TODAY()-TEXT(TODAY(),"dd"),2)+5,"yyyymmdd"),
               TEXT(TODAY()-TEXT(TODAY(),"dd")-0,"yyyymmdd"))

reference - Status options list :
Red:
= IF(mid(a3,1,1)="2",1,IF(mid(a3,1,1)="6",1, IF(mid(a3,1,1)="6",1,0 ) ))

Orange:
= IF(mid(a3,1,1)="1",1,IF(mid(a3,1,1)="3",1, IF(mid(a3,1,1)="4",1,0 ) ))

Green
= IF(mid(a3,1,1)="5",1,IF(mid(a3,1,1)="8",1, IF(mid(a3,1,1)="9",1,0 ) ))

#
= IF(LEN(G4)<=F4-1,G4&REPT("#",F4-LEN(G4)-1)&"-",REPT("#",F4-1)&"-")

= IF(F5>9,"+"&TEXT(C5,"000")&"-"&TEXT(D5,"000")&REPT("#",F5-3-6)&"-", REPT("+",F5-1)&"-")

# Search for instances of a list of strings in cell and return a decode. Like a "case in" statement. VERY USEFUL

# here for output of dir / tree /AF command pasteed into Excel:
=IF(COUNT(SEARCH({"--","xyz"}, b56))>0, "Directory",
  IF(COUNT(SEARCH({".ppt","xyz"}, b56))>0, "Powerpoint",
  IF(COUNT(SEARCH({".xls","xyz"}, b56))>0, "Excel",
  IF(COUNT(SEARCH({".zip",".json",".tar",".dsx"}, b56))>0, "Zip / json / tar / dsx",
  IF(COUNT(SEARCH({".doc",".pdf",".msg"}, b56))>0, "Word / pdf / .msg",
  IF(COUNT(SEARCH({".txt",".csv"}, b56))>0, "Text / csv",
  IF(COUNT(SEARCH({".sql","xyz"}, b56))>0, ".sql",
  IF(COUNT(SEARCH({"    |","xyz"}, b56))>0, "Other 1",
  "OTHER"))))))))


=SWITCH(e41,
"Agreement data","Relationship",
"Party data","Customer",
"Pricing data","Reference",
"[OTHER]")
  
# To CONCATENATE a vertical range with spacers:
1) copy this formula text "=CONCATENATE(TRANSPOSE(B218:B222)&" OR ") " into the one below it
2) Select the .. Portion in CONCAT(..) and press F9. which replaces the TRANSPOSE with its result
3)  Now remove curly brackets - voila!
http://chandoo.org/wp/2014/01/13/combine-text-values-quick-tip/


####

Outlook Customizations (olkexplorer).exportedUI

<mso:cmd app="olkexplorer" dt="0" slr="0" /><mso:customUI xmlns:mso="http://schemas.microsoft.com/office/2009/07/customui"><mso:ribbon><mso:qat><mso:sharedControls><mso:control idQ="mso:FilePrint" visible="false"/><mso:control idQ="mso:FileSaveAs" visible="false"/><mso:control idQ="mso:SendReceiveAll" visible="true"/><mso:control idQ="mso:UpdateFolder" visible="false"/><mso:control idQ="mso:Reply" visible="false"/><mso:control idQ="mso:ReplyAll" visible="false"/><mso:control idQ="mso:Forward" visible="false"/><mso:control idQ="mso:Delete" visible="false"/><mso:control idQ="mso:Undo" visible="false"/><mso:control idQ="mso:EmptyTrash" visible="false"/><mso:control idQ="mso:PointerModeOptions" visible="false"/><mso:control idQ="mso:FindContactCombo" visible="false"/><mso:control idQ="mso:MinimizeRibbon" visible="false"/><mso:control idQ="mso:RulesAndAlerts" visible="true"/><mso:control idQ="mso:FlagThisWeek" visible="true"/><mso:control idQ="mso:AddReminder" visible="true"/><mso:control idQ="mso:ClearFlag" visible="true"/><mso:control idQ="mso:MarkTaskComplete" visible="true"/><mso:control idQ="mso:CurrentViewSettings" visible="true"/><mso:control idQ="mso:ShowInConversations" visible="true"/><mso:control idQ="mso:ConversationsMenu" visible="true"/></mso:sharedControls></mso:qat></mso:ribbon></mso:customUI>

Excel Customizations2.exportedUI

<mso:cmd app="Excel" dt="1" /><mso:customUI xmlns:mso="http://schemas.microsoft.com/office/2009/07/customui"><mso:ribbon><mso:qat><mso:sharedControls><mso:control idQ="mso:FileNewDefault" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:FileOpenUsingBackstage" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:FileSave" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:FileSendAsAttachment" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:FilePrintQuick" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:PrintPreviewAndPrint" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:Spelling" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:Undo" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:Redo" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:SortAscendingExcel" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:SortDescendingExcel" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:PointerModeOptions" visible="false" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:ColumnWidthAutoFit" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:RowHeightAutoFit" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:WrapText" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:ViewFreezePanesGallery" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:Filter" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:SortClear" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:ConditionalFormattingMenu" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:DataValidation" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:MinimizeRibbon" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:BordersAll" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:BorderThickOutside" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:SortFilterMenu" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:FontSizeDecrease" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:FontSizeIncrease" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:RowHeight" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:DecimalsDecrease" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:Strikethrough" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:RemoveDuplicates" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:ReviewNewComment" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:PivotTableChangeDataSource" visible="true" insertBeforeQ="mso:AutoSaveSwitch"/><mso:control idQ="mso:AutoSaveSwitch" visible="true"/></mso:sharedControls></mso:qat><mso:tabs><mso:tab idQ="mso:TabDrawInk" visible="false"/></mso:tabs></mso:ribbon></mso:customUI>




--#### --------------------------------------- recent macros

'DQ Rule Generator 

Sub DQRuleGenerator()
Dim lRow As Long
Dim RepeatFactor As Variant, ColourNum, ColourNumNext, ColourLastNext
Dim Message As String, RepeatFactorCol As String, FirstCol As String, LastCol As String, SeqCol As String
'
lRow = 3             '# First row of data ie below header and other info
SeqCol = "Z"          '# Where to put the "Rule seq no."
RepeatFactorCol = "AB" '# The rule count column ie no of times to duplicate the rule row
FirstCol = "A"         '# First column of data to duplicate down - usually A / sometimes B
LastCol = "BM"         '# Last column of data to duplicate down
'
ColourNum = 2
ColourNumNext = 19
'Colours : White / Light blue / yellow / orange : 2 / 34 / 19 / 40'
Do While (Cells(lRow, FirstCol) <> "" And lRow < 200)
    RepeatFactor = Cells(lRow, RepeatFactorCol)
    If ((RepeatFactor > 1) And IsNumeric(RepeatFactor)) Then
        Range(Cells(lRow, FirstCol), Cells(lRow, LastCol)).Copy
        Range(Cells(lRow + 1, FirstCol), Cells(lRow + RepeatFactor - 1, LastCol)).Select
        Selection.Insert Shift:=xlDown
      For j = 0 To RepeatFactor - 1 Step 1
'         MsgBox ( " lRow: " + CStr(lRow) + " j: " + CStr(j) )'
          Cells(lRow + j, SeqCol).Value = j + 1
      Next
        'Cells(lRow + 1, SeqCol).Value = lRow'
        lRow = lRow + RepeatFactor - 1
      End If
        '# Alternating block colours'
           ColourNumLast = ColourNum
           ColourNum = ColourNumNext
           ColourNumNext = ColourNumLast
           Range(Cells(lRow - RepeatFactor + 1, FirstCol), Cells(lRow, LastCol)).Select
        With Selection
          .Interior.ColorIndex = ColourNum
          '.Interior.Pattern = xlSolid'
            .Borders.LineStyle = xlDot
            .Borders.Weight = xlThin
            .BorderAround LineStyle:=xlContinuous, Weight:=xlMedium
       End With
    lRow = lRow + 1
Loop
End Sub


Private Sub Worksheet_FollowHyperlink(ByVal Target As Hyperlink)
'### create a linked cell to run the DQRuleGenerator macro above
    'Check if the Target Address is same as you have given
    'In the above example i have taken D1 Cell, so I am'
         
    If Target.Range.Address = "$D$1" Then
        'Write your all VBA Code, which you want to execute'
        'Or Call the function or Macro which you have
        'written or recorded.
     Select Case MsgBox("Rule rows will now be generated. Make sure to save before running. Then if not happy with results close without saving and re-open unsaved version!", vbOKCancel, "Confirm if you want generator macro to run?")
    Case vbOK
       ' MsgBox "Your Code here to be executed" '
       Call DQRuleGenerator
    Case vbCancel
        MsgBox "Macro not run."
      End Select
        Exit Sub
    End If
End Sub
    
Private Sub ReportSave()
'### save the DQRuleGenerator to a named file with mutliple sheets? WIP and never really used - TBD.'

    Filename = "_ComparisonResult_" & Format(Now, "ddmmmyy") & "_" & Format(Now, "hhmm") & ".xlsx"

    Dim DstFile As String 'Destination File Name

    'Copy worksheet
    Application.ScreenUpdating = False
    Dim wb As Workbook

    'Sheets(Array("Reference", "Actual", "InRef_NotInAct", "InAct_NotInRef", "Summary", "Key")).Select
    Sheets(Array("Files", "Reference", "Actual", "InRef_NotInAct", "InAct_NotInRef", "Summary", "Key")).Copy

    Set wb = ActiveWorkbook

    'Prompt for SaveAs name
    DstFile = Application.GetSaveAsFilename _
    (InitialFileName:=Filename, _
    Title:="Save As")

    If DstFile = "False" Then
        MsgBox "File not Saved, Actions Cancelled."
        Exit Sub
        Else
        wb.SaveAs DstFile 'Save file
        'wb.Close 'Close file
    End If

    MsgBox ("File Saved")
    Application.ScreenUpdating = True

End Sub


'################################################

Sub CombineCSV()
' Combines mutliple csv file from a dir into one file with many named and formatted sheets'

Dim SavePath As String
Dim SaveFile As String

Dim WorkbookCurrent As Workbook
Dim WorkbookDest As Workbook


SavePath = "T:\Oracle\FEC - sample data\ "
Set WorkbookDest = Excel.Application.Workbooks.Add
' Set WorkbookDest = ThisWorkbook'
Application.ScreenUpdating = False
SaveFile = Dir$(SavePath & "*.csv", vbArchive)

Do While SaveFile <> ""
      Set WorkbookCurrent = Application.Workbooks.Open(SavePath & SaveFile)
  With WorkbookCurrent
      .Sheets(1).Select
'      .Sheets(1).Range("A1").EntireRow.Delete'
      .Sheets(1).Range("A1").EntireRow.Font.Bold = True

      .Sheets(1).Range(Selection, Selection.End(xlDown)).Select
      .Sheets(1).Range(Selection, Selection.End(xlToRight)).Select
       Selection.Columns.AutoFit

       Rows("1:1").Select
       Selection.AutoFilter
        
       Selection.Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
           Selection.WrapText = True
          With Selection.Font
            .name = "Calibri"
            .Size = 10
            .Bold = True
            .ThemeColor = xlThemeColorAccent1
            .TintAndShade = -0.499984740745262
        End With
        Selection.Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove

       Rows("4").Select
       ActiveWindow.FreezePanes = True

'     .Sheets(1).Name = Mid(.Name, 1, Len(.Name) - 4)'
      .Sheets(1).Range("A1").Select
      .Sheets(1).Copy After:=WorkbookDest.Sheets(WorkbookDest.Sheets.Count)
      .Saved = True
      .Close
  End With
  SaveFile = Dir$()
Loop

    Sheets("Sheet1").Select
    ActiveWindow.SelectedSheets.Delete

' ActiveWorkbook.SaveAs Filename:= _
                   "T:\Oracle\FEC - sample data\combined.xlsx" _
        , FileFormat:=xlNormal, Password:="", WriteResPassword:="", ReadOnlyRecommended:=False, CreateBackup:=False

' ActiveWorkbook.Close

Application.ScreenUpdating = True
End Sub

' List all the sheet names of the current open workbook. Listed in a new workbook that you can just close without saving once results are copied.'
Sub ListSheetNamesInNewWorkbook()
    Dim objNewWorkbook As Workbook
    Dim objNewWorksheet As Worksheet
    Dim objCountWorkbook As Workbook
    
    Set objCountWorkbook = ActiveWorkbook
    Set objNewWorkbook = Excel.Application.Workbooks.Add
    Set objNewWorksheet = objNewWorkbook.Sheets(1)
    
    For i = 1 To objCountWorkbook.Sheets.Count
        objNewWorksheet.Cells(i, 1) = i
        objNewWorksheet.Cells(i, 2) = objCountWorkbook.Sheets(i).name
    Next i
    With objNewWorksheet
         .Rows(1).Insert
         .Cells(1, 1) = "Sheet number"
         .Cells(1, 1).Font.Bold = True
         .Cells(1, 2) = "Sheet Name"
         .Cells(1, 2).Font.Bold = True
         .Columns("A:B").AutoFit
    End With
End Sub



Public Function GetColumnLetter(colNum As Integer) As String
' for eg. This would be called in a cell with: =Personal.xlsb!GetColumnLetter(2)
' https://stackoverflow.com/questions/31815205/use-personal-xlsb-function-in-new-workbook
'https://www.myonlinetraininghub.com/creating-a-reference-to-personal-xlsb-for-user-defined-functions-udfs
' https://www.ablebits.com/office-addins-blog/2020/03/04/excel-personal-macro-workbook/

    Dim d As Integer
    Dim m As Integer
    Dim name As String
    d = colNum
    name = ""
    Do While (d > 0)
        m = (d - 1) Mod 26
        name = Chr(65 + m) + name
        d = Int((d - m) / 26)
    Loop
    GetColumnLetter = name
End Function



--#################


SMS creation macro - by Debarshi - NEW as at Nov-21

'Private Sub Worksheet_Activate()
'Dim data_sh As Worksheet
'Set data_sh = ThisWorkbook.Sheets("Data Sheet")
'
'data_sh.Range("a2:xfd1048576").ClearContents
'ThisWorkbook.Sheets("Temp").Range("a1:xfd1048576").ClearContents
'    Set obj = CreateObject("Excel.Application")
'    Set cde_approval = obj.Workbooks.Open(Sheet2.Cells(2, 4).Value)
'    Set CDE_Approval_DataSheet = cde_approval.Worksheets(Sheet2.Cells(3, 4).Value)
'    obj.Visible = True
'
'
'    'begin row
'    RowIndx = 2
'    'empty cell indicator
'    EmptyCell = False
'
'    SoR_Name = Sheet2.Cells(4, 4).Value
'    BusinessDataSteward = Sheet2.Cells(5, 4).Value
'    ExecutiveDataSteward = Sheet2.Cells(6, 4).Value
'    OriginalMappingFile = Sheet2.Cells(7, 4).Value
'    OriginalMappingFile_Sheet = Sheet2.Cells(8, 4).Value
'    IGC_BT_ExtractFile = Sheet2.Cells(9, 4).Value
'    IGC_BT_ExtractFile_Sheet = Sheet2.Cells(10, 4).Value
'
'    'Set obj2 = CreateObject("Excel.Application")
'
'    'Set obj3 = CreateObject("Excel.Application")
'
'    Set omf = obj.Workbooks.Open(OriginalMappingFile)
'    Set OMF_Sheet = omf.Worksheets(OriginalMappingFile_Sheet)
'
'
'    Set IGC = obj.Workbooks.Open(IGC_BT_ExtractFile)
'    Set IGC_Sheet = IGC.Worksheets(IGC_BT_ExtractFile_Sheet)
'    Dim R As Range
'    Dim cnt As Integer
'    Dim I As Long
'    TempRowIndx = 1
'
'    While Not EmptyCell
'        'If tablename is blank for any row in the source file, treated as blank file
'        If IsEmpty(CDE_Approval_DataSheet.Cells(RowIndx, 1)) Then
'            EmptyCell = True
'        Else
'            'SOR Name to be added in the target sheet first column
'            Sheet1.Cells(RowIndx, 1).Value = SoR_Name
'
'            'Populate remaining source fields data to target sheet
'
'            Sheet1.Cells(RowIndx, 2).Value = CDE_Approval_DataSheet.Cells(RowIndx, 1).Value
'            Sheet1.Cells(RowIndx, 5).Value = CDE_Approval_DataSheet.Cells(RowIndx, 2).Value
'            Sheet1.Cells(RowIndx, 6).Value = CDE_Approval_DataSheet.Cells(RowIndx, 3).Value
'            Sheet1.Cells(RowIndx, 7).Value = BusinessDataSteward
'            Sheet1.Cells(RowIndx, 8).Value = ExecutiveDataSteward
'            Set OMF_FilterRangeCells = OMF_Sheet.Cells.Range("A:W")
'            'MsgBox (CDE_Approval_DataSheet.Cells(RowIndx, 1).Value)
'
'            With OMF_FilterRangeCells
'                .AutoFilter Field:=22, Criteria1:=CDE_Approval_DataSheet.Cells(RowIndx, 1).Value
'                .AutoFilter Field:=23, Criteria1:=CDE_Approval_DataSheet.Cells(RowIndx, 2).Value
'                .AutoFilter Field:=15, Criteria1:="Functional"
'                cnt = .SpecialCells(xlCellTypeVisible).Rows.Count
'                'MsgBox ("Count of Rows: " & cnt)
'                I = -1
'                Set d = CreateObject("Scripting.Dictionary")
'
'                For Each R In .SpecialCells(xlCellTypeVisible).Rows
'                    I = I + 1
'                    If I = 0 Then ' For ignoring header row
'                     GoTo SkipAndGoToNextIteration
'                    End If
'                    If I > cnt Or Len(Trim(R.Cells(R.Row, 19).Value)) = 0 Then
'                        Exit For
'                    End If
'                    'MsgBox ("Value: " & R.Cells(1, 19).Value)
'                    'MsgBox ("Length: " & Len(Trim(R.Cells(1, 19).Value)))
'                    d(R.Cells(R.Row, 19).Value) = 1
'SkipAndGoToNextIteration:
'                Next R
'                    Dim aKeys() As Variant
'                    aKeys = d.Keys
'
'                    For I = 1 To d.Count
'                        'MsgBox ("Filtering Criteria in IGC_BT_Extract:" & aKeys(I - 1))
'                        Set IGC_FilterRangeCells = IGC_Sheet.Cells.Range("A:F")
'                        With IGC_FilterRangeCells
'                            .AutoFilter Field:=3, Criteria1:=aKeys(I - 1)
'                            cnt2 = .SpecialCells(xlCellTypeVisible).Rows.Count
'                            On Error Resume Next
'                            For Each r2 In .SpecialCells(xlCellTypeVisible).Rows
'                                'To break the Inner For loop when there is no value in Column I of IGC_BT_Extract
'                                If Len(Trim(r2.Cells(2, 2).Value)) = 0 Then
'                                    GoTo innerForEachLoop
'                                End If
'                                'MsgBox ("RowIndx: " & RowIndx & "I Value: " & Trim(R2.Cells(2, 2).Value))
'                                Sheet1.Cells(RowIndx, 9).Value = Trim(r2.Cells(r2.Row + 1, 2).Value)
'                                Sheet1.Cells(RowIndx, 11).Value = Trim(r2.Cells(r2.Row + 1, 3).Value)
'                                Sheet1.Cells(RowIndx, 10).Value = Trim(r2.Cells(r2.Row + 1, 4).Value)
'                                'MsgBox ("Column I: " & R2.Cells(2, 2).Value & "::Len: " & Len(Trim(R2.Cells(2, 2).Value)))
'                                Sheet3.Cells(TempRowIndx, 1).Value = Sheet1.Cells(RowIndx, 2).Value
'                                Sheet3.Cells(TempRowIndx, 2).Value = Sheet1.Cells(RowIndx, 5).Value
'                                Sheet3.Cells(TempRowIndx, 3).Value = Sheet1.Cells(RowIndx, 6).Value
'                                Sheet3.Cells(TempRowIndx, 4).Value = Sheet1.Cells(RowIndx, 7).Value
'                                Sheet3.Cells(TempRowIndx, 5).Value = Sheet1.Cells(RowIndx, 8).Value
'                                Sheet3.Cells(TempRowIndx, 6).Value = Trim(r2.Cells(r2.Row + 1, 2).Value)
'                                Sheet3.Cells(TempRowIndx, 7).Value = Trim(r2.Cells(r2.Row + 1, 4).Value)
'                                Sheet3.Cells(TempRowIndx, 8).Value = Trim(r2.Cells(r2.Row + 1, 3).Value)
'                                'Sheet3.Cells(TempRowIndx, 9).Value = Sheet1.Cells(RowIndx, 2).Value
'                                TempRowIndx = TempRowIndx + 1
'                                RowIndx = RowIndx + 1
'                                'MsgBox (I2)
'                            Next
'innerForEachLoop:
'                        RowIndx = RowIndx + 1
'
'                        End With
'                        IGC_FilterRangeCells.ShowAllData
'
'
'                    Next
'            End With
'            Set OMF_FilterRangeCells = Nothing
'        End If
'        RowIndx = RowIndx + 1
'    Wend
'
'    If RowIndx = 2 And EmptyCell Then
'        MsgBox "Empty Source file!!"
'    Else
'        MsgBox "Population of the data completed!"
'    End If
'
'    'Close and Clean up
'    omf.Close SaveChanges:=False
'    IGC.Close SaveChanges:=False
'    cde_approval.Close SaveChanges:=True
'    obj.Quit
'    Set obj = Nothing
'    Set omf = Nothing
'    Set IGC = Nothing
'    Set cde_approval = Nothing
'    Set CDE_Approval_DataSheet = Nothing
'    Set OMF_Sheet = Nothing
'    Set IGC_Sheet = Nothing
'
'    Dim lstrow As Long
'
'    Dim row_count As Long
'
'
'    lstrow = data_sh.Cells(Rows.Count, "I").End(xlUp).Row
'
'    For row_count = 2 To lstrow
'
'        data_sh.Range("I" & row_count).Select
'        If row_count - 1 <> 1 And data_sh.Range("I" & row_count - 1).Value = "" Then
'
'            data_sh.Range("I" & row_count - 1).EntireRow.Delete
'        End If
'        lstrow2 = data_sh.Cells(Rows.Count, "I").End(xlUp).Row
'        If data_sh.Range("I" & row_count).Value = "" And data_sh.Range("I" & row_count + 1).Value = "" And data_sh.Range("I" & row_count + 2).Value = "" Then
'            Exit For
'        End If
'    Next row_count
'
'End Sub
