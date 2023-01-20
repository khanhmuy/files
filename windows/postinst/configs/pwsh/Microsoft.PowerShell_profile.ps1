Write-Output "gm/ga/ge/gn hmuy"
oh-my-posh init pwsh --config $env:USERPROFILE\candy_custom.omp.json | Invoke-Expression
function gh {
	Set-Location $env:USERPROFILE\Documents\gh
}
Set-Alias -name ghub -value gh
function vps {
	ssh hmuy@192.9.160.132
}
Set-Alias -name sillyvps -value vps