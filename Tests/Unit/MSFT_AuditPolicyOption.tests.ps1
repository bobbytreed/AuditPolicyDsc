
$script:DSCModuleName      = 'AuditPolicyDsc'
$script:DSCResourceName    = 'MSFT_AuditPolicyOption'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {

        #region Pester Test Initialization

        # set the audit option test strings to Mock
        $optionName  = 'CrashOnAuditFail'
        
        #endregion

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Context 'Option Enabled' {

                $optionState = 'Enabled'
                Mock -CommandName Get-AuditOption -MockWith { 
                    return $optionState } -ModuleName MSFT_AuditPolicyOption -Verifiable
                
                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource -Name $optionName } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $getTargetResourceResult.Name  | Should Be $optionName
                    $getTargetResourceResult.Value | Should Be $optionState
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditOption -Exactly 1
                } 
            }

            Context 'Option Disabled' {

                $optionState = 'Disabled'
                Mock -CommandName Get-AuditOption -MockWith { 
                    return $optionState } -ModuleName MSFT_AuditPolicyOption -Verifiable

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource -Name $optionName } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $getTargetResourceResult.Name  | Should Be $optionName
                    $getTargetResourceResult.Value | Should Be $optionState
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditOption -Exactly 1
                } 
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            
            $target = @{
                Name  = $optionName 
                Value = 'Enabled'
            }

            Context 'Option set to enabled and should be' {

                Mock -CommandName Get-AuditOption -MockWith { 
                    return 'Enabled' } -ModuleName MSFT_AuditPolicyOption -Verifiable

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } | 
                        Should Not Throw
                }

                It "Should return true" {
                    $script:testTargetResourceResult | Should Be $true
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditOption -Exactly 1
                } 
            }

            Context 'Option set to enabled and should not be' {

                Mock -CommandName Get-AuditOption -MockWith { 
                    return 'Disabled' } -ModuleName MSFT_AuditPolicyOption -Verifiable

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } | 
                        Should Not Throw
                }

                It "Should return false" {
                    $script:testTargetResourceResult | Should Be $false
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditOption -Exactly 1
                } 
            }

            $target.Value = 'Disabled'

            Context 'Option set to disabled and should be' {

                Mock -CommandName Get-AuditOption -MockWith { 
                    return 'Disabled' } -ModuleName MSFT_AuditPolicyOption -Verifiable

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } | 
                        Should Not Throw
                }
                
                It "Should return true" {
                    $script:testTargetResourceResult | Should Be $true
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditOption -Exactly 1
                } 
            }

            Context 'Option set to disabled and should not be' {

                Mock -CommandName Get-AuditOption -MockWith { 
                    return 'Enabled' } -ModuleName MSFT_AuditPolicyOption -Verifiable
                
                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } | 
                        Should Not Throw
                }

                It "Should return false" {
                    $script:testTargetResourceResult | Should Be $false
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditOption -Exactly 1
                } 
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            
            $target = @{
                Name  = $optionName 
                Value = 'Enabled'
            }

            Context 'Option Enabled' {

                Mock -CommandName Set-AuditOption -MockWith { } `
                     -ModuleName MSFT_AuditPolicyOption -Verifiable
                    
                It 'Should not throw an exception' {
                    { $script:setTargetResourceResult = Set-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Set-AuditOption -Exactly 1
                } 
            }

            $target.Value = 'Disabled'

            Context 'Option Disabled' {

                Mock -CommandName Set-AuditOption -MockWith { } `
                     -ModuleName MSFT_AuditPolicyOption -Verifiable
                    
                It 'Should not throw an exception' {
                    { $script:setTargetResourceResult = Set-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Set-AuditOption -Exactly 1
                } 
            }
        }
        #endregion

        #region Helper Cmdlets
        Describe 'Private function Get-AuditOption' { 

            Context 'Get audit policy option' {

                [String] $name  = 'CrashOnAuditFail'
                [String] $value = 'Enabled'
                # the return is 3 lines Header, blank line, data
                # ComputerName,System,Subcategory,GUID,AuditFlags
                Mock -CommandName Invoke-Auditpol -MockWith { 
                    @("","","$env:COMPUTERNAME,,Option:$name,,$value,,") 
                } -ParameterFilter { $Command -eq 'Get' } -Verifiable

                It 'Should not throw an exception' {
                    { $script:getAuditOptionResult = Get-AuditOption -Name $name } | 
                        Should Not Throw
                } 

                It "Should return the correct value" {
                    $script:getAuditOptionResult | should Be $value
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }
        }

        Describe 'Private function Set-AuditOption' { 

            [String] $name  = "CrashOnAuditFail"

            Context "Set audit poliy option to enabled" {

                [String] $value = "Enabled"

                Mock -CommandName Invoke-Auditpol -MockWith { } -ParameterFilter {
                    $Command -eq 'Set' } -Verifiable

                It 'Should not throw an exception' {
                    { Set-AuditOption -Name $name -Value $value } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            Context "Set audit policy option to disabled" {

                [String] $value = "Disabled"

                Mock -CommandName Invoke-Auditpol -MockWith { } -ParameterFilter {
                    $Command -eq 'Set' } -Verifiable

                It 'Should not throw an exception' {
                    { Set-AuditOption -Name $name -Value $value } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }
        }
        #endregion
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
