# devtools::install_github("R-Computing-Lab/BGmisc")
library(tidyverse)
library(here)
library(readr)
library(usethis)
library(BGmisc)


## Create dataframe
ASOIAF <- ged <- readGedcom("data-raw/ASOIAF.ged") %>%
  mutate(name = str_remove(name, "/"))

# ASOIAF <- readGedcom("data-raw/ASOIAF_040725.ged")

df <- ped2fam(ASOIAF, personID = "personID") %>%
  select(
    -name_npfx,
    -name_nsfx,
    -name_given,
    -name_surn,
    #    -name_marriedsurn,
    -death_caus,
    -FAMC,
    -FAMS
  ) %>%
  mutate(
    momID = as.numeric(momID),
    dadID = as.numeric(dadID),
    personID = as.numeric(personID),
    name = case_when(
      name == "Naerys " ~ "Naerys Targaryen",
      name == "Rhaenyra " ~ "Rhaenyra Targaryen",
      name == "Betharios " ~ "Betharios of Braavos",
      name == "Rowena " ~ "Rowena Arryn",
      name == "Pate " ~ "Pate of the Blue Fork",
      name == "Mellario " ~ "Mellario of Norvos",
      is.na(.data$name) &
        personID %in% c(360, 489:498) ~ "Bastard of Robert Baratheon",
      personID == 86 ~ "Mariya Darry",
      personID == 179 ~ "Gerold Lannister",
      personID == 180 ~ "Tywald Lannister",
      personID == 181 ~ "Tion Lannister",
      personID == 182 ~ "Jason Lannister",
      personID == 200 ~ "Aegon V Targaryen",
      personID == 201 ~ "Jaehaerys II Targaryen",
      personID == 202 ~ "Aerys II Targaryen",
      personID == 237 ~ "Youngest daughter of Elys Waynwood",
      personID == 255 ~ "Lord Tully",
      personID == 257 ~ "Princess Of Dorne",
      personID == 274 ~ "Lord Uller",
      personID == 281 ~ "Daeron Targaryen (son of Aegon V)",
      personID == 283 ~ "Daeron (son of Maekar) Targaryen",
      personID == 284 ~ "Vaella Targaryen",
      personID == 285 ~ "Aerion (son of Maekar) Targaryen",
      personID == 286 ~ "Unknown Targaryen",
      personID == 288 ~ "Rhae Targaryen", # not Rhaelle Targaryen
      personID == 289 ~ "Daella Targaryen (daughter of Maekar I)",
      personID == 294 ~ "Aelinor Penrose",
      personID %in% c(300:301) ~ "Stillborn Targaryen",
      personID == 317 ~ "Father of Maelys I Blackfyre",
      personID == 322 ~ "Daenaera Velaryon",
      personID == 325 ~ "Ronnel Penrose",
      personID == 326 ~ "Viserys Plumm",
      personID == 327 ~ "Robin Penrose",
      personID == 328 ~ "Laena Penrose",
      personID == 329 ~ "Jocelyn Penrose",
      personID == 330 ~ "Joy Penrose",
      personID == 341 ~ "Aemma Arryn",
      personID == 343 ~ "Baelon Targaryen (son of Viserys I)",
      personID == 347 ~ "Daeron Targaryen",
      personID == 348 ~ "Helaena Targaryen",
      personID == 358 ~ "Aerion (son of Daemion) Targaryen",
      personID == 364 ~ "Daemion Targaryen (Lord of Dragonstone)",
      personID == 366 ~ "Aelyx Targaryen",
      personID == 393 ~ "Lord Tyrell",
      personID == 425 ~ "Lord High Tower",
      personID == 429 ~ "Lord Mormont",
      personID == 443 ~ "Lord Florent",
      personID == 465 ~ "Willam Stark",
      personID == 467 ~ "Melantha Blackwood",
      personID == 468 ~ "Lyarra Stark",
      personID == 469 ~ "Jocelyn Stark",
      personID == 470 ~ "Benedict Royce",
      personID == 482 ~ "Lord Dayne (father of Edric)",
      personID == 499 ~ "Ormund Baratheon",
      personID == 500 ~ "Unknown Baratheon",
      TRUE ~ name
    ),
    url = case_when(
      personID == 1 ~ "https://awoiaf.westeros.org/index.php/Walder_Frey",
      personID == 2 ~ "https://awoiaf.westeros.org/index.php/Perra_Royce",
      personID == 3 ~ "https://awoiaf.westeros.org/index.php/Stevron_Frey",
      personID == 4 ~ "https://awoiaf.westeros.org/index.php/Emmon_Frey",
      personID == 5 ~ "https://awoiaf.westeros.org/index.php/Aenys_Frey",
      personID == 9 ~ "https://awoiaf.westeros.org/index.php/Walder_Frey_(son_of_Ryman)",
      personID == 16 ~ "https://awoiaf.westeros.org/index.php/Aegon_Frey_(son_of_Stevron)",
      personID == 26 ~ "https://awoiaf.westeros.org/index.php/Walda_Frey_(daughter_of_Walton)",
      personID == 32 ~ "https://awoiaf.westeros.org/index.php/Walder_Frey_(son_of_Emmon)",
      personID == 34 ~ "https://awoiaf.westeros.org/index.php/Tywin_Frey",
      personID == 37 ~ "https://awoiaf.westeros.org/index.php/Aegon_Frey_(son_of_Aenys)",
      personID == 41 ~ "https://awoiaf.westeros.org/index.php/Walda_Frey_(daughter_of_Rhaegar)",
      personID == 87 ~ "https://awoiaf.westeros.org/index.php/Amerei_Frey",
      personID == 89 ~ "https://awoiaf.westeros.org/index.php/Walda_Frey_(daughter_of_Merrett)",
      personID == 91 ~ "https://awoiaf.westeros.org/index.php/Walder_Frey_(son_of_Merrett)",
      personID == 115 ~ "https://awoiaf.westeros.org/index.php/Walder_Frey_(son_of_Jammos)",
      personID == 156 ~ NA_character_,
      personID == 191 ~ "https://awoiaf.westeros.org/index.php/Barra",
      personID == 193 ~ "https://awoiaf.westeros.org/index.php/Gendry",
      personID == 194 ~ "https://awoiaf.westeros.org/index.php/Bella",
      personID == 209 ~ "https://awoiaf.westeros.org/index.php/Aegon_Targaryen_(son_of_Rhaegar)",
      personID == 220 ~ "https://awoiaf.westeros.org/index.php/Bran_Stark",
      personID %in% c(234, 240:245, 237, 249, 250) ~ "https://awoiaf.westeros.org/index.php/House_Waynwood",
      personID == 236 ~ "https://awoiaf.westeros.org/index.php/House_Arryn",
      personID == 238 ~ "https://awoiaf.westeros.org/index.php/House_Hardyng",
      personID == 256 ~ "https://awoiaf.westeros.org/index.php/Brynden_Tully",
      personID == 257 ~ "https://awoiaf.westeros.org/index.php/Princess_of_Dorne_(mother_of_Doran)",
      personID == 258 ~ NA_character_,
      personID == 263 ~ "https://awoiaf.westeros.org/index.php/Oberyn_Martell",
      personID == 274 ~ "https://awoiaf.westeros.org/index.php/Harmen_Uller#Family",
      personID == 280 ~ "https://awoiaf.westeros.org/index.php/Duncan_Targaryen",
      personID == 283 ~ "https://awoiaf.westeros.org/index.php/Daeron_Targaryen_(son_of_Maekar_I)",
      personID == 285 ~ "https://awoiaf.westeros.org/index.php/Aerion_Targaryen",
      personID == 286 ~ "https://awoiaf.westeros.org/index.php/House_Targaryen",
      personID == 292 ~ "https://awoiaf.westeros.org/index.php/Baelor_Targaryen_(son_of_Daeron_II)",
      personID == 294 ~ "https://awoiaf.westeros.org/index.php/Aelinor_Penrose",
      personID == 296 ~ "https://awoiaf.westeros.org/index.php/House_Targaryen",
      personID == 297 ~ "https://awoiaf.westeros.org/index.php/House_Targaryen",
      personID %in% c(300:301) ~ "https://awoiaf.westeros.org/index.php/Valarr_Targaryen#Family",
      personID %in% c(318:319) ~ "https://awoiaf.westeros.org/index.php/House_Blackfyre#Family",
      personID == 302 ~ "https://awoiaf.westeros.org/index.php/Aegon_IV_Targaryen",
      personID == 307 ~ "https://awoiaf.westeros.org/index.php/Aemon_Targaryen_(son_of_Viserys_II)",
      personID == 309 ~ "https://awoiaf.westeros.org/index.php/Aegor_Rivers",
      personID == 310 ~ "https://awoiaf.westeros.org/index.php/Brynden_Rivers",
      personID == 313 ~ "https://awoiaf.westeros.org/index.php/Aegon_Blackfyre",
      personID == 317 ~ "https://awoiaf.westeros.org/index.php/Maelys_I_Blackfyre#Family",
      personID == 320 ~ "https://awoiaf.westeros.org/index.php/Maelys_I_Blackfyre",
      personID == 321 ~ "https://awoiaf.westeros.org/index.php/Aegon_III_Targaryen",
      personID == 345 ~ "https://awoiaf.westeros.org/index.php/Aegon_II_Targaryen",
      personID == 349 ~ "https://awoiaf.westeros.org/index.php/House_Targaryen",
      personID == 350 ~ "https://awoiaf.westeros.org/index.php/Jaehaerys_I_Targaryen",
      personID == 351 ~ "https://awoiaf.westeros.org/index.php/Alysanne_Targaryen",
      personID == 353 ~ "https://awoiaf.westeros.org/index.php/Aegon_I_Targaryen",
      personID == 358 ~ "https://awoiaf.westeros.org/index.php/Aerion_Targaryen_(son_of_Daemion)",
      personID %in% c(360, 489:498) ~ "https://awoiaf.westeros.org/index.php/Robert_I_Baratheon#Family",
      personID == 363 ~ "https://awoiaf.westeros.org/index.php/Argilac_Durrandon",
      personID == 364 ~ "https://awoiaf.westeros.org/index.php/Daemion_Targaryen",
      personID == 365 ~ "https://awoiaf.westeros.org/index.php/Aerys_Targaryen_(son_of_Aegon)",
      personID == 366 ~ "https://awoiaf.westeros.org/index.php/Aelyx_Targaryen",
      personID == 368 ~ "https://awoiaf.westeros.org/index.php/Aegon_Targaryen_(son_of_Gaemon)",
      personID == 370 ~ "https://awoiaf.westeros.org/index.php/Elaena_Targaryen_(daughter_of_Gaemon)",
      personID == 383 ~ "https://awoiaf.westeros.org/index.php/Garth_Tyrell",
      personID == 390 ~ "https://awoiaf.westeros.org/index.php/Horas_Redwyne",
      personID == 391 ~ "https://awoiaf.westeros.org/index.php/Hobber_Redwyne",
      personID == 397 ~ "https://awoiaf.westeros.org/index.php/Leo_Tyrell_(son_of_Moryn)",
      personID %in% c(425:426) ~ "https://awoiaf.westeros.org/index.php/House_Hightower#House_Hightower_at_the_end_of_the_third_century",
      personID == 427 ~ "https://awoiaf.westeros.org/index.php/Gerold_Hightower",
      personID %in% c(428) ~ "https://awoiaf.westeros.org/index.php/House_Glover",
      personID %in% c(436:437) ~ "https://awoiaf.westeros.org/index.php/Alysane_Mormont#Family",
      personID %in% c(438, 460:461) ~ NA_character_,
      personID %in% c(471:475) ~ NA_character_,
      personID == 479 ~ "https://awoiaf.westeros.org/index.php/Sylva_Santagar",
      personID == 482 ~ "https://awoiaf.westeros.org/index.php/Lord_Dayne_(father_of_Edric)",
      personID == 483 ~ NA_character_, # No specific URL available
      personID == 500 ~ "https://awoiaf.westeros.org/index.php/House_Baratheon",
      TRUE ~ paste0("https://awoiaf.westeros.org/index.php/", str_replace_all(name, " ", "_"))
    ),
    twinID = case_match(name,
      "Jaime Lannister" ~ 165,
      "Cersei Lannister" ~ 164,
      "Alyn Frey" ~ 73,
      "Androw Frey" ~ 74,
      "Aegon Blackfyre" ~ 314,
      "Aemon Blackfyre" ~ 313,
      "Dickon Frey" ~ 117,
      "Mathis Frey" ~ 116,
      "Jaime Frey" ~ 101,
      "Tywin Frey" ~ 102,
      "Sarra Frey" ~ 99,
      "Serra Frey" ~ 98,
      "Martyn Lannister" ~ 173,
      "Willem Lannister" ~ 174,
      "Jeyne Waters" ~ 337,
      "Jon Waters" ~ 338,
      "Hobber 'Slobber' Redwyne" ~ 390,
      "Horas 'Horror' Redwyne" ~ 391,
      .default = NA_real_
    )
  ) %>%
  mutate(
    zygosity = case_when(
      personID %in% c(164, 165) ~ "dz", # Jaime Lannister
      !is.na(twinID) ~ "unknown",
      TRUE ~ NA_character_
    )
  )

