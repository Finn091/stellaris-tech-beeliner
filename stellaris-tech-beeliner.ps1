# stellaris-tech-beeliner version 1.0 by sabrenity @ paradoxplaza
# written while listening to Main Theme from Higurashi no Naku Koro ni

# execute the command below to find out PowerShell version
# $PSVersionTable.PSVersion.Major

# it runs on version 5 and definetly doesn't run on version 2
# versions in-between might work
# the update to version 5 can be dowloaded from here: https://www.microsoft.com/en-us/download/details.aspx?id=50395

# if you haven't used PowerShell before it will most probably complain about execution policy
# use command below to run this specific script bypassing the policy (check for correct path)
# powershell -executionpolicy bypass -File D:\repos\GitHub\stellaris-tech-beeliner\stellaris-tech-beeliner.ps1

# the other option is to select and copy-paste all the code to a new PowerShell file and run it WITHOUT SAVING

### input of user-specific stuff

# path to script folder
$path = 'D:\repos\GitHub\stellaris-tech-beeliner'

# relative path to CSV database file
$techsCSV = Import-Csv "$path\database\expandedTechs202.csv"

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

# put here tech you would like to beeline to
$target_tech = "tech_mega_engineering"

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

# put here techs which will be blocked from start
# use when pursuing multiple techs and/or techs from different areas
$blocked_techs = @(
                    "tech_genome_mapping",
                    "tech_shields_2",
                    "tech_lasers_2"
                    )

# specify number of research alternatives
$research_alternatives = 5

# set this to 1 if you want to see which technologies were not blocked
$show_allowed = 0

### end of user input

### defines

# additional ignored techs based on ethos are defined here
# full arrays are not used because all the children will be ignored later
# it will as well impact the performance in the not cool way
# and may complicate things when reducing techs unlocks and costs

# remove tech_resource_processing_algorithms if assimilator
$me_only_techs = @( "tech_robomodding_m", "tech_probability_theory", "tech_adaptive_combat_algorithms", "tech_singularity_core", "tech_modular_components", "tech_resource_processing_algorithms" )
#$me_only_techs_full = @( "tech_robomodding_m", "tech_probability_theory", "tech_binary_motivators", "tech_nanite_assemblers", "tech_adaptive_combat_algorithms", "tech_biomechanics", "tech_modular_components", "tech_intelligent_factories", "tech_resource_processing_algorithms" )

# remove tech_colonization_2, tech_genome_mapping if servitor or assimilator
$me_blocked_techs = @( "tech_global_research_initiative", "tech_hydroponics", "tech_colonization_2", "tech_frontier_health", "tech_genome_mapping", "tech_selected_lineages", "tech_galactic_markets", "tech_galactic_benevolence", "tech_living_state", "tech_collective_self" )
# remove tech_colonization_2, "tech_colonization_3", tech_colonization_4, tech_colonization_5, tech_tomb_world_adaption, tech_genome_mapping, tech_epigenetic_triggers, tech_gene_tailoring, tech_glandular_acclimation, tech_gene_expressions if servitor or assimilator
# tech_vitality_boosters, tech_cloning, tech_gene_banks are for assimilator only
# tech_morphogenetic_field_mastery is not available for both asiimilators and servitors
#$me_blocked_techs_full = @( "tech_global_research_initiative", "tech_hydroponics", "tech_gene_crops", "tech_nano_vitality_crops", "tech_nutrient_replication", "tech_colonization_2", "tech_colonization_3", "tech_colonization_4", "tech_colonization_5", "tech_tomb_world_adaption", "tech_frontier_health", "tech_frontier_hospital", "tech_genome_mapping", "tech_vitality_boosters", "tech_epigenetic_triggers", "tech_cloning", "tech_gene_banks", "tech_gene_seed_purification", "tech_morphogenetic_field_mastery", "tech_gene_tailoring", "tech_glandular_acclimation", "tech_gene_expressions", "tech_selected_lineages", "tech_capacity_boosters", "tech_galactic_markets", "tech_subdermal_stimulation", "tech_galactic_benevolence", "tech_living_state", "tech_collective_self" )

# remove tech_collective_production_methods if machine and not assimilator
$gestalt_only_techs = @( "tech_positronic_implants", "tech_autonomous_agents", "tech_collective_production_methods" )
#$gestalt_only_techs_full = @( "tech_positronic_implants", "tech_combat_computers_autonomous", "tech_autonomous_agents", "tech_embodied_dynamism", "tech_collective_production_methods" )

$gestalt_blocked_techs = @( "tech_robotic_workers", "tech_sapient_ai", "tech_psionic_theory", "tech_neural_implants", "tech_artificial_moral_codes" )
#$gestalt_blocked_techs_full = @( "tech_robotic_workers", "tech_droid_workers", "tech_synthetic_workers", "tech_synthetic_leaders", "tech_robomodding", "tech_robomodding_points_1", "tech_robomodding_points_2", "tech_sapient_ai", "tech_combat_computers_3", "tech_psionic_theory", "tech_telepathy", "tech_precognition_interface", "tech_psi_jump_drive_1", "tech_neural_implants", "tech_artificial_moral_codes", "tech_synthetic_thought_patterns" )

$spiritualist_only_techs = @( "tech_holographic_rituals" )
#$spiritualist_only_techs_full = @( "tech_holographic_rituals", "tech_consecration_fields", "tech_transcendent_faith" )

$spiritualist_blocked_techs = @( "tech_heritage_site" )
#$spiritualist_blocked_techs_full = @( "tech_heritage_site", "tech_hypercomms_forum", "tech_autocurating_vault" )

$slaver_only_techs = @( "tech_neural_implants" )

$utopia_blocked_techs = @( "tech_telepathy" )
#$utopia_blocked_techs_full = @( "tech_telepathy", "tech_precognition_interface", "tech_psi_jump_drive_1" )

$apocalypse_blocked_techs = @( "tech_ascension_theory" )
$no_apocalypse_blocked_techs = @( "tech_ascension_theory_apoc" )

# numbers of lower tier techs needed to unlock higher tier
# unless mods are used, can be left as it is
$tier2threshold = 6
$tier3threshold = 6
$tier4threshold = 6
$tier5threshold = 6

### end of defines

# empire setup sanity check

if ($servitor -eq 1 -or $assimilator -eq 1) {
    if ($me -eq 0) {
        echo "cannot be servitor or assimilator without being machine empire"
        echo "script terminated"
        break
    }
}

if ($me -eq 1) {
    if ($gestalt -eq 0) {
        echo "cannot be machine empire without being gestalt"
        echo "script terminated"
        break
    }
}

