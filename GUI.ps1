Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(1080,370)
$form.StartPosition = 'CenterScreen'

#Labels--------------------------------------------------#
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(15,10)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'String to look for:'
$form.Controls.Add($label)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(15,65)
$label2.Size = New-Object System.Drawing.Size(280,20)
$label2.Text = 'Select folder or a file to search trough:'
$form.Controls.Add($label2)
#--------------------------------------------------------#

#input for word to look for--------------------------------------#
$wordToSearchFor = New-Object System.Windows.Forms.TextBox
$wordToSearchFor.Location = New-Object System.Drawing.Point(15,30)
$wordToSearchFor.Size = New-Object System.Drawing.Size(400,20)
$form.Controls.Add($wordToSearchFor)
#----------------------------------------------------------------#


#selector for the folder to search trough---------------------------------#
$openFolderSearch = New-Object System.Windows.Forms.Button
$openFolderSearch.Location = New-Object System.Drawing.Point(15,94)
$openFolderSearch.Size = New-Object System.Drawing.Size(200,22)
$openFolderSearch.Text = 'Folder'
$form.Controls.Add($openFolderSearch)
$searchFolder = [System.Windows.Forms.FolderBrowserDialog]::new()
$searchFolder.Description = 'Select folder to search trough'
$searchFolder.RootFolder = [System.Environment+specialfolder]::Desktop
$searchFolder.ShowNewFolderButton = $true
$openFolderSearch.Add_Click(
     {    
		$folderWasSelected = $searchFolder.ShowDialog()
        if ($folderWasSelected -eq [System.Windows.Forms.DialogResult]::OK)
            {
               $FolderPath.Text =  $searchFolder.SelectedPath
            }
        $searchFolder.Dispose()

     }

)
#-------------------------------------------------------------------------#

#selector for the file to search trough---------------------------------#
$openFileSearch = New-Object System.Windows.Forms.Button
$openFileSearch.Location = New-Object System.Drawing.Point(215,94)
$openFileSearch.Size = New-Object System.Drawing.Size(200,22)
$openFileSearch.Text = 'File'
$form.Controls.Add($openFileSearch)
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
$openFileSearch.Add_Click(
   {
   $fileWasSelected = $FileBrowser.ShowDialog()
   if ($fileWasSelected -eq [System.Windows.Forms.DialogResult]::OK)
            {
               $FolderPath.Text =  $FileBrowser.FileName
            }
   }
)
#-------------------------------------------------------------------------#

#path of the folder to search trough--------------------------------------#
$FolderPath = New-Object System.Windows.Forms.TextBox
$FolderPath.Location = New-Object System.Drawing.Point(15,120)
$FolderPath.Size = New-Object System.Drawing.Size(400,40)
$FolderPath.Scrollbars = 3#Scrollbars.Vertical
$FolderPath.Multiline = $True;
$form.Controls.Add($FolderPath)
#-------------------------------------------------------------------------#

$searchButton = New-Object System.Windows.Forms.Button
$searchButton.Location = New-Object System.Drawing.Point(15,165)
$searchButton.Size = New-Object System.Drawing.Size(400,23)
$searchButton.Text = 'Search'
$form.Controls.Add($searchButton)


#path of the folder to search trough--------------------------------------#
$resultData = New-Object System.Windows.Forms.TextBox
$resultData.Location = New-Object System.Drawing.Point(450,10)
$resultData.Size = New-Object System.Drawing.Size(600,300)
$resultData.Scrollbars = 3#Scrollbars.Vertical
$resultData.Multiline = $True;
$resultData.Text = "Results`r`n`r`n"
$resultData.WordWrap = $False
$resultData.Font = New-Object System.Drawing.Font("Lucida Console",7,[System.Drawing.FontStyle]::Regular)
$form.Controls.Add($resultData)
#-------------------------------------------------------------------------#

$searchButton.Add_Click({
    $resultData.Text = "Results`r`n`r`n"
    $word = $wordToSearchFor.Text
    $FolderToIterate = $FolderPath.Text
    if($FolderToIterate -ne ""){
        if(Test-Path $FolderToIterate -PathType Any){       
            $data = @(Get-ChildItem -Path $FolderToIterate -Recurse | Select-String -Pattern $word)
            if($data.Count){
                $resultData.Text += "There were "+$data.Count+" instances of '"+$word+"' found in the files`r`n"
                $resultData.Text += "{`r`n"
                for ($i = 0; $i -lt $data.Count; $i++){
                    $resultData.Text += "    "+$data[$i] +"`r`n"
                }
                $resultData.Text += "}`r`n" 
            }else{$resultData.Text += "no instances of '"+$word+"' found`r`n"}
        }else{$resultData.Text += "path doesent exist"}
     }else{$resultData.Text += "no path selected"}   
})

$saveResultToFile = New-Object System.Windows.Forms.Button
$saveResultToFile.Location = New-Object System.Drawing.Point(15,270)
$saveResultToFile.Size = New-Object System.Drawing.Size(400,40)
$saveResultToFile.Text = 'Save result to file'
$form.Controls.Add($saveResultToFile)
$selectFolderToSaveTo = [System.Windows.Forms.FolderBrowserDialog]::new()
$selectFolderToSaveTo.Description = 'Select folder to search trough'
$selectFolderToSaveTo.RootFolder = [System.Environment+specialfolder]::Desktop
$selectFolderToSaveTo.ShowNewFolderButton = $true

$saveResultToFile.Add_Click({
		$folderToSaveTo = $selectFolderToSaveTo.ShowDialog()
       
        if ($folderToSaveTo -eq [System.Windows.Forms.DialogResult]::OK)
            {
               $word = $wordToSearchFor.Text
               $pathOfNewFile = $selectFolderToSaveTo.SelectedPath +"\"+$word+"results.txt"
               if(Test-Path $pathOfNewFile -PathType Any){
                $pathOfNewFile = $selectFolderToSaveTo.SelectedPath +"\"+$word+"results"+(Get-Random -Maximum 9999)+ ".txt"
               }
               New-Item $pathOfNewFile
               Set-Content $pathOfNewFile $resultData.Text
               if(Test-Path $pathOfNewFile -PathType Any){
                 $succesfullSave = new-object -comobject wscript.shell
                 $succesfullSave.popup(“Save was succesfull“,0,“Save”,1)
               }else{
                 $succesfullSave = new-object -comobject wscript.shell
                 $succesfullSave.popup(“Something went wrong“,0,“Save”,1)
               }
            }
        $selectFolderToSaveTo.Dispose()
})

$form.Topmost = $true
$formConclusion = $form.ShowDialog()