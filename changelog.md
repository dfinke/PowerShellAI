# v0.3.3
- Check if `$result.choices` is not null before trying to access it. Thank you [StartAutomating](https://github.com/StartAutomating)
- Examples added to comment based help in `copilot`. Thank you [Wes Stahler](https://github.com/stahler)
- Add `New-Spreadsheet` script. Creates a new spreadsheet from a prompt. [Check out the code](Examples/Excel/New-Spreadsheet.ps1)
- Added `ConvertFrom-GPTMarkdownTable` function. Converts a markdown table to a PowerShell object. [Check out the code](Public/ConvertFrom-GPTMarkdownTable.ps1)
- Unit tests started
- GitHub Actions in place to run CI/CD

# v0.3.2
- Added `Get-DalleImage`: Given a description, the model will return an image
- Added `Set-DalleImageAsWallpaper`: Given a description, the model will return an image form DALL-E and set it as the wallpaper

# v0.3.1
- Added -max_tokens parameter to the `ai` function

# v0.3.0
- Added `copilot` - Makes the request to GPT, parses the response and displays it in a box and then prompts the user to run the code or not. Check the [README.md](README.md) for me details.

- Added `ai` function:
    - Experimental function enables piping

        ```powershell
        ai "list of planets only names as json"
        ```
    
        ```json
        [
            "Mercury",
            "Venus",
            "Earth",
            "Mars",
            "Jupiter",
            "Saturn",
            "Uranus",
            "Neptune"
        ]
        ```
    
        ```powershell
        ai "list of planets only names as json" |
        ai 'convert to  xml'
        ```

        ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        <Planets>
            <Planet>Mercury</Planet>
            <Planet>Venus</Planet>
            <Planet>Earth</Planet>
            <Planet>Mars</Planet>
            <Planet>Jupiter</Planet>
            <Planet>Saturn</Planet>
            <Planet>Uranus</Planet>
            <Planet>Neptune</Planet>
        </Planets>
        ```        
        
# v0.2.0

- Thank you [Martyn Keigher](https://github.com/MartynKeigher) for your contributions!
    - Added `gpt` as an alias:
    
        ```powershell
        # Get-GPT3Completion "list of planets only names as json"
        gpt "list of planets only names as json"
        ``

    - Added validation for: `temperature`, `max_tokens`, `top_p`, `frequency_penalty`, `presence_penalty`