if ($gestalt -eq 1) {
    if ($spiritualist -eq 1) {
        echo "cannot be spiritualist as gestalt"
        echo "script terminated"
        break
    }

    if ($slaver -eq 1) {
        echo "cannot be slaver as gestalt"
        echo "script terminated"
        break
    }
}


# specific ethos
$spiritualist = 1

# sorting out ignored techs

# regular empire
if ($gestalt -eq 0) {
    $ignored_techs = $ignored_techs + $gestalt_only_techs + $me_only_techs
    if ($slaver -eq 0) { $ignored_techs = $ignored_techs + $slaver_only_techs }
    if ($spiritualist -eq 0) { $ignored_techs = $ignored_techs + $spiritualist_only_techs }
    if ($spiritualist -eq 1) { $ignored_techs = $ignored_techs + $spiritualist_blocked_techs }
}

# gestalt empire
if ($gestalt -eq 1) {
    # machine empire
    if ($me -eq 1) {
        # assimilators doesn't have some ME stuff
        if ($assimilator -eq 1) { $me_only_techs = $me_only_techs | Where-Object { $_ –ne "tech_resource_processing_algorithms" } }

        # assimilators and servitors do have some biological stuff
        if ($assimilator -eq 1 -or $servitor -eq 1) {
            $me_blocked_techs = $me_blocked_techs | Where-Object { $_ –ne "tech_colonization_2" } | Where-Object { $_ –ne "tech_genome_mapping" }
            $me_blocked_techs = $me_blocked_techs + @( "tech_morphogenetic_field_mastery")
        }

        # assimilators do have some additional biological stuff
        if ($assimilator -eq 0) {
            $gestalt_only_techs = $gestalt_only_techs | Where-Object { $_ –ne "tech_collective_production_methods" }
            $me_blocked_techs = $me_blocked_techs + @("tech_vitality_boosters", "tech_cloning")
        }

        $ignored_techs = $ignored_techs + $gestalt_blocked + $me_blocked_techs + $spiritualist_only_techs
    }
    # hive mind
    if ($me -eq 0) {
        $ignored_techs = $ignored_techs + $me_only_techs + $gestalt_blocked_techs + $spiritualist_only_techs
    }
}

# utopia blocks psionics
if ($has_utopia -eq 1) { $ignored_techs = $ignored_techs + $utopia_blocked_techs }

# apocalypse messes with ascension theory
if ($has_apocalypse -eq 1) { $ignored_techs = $ignored_techs + $apocalypse_blocked_techs }
if ($has_apocalypse -eq 0) { $ignored_techs = $ignored_techs + $no_apocalypse_blocked_techs }

# removing duplicates
$ignored_techs = $ignored_techs | select -uniq

# pretending we are doing something useful
echo "aware of player empire setup"

# flags
$unlocked_flag = 1
$can_block_flag = 1
$should_block_flag = 1
$physics_tier_ok_flag_array = @(1, 1, 1, 1)
$society_tier_ok_flag_array = @(1, 1, 1, 1)
$engineering_tier_ok_flag_array = @(1, 1, 1, 1)
$was_blocked = 0
$conflict_flag = 0

# due to odd/even behavior we can block twice as much tech cards
$blocked_physics = ($research_alternatives - 1) * 2
$blocked_society = ($research_alternatives - 1) * 2
$blocked_engineering = ($research_alternatives - 1) * 2

# checking if desired and ignored / blocked techs are not in conflict
$ignored_techs | ForEach-Object {
    $tech_name = $_
    if ($tech_name -in $desired_techs) {
        $conflict_flag = 1
        echo "ignored $tech_name is conflicting with one of your desired techs"
    }
    ($techsCSV | Where {$_.name -eq $tech_name}).unlocked_full | ForEach-Object {
        if ($_ -in $desired_techs) {
            $conflict_flag = 1
            echo "ignored $tech_name is conflicting with one of your desired techs"
        }
    }
}

$blocked_techs | ForEach-Object {
    $tech_name = $_
    if ($tech_name -in $desired_techs) {
        $conflict_flag = 1
        echo "blocked $tech_name is conflicting with one of your desired techs"
    }
    ($techsCSV | Where {$_.name -eq $tech_name}).unlocked_full | ForEach-Object {
        if ($_ -in $desired_techs) {
            $conflict_flag = 1
            echo "blocked $tech_name is conflicting with one of your desired techs"
        }
    }
}

if ($conflict_flag -eq 1) {
    echo "conflicts were found"
    echo "take into consideration empire setup if having troubles eliminating conflicts"
    echo "script terminated"
    break
}

# pretending we are doing something useful
echo "aware of desired techs"

# cool message for the user
echo "beelining for $target_tech..."

# target tech properties
$target_tier = ($techsCSV | Where {$_.name -eq $target_tech}).tier
$target_area = ($techsCSV | Where {$_.name -eq $target_tech}).area

# sorting criteria is constructed here
$criteria = "to_tier" + $target_tier + "_" + $target_area + "_techs_unlocked_cost"
$prop1 = @{Expression={[int]$_.$criteria}; Descending = $true }
$prop2 = @{Expression={[int]$_.$criteria}; Ascending = $true }

# additinal criterias to first block technologies from non-target area
if ($target_area -eq "physics") {
    $prop3 = "society"
    $prop4 = "engineering"
    $prop5 = "physics"
}

if ($target_area -eq "society") {
    $prop3 = "physics"
    $prop4 = "engineering"
    $prop5 = "society"
}

if ($target_area -eq "engineering") {
    $prop3 = "society"
    $prop4 = "physics"
    $prop5 = "engineering"
}

# criteria for allowed techs
$prop6 = @{Expression={[int]$_.tier}; Ascending = $true }

# setting max tier per area for desired techs so we'll not block anything along the way
$max_physics_tier = ($techsCSV | Where {$_.name -in $desired_techs} | Where {$_.area -eq "physics"} | Measure-Object -Property tier -maximum).maximum
$max_society_tier = ($techsCSV | Where {$_.name -in $desired_techs} | Where {$_.area -eq "society"} | Measure-Object -Property tier -maximum).maximum
$max_engineering_tier = ($techsCSV | Where {$_.name -in $desired_techs} | Where {$_.area -eq "engineering"} | Measure-Object -Property tier -maximum).maximum

if ($max_physics_tier -eq $null) { $max_physics_tier = 1 }
if ($max_society_tier -eq $null) { $max_society_tier = 1 }
if ($max_engineering_tier -eq $null) { $max_engineering_tier = 1 }

echo "updating database"

