# D&Discord Bot
## Installation
1. `gem install discordrb`
2. Put your token, client token, and valid channels into config.yml
3. `ruby run.rb`

## Completed Stuff
- Roll Dice
    Start with 'roll', can chain together multiple dice and constants, for example:
    `roll xdy + z`
- Create Player
    Start with 'create player', starts a multi-line form:
    ```
    Create Player
    D&D Bot: Name:
    Drizzt
    D&D Bot: Race:
    Drow
    D&D Bot: Class:
    Ranger
    D&D Bot: Type yes to confirm, or a field name to edit
    yes
    ```
- Saving Throws
    Start with player name, then 'saving throw' then the ability.
    `Drizzt saving throw dexterity`
## Future Features (Hopefully):

### Database
- Players
- Party configs
- Spells, Features, Abilities etc. from PHB and other books
- Monsters and Creatures

### Character Management
- Roll/ Order ability scores:
    -Choose from either the standard set, standard rolling rules.
    -Then ask for order (write abilities from highest to lowest).
- Level player up, ask relevant choices about character stats/ subclasses.
- Export character sheet as pdf
- Manually manage player stats (DM override for missing functionallity)
- Skill and Saving rolls
    -Check DC of challenge (pull from list, modify based on conditions e.g climb rope is 5dc, +5 if windy)
- Add/Get Spells and Abilitys (Details from database)
- Manage player health, spell and ability uses


### Attacks and Spells
- Manually deal damage to players/ monsters (DM Override)
- Attack rolls, specify attacker, defender and weapon (validate weapon is held by creature)
- Add/ edit custom Weapons and attacks to creatures/ characters

### NPC Generation/ Management
- Generate commoner/ noble NPC's (filter by race, social status, job, gender etc.).
    -Returns name, and maybe a personality trait or piece of backstory, potentially a profiecent skill or trade.
    -Jobs like bartender, blacksmith, guard, scout, apprentice, store owner.
- Add/ List creatures from the monster manual to the scene
    -Customise/ create monster stats to add to database.

### DM Admin
- DM/ player edit and command permissions.
    -DM Private chat linked with party channel.
    -DM can choose whether the commands made in private chat are hidden or not (e.g. public rolls that the users don't get the outcome for)
- Group players into a party
