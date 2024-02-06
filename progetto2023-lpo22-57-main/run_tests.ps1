# Script per eseguire i test automatici del progetto

# Versione di Java richiesta: 19

# Test eseguiti su Windows 11 - 22H2 con PowerShell 7.3.5 e Java 19.0.1 

# Per eseguire lo script, aprire PowerShell e digitare: .\run_tests.ps1

& Clear-Host

Write-Host -ForegroundColor DarkMagenta "TEST AUTOMATICI PROGETTO LPO 2022/2023"
Write-Host ""

$javaPath = "$env:JAVA_HOME\bin\java.exe" # Inserisci il percorso alla tua installazione di Java
$javacPath = "$env:JAVA_HOME\bin\javac.exe" # Inserisci il percorso alla tua installazione di Javac
$sourceFile = "progetto\Main.java"  # Inserisci il percorso al tuo file sorgente Java

# Aggiungi i file di input
$successInput = @(
    "tests/success/prog01.txt", "tests/success/prog02.txt", "tests/success/prog03.txt",
    "tests/success/prog04.txt", "tests/success/prog05.txt", "tests/success/prog06.txt", 
    "tests/success/prog07.txt", "tests/success/prog08.txt"
)

$failureDsInput = @( 
    "tests/failure/dynamic-semantics/prog01.txt", "tests/failure/dynamic-semantics/prog02.txt", 
    "tests/failure/dynamic-semantics/prog03.txt", "tests/failure/dynamic-semantics/prog04.txt", 
    "tests/failure/dynamic-semantics/prog05.txt"
)

$failureSsInput = @( 
    "tests/failure/static-semantics/prog01.txt", "tests/failure/static-semantics/prog02.txt", 
    "tests/failure/static-semantics/prog03.txt", "tests/failure/static-semantics/prog04.txt"
)

$failureSsoInput = @( "tests/failure/static-semantics-only/prog01.txt")

$failureSyInput = @( 
    "tests/failure/syntax/prog01.txt", "tests/failure/syntax/prog02.txt",
    "tests/failure/syntax/prog03.txt"
)

Write-Host -ForegroundColor Yellow "Compiling $sourceFile..."
# Compila il programma Java
& $javacPath $sourceFile
Write-Host -ForegroundColor Green "Compiled $sourceFile"
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host ""

# Esegui il programma Java
$className = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)
$classPath = [System.IO.Path]::GetDirectoryName($sourceFile)

# Funzione per eseguire il programma Java con gli argomenti forniti
function RunJavaProgram($inputFile) {
    Write-Host ""
    Write-Host -ForegroundColor Magenta "---------------------------------"
    Write-Host -ForegroundColor Yellow "$inputFile"
    Write-Host ""
    $arguments = "-i", $inputFile
    $runCommand = "$classPath.$className"
    & $javaPath $runCommand $arguments
}

function RunJavaProgramNTC($inputFile) {
    Write-Host ""
    Write-Host -ForegroundColor Magenta "---------------------------------"
    Write-Host -ForegroundColor Yellow "$inputFile"
    Write-Host ""
    $arguments = "-i", $inputFile, "-ntc"
    $runCommand = "$classPath.$className"
    & $javaPath $runCommand $arguments
}

Write-Host -ForegroundColor Red "Running tests WITHOUT -NTC..."
# Senza -NTC
Write-Host -ForegroundColor Cyan "Running success tests..."
# Esegui i test di successo
for ($i = 0; $i -lt $successInput.Length; $i++) {
    RunJavaProgram $successInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure dynamic-semantics tests..."
# Esegui i test di failure dynamic semantics
for ($i = 0; $i -lt $failureDsInput.Length; $i++) {
    RunJavaProgram $failureDsInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure static-semantics tests..."
# Esegui i test di failure static semantics
for ($i = 0; $i -lt $failureSsInput.Length; $i++) {
    RunJavaProgram $failureSsInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure static-semantics-only tests..."
# Esegui i test di failure static semantics only
for ($i = 0; $i -lt $failureSsoInput.Length; $i++) {
    RunJavaProgram $failureSsoInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure syntax tests..."
# Esegui i test di failure syntax
for ($i = 0; $i -lt $failureSyInput.Length; $i++) {
    RunJavaProgram $failureSyInput[$i]
}

Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host ""

Write-Host -ForegroundColor Red "Running tests WITH -NTC..."
# Con -NTC
Write-Host -ForegroundColor Cyan "Running success tests..."
# Esegui i test di successo
for ($i = 0; $i -lt $successInput.Length; $i++) {
    RunJavaProgramNTC $successInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure dynamic-semantics tests..."
# Esegui i test di failure dynamic semantics
for ($i = 0; $i -lt $failureDsInput.Length; $i++) {
    RunJavaProgramNTC $failureDsInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure static-semantics tests..."
# Esegui i test di failure static semantics
for ($i = 0; $i -lt $failureSsInput.Length; $i++) {
    RunJavaProgramNTC $failureSsInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure static-semantics-only tests..."
# Esegui i test di failure static semantics only
for ($i = 0; $i -lt $failureSsoInput.Length; $i++) {
    RunJavaProgramNTC $failureSsoInput[$i]
}
Write-Host ""
Write-Host -ForegroundColor Magenta "---------------------------------"
Write-Host -ForegroundColor Cyan "Running failure syntax tests..."
# Esegui i test di failure syntax
for ($i = 0; $i -lt $failureSyInput.Length; $i++) {
    RunJavaProgramNTC $failureSyInput[$i]
}

Write-Host ""
Write-HOst -ForegroundColor Green "Done!"