# preparation of CSV database - splitting strings into arrays
$techsCSV | ForEach-Object {
    if ($_.prerequisites.Length -ne 0) {
        $_.prerequisites = $_.prerequisites -split " "
    }

    if ($_.unlocked_direct.Length -ne 0) {
        $_.unlocked_direct = $_.unlocked_direct -split " "
    }

    if ($_.unlocked_full.Length -ne 0) {
        $_.unlocked_full = $_.unlocked_full -split " "
    }

    if ($_.prerequisites_full.Length -ne 0) {
        $_.prerequisites_full = $_.prerequisites_full -split " "
    }
}

# pretending we are doing something useful
echo "  strings split into arrays"

# preparation of CSV database - marking ignored techs and ones they unlock as ignored
$techsCSV | ForEach-Object {
    if ($_.name -in $ignored_techs -and $_.ignored -ne "True") {
        $_.ignored = "True"
    }

    if ($_.ignored -eq "True") {
        if ($_.unlocked_full.Length -ne 0) {
            $_.unlocked_full | ForEach-Object {
                $child_name = $_
                ($techsCSV | Where {$_.name -eq $child_name}).ignored = "True"
            }
        }
#        this is not working that well here
        <#
        $_.prerequisites_full | ForEach-Object {
            $parent_tech = $_
            $techsCSV | Where {$_.name -eq $parent_tech } | ForEach-Object {
                for ($i = 1; $i -le 5; $i++) {
                    $parameter = "tier" + $i + "_physics_techs_unlocked"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "tier" + $i + "_society_techs_unlocked"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "tier" + $i + "_engineering_techs_unlocked"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "tier" + $i + "_physics_techs_unlocked_cost"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "tier" + $i + "_society_techs_unlocked_cost"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "tier" + $i + "_engineering_techs_unlocked_cost"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "to_tier" + $i + "_physics_techs_unlocked"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "to_tier" + $i + "_society_techs_unlocked"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "to_tier" + $i + "_engineering_techs_unlocked"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "to_tier" + $i + "_physics_techs_unlocked_cost"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "to_tier" + $i + "_society_techs_unlocked_cost"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                    $parameter = "to_tier" + $i + "_engineering_techs_unlocked_cost"
                    $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter
                }
            }
        }
        #>
    }
}

# if there are any ignored techs, all parent techs should be updated
$ignored_techs | ForEach-Object {
    $tech_name = $_
    ($techsCSV | Where {$_.name -eq $tech_name}).prerequisites_full | ForEach-Object {
        $parent_tech = $_
        $techsCSV | Where {$_.name -eq $parent_tech } | ForEach-Object {
            for ($i = 1; $i -le 5; $i++) {
                $parameter = "tier" + $i + "_physics_techs_unlocked"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "tier" + $i + "_society_techs_unlocked"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "tier" + $i + "_engineering_techs_unlocked"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "tier" + $i + "_physics_techs_unlocked_cost"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "tier" + $i + "_society_techs_unlocked_cost"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "tier" + $i + "_engineering_techs_unlocked_cost"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "to_tier" + $i + "_physics_techs_unlocked"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "to_tier" + $i + "_society_techs_unlocked"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "to_tier" + $i + "_engineering_techs_unlocked"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "to_tier" + $i + "_physics_techs_unlocked_cost"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "to_tier" + $i + "_society_techs_unlocked_cost"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter

                $parameter = "to_tier" + $i + "_engineering_techs_unlocked_cost"
                $_.$parameter -= ($techsCSV | Where {$_.name -eq $tech_name}).$parameter
            }
         }
    }
}

# pretending we are doing something useful
echo "  ignored techs impact taken into account"

# getting total techs per tier per area - skipping over ignored techs and ones with weight 0 (most of reverse-engineered only techs)
$tier1_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
$tier1_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
$tier1_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count

