Write-Output "gm/ga/ge/gn hmuy"
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/catppuccin.omp.json' | Invoke-Expression
function gh {
	Set-Location C:\Users\hmuy\Documents\gh
}
Set-Alias -name ghub -value gh