df <- df %>%
  addPersonToPed(
    personID = 247,
    name = "Lady Belmore",
    sex = "F",
    momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/House_Belmore#House_Belmore_at_the_end_of_the_third_century",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    name = "Father of Anya Waynwood", sex = "M",
    personID = 250, momID = NA, dadID = 249,
    url = "https://awoiaf.westeros.org/index.php/Anya_Waynwood", overwrite = TRUE
  ) %>%
  addPersonToPed(
    name = "Anya Waynwood", sex = "F",
    personID = 251, momID = NA, dadID = 250,
    url = "https://awoiaf.westeros.org/index.php/Anya_Waynwood",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    name = "Consort of Dorne (Father of Doran Martell)", sex = "M",
    personID = 258, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Princess_of_Dorne_(mother_of_Doran)#Family",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    personID = 259,
    name = "Lewyn Martell",
    sex = "M",
    momID = 505,
    dadID = 504,
    url = "https://awoiaf.westeros.org/index.php/Lewyn_Martell",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    name = "Lord Penrose", sex = "M",
    personID = 331, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lord_Penrose",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    name = "Cortnay Penrose", sex = "M",
    personID = 332, momID = NA, dadID = 331,
    url = "https://awoiaf.westeros.org/index.php/Cortnay_Penrose",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    personID = 333,
    name = "Alyn Velaryon",
    sex = "M",
    momID = 520,
    dadID = 522, # officially Laenor Velaryon (but it's probably Corlys Velaryon)
    url = "https://awoiaf.westeros.org/index.php/Alyn_Velaryon",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    name = "Aliandra Martell", sex = "F",
    personID = 336, momID = 620, dadID = 619,
    url = "https://awoiaf.westeros.org/index.php/Aliandra_Martell",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    personID = 340,
    name = "Viserys I Targaryen",
    sex = "M",
    momID = 506,
    dadID = 537,
    url = "https://awoiaf.westeros.org/index.php/Viserys_I_Targaryen",
    overwrite = TRUE
  ) %>%
  addPersonToPed(
    personID = 344,
    name = "Alicent Hightower",
    sex = "F",
    momID = 541,
    dadID = 539,
    url = "https://awoiaf.westeros.org/index.php/Alicent_Hightower",
    overwrite = TRUE
  ) %>%
  # Add new people to the pedigree
  addPersonToPed(
    name = "Larra Rogare", sex = "F",
    personID = 502, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Larra_Rogare"
  ) %>%
  addPersonToPed(
    name = "Rodrik Arryn", sex = "M",
    personID = 503, momID = NA, dadID = 519,
    url = "https://awoiaf.westeros.org/index.php/Rodrik_Arryn"
  ) %>%
  addPersonToPed(
    name = "Father of Princess of Dorne",
    sex = "M", personID = 504, momID = NA, dadID = NA,
    url = NA_character_ # No specific URL available
  ) %>%
  addPersonToPed(
    name = "Mother of Princess of Dorne",
    sex = "F", personID = 505, momID = NA, dadID = NA,
    url = NA_character_ # No specific URL available
  ) %>%
  addPersonToPed(
    name = "Alyssa Targaryen",
    sex = "F", personID = 506, momID = 351, dadID = 350,
    url = "https://awoiaf.westeros.org/index.php/Alyssa_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Davos Baratheon",
    sex = "M", personID = 507, momID = 362, dadID = 361,
    url = "https://awoiaf.westeros.org/index.php/Davos_Baratheon"
  ) %>%
  addPersonToPed(
    name = "Unknown Baratheon",
    sex = "M", personID = 508, momID = 362, dadID = 361,
    url = "https://awoiaf.westeros.org/index.php/Davos_Baratheon#cite_note-4"
  ) %>%
  addPersonToPed(
    name = "Rogar Baratheon",
    sex = "M", personID = 509, momID = 675, dadID = 508,
    url = "https://awoiaf.westeros.org/index.php/Rogar_Baratheon"
  ) %>%
  addPersonToPed(
    name = "Alyssa Velaryon",
    sex = "F", personID = 510, momID = 527, dadID = 526,
    url = "https://awoiaf.westeros.org/index.php/Alyssa_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Boremund Baratheon",
    sex = "M", personID = 511, momID = 510, dadID = 509,
    url = "https://awoiaf.westeros.org/index.php/Boremund_Baratheon"
  ) %>%
  addPersonToPed(
    name = "Jocelyn Baratheon",
    sex = "F", personID = 512, momID = 510, dadID = 509,
    url = "https://awoiaf.westeros.org/index.php/Jocelyn_Baratheon"
  ) %>%
  addPersonToPed(
    name = "Aemon Targaryen (son of Jaehaerys I)",
    sex = "M", personID = 513, momID = 351, dadID = 350,
    url = "https://awoiaf.westeros.org/index.php/Aemon_Targaryen_(son_of_Jaehaerys_I)"
  ) %>%
  addPersonToPed(
    name = "Rhaenys Targaryen (daughter of Aemon)",
    sex = "F", personID = 514, momID = 512, dadID = 513,
    url = "https://awoiaf.westeros.org/index.php/Rhaenys_Targaryen_(daughter_of_Aemon)"
  ) %>%
  addPersonToPed(
    name = "Daella Targaryen (daughter of Jaehaerys I)",
    sex = "F", personID = 515, momID = 351, dadID = 350,
    url = "https://awoiaf.westeros.org/index.php/Daella_Targaryen_(daughter_of_Jaehaerys_I)"
  ) %>%
  addPersonToPed(
    name = "Dyanna Dayne",
    sex = "F", personID = 516, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Dyanna_Dayne"
  ) %>%
  addPersonToPed(
    name = "Betha Blackwood",
    sex = "F", personID = 517, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Betha_Blackwood"
  ) %>%
  addPersonToPed(
    name = "Shaera Targaryen",
    sex = "F", personID = 518, momID = 517, dadID = 200,
    url = "https://awoiaf.westeros.org/index.php/Shaera_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Rymond Arryn",
    sex = "M", personID = 519, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Rymond_Arryn"
  ) %>%
  addPersonToPed(
    name = "Marilda of Hull",
    sex = "F", personID = 520, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Marilda_of_Hull"
  ) %>%
  addPersonToPed(
    name = "Addam Velaryon of Hull",
    sex = "M", personID = 521, momID = 520, dadID = 522,
    url = "https://awoiaf.westeros.org/index.php/Addam_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Laenor Velaryon",
    sex = "M", personID = 522, momID = 514, dadID = 523,
    url = "https://awoiaf.westeros.org/index.php/Laenor_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Corlys Velaryon",
    sex = "M", personID = 523, momID = 534, dadID = 524,
    url = "https://awoiaf.westeros.org/index.php/Corlys_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Corwyn Velaryon",
    sex = "M", personID = 524, momID = NA, dadID = 525,
    url = "https://awoiaf.westeros.org/index.php/Corwyn_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Daemon Velaryon",
    sex = "M", personID = 525, momID = 527, dadID = 526,
    url = "https://awoiaf.westeros.org/index.php/Daemon_Velaryon_(son_of_Aethan)"
  ) %>%
  addPersonToPed(
    name = "Aethan Velaryon",
    sex = "M", personID = 526, momID = 617, dadID = 616,
    url = "https://awoiaf.westeros.org/index.php/Aethan_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Alarra Massey",
    sex = "F", personID = 527, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Alarra_Massey"
  ) %>%
  addPersonToPed(
    name = "Ossifer Plumm",
    sex = "M", personID = 528, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Ossifer_Plumm"
  ) %>%
  addPersonToPed(
    name = "Daeron Velaryon",
    sex = "M", personID = 529, momID = 531, dadID = 532,
    url = "https://awoiaf.westeros.org/index.php/Daeron_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Daemion Velaryon",
    sex = "M", personID = 530, momID = 531, dadID = 532,
    url = "https://awoiaf.westeros.org/index.php/Daemion_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Wife of Vaemond Velaryon",
    sex = "F", personID = 531, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Vaemond_Velaryon#Family"
  ) %>%
  addPersonToPed(
    name = "Vaemond Velaryon",
    sex = "M", personID = 532, momID = NA, dadID = 533,
    url = "https://awoiaf.westeros.org/index.php/Vaemond_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Second-born son of Corwyn Velaryon",
    sex = "M", personID = 533, momID = 534, dadID = 524,
    url = "https://awoiaf.westeros.org/index.php/Corwyn_Velaryon#Family"
  ) %>%
  addPersonToPed(
    name = "Unknown wife of Corwyn Velaryon",
    sex = "F", personID = 534, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Corwyn_Velaryon#Family"
  ) %>%
  addPersonToPed(
    name = "Hazel Harte",
    sex = "F", personID = 535, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Hazel_Harte"
  ) %>%
  addPersonToPed(
    name = "Daemon Targaryen",
    sex = "M", personID = 536, momID = 506, dadID = 537,
    url = "https://awoiaf.westeros.org/index.php/Daemon_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Baelon Targaryen (son of Jaehaerys I)",
    sex = "M", personID = 537, momID = 351, dadID = 350,
    url = "https://awoiaf.westeros.org/index.php/Baelon_Targaryen_(son_of_Jaehaerys_I)"
  ) %>%
  addPersonToPed(
    name = "Wife of Jasper Arryn",
    sex = "F", personID = 538, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Jasper_Arryn#Family"
  ) %>%
  addPersonToPed(
    name = "Otto Hightower",
    sex = "M", personID = 539, momID = 543, dadID = 542,
    url = "https://awoiaf.westeros.org/index.php/Otto_Hightower"
  ) %>%
  addPersonToPed(
    name = "Gwayne Hightower",
    sex = "M", personID = 540, momID = 541, dadID = 539,
    url = "https://awoiaf.westeros.org/index.php/Gwayne_Hightower"
  ) %>%
  addPersonToPed(
    name = "Wife of Otto Hightower",
    sex = "F", personID = 541, momID = NA, dadID = NA
  ) %>%
  addPersonToPed(
    name = "Father of Otto Hightower",
    sex = "M", personID = 542, momID = NA, dadID = NA
  ) %>%
  addPersonToPed(
    name = "Mother of Otto Hightower",
    sex = "F", personID = 543, momID = NA, dadID = NA
  ) %>%
  addPersonToPed(
    name = "Lord Hightower",
    sex = "M", personID = 544, momID = 543, dadID = 542,
    url = "https://awoiaf.westeros.org/index.php/Lord_Hightower"
  ) %>%
  addPersonToPed(
    name = "Laena Velaryon",
    sex = "F", personID = 545, momID = 514, dadID = 523,
    url = "https://awoiaf.westeros.org/index.php/Laena_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Baela	Targaryen",
    sex = "F", personID = 546, momID = 545, dadID = 536,
    twinID = 547, zygosity = "mz",
    url = "https://awoiaf.westeros.org/index.php/Baela_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Rhaena Targaryen",
    sex = "F", personID = 547, momID = 545, dadID = 536,
    twinID = 546, zygosity = "mz",
    url = "https://awoiaf.westeros.org/index.php/Rhaena_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Visenya Targaryen (daughter of Rhaenyra)",
    sex = "F", personID = 548, momID = 339, dadID = 536,
    url = "https://awoiaf.westeros.org/index.php/Visenya_Targaryen_(daughter_of_Rhaenyra)"
  ) %>%
  addPersonToPed(
    name = "Harwin Strong",
    sex = "M", personID = 549, momID = NA, dadID = 553,
    url = "https://awoiaf.westeros.org/index.php/Harwin_Strong"
  ) %>%
  addPersonToPed(
    name = "Jacaerys Velaryon",
    sex = "M", personID = 550, momID = 339, dadID = 549,
    url = "https://awoiaf.westeros.org/index.php/Jacaerys_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Lucerys Velaryon",
    sex = "M", personID = 551, momID = 339, dadID = 549,
    url = "https://awoiaf.westeros.org/index.php/Lucerys_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Joffrey Velaryon",
    sex = "M", personID = 552, momID = 339, dadID = 549,
    url = "https://awoiaf.westeros.org/index.php/Joffrey_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Lyonel Strong",
    sex = "M", personID = 553, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lyonel_Strong"
  ) %>%
  addPersonToPed(
    name = "Alys Rivers",
    sex = "F", personID = 554, momID = NA, dadID = 553,
    url = "https://awoiaf.westeros.org/index.php/Alys_Rivers"
  ) %>%
  addPersonToPed(
    name = "Son of Alys Rivers",
    sex = "M", personID = 555, momID = 554, dadID = 346,
    url = "https://awoiaf.westeros.org/index.php/Alys_Rivers#Family"
  ) %>%
  addPersonToPed(
    name = "Jaehaera Targaryen",
    sex = "F", personID = 556, momID = 348, dadID = 345,
    twinID = 557, zygosity = "dz",
    url = "https://awoiaf.westeros.org/index.php/Jaehaera_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Jaehaerys Targaryen (son of Aegon II)",
    sex = "M", personID = 557, momID = 348, dadID = 345,
    twinID = 556, zygosity = "dz",
    url = "https://awoiaf.westeros.org/index.php/Jaehaerys_Targaryen_(son_of_Aegon_II)"
  ) %>%
  addPersonToPed(
    name = "Maelor Targaryen (son of Aegon II)",
    sex = "M", personID = 558, momID = 348, dadID = 345,
    url = "https://awoiaf.westeros.org/index.php/Maelor_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Laena Velaryon (daughter of Baela Targaryen)",
    sex = "F", personID = 559, momID = 546, dadID = 333,
    url = "https://awoiaf.westeros.org/index.php/Laena_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Rohanne of Tyrosh",
    sex = "F", personID = 560, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Rohanne_of_Tyrosh"
  ) %>%
  addPersonToPed(
    name = "Daemon III Blackfyre",
    sex = "M", personID = 561, momID = NA, dadID = 316,
    url = "https://awoiaf.westeros.org/index.php/Daemon_III_Blackfyre"
  ) %>%
  addPersonToPed(
    name = "Calla Blackfyre",
    sex = "F", personID = 562, momID = 560, dadID = 312,
    url = "https://awoiaf.westeros.org/index.php/Calla_Blackfyre"
  ) %>%
  addPersonToPed(
    name = "Barba Bracken",
    sex = "F", personID = 563, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Barba_Bracken"
  ) %>%
  addPersonToPed(
    name = "Lord Frey",
    sex = "M", personID = 564, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lord_Frey"
  ) %>%
  addPersonToPed(
    name = "Lady Butterwell Frey",
    sex = "F", personID = 565, momID = 566, dadID = 564,
    url = "https://awoiaf.westeros.org/index.php/Lady_Butterwell"
  ) %>%
  addPersonToPed(
    name = "Lady Frey",
    sex = "F", personID = 566, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lord_Frey#Family"
  ) %>%
  addPersonToPed(
    name = "Mother of Maron Martell", sex = "F",
    personID = 567, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Prince_of_Dorne_(father_of_Maron)#Family"
  ) %>%
  addPersonToPed(
    name = "Prince of Dorne (father of Maron)", sex = "M",
    personID = 568, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Prince_of_Dorne_(father_of_Maron)"
  ) %>%
  addPersonToPed(
    name = "Maron Martell", sex = "M",
    personID = 569, momID = 567, dadID = 568,
    url = "https://awoiaf.westeros.org/index.php/Maron_Martell"
  ) %>%
  addPersonToPed(
    name = "Mother of Hoster Tully", sex = "F",
    personID = 570, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Hoster_Tully#Family"
  ) %>%
  addPersonToPed(
    name = "Marna Locke", sex = "F",
    personID = 571, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Marna_Locke"
  ) %>%
  addPersonToPed(
    name = "Arya Flint", sex = "F",
    personID = 572, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Arya_Flint"
  ) %>%
  addPersonToPed(
    name = "Rodrik Stark", sex = "M",
    personID = 573, momID = 576, dadID = 575,
    url = "https://awoiaf.westeros.org/index.php/Rodrik_Stark"
  ) %>%
  addPersonToPed(
    name = "Lyanne Glover", sex = "F",
    personID = 574, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lyanne_Glover"
  ) %>%
  addPersonToPed(
    name = "Beron Stark", sex = "M",
    personID = 575, momID = 608, dadID = 607,
    url = "https://awoiaf.westeros.org/index.php/Beron_Stark"
  ) %>%
  addPersonToPed(
    name = "Lorra Royce", sex = "F",
    personID = 576, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lorra_Royce"
  ) %>%
  addPersonToPed(
    name = "Donnor Stark", sex = "M",
    personID = 577, momID = 576, dadID = 575,
    url = "https://awoiaf.westeros.org/index.php/Donnor_Stark"
  ) %>%
  addPersonToPed(
    name = "Artos Stark", sex = "M",
    personID = 578, momID = 576, dadID = 575,
    url = "https://awoiaf.westeros.org/index.php/Artos_Stark"
  ) %>%
  addPersonToPed(
    name = "Berena Stark", sex = "F",
    personID = 579, momID = 576, dadID = 575,
    url = "https://awoiaf.westeros.org/index.php/Berena_Stark"
  ) %>%
  addPersonToPed(
    name = "Alysanne Stark", sex = "F",
    personID = 580, momID = 576, dadID = 575,
    url = "https://awoiaf.westeros.org/index.php/Alysanne_Stark"
  ) %>%
  addPersonToPed(
    name = "Errold Stark", sex = "M",
    personID = 581, momID = 576, dadID = 575,
    url = "https://awoiaf.westeros.org/index.php/Errold_Stark"
  ) %>%
  addPersonToPed(
    name = "Branda Stark", sex = "F",
    personID = 582, momID = 572, dadID = 573,
    url = "https://awoiaf.westeros.org/index.php/Branda_Stark"
  ) %>%
  addPersonToPed(
    name = "Wife of Andros Brax", sex = "F",
    personID = 583, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Andros_Brax#Family"
  ) %>%
  addPersonToPed(
    name = "Jeyne Marbrand", sex = "F",
    personID = 584, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Jeyne_Marbrand"
  ) %>%
  addPersonToPed(
    name = "Rohanne Webber", sex = "F",
    personID = 585, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Rohanne_Webber"
  ) %>%
  addPersonToPed(
    name = "Marla Prester", sex = "F",
    personID = 586, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Marla_Prester"
  ) %>%
  addPersonToPed(
    name = "Alys Stackspear", sex = "F",
    personID = 587, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Alys_Stackspear"
  ) %>%
  addPersonToPed(
    name = "Damon Lannister", sex = "M",
    personID = 588, momID = 587, dadID = 182,
    url = "https://awoiaf.westeros.org/index.php/Damon_Lannister"
  ) %>%
  addPersonToPed(
    name = "Jena Dondarrion", sex = "F",
    personID = 589, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Jena_Dondarrion"
  ) %>%
  addPersonToPed(
    name = "Wife of Aerys", sex = "F",
    personID = 590, momID = NA, dadID = NA
  ) %>%
  addPersonToPed(
    name = "Melissa Blackwood", sex = "F",
    personID = 591, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Melissa_Blackwood"
  ) %>%
  addPersonToPed(
    name = "Gwenys Rivers", sex = "F",
    personID = 592, momID = 591, dadID = 302,
    url = "https://awoiaf.westeros.org/index.php/Gwenys_Rivers"
  ) %>%
  addPersonToPed(
    name = "Mya Rivers", sex = "F",
    personID = 593, momID = 591, dadID = 302,
    url = "https://awoiaf.westeros.org/index.php/Mya_Rivers"
  ) %>%
  addPersonToPed(
    name = "Stillborn Twin Targaryen", sex = "M",
    personID = 594, momID = 303, dadID = 302,
    twinID = 304, zygosity = "dz",
    url = "https://awoiaf.westeros.org/index.php/Naerys_Targaryen#Family"
  ) %>%
  addPersonToPed(
    name = "Benjicot Blackwood", sex = "M",
    personID = 595, momID = NA, dadID = 639,
    url = "https://awoiaf.westeros.org/index.php/Benjicot_Blackwood"
  ) %>%
  addPersonToPed(
    name = "Rhaena Targaryen (daughter of Aenys I)", sex = "F",
    personID = 596, momID = 510, dadID = 352,
    url = "https://awoiaf.westeros.org/index.php/Rhaena_Targaryen_(daughter_of_Aenys_I)"
  ) %>%
  addPersonToPed(
    name = "Aegon Targaryen (son of Aenys I)", sex = "M",
    personID = 597, momID = 510, dadID = 352,
    url = "https://awoiaf.westeros.org/index.php/Aegon_Targaryen_(son_of_Aenys_I)"
  ) %>%
  addPersonToPed(
    name = "Viserys Targaryen (son of Aenys I)", sex = "M",
    personID = 598, momID = 510, dadID = 352,
    url = "https://awoiaf.westeros.org/index.php/Viserys_Targaryen_(son_of_Aenys_I)"
  ) %>%
  addPersonToPed(
    name = "Vaella Targaryen", sex = "F",
    personID = 599, momID = 510, dadID = 352,
    url = "https://awoiaf.westeros.org/index.php/Vaella_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Kiera of Tyrosh", sex = "F",
    personID = 600, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Kiera_of_Tyrosh"
  ) %>%
  addPersonToPed(
    name = "Aerea Targaryen", sex = "F",
    personID = 601, momID = 596, dadID = 597,
    twinID = 602, zygosity = "mz",
    url = "https://awoiaf.westeros.org/index.php/Aerea_Targaryen"
  ) %>%
  addPersonToPed(
    name = "Rhaella Targaryen (daughter of Aegon)", sex = "F",
    personID = 602, momID = 596, dadID = 597,
    twinID = 601, zygosity = "mz",
    url = "https://awoiaf.westeros.org/index.php/Rhaella_Targaryen_(daughter_of_Aegon)"
  ) %>%
  addPersonToPed(
    name = "Erryk Cargyll", sex = "M",
    personID = 603, momID = 605, dadID = 606,
    twinID = 604, zygosity = "mz",
    url = "https://awoiaf.westeros.org/index.php/Erryk_Cargyll"
  ) %>%
  addPersonToPed(
    name = "Arryk Cargyll", sex = "M",
    personID = 604, momID = 605, dadID = 606,
    twinID = 603, zygosity = "mz",
    url = "https://awoiaf.westeros.org/index.php/Arryk_Cargyll"
  ) %>%
  addPersonToPed(
    name = "Mother Cargyll", sex = "F",
    personID = 605, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/House_Cargyll"
  ) %>%
  addPersonToPed(
    name = "Father Cargyll", sex = "M",
    personID = 606, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/House_Cargyll"
  ) %>%
  addPersonToPed(
    name = "Brandon Stark (son of Cregan)", sex = "M",
    personID = 607, momID = 609, dadID = 610,
    url = "https://awoiaf.westeros.org/index.php/Brandon_Stark_(son_of_Cregan)"
  ) %>%
  addPersonToPed(
    name = "Alys Karstark (wife of Brandon)", sex = "F",
    personID = 608, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Alys_Karstark_(wife_of_Brandon)"
  ) %>%
  addPersonToPed(
    name = "Lynara Stark", sex = "F",
    personID = 609, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lynara_Stark"
  ) %>%
  addPersonToPed(
    name = "Cregan Stark", sex = "M",
    personID = 610, momID = 612, dadID = 611,
    url = "https://awoiaf.westeros.org/index.php/Cregan_Stark"
  ) %>%
  addPersonToPed(
    name = "Rickon Stark (son of Benjen)", sex = "M",
    personID = 611, momID = 648, dadID = 647,
    url = "https://awoiaf.westeros.org/index.php/Rickon_Stark_(son_of_Benjen)"
  ) %>%
  addPersonToPed(
    name = "Gilliane Glover", sex = "F",
    personID = 612, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Gilliane_Glover"
  ) %>%
  addPersonToPed(
    name = "Raymar Royce", sex = "M",
    personID = 613, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Raymar_Royce"
  ) %>%
  addPersonToPed(
    name = "Mother of Luthor Tyrell", sex = "F",
    personID = 614, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Luthor_Tyrell_(son_of_Moryn)"
  ) %>%
  addPersonToPed(
    name = "Mother of Jeor Mormont", sex = "F",
    personID = 615, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/House_Mormont#House_Mormont_at_the_end_of_the_third_century"
  ) %>%
  addPersonToPed(
    name = "Daemon Velaryon", sex = "M",
    personID = 616, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Daemon_Velaryon"
  ) %>%
  addPersonToPed(
    name = "Wife of Daemon Velaryon", sex = "F",
    personID = 617, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Daemon_Velaryon#Family"
  ) %>%
  addPersonToPed(
    name = "Corlys Velaryon (son of Daemon)", sex = "M",
    personID = 618, momID = 617, dadID = 616,
    url = "https://awoiaf.westeros.org/index.php/Corlys_Velaryon_(son_of_Daemon)"
  ) %>%
  addPersonToPed(
    name = "Qoren Nymeros Martell", sex = "M",
    personID = 619, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Qoren_Martell"
  ) %>%
  addPersonToPed(
    name = "Wife of Qoren Nymeros Martell", sex = "F",
    personID = 620, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Qoren_Martell#Family"
  ) %>%
  addPersonToPed(
    name = "Coryanne Martell", sex = "F",
    personID = 621, momID = 620, dadID = 619,
    url = "https://awoiaf.westeros.org/index.php/Coryanne_Martell"
  ) %>%
  addPersonToPed(
    name = "Qyle Martell", sex = "M",
    personID = 622, momID = 620, dadID = 619,
    url = "https://awoiaf.westeros.org/index.php/Qyle_Martell"
  ) %>%
  addPersonToPed(
    name = "Father of Lysandro Rogare", sex = "M",
    personID = 623, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lysandro_Rogare#Family"
  ) %>%
  addPersonToPed(
    name = "Mother of Lysandro Rogare", sex = "F",
    personID = 624, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lysandro_Rogare#Family"
  ) %>%
  addPersonToPed(
    name = "Lysandro Rogare", sex = "M",
    personID = 625, momID = 624, dadID = 623,
    url = "https://awoiaf.westeros.org/index.php/Lysandro_Rogare"
  ) %>%
  addPersonToPed(
    name = "Drazenko Rogare", sex = "M",
    personID = 626, momID = 624, dadID = 623,
    url = "https://awoiaf.westeros.org/index.php/Drazenko_Rogare"
  ) %>%
  addPersonToPed(
    name = "Wife of Lysandro Rogare", sex = "F",
    personID = 627, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lysandro_Rogare#Family"
  ) %>%
  addPersonToPed(
    name = "Lysaro Rogare", sex = "M",
    personID = 628, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Lysaro_Rogare"
  ) %>%
  addPersonToPed(
    name = "Fredo Rogare", sex = "M",
    personID = 629, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Fredo_Rogare"
  ) %>%
  addPersonToPed(
    name = "Drako Rogare", sex = "M",
    personID = 630, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Drako_Rogare"
  ) %>%
  addPersonToPed(
    name = "Moredo Rogare", sex = "M",
    personID = 631, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Moredo_Rogare"
  ) %>%
  addPersonToPed(
    name = "Lotho Rogare", sex = "M",
    personID = 632, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Lotho_Rogare"
  ) %>%
  addPersonToPed(
    name = "Roggerio Rogare", sex = "M",
    personID = 633, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Roggerio_Rogare"
  ) %>%
  addPersonToPed(
    name = "Marra Rogare", sex = "F",
    personID = 634, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Marra_Rogare"
  ) %>%
  addPersonToPed(
    name = "Lysara Rogare", sex = "F",
    personID = 635, momID = 627, dadID = 625,
    url = "https://awoiaf.westeros.org/index.php/Lysara_Rogare"
  ) %>%
  addPersonToPed(
    name = "Husband of Anya Waynwood", sex = "M",
    personID = 636, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Anya_Waynwood"
  ) %>%
  addPersonToPed(
    name = "Stillborn daughter of Jon Arryn", sex = "F",
    personID = 637, momID = 228, dadID = 226,
    url = "https://awoiaf.westeros.org/index.php/Jeyne_Royce"
  ) %>%
  addPersonToPed(
    name = "Unborn Tully", sex = "U",
    personID = 638, momID = 131, dadID = 225,
    url = "https://awoiaf.westeros.org/index.php/Roslin_Frey"
  ) %>%
  addPersonToPed(
    name = "Samwell Blackwood", sex = "M",
    personID = 639, momID = 641, dadID = 640,
    url = "https://awoiaf.westeros.org/index.php/Samwell_Blackwood"
  ) %>%
  addPersonToPed(
    name = "Lord Blackwood", sex = "M",
    personID = 640, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Samwell_Blackwood#Family"
  ) %>%
  addPersonToPed(
    name = "Lady Blackwood", sex = "F",
    personID = 641, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Samwell_Blackwood#Family"
  ) %>%
  addPersonToPed(
    name = "Alysanne Blackwood", sex = "F",
    personID = 642, momID = 641, dadID = 640,
    url = "https://awoiaf.westeros.org/index.php/Alysanne_Blackwood"
  ) %>%
  addPersonToPed(
    name = "Sarra Stark", sex = "F",
    personID = 643, momID = 642, dadID = 610,
    url = "https://awoiaf.westeros.org/index.php/Sarra_Stark"
  ) %>%
  addPersonToPed(
    name = "Mariah Stark", sex = "F",
    personID = 644, momID = 642, dadID = 610,
    url = "https://awoiaf.westeros.org/index.php/Mariah_Stark"
  ) %>%
  addPersonToPed(
    name = "Raya Stark", sex = "F",
    personID = 645, momID = 642, dadID = 610,
    url = "https://awoiaf.westeros.org/index.php/Raya_Stark"
  ) %>%
  addPersonToPed(
    name = "Alys Stark", sex = "F",
    personID = 646, momID = 642, dadID = 610,
    url = "https://awoiaf.westeros.org/index.php/Alys_Stark"
  ) %>%
  addPersonToPed(
    name = "Benjen Stark (lord)", sex = "M",
    personID = 647, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Benjen_Stark_(lord)"
  ) %>%
  addPersonToPed(
    name = "Lysa Locke", sex = "F",
    personID = 648, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Lysa_Locke"
  ) %>%
  addPersonToPed(
    name = "Bennard Stark", sex = "M",
    personID = 649, momID = 648, dadID = 647,
    url = "https://awoiaf.westeros.org/index.php/Bennard_Stark"
  ) %>%
  addPersonToPed(
    name = "Margaret Karstark", sex = "F",
    personID = 650, momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Margaret_Karstark"
  ) %>%
  addPersonToPed(
    name = "Benjen Stark (son of Bennard)", sex = "M",
    personID = 651, momID = 650, dadID = 649,
    url = "https://awoiaf.westeros.org/index.php/Benjen_Stark_(son_of_Bennard)"
  ) %>%
  addPersonToPed(
    name = "Brandon Stark (son of Bennard)", sex = "M",
    personID = 652, momID = 650, dadID = 649,
    url = "https://awoiaf.westeros.org/index.php/Brandon_Stark_(son_of_Bennard)"
  ) %>%
  addPersonToPed(
    name = "Elric Stark", sex = "M",
    personID = 653, momID = 650, dadID = 649,
    url = "https://awoiaf.westeros.org/index.php/Elric_Stark"
  ) %>%
  addPersonToPed(
    name = "Selwyn Tarth", sex = "M", personID = 654,
    momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Selwyn_Tarth"
  ) %>%
  addPersonToPed(
    name = "Unknown wife of Selwyn Tarth", sex = "F", personID = 655,
    momID = NA, dadID = NA,
    url = "https://awoiaf.westeros.org/index.php/Selwyn_Tarth#Family"
  ) %>%
  addPersonToPed(
    name = "Galladon Tarth", sex = "M", personID = 656,
    dadID = 654, momID = 655,
    url = "https://awoiaf.westeros.org/index.php/Galladon_Tarth"
  ) %>%
  addPersonToPed(
    name = "Arianne Tarth", sex = "F", personID = 657,
    dadID = 654, momID = 655,
    url = "https://awoiaf.westeros.org/index.php/Arianne_Tarth"
  ) %>%
  addPersonToPed(
    name = "Alysanne Tarth", sex = "F", personID = 658,
    dadID = 654, momID = 655,
    url = "https://awoiaf.westeros.org/index.php/Alysanne_Tarth"
  ) %>%
  addPersonToPed(
    name = "Brienne of Tarth", sex = "F", personID = 659,
    dadID = 654, momID = 655,
    url = "https://awoiaf.westeros.org/index.php/Brienne_of_Tarth"
  ) %>%
  addPersonToPed(
    name = "Jonos Bracken", sex = "M", personID = 660,
    url = "https://awoiaf.westeros.org/index.php/Jonos_Bracken",
    momID = 674, dadID = 673,
  ) %>%
  addPersonToPed(
    name = "Unknown first wife of Jonos Bracken", sex = "F", personID = 661
  ) %>%
  addPersonToPed(
    name = "Barbara Bracken", sex = "F", personID = 662,
    dadID = 660, momID = 661,
    url = "https://awoiaf.westeros.org/index.php/Barbara_Bracken"
  ) %>%
  addPersonToPed(
    name = "Jayne Bracken", sex = "F", personID = 663,
    dadID = 660, momID = 661,
    url = "https://awoiaf.westeros.org/index.php/Jayne_Bracken"
  ) %>%
  addPersonToPed(
    name = "Unknown second wife of Jonos Bracken", sex = "F", personID = 664,
    url = "https://awoiaf.westeros.org/index.php/Jonos_Bracken#Family"
  ) %>%
  addPersonToPed(
    name = "Lady Bracken (third wife of Jonos)", sex = "F", personID = 665,
    url = "https://awoiaf.westeros.org/index.php/Lady_Bracken"
  ) %>%
  addPersonToPed(
    name = "Catelyn Bracken", sex = "F", personID = 666,
    dadID = 660, momID = 665,
    url = "https://awoiaf.westeros.org/index.php/Catelyn_Bracken"
  ) %>%
  addPersonToPed(
    name = "Bess Bracken", sex = "F", personID = 667,
    dadID = 660, momID = 665,
    url = "https://awoiaf.westeros.org/index.php/Bess_Bracken"
  ) %>%
  addPersonToPed(
    name = "Alysanne Bracken", sex = "F", personID = 668,
    dadID = 660, momID = 665,
    url = "https://awoiaf.westeros.org/index.php/Alysanne_Bracken"
  ) %>%
  addPersonToPed(
    name = "Hendry Bracken", sex = "M", personID = 669,
    dadID = 670, momID = NA,
    url = "https://awoiaf.westeros.org/index.php/Hendry_Bracken"
  ) %>%
  addPersonToPed(
    name = "Unknown sibling of Jonos Bracken", sex = "M", personID = 670,
    momID = 674, dadID = 673,
    url = "https://awoiaf.westeros.org/index.php/Jonos_Bracken#Family"
  ) %>%
  addPersonToPed(
    name = "mother of Harry Rivers", sex = "F", personID = 671,
    url = "https://awoiaf.westeros.org/index.php/Harry_Rivers"
  ) %>%
  addPersonToPed(
    name = "Harry Rivers", sex = "M", personID = 672,
    dadID = 660, momID = 671,
    url = "https://awoiaf.westeros.org/index.php/Harry_Rivers"
  ) %>%
  addPersonToPed(
    name = "Father of Jonas Bracken", sex = "M", personID = 673,
    url = "https://awoiaf.westeros.org/index.php/Jonos_Bracken#Family"
  ) %>%
  addPersonToPed(
    name = "Mother of Jonas Bracken", sex = "F", personID = 674,
    url = "https://awoiaf.westeros.org/index.php/Jonos_Bracken#Family"
  ) %>%
  addPersonToPed(
    name = "Mother of Rogar Baratheon", sex = "F", personID = 675,
    url = "https://awoiaf.westeros.org/index.php/Rogar_Baratheon#Family"
  ) %>%
  addPersonToPed(
    name = "Garon Baratheon",
    sex = "M", personID = 676, momID = 675, dadID = 508,
    url = "https://awoiaf.westeros.org/index.php/Garon_Baratheon"
  ) %>%
  addPersonToPed(
    name = "Orryn Baratheon",
    sex = "M", personID = 677, momID = 675, dadID = 508,
    url = "https://awoiaf.westeros.org/index.php/Orryn_Baratheon"
  ) %>%
  addPersonToPed(
    name = "Ronnal Baratheon",
    sex = "M", personID = 678, momID = 675, dadID = 508,
    url = "https://awoiaf.westeros.org/index.php/Ronnal_Baratheon"
  ) %>%
  addPersonToPed(
    name = "Lord Darry (father of Raymun)",
    sex = "M", personID = 679,
    url = "https://awoiaf.westeros.org/index.php/Lord_Darry_(father_of_Raymun)"
  )