$tier2_physics_techs = ($techsCSV | Where {$_.area -eq "physics"}  | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
$tier2_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
$tier2_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count

$tier3_physics_techs = ($techsCSV | Where {$_.area -eq "physics"}  | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
$tier3_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
$tier3_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count

$tier4_physics_techs = ($techsCSV | Where {$_.area -eq "physics"}  | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
$tier4_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
$tier4_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count

$tier5_physics_techs = ($techsCSV | Where {$_.area -eq "physics"}  | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
$tier5_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
$tier5_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.ignored -ne "True" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count

# sanity check
if ($tier1_physics_techs -eq $null) { $tier1_physics_techs = 0 }
if ($tier1_society_techs -eq $null) { $tier1_society_techs = 0 }
if ($tier1_engineering_techs -eq $null) { $tier1_engineering_techs = 0 }
if ($tier2_physics_techs -eq $null) { $tier2_physics_techs = 0 }
if ($tier2_society_techs -eq $null) { $tier2_society_techs = 0 }
if ($tier2_engineering_techs -eq $null) { $tier2_engineering_techs = 0 }
if ($tier3_physics_techs -eq $null) { $tier3_physics_techs = 0 }
if ($tier3_society_techs -eq $null) { $tier3_society_techs = 0 }
if ($tier3_engineering_techs -eq $null) { $tier3_engineering_techs = 0 }
if ($tier4_physics_techs -eq $null) { $tier4_physics_techs = 0 }
if ($tier4_society_techs -eq $null) { $tier4_society_techs = 0 }
if ($tier4_engineering_techs -eq $null) { $tier4_engineering_techs = 0 }
if ($tier5_physics_techs -eq $null) { $tier5_physics_techs = 0 }
if ($tier5_society_techs -eq $null) { $tier5_society_techs = 0 }
if ($tier5_engineering_techs -eq $null) { $tier5_engineering_techs = 0 }

# pretending we are doing something useful
echo "  available technologies per tier calculated"

# if there are any hard-blocked techs, they need to be eliminated right away
$techsCSV | ForEach-Object {
    if ($_.name -in $blocked_techs -and $_.ignored -ne "True") {
        # blocking the tech
        $_.blocked = "True"

        # reducing possible blocked tech count
        if ($_.area -eq "physics") { $blocked_physics -= 1 }
        if ($_.area -eq "society") { $blocked_society -= 1 }
        if ($_.area -eq "engineering") { $blocked_engineering -= 1 }

        # as well blocking all the unlocked techs and removing them from the possible options
        if ($_.unlocked_full.Length -ne 0) {
            $_.unlocked_full | ForEach-Object {
                $child_name = $_
                ($techsCSV | Where {$_.name -eq $child_name}).indirectly_blocked = "True"
            }
        }
    }
}

# updating available techs once again
$tier1_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
$tier1_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
$tier1_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count

$tier2_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
$tier2_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
$tier2_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count

$tier3_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
$tier3_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
$tier3_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count

$tier4_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
$tier4_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
$tier4_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count

$tier5_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
$tier5_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
$tier5_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count

# sanity check
if ($tier1_physics_techs -eq $null) { $tier1_physics_techs = 0 }
if ($tier1_society_techs -eq $null) { $tier1_society_techs = 0 }
if ($tier1_engineering_techs -eq $null) { $tier1_engineering_techs = 0 }
if ($tier2_physics_techs -eq $null) { $tier2_physics_techs = 0 }
if ($tier2_society_techs -eq $null) { $tier2_society_techs = 0 }
if ($tier2_engineering_techs -eq $null) { $tier2_engineering_techs = 0 }
if ($tier3_physics_techs -eq $null) { $tier3_physics_techs = 0 }
if ($tier3_society_techs -eq $null) { $tier3_society_techs = 0 }
if ($tier3_engineering_techs -eq $null) { $tier3_engineering_techs = 0 }
if ($tier4_physics_techs -eq $null) { $tier4_physics_techs = 0 }
if ($tier4_society_techs -eq $null) { $tier4_society_techs = 0 }
if ($tier4_engineering_techs -eq $null) { $tier4_engineering_techs = 0 }
if ($tier5_physics_techs -eq $null) { $tier5_physics_techs = 0 }
if ($tier5_society_techs -eq $null) { $tier5_society_techs = 0 }
if ($tier5_engineering_techs -eq $null) { $tier5_engineering_techs = 0 }

# pretending we are doing something useful
echo "  forced blocks applied"

echo "database updated"

# primary data loops - iterating through everything which is not a starter tech and not ignored, techs which are contributing the most to our target tier-area are on the top
# first area data loop
$techsCSV | Where {$_.area -eq $prop3} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.blocked -eq "False" } | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Sort-Object $prop1 | ForEach-Object {
    # resetting flags
    $unlocked_flag = 1
    $can_block_flag = 1
    $should_block_flag = 1
    $physics_tier_ok_flag_array = @(1, 1, 1, 1)
    $society_tier_ok_flag_array = @(1, 1, 1, 1)
    $engineering_tier_ok_flag_array = @(1, 1, 1, 1)

    $name = $_.name

    # checking if we are not blocking desired technology
    if ($_.name -in $desired_techs) {
        $unlocked_flag = 0
    }

    # checking if technology doesn't unlock target technology
    $_.unlocked_full | ForEach-Object {
        if ($_ -in $desired_techs) {
            $unlocked_flag = 0
        }
    }

    # checking if technology isn't already blocked
    if ($_.blocked -eq "True") {
        $should_block_flag = 0
    }

    # checking if technology isn't already blocked
    if ($_.indirectly_blocked -eq "True") {
        $should_block_flag = 0
    }

    # checking if blocking tech will not prevent us from reaching higher tiers
    if ($tier1_physics_techs - $_.tier1_physics_techs_unlocked -lt $tier2threshold) { $physics_tier_ok_flag_array[0] = 0 }
    if ($tier1_society_techs - $_.tier1_society_techs_unlocked -lt $tier2threshold) { $society_tier_ok_flag_array[0] = 0 }
    if ($tier1_engineering_techs - $_.tier1_engineering_techs_unlocked -lt $tier2threshold) { $engineering_tier_ok_flag_array[0] = 0 }
    
    if ($tier2_physics_techs - $_.tier2_physics_techs_unlocked -lt $tier3threshold) { $physics_tier_ok_flag_array[1] = 0 }
    if ($tier2_society_techs - $_.tier2_society_techs_unlocked -lt $tier3threshold) { $society_tier_ok_flag_array[1] = 0 }
    if ($tier2_engineering_techs - $_.tier2_engineering_techs_unlocked -lt $tier3threshold) { $engineering_tier_ok_flag_array[1] = 0 }

    if ($tier3_physics_techs - $_.tier3_physics_techs_unlocked -lt $tier4threshold) { $physics_tier_ok_flag_array[2] = 0 }
    if ($tier3_society_techs - $_.tier3_society_techs_unlocked -lt $tier4threshold) { $society_tier_ok_flag_array[2] = 0 }
    if ($tier3_engineering_techs - $_.tier3_engineering_techs_unlocked -lt $tier4threshold) { $engineering_tier_ok_flag_array[2] = 0 }
    
    if ($tier4_physics_techs - $_.tier4_physics_techs_unlocked -lt $tier5threshold) { $physics_tier_ok_flag_array[3] = 0 }
    if ($tier4_society_techs - $_.tier4_society_techs_unlocked -lt $tier5threshold) { $society_tier_ok_flag_array[3] = 0 }
    if ($tier4_engineering_techs - $_.tier4_engineering_techs_unlocked -lt $tier5threshold) { $engineering_tier_ok_flag_array[3] = 0 }

    # sanity check against desired techs tiers
    if ($max_physics_tier -lt 2) { $physics_tier_ok_flag_array[0] = 1 }
    if ($max_society_tier -lt 2) { $society_tier_ok_flag_array[0] = 1 }
    if ($max_engineering_tier -lt 2) { $engineering_tier_ok_flag_array[0] = 1 }
    
    if ($max_physics_tier -lt 3) { $physics_tier_ok_flag_array[1] = 1 }
    if ($max_society_tier -lt 3) { $society_tier_ok_flag_array[1] = 1 }
    if ($max_engineering_tier -lt 3) { $engineering_tier_ok_flag_array[1] = 1 }

    if ($max_physics_tier -lt 4) { $physics_tier_ok_flag_array[2] = 1 }
    if ($max_society_tier -lt 4) { $society_tier_ok_flag_array[2] = 1 }
    if ($max_engineering_tier -lt 4) { $engineering_tier_ok_flag_array[2] = 1 }
    
    if ($max_physics_tier -lt 5) { $physics_tier_ok_flag_array[3] = 1 }
    if ($max_society_tier -lt 5) { $society_tier_ok_flag_array[3] = 1 }
    if ($max_engineering_tier -lt 5) { $engineering_tier_ok_flag_array[3] = 1 }
    
    # checking if we are not blocking something out of the correct tier
    if (($_.area -eq "physics") -and ([int]$max_physics_tier -lt [int]$_.tier)) { $should_block_flag = 0 }
    if (($_.area -eq "society") -and ([int]$max_society_tier -lt [int]$_.tier)) { $should_block_flag = 0 }
    if (($_.area -eq "engineering") -and ([int]$max_engineering_tier -lt [int]$_.tier)) { $should_block_flag = 0 }

    # checking if there is enough research alternatives
    if (($_.area -eq "physics") -and ($blocked_physics -eq 0)) { $can_block_flag = 0 }
    if (($_.area -eq "society") -and ($blocked_society -eq 0)) { $can_block_flag = 0 }
    if (($_.area -eq "engineering") -and ($blocked_engineering -eq 0)) { $can_block_flag = 0 }

    # calculating megaflag
    $flag = $unlocked_flag * $physics_tier_ok_flag_array[0] * $physics_tier_ok_flag_array[1] * $physics_tier_ok_flag_array[2] * $physics_tier_ok_flag_array[3] * $society_tier_ok_flag_array[0] * $society_tier_ok_flag_array[1] * $society_tier_ok_flag_array[2] * $society_tier_ok_flag_array[3] * $engineering_tier_ok_flag_array[0] * $engineering_tier_ok_flag_array[1] * $engineering_tier_ok_flag_array[2] * $engineering_tier_ok_flag_array[3] * $can_block_flag * $should_block_flag

    # if tech is not messing anything, it can be added to pool of blocked techs
    if ($flag -eq 1 -and $_.indirectly_blocked -ne "True") {
        # setting flag
        $was_blocked = 1

        # blocking the tech
        ($techsCSV | Where {$_.name -eq $name}).blocked = "True"

        # reducing overall number of techs - doesn't work that well here either
        <#
        $tier1_physics_techs -= $_.tier1_physics_techs_unlocked
        $tier1_society_techs -= $_.tier1_society_techs_unlocked
        $tier1_engineering_techs -= $_.tier1_engineering_techs_unlocked
    
        $tier2_physics_techs -= $_.tier2_physics_techs_unlocked
        $tier2_society_techs -= $_.tier2_society_techs_unlocked
        $tier2_engineering_techs -= $_.tier2_engineering_techs_unlocked

        $tier3_physics_techs -= $_.tier3_physics_techs_unlocked
        $tier3_society_techs -= $_.tier3_society_techs_unlocked
        $tier3_engineering_techs -= $_.tier3_engineering_techs_unlocked
    
        $tier4_physics_techs -= $_.tier4_physics_techs_unlocked
        $tier4_society_techs -= $_.tier4_society_techs_unlocked
        $tier4_engineering_techs -= $_.tier4_engineering_techs_unlocked
        #>

        # reducing possible blocked tech count
        if ($_.area -eq "physics") { $blocked_physics -= 1 }
        if ($_.area -eq "society") { $blocked_society -= 1 }
        if ($_.area -eq "engineering") { $blocked_engineering -= 1 }

        # as well blocking all the unlocked techs and removing them from the possible options
        if ($_.unlocked_full.Length -ne 0) {
            $_.unlocked_full | ForEach-Object {
                $child_name = $_
                ($techsCSV | Where {$_.name -eq $child_name}).indirectly_blocked = "True"
            }
        } 
    }
    
    #resetting tech counters - probably there is smarter way to do that
    if ($was_blocked -eq 1) {

        $tier1_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
        $tier1_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
        $tier1_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count

        $tier2_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
        $tier2_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
        $tier2_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count

        $tier3_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
        $tier3_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
        $tier3_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count

        $tier4_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
        $tier4_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
        $tier4_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count

        $tier5_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
        $tier5_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
        $tier5_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count

        # sanity check
        if ($tier1_physics_techs -eq $null) { $tier1_physics_techs = 0 }
        if ($tier1_society_techs -eq $null) { $tier1_society_techs = 0 }
        if ($tier1_engineering_techs -eq $null) { $tier1_engineering_techs = 0 }
        if ($tier2_physics_techs -eq $null) { $tier2_physics_techs = 0 }
        if ($tier2_society_techs -eq $null) { $tier2_society_techs = 0 }
        if ($tier2_engineering_techs -eq $null) { $tier2_engineering_techs = 0 }
        if ($tier3_physics_techs -eq $null) { $tier3_physics_techs = 0 }
        if ($tier3_society_techs -eq $null) { $tier3_society_techs = 0 }
        if ($tier3_engineering_techs -eq $null) { $tier3_engineering_techs = 0 }
        if ($tier4_physics_techs -eq $null) { $tier4_physics_techs = 0 }
        if ($tier4_society_techs -eq $null) { $tier4_society_techs = 0 }
        if ($tier4_engineering_techs -eq $null) { $tier4_engineering_techs = 0 }
        if ($tier5_physics_techs -eq $null) { $tier5_physics_techs = 0 }
        if ($tier5_society_techs -eq $null) { $tier5_society_techs = 0 }
        if ($tier5_engineering_techs -eq $null) { $tier5_engineering_techs = 0 }

        $was_blocked = 0
    }       
}

# pretending we are doing something useful
echo "$prop3 data loop complete"

# second area data loop
$techsCSV | Where {$_.area -eq $prop4} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.blocked -eq "False" } | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Sort-Object $prop1 | ForEach-Object {
    # resetting flags
    $unlocked_flag = 1
    $can_block_flag = 1
    $should_block_flag = 1
    $physics_tier_ok_flag_array = @(1, 1, 1, 1)
    $society_tier_ok_flag_array = @(1, 1, 1, 1)
    $engineering_tier_ok_flag_array = @(1, 1, 1, 1)

    $name = $_.name

    # checking if we are not blocking desired technology
    if ($_.name -in $desired_techs) {
        $unlocked_flag = 0
    }

    # checking if technology doesn't unlock target technology
    $_.unlocked_full | ForEach-Object {
        if ($_ -in $desired_techs) {
            $unlocked_flag = 0
        }
    }

    # checking if technology isn't already blocked
    if ($_.blocked -eq "True") {
        $should_block_flag = 0
    }

    # checking if technology isn't already blocked
    if ($_.indirectly_blocked -eq "True") {
        $should_block_flag = 0
    }

    # checking if blocking tech will not prevent us from reaching higher tiers
    if ($tier1_physics_techs - $_.tier1_physics_techs_unlocked -lt $tier2threshold) { $physics_tier_ok_flag_array[0] = 0 }
    if ($tier1_society_techs - $_.tier1_society_techs_unlocked -lt $tier2threshold) { $society_tier_ok_flag_array[0] = 0 }
    if ($tier1_engineering_techs - $_.tier1_engineering_techs_unlocked -lt $tier2threshold) { $engineering_tier_ok_flag_array[0] = 0 }
    
    if ($tier2_physics_techs - $_.tier2_physics_techs_unlocked -lt $tier3threshold) { $physics_tier_ok_flag_array[1] = 0 }
    if ($tier2_society_techs - $_.tier2_society_techs_unlocked -lt $tier3threshold) { $society_tier_ok_flag_array[1] = 0 }
    if ($tier2_engineering_techs - $_.tier2_engineering_techs_unlocked -lt $tier3threshold) { $engineering_tier_ok_flag_array[1] = 0 }

    if ($tier3_physics_techs - $_.tier3_physics_techs_unlocked -lt $tier4threshold) { $physics_tier_ok_flag_array[2] = 0 }
    if ($tier3_society_techs - $_.tier3_society_techs_unlocked -lt $tier4threshold) { $society_tier_ok_flag_array[2] = 0 }
    if ($tier3_engineering_techs - $_.tier3_engineering_techs_unlocked -lt $tier4threshold) { $engineering_tier_ok_flag_array[2] = 0 }
    
    if ($tier4_physics_techs - $_.tier4_physics_techs_unlocked -lt $tier5threshold) { $physics_tier_ok_flag_array[3] = 0 }
    if ($tier4_society_techs - $_.tier4_society_techs_unlocked -lt $tier5threshold) { $society_tier_ok_flag_array[3] = 0 }
    if ($tier4_engineering_techs - $_.tier4_engineering_techs_unlocked -lt $tier5threshold) { $engineering_tier_ok_flag_array[3] = 0 }

    # sanity check against desired techs tiers
    if ($max_physics_tier -lt 2) { $physics_tier_ok_flag_array[0] = 1 }
    if ($max_society_tier -lt 2) { $society_tier_ok_flag_array[0] = 1 }
    if ($max_engineering_tier -lt 2) { $engineering_tier_ok_flag_array[0] = 1 }
    
    if ($max_physics_tier -lt 3) { $physics_tier_ok_flag_array[1] = 1 }
    if ($max_society_tier -lt 3) { $society_tier_ok_flag_array[1] = 1 }
    if ($max_engineering_tier -lt 3) { $engineering_tier_ok_flag_array[1] = 1 }

    if ($max_physics_tier -lt 4) { $physics_tier_ok_flag_array[2] = 1 }
    if ($max_society_tier -lt 4) { $society_tier_ok_flag_array[2] = 1 }
    if ($max_engineering_tier -lt 4) { $engineering_tier_ok_flag_array[2] = 1 }
    
    if ($max_physics_tier -lt 5) { $physics_tier_ok_flag_array[3] = 1 }
    if ($max_society_tier -lt 5) { $society_tier_ok_flag_array[3] = 1 }
    if ($max_engineering_tier -lt 5) { $engineering_tier_ok_flag_array[3] = 1 }
    
    # checking if we are not blocking something out of the correct tier
    if (($_.area -eq "physics") -and ([int]$max_physics_tier -lt [int]$_.tier)) { $should_block_flag = 0 }
    if (($_.area -eq "society") -and ([int]$max_society_tier -lt [int]$_.tier)) { $should_block_flag = 0 }
    if (($_.area -eq "engineering") -and ([int]$max_engineering_tier -lt [int]$_.tier)) { $should_block_flag = 0 }

    # checking if there is enough research alternatives
    if (($_.area -eq "physics") -and ($blocked_physics -eq 0)) { $can_block_flag = 0 }
    if (($_.area -eq "society") -and ($blocked_society -eq 0)) { $can_block_flag = 0 }
    if (($_.area -eq "engineering") -and ($blocked_engineering -eq 0)) { $can_block_flag = 0 }

    # calculating megaflag
    $flag = $unlocked_flag * $physics_tier_ok_flag_array[0] * $physics_tier_ok_flag_array[1] * $physics_tier_ok_flag_array[2] * $physics_tier_ok_flag_array[3] * $society_tier_ok_flag_array[0] * $society_tier_ok_flag_array[1] * $society_tier_ok_flag_array[2] * $society_tier_ok_flag_array[3] * $engineering_tier_ok_flag_array[0] * $engineering_tier_ok_flag_array[1] * $engineering_tier_ok_flag_array[2] * $engineering_tier_ok_flag_array[3] * $can_block_flag * $should_block_flag

    # if tech is not messing anything, it can be added to pool of blocked techs
    if ($flag -eq 1 -and $_.indirectly_blocked -ne "True") {
        # setting flag
        $was_blocked = 1

        # blocking the tech
        ($techsCSV | Where {$_.name -eq $name}).blocked = "True"

        # reducing overall number of techs - doesn't work that well here either
        <#
        $tier1_physics_techs -= $_.tier1_physics_techs_unlocked
        $tier1_society_techs -= $_.tier1_society_techs_unlocked
        $tier1_engineering_techs -= $_.tier1_engineering_techs_unlocked
    
        $tier2_physics_techs -= $_.tier2_physics_techs_unlocked
        $tier2_society_techs -= $_.tier2_society_techs_unlocked
        $tier2_engineering_techs -= $_.tier2_engineering_techs_unlocked

        $tier3_physics_techs -= $_.tier3_physics_techs_unlocked
        $tier3_society_techs -= $_.tier3_society_techs_unlocked
        $tier3_engineering_techs -= $_.tier3_engineering_techs_unlocked
    
        $tier4_physics_techs -= $_.tier4_physics_techs_unlocked
        $tier4_society_techs -= $_.tier4_society_techs_unlocked
        $tier4_engineering_techs -= $_.tier4_engineering_techs_unlocked
        #>

        # reducing possible blocked tech count
        if ($_.area -eq "physics") { $blocked_physics -= 1 }
        if ($_.area -eq "society") { $blocked_society -= 1 }
        if ($_.area -eq "engineering") { $blocked_engineering -= 1 }

        # as well blocking all the unlocked techs and removing them from the possible options
        if ($_.unlocked_full.Length -ne 0) {
            $_.unlocked_full | ForEach-Object {
                $child_name = $_
                ($techsCSV | Where {$_.name -eq $child_name}).indirectly_blocked = "True"
            }
        } 
    }
    
    #resetting tech counters - probably there is smarter way to do that
    if ($was_blocked -eq 1) {

        $tier1_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
        $tier1_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
        $tier1_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count

        $tier2_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
        $tier2_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
        $tier2_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count

        $tier3_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
        $tier3_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
        $tier3_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count

        $tier4_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
        $tier4_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
        $tier4_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count

        $tier5_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
        $tier5_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
        $tier5_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count

        # sanity check
        if ($tier1_physics_techs -eq $null) { $tier1_physics_techs = 0 }
        if ($tier1_society_techs -eq $null) { $tier1_society_techs = 0 }
        if ($tier1_engineering_techs -eq $null) { $tier1_engineering_techs = 0 }
        if ($tier2_physics_techs -eq $null) { $tier2_physics_techs = 0 }
        if ($tier2_society_techs -eq $null) { $tier2_society_techs = 0 }
        if ($tier2_engineering_techs -eq $null) { $tier2_engineering_techs = 0 }
        if ($tier3_physics_techs -eq $null) { $tier3_physics_techs = 0 }
        if ($tier3_society_techs -eq $null) { $tier3_society_techs = 0 }
        if ($tier3_engineering_techs -eq $null) { $tier3_engineering_techs = 0 }
        if ($tier4_physics_techs -eq $null) { $tier4_physics_techs = 0 }
        if ($tier4_society_techs -eq $null) { $tier4_society_techs = 0 }
        if ($tier4_engineering_techs -eq $null) { $tier4_engineering_techs = 0 }
        if ($tier5_physics_techs -eq $null) { $tier5_physics_techs = 0 }
        if ($tier5_society_techs -eq $null) { $tier5_society_techs = 0 }
        if ($tier5_engineering_techs -eq $null) { $tier5_engineering_techs = 0 }

        $was_blocked = 0
    }
}

# pretending we are doing something useful
echo "$prop4 data loop complete"

# third area data loop
$techsCSV | Where {$_.area -eq $prop5} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.blocked -eq "False" } | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Sort-Object $prop1 | ForEach-Object {
    # resetting flags
    $unlocked_flag = 1
    $can_block_flag = 1
    $should_block_flag = 1
    $physics_tier_ok_flag_array = @(1, 1, 1, 1)
    $society_tier_ok_flag_array = @(1, 1, 1, 1)
    $engineering_tier_ok_flag_array = @(1, 1, 1, 1)

    $name = $_.name

    # checking if we are not blocking desired technology
    if ($_.name -in $desired_techs) {
        $unlocked_flag = 0
    }

    # checking if technology doesn't unlock target technology
    $_.unlocked_full | ForEach-Object {
        if ($_ -in $desired_techs) {
            $unlocked_flag = 0
        }
    }

    # checking if technology isn't already blocked
    if ($_.blocked -eq "True") {
        $should_block_flag = 0
    }

    # checking if technology isn't already blocked
    if ($_.indirectly_blocked -eq "True") {
        $should_block_flag = 0
    }

    # checking if blocking tech will not prevent us from reaching higher tiers
    if ($tier1_physics_techs - $_.tier1_physics_techs_unlocked -lt $tier2threshold) { $physics_tier_ok_flag_array[0] = 0 }
    if ($tier1_society_techs - $_.tier1_society_techs_unlocked -lt $tier2threshold) { $society_tier_ok_flag_array[0] = 0 }
    if ($tier1_engineering_techs - $_.tier1_engineering_techs_unlocked -lt $tier2threshold) { $engineering_tier_ok_flag_array[0] = 0 }
    
    if ($tier2_physics_techs - $_.tier2_physics_techs_unlocked -lt $tier3threshold) { $physics_tier_ok_flag_array[1] = 0 }
    if ($tier2_society_techs - $_.tier2_society_techs_unlocked -lt $tier3threshold) { $society_tier_ok_flag_array[1] = 0 }
    if ($tier2_engineering_techs - $_.tier2_engineering_techs_unlocked -lt $tier3threshold) { $engineering_tier_ok_flag_array[1] = 0 }

    if ($tier3_physics_techs - $_.tier3_physics_techs_unlocked -lt $tier4threshold) { $physics_tier_ok_flag_array[2] = 0 }
    if ($tier3_society_techs - $_.tier3_society_techs_unlocked -lt $tier4threshold) { $society_tier_ok_flag_array[2] = 0 }
    if ($tier3_engineering_techs - $_.tier3_engineering_techs_unlocked -lt $tier4threshold) { $engineering_tier_ok_flag_array[2] = 0 }
    
    if ($tier4_physics_techs - $_.tier4_physics_techs_unlocked -lt $tier5threshold) { $physics_tier_ok_flag_array[3] = 0 }
    if ($tier4_society_techs - $_.tier4_society_techs_unlocked -lt $tier5threshold) { $society_tier_ok_flag_array[3] = 0 }
    if ($tier4_engineering_techs - $_.tier4_engineering_techs_unlocked -lt $tier5threshold) { $engineering_tier_ok_flag_array[3] = 0 }

    # sanity check against desired techs tiers
    if ($max_physics_tier -lt 2) { $physics_tier_ok_flag_array[0] = 1 }
    if ($max_society_tier -lt 2) { $society_tier_ok_flag_array[0] = 1 }
    if ($max_engineering_tier -lt 2) { $engineering_tier_ok_flag_array[0] = 1 }
    
    if ($max_physics_tier -lt 3) { $physics_tier_ok_flag_array[1] = 1 }
    if ($max_society_tier -lt 3) { $society_tier_ok_flag_array[1] = 1 }
    if ($max_engineering_tier -lt 3) { $engineering_tier_ok_flag_array[1] = 1 }

    if ($max_physics_tier -lt 4) { $physics_tier_ok_flag_array[2] = 1 }
    if ($max_society_tier -lt 4) { $society_tier_ok_flag_array[2] = 1 }
    if ($max_engineering_tier -lt 4) { $engineering_tier_ok_flag_array[2] = 1 }
    
    if ($max_physics_tier -lt 5) { $physics_tier_ok_flag_array[3] = 1 }
    if ($max_society_tier -lt 5) { $society_tier_ok_flag_array[3] = 1 }
    if ($max_engineering_tier -lt 5) { $engineering_tier_ok_flag_array[3] = 1 }
    
    # checking if we are not blocking something out of the correct tier
    if (($_.area -eq "physics") -and ([int]$max_physics_tier -lt [int]$_.tier)) { $should_block_flag = 0 }
    if (($_.area -eq "society") -and ([int]$max_society_tier -lt [int]$_.tier)) { $should_block_flag = 0 }
    if (($_.area -eq "engineering") -and ([int]$max_engineering_tier -lt [int]$_.tier)) { $should_block_flag = 0 }

    # checking if there is enough research alternatives
    if (($_.area -eq "physics") -and ($blocked_physics -eq 0)) { $can_block_flag = 0 }
    if (($_.area -eq "society") -and ($blocked_society -eq 0)) { $can_block_flag = 0 }
    if (($_.area -eq "engineering") -and ($blocked_engineering -eq 0)) { $can_block_flag = 0 }

    # calculating megaflag
    $flag = $unlocked_flag * $physics_tier_ok_flag_array[0] * $physics_tier_ok_flag_array[1] * $physics_tier_ok_flag_array[2] * $physics_tier_ok_flag_array[3] * $society_tier_ok_flag_array[0] * $society_tier_ok_flag_array[1] * $society_tier_ok_flag_array[2] * $society_tier_ok_flag_array[3] * $engineering_tier_ok_flag_array[0] * $engineering_tier_ok_flag_array[1] * $engineering_tier_ok_flag_array[2] * $engineering_tier_ok_flag_array[3] * $can_block_flag * $should_block_flag

    # if tech is not messing anything, it can be added to pool of blocked techs
    if ($flag -eq 1 -and $_.indirectly_blocked -ne "True") {
        # setting flag
        $was_blocked = 1

        # blocking the tech
        ($techsCSV | Where {$_.name -eq $name}).blocked = "True"

        # reducing overall number of techs - doesn't work that well here either
        <#
        $tier1_physics_techs -= $_.tier1_physics_techs_unlocked
        $tier1_society_techs -= $_.tier1_society_techs_unlocked
        $tier1_engineering_techs -= $_.tier1_engineering_techs_unlocked
    
        $tier2_physics_techs -= $_.tier2_physics_techs_unlocked
        $tier2_society_techs -= $_.tier2_society_techs_unlocked
        $tier2_engineering_techs -= $_.tier2_engineering_techs_unlocked

        $tier3_physics_techs -= $_.tier3_physics_techs_unlocked
        $tier3_society_techs -= $_.tier3_society_techs_unlocked
        $tier3_engineering_techs -= $_.tier3_engineering_techs_unlocked
    
        $tier4_physics_techs -= $_.tier4_physics_techs_unlocked
        $tier4_society_techs -= $_.tier4_society_techs_unlocked
        $tier4_engineering_techs -= $_.tier4_engineering_techs_unlocked
        #>

        # reducing possible blocked tech count
        if ($_.area -eq "physics") { $blocked_physics -= 1 }
        if ($_.area -eq "society") { $blocked_society -= 1 }
        if ($_.area -eq "engineering") { $blocked_engineering -= 1 }

        # as well blocking all the unlocked techs and removing them from the possible options
        if ($_.unlocked_full.Length -ne 0) {
            $_.unlocked_full | ForEach-Object {
                $child_name = $_
                ($techsCSV | Where {$_.name -eq $child_name}).indirectly_blocked = "True"
            }
        } 
    }

    #resetting tech counters - probably there is smarter way to do that
    if ($was_blocked -eq 1) {

        $tier1_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
        $tier1_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count
        $tier1_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 1 }).Count

        $tier2_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
        $tier2_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count
        $tier2_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 2 }).Count

        $tier3_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
        $tier3_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count
        $tier3_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 3 }).Count

        $tier4_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
        $tier4_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count
        $tier4_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 4 }).Count

        $tier5_physics_techs = ($techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
        $tier5_society_techs = ($techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count
        $tier5_engineering_techs = ($techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -ne "True" } | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Where {$_.weight -ne "0" } | Where { $_.tier -eq 5 }).Count

        #  sanity check
        if ($tier1_physics_techs -eq $null) { $tier1_physics_techs = 0 }
        if ($tier1_society_techs -eq $null) { $tier1_society_techs = 0 }
        if ($tier1_engineering_techs -eq $null) { $tier1_engineering_techs = 0 }
        if ($tier2_physics_techs -eq $null) { $tier2_physics_techs = 0 }
        if ($tier2_society_techs -eq $null) { $tier2_society_techs = 0 }
        if ($tier2_engineering_techs -eq $null) { $tier2_engineering_techs = 0 }
        if ($tier3_physics_techs -eq $null) { $tier3_physics_techs = 0 }
        if ($tier3_society_techs -eq $null) { $tier3_society_techs = 0 }
        if ($tier3_engineering_techs -eq $null) { $tier3_engineering_techs = 0 }
        if ($tier4_physics_techs -eq $null) { $tier4_physics_techs = 0 }
        if ($tier4_society_techs -eq $null) { $tier4_society_techs = 0 }
        if ($tier4_engineering_techs -eq $null) { $tier4_engineering_techs = 0 }
        if ($tier5_physics_techs -eq $null) { $tier5_physics_techs = 0 }
        if ($tier5_society_techs -eq $null) { $tier5_society_techs = 0 }
        if ($tier5_engineering_techs -eq $null) { $tier5_engineering_techs = 0 }

        $was_blocked = 0
    }   
}

