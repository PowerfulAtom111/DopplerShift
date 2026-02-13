
/// List if all language typepaths learnable, i.e. those with keys, sorted by default_priority.
/// Used by the language menu to determine display priority.
GLOBAL_LIST_INIT(all_languages_by_priority, init_all_languages_by_priority())

/proc/init_all_languages_by_priority()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue
		lang_list += lang_type
	sortTim(lang_list, cmp = GLOBAL_PROC_REF(cmp_language_priority_dsc))
	return lang_list

/// Sorts languages based on their default_priority, in descending order.
/proc/cmp_language_priority_dsc(datum/language/lang_a, datum/language/lang_b)
	return lang_b.default_priority - lang_a.default_priority


/// Randomizes Crusoe's Locals' Pidgins.
/// We can't run this when making the language, as other language prototypes haven't finished.
/// But our global var handling is before base TG's, so we can't override it easily either.
/// Thus, we non-modularly run this proc in base TG's language prototype init.
/proc/randomize_crusoes_local(list/language_prototypes)
	var/datum/language/the_localspeak = language_prototypes[/datum/language/crusoeslocal]
	the_localspeak.syllables = list()
	var/total_mutual_understanding = counterlist_sum(the_localspeak.mutual_understanding)
	log_admin("randomize_crusoes_local - [total_mutual_understanding]")

	for(var/datum/language/mutual_lang_type as anything in the_localspeak.mutual_understanding)
		log_admin("[mutual_lang_type]")
		var/list/syllables_to_steal = language_prototypes[mutual_lang_type].syllables.Copy()
		var/percent_this_language = round((the_localspeak.mutual_understanding[mutual_lang_type] / total_mutual_understanding) * 100, 1)
		var/amount_to_steal = min(percent_this_language, length(syllables_to_steal))
		log_admin("[mutual_lang_type]: [percent_this_language] - [amount_to_steal] - [the_localspeak.mutual_understanding[mutual_lang_type]] - [(the_localspeak.mutual_understanding[mutual_lang_type] / total_mutual_understanding)]")
		for(var/i = 0, i < amount_to_steal, i++)
			var/stolen_syllable = pick(syllables_to_steal)
			log_admin("[mutual_lang_type]: [i] - [stolen_syllable] - [syllables_to_steal]")
			the_localspeak.syllables.Add(stolen_syllable)
			syllables_to_steal.Remove(stolen_syllable)

	var/datum/language/space_chance_lang_type = pick_weight(the_localspeak.mutual_understanding)
	the_localspeak.space_chance = language_prototypes[space_chance_lang_type].space_chance

	var/datum/language/sentence_chance_lang_type = pick_weight(the_localspeak.mutual_understanding)
	the_localspeak.sentence_chance = language_prototypes[sentence_chance_lang_type].sentence_chance
	the_localspeak.between_word_sentence_chance = language_prototypes[sentence_chance_lang_type].between_word_sentence_chance

	var/datum/language/syllable_chance_lang_type = pick_weight(the_localspeak.mutual_understanding)
	the_localspeak.additional_syllable_low = language_prototypes[syllable_chance_lang_type].additional_syllable_low
	the_localspeak.additional_syllable_high = language_prototypes[syllable_chance_lang_type].additional_syllable_high
