# D&Discord Bot
## Installation
1. `gem install discordrb, mongo, titleize`
2. Put your token, client token, and valid channels into config.yml
3. `ruby run.rb`

## Completed Stuff
##### General Use
Command words and parameters are seperated by space, but multi word parameters can be grouped with double quotes e.g.

`Proficiencies add skill "Animal Handling"`

#### Roll Dice
 with 'roll', can chain together multiple dice and constants, for example:

`roll xdy + z`

#### Create Player
Start with 'create player', starts a multi-line form:
```
Create Player
D&D Bot: Name:
Drizzt
D&D Bot: Race:
Drow
D&D Bot: Class:
Ranger
etc...
D&D Bot: Type yes to confirm, or a field name to edit
yes
```

#### Load Player
Loads the player info into the party and links them with the user who enters the command. All player commands will be done to this player.

`Load Drizzt`
#### Saving Throws
Start with player name (If DM), then 'saving throw' then the ability.

`Save dex 10`
#### Proficiencies
Add, remove and list proficiencies/ expertise for skills, saves, weapons, armour, and tools
Start command with 'proficiencies', then either 'list', or 'add'/'remove' followed by the category (listed above, in singular form e.g. 'weapon'), then the name of the proficiency.
Skills or tools players have expertise in are in their own expertise category, and will be automatically removed from their respective categories when added.

`Proficiencies list`

`Proficiencies add skill history`

`Proficiencies add expertise 'theives tools'`

## Future Features (Hopefully):

### Database
- Players
- Party configs
- Spells, Features, Abilities etc. from PHB and other books
- Monsters and Creatures

### Character Management
- Roll/ Order ability scores:
	* Choose from either the standard set, standard rolling rules.
	* Then ask for order (write abilities from highest to lowest).
- Level player up, ask relevant choices about character stats/ subclasses.
- Export character sheet as pdf
- Manually manage player stats (DM override for missing functionallity)
- Skill and Saving rolls
	* Check DC of challenge (pull from list, modify based on conditions e.g climb rope is 5dc, +5 if windy)
- Add/Get Spells and Abilitys (Details from database)
- Manage player health, spell and ability uses

### Attacks and Spells
- Manually deal damage to players/ monsters (DM Override)
- Attack rolls, specify attacker, defender and weapon (validate weapon is held by creature)
- Add/ edit custom Weapons and attacks to creatures/ characters

### NPC Generation/ Management
- Generate commoner/ noble NPC's (filter by race, social status, job, gender etc.).
	* Returns name, and maybe a personality trait or piece of backstory, potentially a profiecent skill or trade.
	* Jobs like bartender, blacksmith, guard, scout, apprentice, store owner.
- Add/ List creatures from the monster manual to the scene
- Customise/ create monster stats to add to database.

### DM Admin
- DM/ player edit and command permissions.
	* DM Private chat linked with party channel.
	* DM can choose whether the commands made in private chat are hidden or not (e.g. public rolls that the users don't get the outcome for)
- Group players into a party
