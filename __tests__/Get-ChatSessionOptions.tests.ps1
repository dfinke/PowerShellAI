Import-Module "$PSScriptRoot\..\PowerShellAI.psd1" -Force

Describe "Get-ChatSessionOptions" -Tag 'Get-ChatSessionOptions' {

    AfterAll {
        Reset-ChatSessionOptions
    }
    
    It "Test Get-ChatSessionOptions function exists" {
        $actual = Get-Command Get-ChatSessionOptions -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Tests default Get-ChatSessionOptions' {
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption' {
        $actual = Get-Command Set-ChatSessionOption -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Set-ChatSessionOption model' {
        Set-ChatSessionOption -model 'davinci'
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'davinci'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }

    It 'Test Reset-ChatSessionOptions function exists' {
        $actual = Get-Command Reset-ChatSessionOptions -ErrorAction SilentlyContinue
        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test Reset-ChatSessionOptions' {
        Reset-ChatSessionOptions
        $actual = Get-ChatSessionOptions
        
        $actual | Should -Not -BeNullOrEmpty

        $actual.model | Should -BeExactly 'gpt-4'
        $actual.temperature | Should -Be 0.0
        $actual.max_tokens | Should -Be 256
        $actual.top_p | Should -Be 1.0
        $actual.frequency_penalty | Should -Be 0
        $actual.presence_penalty | Should -Be 0
        $actual.stop | Should -BeNullOrEmpty
    }
}