# pretending we are doing something useful
echo "$prop5 data loop complete"

echo "---"

echo "blocked physics techs (from least to most heavy techs):"
$techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.weight -ne "0" } | Where {[int]$_.tier -le [int]$target_tier} | Where {$_.blocked -eq "True"} | Sort-Object $prop2 | ForEach-Object {
    $name = $_.name
    $blocked = $_.$criteria
    echo "$name - blocked $blocked $target_area research points"
}

echo "tier sanity check (maximum desired is $max_physics_tier): $tier1_physics_techs / $tier2_physics_techs / $tier3_physics_techs / $tier4_physics_techs"
echo "---"

echo "blocked society techs (from least to most heavy techs):"
$techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.weight -ne "0" } | Where {[int]$_.tier -le [int]$target_tier} | Where {$_.blocked -eq "True"} | Sort-Object $prop2 | ForEach-Object {
    $name = $_.name
    $blocked = $_.$criteria
    echo "$name - blocked $blocked $target_area research points"
}

echo "tier sanity check (maximum desired is $max_society_tier): $tier1_society_techs / $tier2_society_techs / $tier3_society_techs / $tier4_society_techs"
echo "---"

echo "blocked engineering techs (from least to most heavy techs):"
$techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.weight -ne "0" } | Where {[int]$_.tier -le [int]$target_tier} | Where {$_.blocked -eq "True"} | Sort-Object $prop2 | ForEach-Object {
    $name = $_.name
    $blocked = $_.$criteria
    echo "$name - blocked $blocked $target_area research points"
}

