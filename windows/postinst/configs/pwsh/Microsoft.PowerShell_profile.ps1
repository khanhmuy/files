#hopefully no one's gonna see this
Write-Output "gm/ga/ge/gn hmuy"
oh-my-posh init pwsh --config 'C:\Users\hmuy\catppuccin_mocha.omp.json' | Invoke-Expression
function gh {
	Set-Location C:\Users\hmuy\Documents\gh
}
Set-Alias -name ghub -value gh
function vps {
	ssh hmuy@192.9.160.132
}
Set-Alias -name sillyvps -value vps