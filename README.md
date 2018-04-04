# stellaris-tech-beeliner
This script started out as a simple tool to find the shortest research way towards desired technology in Stellaris video game.

It degenerated into a cumbersome mess pretty much immediately.

Even so, it works and may or may not assist you in planning your research path.

# What does it do?

The script uses pre-generated expanded technology database to determine the most cost-intensive technologies and marks them as blocked. The list of blocked technologies and amount of saved research points is presented as a result.

There is possibility to mark some technologies as desired, ignored or forcefully blocked. The script automatically ignores invalid technologies (e.g. Machine Empire specific technologies, if empire is not set as one).

There are some sanity checks but the script is by no means fool-proof. It will not notice if technology name is incorrectly typed and will not alert if two or more dependant technologies are set to be ignored.

# How to install and run it?

## Checking PowerShell version

The script was tested on PowerShell version 5. It may work on earlier versions, but 2 is a total no-go. To check PowerShell version:
1. Press Win + R keys to open "Run" dialog
2. Type "powershell" (without quotes) and press Enter
3. Wait until "Windows PowerShell" window will finish loading
4. Type "$PSVersionTable.PSVersion.Major" (without quotes) and press Enter
5. If result is less than 5, you may need to install update from here: https://www.microsoft.com/en-us/download/details.aspx?id=50395

## Script installation

The installation process is described below:
1. Download stellaris-tech-beeliner.ps1
2. Download latest technology database (expandedTechsXYZ.csv)
3. Place database file together with script file in \database\ sub-folder
4. Press Win + R keys to open "Run" dialog
5. Type "powershell ise" (without quotes) and press Enter
6. Wait until "Windows PowerShell ISE" window will finish loading
7. Press Ctrl + O keys and open script file from saved location
8. Edit the line 20, so it will contain correct path

## Running

Pressing F5 key in "Windows PowerShell ISE" should run the script. It most probably will complain about execution policy. The following may be done in such situation (from preferred to less preferred):
* copy the line 13 (without hash) command into command prompt. Make sure that path to script file is correct. Press Enter. This is the safest method
* create a new ps1 file in "Windows PowerShell ISE" and copy script code there. Do not save file, press F5. This is as safe as method above, but a bit more annoying
* (not confirmed) run "Windows PowerShell ISE" as administrator. Should be safe
* change execution policy. This may lead for some safety issues, so not described here. Advanced users are to google it and use at own risk

# How to use it?

## Setting up empire

The following code is responsible for empire customization:
```PowerShell
# set your empire
$gestalt = 0

# machine empire stuff
$me = 0
$servitor = 0
$assimilator = 0

# specific ethos
$spiritualist = 1

# set to 1 if authoritarian or xenophobe with xeno slaves
$slaver = 1

$has_utopia = 1
$has_apocalypse = 1
```
The correct values are either 0 or 1. Based on this input, some technologies will be ignored. The message will be displayed if impossible combination is set.

## Setting target technology

This section sets the technology to beeline for:
```PowerShell
# put here tech you would like to beeline to
$target_tech = "tech_mega_engineering"
```
There is no localization support for technology names. Refer to \localisation\english\technology_l_english.yml in game folder if confused.

## Setting desired technologies

Desired technologies will not be marked as blocked. They can be specified there:
```PowerShell
# put here any other tech you would like to have
$desired_techs =  @(
                    $target_tech,
# hashes can be used to quickly remove entries
# be careful doing it to the last line though (check for comma)
<# multiline comments work as well
                    "tech_ftl_inhibitor",
                    "tech_neural_implants",
#>
                    "tech_mining_network_2",
                    "tech_engineering_lab_1",
                    "tech_colonial_centralization",
                    "tech_synthetic_workers",
                    "tech_sensors_2",
                    "tech_climate_restoration",
                    "tech_sapient_ai"
                    )
```
This array may be reduced to single element. In that case the comma after $target_tech should be removed.

## Setting ignored technologies

Ignored technologies are removed from the calculation entirely. Any technologies that list ignored one as a pre-requisite will be ignored too. The script automatically updates database to reflect reduced costs and research options. These are set in following part of code:
```PowerShell
# put here techs which can be ignored
# most of reverse-engineering-only, ME, gestalt and ethos-specific stuff is blocked down in the script
# there are, however, exceprions like tech_living_metal
#
# significant part of tile blockers should end up here
#
# same tier techs which are unlocked after target tech may be put here to reduce weights of other prerequisite techs
# e.g if pursuing tech_starbase_4, tech_space_defense_station_improvement may be ignored to reduce cumulative costs of tech_modular_engineering
$ignored_techs = @(
# curators
                    "tech_curator_lab",
                    "tech_archeology_lab",
# special conditions only
                    "tech_regenerative_hull_tissue",
                    "tech_mine_living_metal",
# RNG stuff
                    "tech_mine_betharian",
                    "tech_alien_life_studies",
# tile blockers
                    "tech_tb_mountain_range",
                    "tech_tb_volcano",
                    "tech_tb_dangerous_wildlife",
                    "tech_tb_dense_jungle",
                    "tech_tb_quicksand_basin",
                    "tech_tb_noxious_swamp",
                    "tech_tb_massive_glacier",
                    "tech_tb_toxic_kelp",
                    "tech_tb_deep_sinkhole"
# unlocked after target
#                    ,"tech_space_defense_station_improvement",
#                    "tech_afterburners_2"
                    )
```

This array may be left completely empty.

It is important to not list dependent technologies (e.g. tech_sensors_2 and tech_sensors_3 *or* tech_colonial_centralization and tech_droids) as this may lead to incorrect cost/option reduction. There are no checks against this yet.

## Setting forcefully blocked technologies

Forcefully blocked technologies will be automatically blocked before script will go through the database. This is mainly used in combination with desired technologies, when goal is to get several technologies from different areas (e.g. if beelining for engineering technology it is almost always beneficial to block tech_lasers_2 if something from physics is wanted as well). They are specified there:
```PowerShell
# put here techs which will be blocked from start
# use when pursuing multiple techs and/or techs from different areas
$blocked_techs = @(
                    "tech_genome_mapping",
                    "tech_shields_2",
                    "tech_lasers_2"
                    )
```

This array may be left completely empty.

There is a conflict check for desired and ignored/blocked technologies. The script will show a message in such a case.

## Setting research alternatives

Research alternatives will define how many technologies will/can be blocked. Set them there:
```PowerShell
# specify number of research alternatives
$research_alternatives = 5
```

## Toggle showing allowed to research technologies on/off

By default, only blocked technologies are shown. There is possibility to list non-blocked technologies:
```PowerShell
# set this to 1 if you want to see which technologies were not blocked
$show_allowed = 0
```
This is mainly used as quick reference list if one is not familiar with technology tree.

# Remarks on pursuing multiple technologies

As script focuses on one technology at the time, the general approach on finding out complex research path is the following:
1. Beeline for wanted technologies one-by-one. Note down the most expensive blocked technologies
2. List wanted technologies, apart from the one that is most difficult to get, as desired
3. List the most expensive blocked technologies from step 1, apart from results of the one that is most difficult to get, as forcefully blocked
4. Try beelining for technology that is most difficult to get
5. Resolve whatever conflicts may arise
6. Use edited save file from \extras\ folder to confirm results before trying in normal game