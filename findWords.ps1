#words to find
$words = @('the','if','yes','no','data','file','hamburger','word','f', '{')

#location of the folder where all the files are you want to iterate trough
$FolderToIterate = 'C:\Users\juhku\OneDrive\Tiedostot\Scripts\experimentFiles'

#location of the folder where result files will go
$ResultFolder = 'C:\Users\juhku\OneDrive\Tiedostot\Scripts\results'



#creates a file for the result
$resultFileName = "result"
if(Test-Path -Path $ResultFolder'\'$resultFileName".txt" -PathType Leaf){
    $resultFileName +=(Get-Random -Maximum 1000).ToString()
}
$resultFileName += ".txt"
New-Item $ResultFolder'\'$resultFileName

#iterates trough all the files, and finds all the words/letters you put on the $words variable to find
function fetchData {
    for($word = 0;$word -lt $words.Count; $word++){
        $data = @(Get-ChildItem -Path $FolderToIterate -Recurse | Select-String -Pattern $words[$word])
        if($data.Count){
            "There were "+$data.Count+" instances of '"+$words[$word]+"' found in the files"
            "{"
            for ($i = 0; $i -lt $data.Count; $i++){
                "    "+$data[$i]
            }
            "}"
            "-----------------------------------------------------------------------------------"
        } else {
         
            "no instances of '"+$words[$word]+"' found"
            "-----------------------------------------------------------------------------------"
        }
    }
    "Word finder by Juhani Kangas"
    ""
}


#prints result of the fetchData function to your result file
fetchData | Out-File -FilePath C:\Users\juhku\OneDrive\Tiedostot\Scripts\results\$resultFileName 

#opens result file
start C:\Users\juhku\OneDrive\Tiedostot\Scripts\results\$resultFileName 