# modify existing people
df <- df %>%
  mutate(
    sex = case_when(
      personID == 326 ~ "M",
      personID == 327 ~ "M",
      personID == 328 ~ "F",
      personID == 329 ~ "F",
      personID == 330 ~ "F",
      personID == 274 ~ "M",
      personID == 236 ~ "M",
      TRUE ~ sex
    ),
    momID = case_when(
      personID %in% c(422, 376, 408, 410, 412, 415, 416, 417, 419, 421) ~ NA, # has one of 4 potential mothers
      personID %in% c(488, 430) ~ 615,
      personID %in% c(385, 384, 383, 380) ~ 614,
      personID %in% c(300:301) ~ 600,
      personID %in% c(281) ~ 517,
      personID %in% c(310) ~ 591,
      personID %in% c(364, 366, 367) ~ 590,
      personID %in% c(298:299) ~ 589, # Jena Dondarrion
      personID %in% c(163, 183) ~ 586,
      personID %in% c(158, 180, 181, 182) ~ 585, # Rohanne Webber
      personID %in% c(28, 159:162) ~ 584, # Jeyne Marbrand is mother of Tywin Lannisteretc
      personID %in% c(154, 155, 121) ~ 583, # all the braxes share the same mother
      personID == 465 ~ 576, # Lorra Royce
      personID == 466 ~ 574, # Lyanne Glover is the mother of Brandon Stark
      personID == 468 ~ 572, # Arya Flint's is the Mother of Lyarra Stark
      personID %in% c(222, 256) ~ 570,
      personID == 212 ~ 571, # Marna Locke is the mother of Rickard Stark
      personID == 291 ~ 567, # Myriah Martell's mother is the Mother of Maron Martell
      personID == 309 ~ 563, # Barba Bracken is the mother of Aegor Rivers
      personID %in% c(313:319) ~ 560, # Blackfyres
      personID == 354 ~ 359, # Rhaenys Targaryen
      personID == 355 ~ 359, # Visenya Targaryen,
      personID == 303 ~ 502, # Naerys Targaryen's mother is Larra Rogare
      personID == 302 ~ 502, # Aegon IV Targaryen's mother is Larra Rogare
      personID == 307 ~ 502, # Aemon Targaryen, the Dragonknight, mother is Larra Rogare
      personID == 200 ~ 516, # Aegon V Targaryen's mother is Dyanna Dayne
      personID == 341 ~ 515, # Aemma Arryn's mother is Daella Targaryen (daughter of Jaehaerys I)
      personID == 289 ~ 516, # Daella Targaryen (daughter of Maekar I) has Dyanna Dayne
      personID == 257 ~ 505, # Princess of Dorne's mother is the Mother of Princess of Dorne
      personID == 280 ~ 517, # Betha Blackwood is mother of Duncan the Small
      personID == 201 ~ 517, # Betha Blackwood  is mother of Jaehaerys II Targaryen
      personID == 199 ~ 517, # Betha Blackwood is mother of Rhaelle Targaryen
      personID == 203 ~ 518, # Rhaella Targaryen's mother is Shaera Targaryen
      personID == 202 ~ 518, # 	Aerys II's mother is Shaera Targaryen
      personID == 322 ~ 535, # Daenaera Velaryon's mother is Hazel Harte
      personID == 306 ~ 339, #  Viserys II's mother is Rhaenyra Targaryen
      personID %in% c(351, 350) ~ 510, # Alysanne Targaryen's mom is Alyssa Velaryon
      personID %in% c(
        283, # # Daeron Targaryen (son of Maekar I)
        287, #  Aemon Targaryen (son of Maekar I)
        285, # Aerion (son of Maekar) Targaryen
        288 #  Rhae Targaryen
      ) ~ 516, # 	Dyanna Dayne is mother of
      personID %in% c(226, 232, 231) ~ 538, # kids of  Jasper
      personID == 1 ~ 566, # Walder Frey's mother
      personID == 284 ~ 600,
      personID == 294 ~ NA,

      TRUE ~ momID
    ),
    dadID = case_when(
      personID %in% c(252:254) ~ 636,
      personID == 422 ~ 406,
      personID == 294 ~ NA,
      personID == 470 ~ 613, # Raymar Royce
      personID %in% c(273, 275) ~ 274,
      personID %in% c(207, 260:263) ~ 258,
      personID == 465 ~ 575, # Beron Stark
      personID == 291 ~ 568, # Myriah Martell's mother is the Father of Maron Martell
      personID == 354 ~ 358, # Rhaenys Targaryen
      personID == 355 ~ 358, # Visenya Targaryen
      personID == 341 ~ 503, # Aemma Arryn's  father is Rodrik Arryn
      personID == 257 ~ 504, # Princess of Dorne's father is the Father of Princess of Dorne
      personID == 326 ~ 528, #  Viserys Plumm
      personID == 322 ~ 529, #  Daenaera Velaryon's father is Daeron Velaryon
      personID == 306 ~ 536, #  Viserys II's father is Daemon Targaryen
      personID == 321 ~ 536, # Aegon III's father is Daemon Targaryen
      personID == 1 ~ 564, # Walder Frey's father is Lord Frey
      personID == 468 ~ 573, # Rodrik	Stark's is the Father of Lyarra Stark
      personID == 33 ~ 679, # Jeyne  Darry's father is Lord Darry
      TRUE ~ dadID
    ),
    twinID = case_when(
      personID == 304 ~ 594,
      TRUE ~ twinID
    )
  )



