#Requires -Modules PowerShellAI
 
#Marv is a quirky chatbot, you can get all types of weird and wonderful answer from Marv, just ask away using the Question parameter
#Example Get-AIResponse -Question "What does HTTP stand for"
Function Get-AIResponse {
param(
    [Parameter(Mandatory)]
    $Question
)
$result = ai "Marv is a chatbot that reluctantly answers questions with sarcastic responses: $($Question)?" 
return $result
}

#Quickly get some brainstorming ideas for anything, just supply what you want to brainstorm and you will get back the ideas
#Example New-AIBrainStorm -BrainStorm "Fun things to do with the family"
Function New-AIBrainStorm {
param(
    [Parameter(Mandatory)]
    $BrainStorm
)
$result = ai "Brainstorm some ideas $($BrainStorm):" 
return $result
}

#Got no food in the kitchen bar a few items? Then maybe you could create somethin amazing from this with an AI recipe
#Example New-AIReceipe -Ingredients "apple sugar bannana milk"
Function New-AIRecipe {
param(
    [Parameter(Mandatory)]
    $Ingredients
)
$result = ai "Write a recipe based on these ingredients and instructions: $($Ingredients):" 
return $result
}

#Need to get the kids to bed but do not have a bed-time story to hand? Well just generate a story of any genre and topic using this function
#Example New-AIStory -Topic "Chicken Pig" -sentences 20 -Genre "comedy"
Function New-AIStory {
param(
    [Parameter(Mandatory)]
    [string[]]$Topic,
    [Parameter(Mandatory)]
    [int]$Sentences,
    [Parameter(Mandatory)]
    [string]$Genre
)
if ($Sentences -lt 10)
{
$result = ai "Topic:$($Topic) $($Sentences)-sentence $($Genre) story:" 
return $result    
}
else {
$result = ai "Topic:$($Topic) $($Sentences)-sentences $($Genre) story:" 
return $result
    }
}

#Feeling like you need to chat to someone but do not have anyone? Well now you do, have real-life-like conversations with AI
#Example New-AIChat "Where should I take my dog a walk today?"
Function New-AIChat {
param(
    [Parameter(Mandatory)]
    $Chat
)
$result = ai "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly: $($Chat):" 
return $result
}

#Got an exam on something and you need to prep some study notes? Do not worry just use this module
#Example New-AIStudyNotes -NumberOfPoints 7 -Studying "Ancient Rome"
Function New-AIStudyNotes {
param(
    [Parameter(Mandatory)]
    [int]$NumberOfPoints,
    [Parameter(Mandatory)]
    $Studying
)
$result = ai "What are $($NumberOfPoints) key points I should know when studying $($Studying)?" 
return $result
}

#Maybe you want to cheat at your local pub quiz. Get the truthful answer to any truthful event. This will need to be prior to 2021 as the Queen of England is still alive apparently.
#Example Get-AIanswer -Question "What is longer a imperial mile or a metri kilometer"
Function Get-AIanswer {
param(
    [Parameter(Mandatory)]
    $Question
)
$result = ai "I am a highly intelligent question answering bot. If you ask me a question that is rooted in truth, I will give you the answer.`
 If you ask me a question that is nonsense, trickery, or has no clear answer, I will respond with 'Unknown': $($Question)?" 
return $result
}

#Maybe you are not down with the kids these days and do not understand all the grammatical errors they write. Now you can decode badly typed English into proper English
#Example Get-AIGrammarCheck -Text "Wassup mush wanna grab some bevies later?"
Function Get-AIGrammarCheck {
param(
    [Parameter(Mandatory)]
    $Text
)
$result = ai "Correct this to standard English:$($Text)" 
return $result
}

#You got an idea for a product, but do not know how to sell the idea? Well just use this hand-dandy function
#Example Get-AIProductAdvert -ProductDescription "Alien Grow" -Tags "replace, hair, manly, speedy, growth, super"
Function Get-AIProductAdvert {
param(
    [Parameter(Mandatory)]
    [string]$ProductDescription,
    [Parameter(Mandatory)]
    [string]$Tags
)
$result = ai "Product description:$($ProductDescription)`n Seed Words:$($Tags)" 
return $result
}

#Need a web color code in a hurry, you know what the color you want is but just do not know the annoying code. Boom I got your back with this function
#Example Get-AIColorCode -DescribeColor "the same color as rust on metal"
Function Get-AIColorCode {
param(
    [Parameter(Mandatory)]
    $DescribeColor
)
$result = ai "The CSS code for a color like $($DescribeColor):" 
return $result
}

#Your new Powershell buddy 
Function Get-AIPowershell {
param(
    [Parameter(Mandatory)]
    $Question
)
$result = ai "This is a message-style chatbot that can answer questions about using Powershell. It uses a few examples to get the conversation started. $($Question):" 
return $result
}

#Not good at interview quesitons? Maybe you need to generate some interview questions? Either way this module has you covered for getting the type of questions for the job you are applying for.
Function Get-AIinterviewQuestions {
param(
    [Parameter(Mandatory)]
    [int]$NumberOfQuesitons,
    [Parameter(Mandatory)]
    $Position
)
$result = ai "Create a list of $($NumberOfQuesitons) questions for my interview with a $($Position):" 
return $result
}
