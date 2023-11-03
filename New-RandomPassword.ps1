function New-RandomPassword {
    param (
    [Parameter()]
    [int]$Length=12
    )

$Password = ""    
for($i=0; $i -LT $Length ; $i++)
    {
       
       $Password = -join ($Password,[char]((46..46)+(48..57)+(65..90)+(97..122)|Get-Random))
    }

    Return $Password
}