ASOIAF <- df %>%
  select(-famID) %>%
  ped2fam(personID = "personID", famID = "famID") %>%
  rename(
    id = personID
  ) %>%
  # http://reddit.com/r/asoiaf/comments/n735xj/spoilers_extended_grrm_describing_twins/
  mutate(
    zygosity = case_when(
      id %in% c(337, 338, 304) ~ "dz",
      id %in% c(390, 391, 99, 98) ~ "mz",
      !is.na(zygosity) ~ zygosity,
      !is.na(twinID) ~ "unknown",
      TRUE ~ NA_character_
    )
  )


# checks

df_repaired <- checkSex(ASOIAF,
  code_male = 1,
  code_female = 0,
  verbose = TRUE, repair = TRUE
) %>%
  checkParentIDs(
    addphantoms = TRUE,
    repair = TRUE,
    parentswithoutrow = FALSE,
    repairsex = FALSE
  )


checkIDs(df_repaired)

checkis_acyclic <- checkPedigreeNetwork(df_repaired,
  personID = "ID",
  momID = "momID",
  dadID = "dadID",
  verbose = TRUE
)
checkis_acyclic
if (checkis_acyclic$is_acyclic) {
  message("The pedigree is acyclic.")
  write_csv(ASOIAF, here("data-raw", "ASOIAF.csv"))
  usethis::use_data(ASOIAF, overwrite = TRUE, compress = "xz")
} else {
  message("The pedigree contains cyclic relationships.")
}

ASOIAF %>%
  filter(is.na(momID) & is.na(dadID)) %>%
  select(id, name, famID, momID, dadID, sex) %>%
  mutate(
    first_name = str_extract(name, "^[^ ]+"),
    last_name = str_extract(name, "[^ ]+$"),
  ) %>%
  arrange(last_name, id)