echo "tier sanity check (maximum desired is $max_engineering_tier): $tier1_engineering_techs / $tier2_engineering_techs / $tier3_engineering_techs / $tier4_engineering_techs"
echo "---"


if ($show_allowed -eq 1) {
    echo "allowed physics techs:"
    $techsCSV | Where {$_.area -eq "physics"} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" }  | Where {$_.weight -ne "0" } | Where {[int]$_.tier -le [int]$target_tier} | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } |  Sort-Object $prop6 | ForEach-Object {
        $name = $_.name
        $tier = $_.tier
        echo "$tier - $name"
    }

    echo "---"

    echo "allowed society techs:"
    $techsCSV | Where {$_.area -eq "society"} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.weight -ne "0" } | Where {[int]$_.tier -le [int]$target_tier} | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Sort-Object $prop6 | ForEach-Object {
        $name = $_.name
        $tier = $_.tier
        echo "$tier - $name"
    }

    echo "---"

    echo "allowed engineering techs:"
    $techsCSV | Where {$_.area -eq "engineering"} | Where {$_.starting -eq "False" } | Where {$_.ignored -eq "False" } | Where {$_.weight -ne "0" } | Where {[int]$_.tier -le [int]$target_tier} | Where {$_.blocked -eq "False"} | Where {$_.indirectly_blocked -eq "False" } | Sort-Object $prop6 | ForEach-Object {
        $name = $_.name
        $tier = $_.tier
        echo "$tier - $name"
    }

    echo "---"
}

# another cool message for the user
echo "my job here is done"