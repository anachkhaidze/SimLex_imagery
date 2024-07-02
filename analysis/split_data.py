import numpy as np
import pandas as pd
from scipy.spatial import distance
glove = {}

with open("D:\kiyonaga\glove.6B.300d.txt", 'r', encoding='utf-8') as f:
    for line in f:
        values = line.split()
        word = values[0]
        vector = np.array(values[1:], dtype='float32')
        glove[word] = vector

data = pd.read_csv('C:\\Users\\HP\\Desktop\\SimLex_imagery\\datasets\\simLex.csv')
lancaster_norms = pd.read_csv('C:\\Users\\HP\\Desktop\\SimLex_imagery\\datasets\\lancaster_norms.csv')

lancaster_norms['Word'] = lancaster_norms['Word'].str.lower()
sensory_columns = ['Word', 'Auditory.mean', 'Gustatory.mean', 'Haptic.mean','Interoceptive.mean', 'Olfactory.mean', 'Visual.mean']
motor_columns = ['Word', 'Foot_leg.mean', 'Hand_arm.mean', 'Head.mean', 'Mouth.mean', 'Torso.mean']
visual_columns = ['Word', 'Visual.mean']
sensory_reduced_columns =  ['Word', 'Auditory.mean', 'Gustatory.mean', 'Haptic.mean', 'Olfactory.mean', 'Visual.mean']

combined = list(set(sensory_columns + motor_columns))

lancaster_motor = lancaster_norms[motor_columns]
lancaster_sensory = lancaster_norms[sensory_columns]
lancaster_norms = lancaster_norms[combined]
lancaster_visual = lancaster_norms[visual_columns]
lancaster_reduced = lancaster_norms[sensory_reduced_columns]

nouns = data[data['POS'] == 'N'].index
adjs = data[data['POS'] == 'A'].index
verbs = data[data['POS'] == 'V'].index

nouns_indices = np.random.choice(nouns, 666, replace=False)
adjs_indices = np.random.choice(adjs, 111, replace=False)
verbs_indices = np.random.choice(verbs, 222, replace=False)

missed_indices = np.concatenate((nouns_indices[-6:], adjs_indices[-1:], verbs_indices[-2:]), axis=0)

nouns_indices = nouns_indices[:-6]
adjs_indices = adjs_indices[:-1]
verbs_indices = verbs_indices[:-2]

nouns_indices = nouns_indices.reshape(11, 60)
adjs_indices = adjs_indices.reshape(11, 10)
verbs_indices = verbs_indices.reshape(11, 20)

samples_sets = []
for i in range(11):
    sample_set = np.concatenate([nouns_indices[i], adjs_indices[i], verbs_indices[i]])
    samples_sets.append(sorted(sample_set))
samples_sets = np.array(samples_sets)

experiment_word_pairs = {}
number_of_duplicate_pairs = 3
number_of_force_checks = 2
    
for i in range(11):
    current_experiment = []
    experiment_indices = np.concatenate((samples_sets[i], missed_indices))
    for index in experiment_indices:
        word1 = data.loc[index, 'word1']
        word2 = data.loc[index, 'word2']
        word1_lanc_motor = np.array(lancaster_motor.loc[lancaster_motor['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_motor = np.array(lancaster_motor.loc[lancaster_motor['Word'] == word2].drop('Word', axis=1).values[0])
        word1_lanc_sensory = np.array(lancaster_sensory.loc[lancaster_sensory['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_sensory = np.array(lancaster_sensory.loc[lancaster_sensory['Word'] == word2].drop('Word', axis=1).values[0])
        word1_lanc_sensorymotor = np.array(lancaster_norms.loc[lancaster_norms['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_sensorymotor = np.array(lancaster_norms.loc[lancaster_norms['Word'] == word2].drop('Word', axis=1).values[0])
        word1_lanc_visual = np.array(lancaster_visual.loc[lancaster_visual['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_visual = np.array(lancaster_visual.loc[lancaster_visual['Word'] == word2].drop('Word', axis=1).values[0])
        word1_lanc_reduced = np.array(lancaster_reduced.loc[lancaster_reduced['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_reduced = np.array(lancaster_reduced.loc[lancaster_reduced['Word'] == word2].drop('Word', axis=1).values[0])

        current_experiment.append({
            'word1': word1,
            'word2': word2,
            'POS': data.loc[index, 'POS'],
            'SimLex999': data.loc[index, 'SimLex999'],
            'conc_word1': data.loc[index, 'conc(w1)'],
            'conc_word2': data.loc[index, 'conc(w2)'],
            'concQ': data.loc[index, 'concQ'],
            'assoc_usf': data.loc[index, 'Assoc(USF)'],
            'SimAssoc333': data.loc[index, 'SimAssoc333'],
            'sd_simLex': data.loc[index, 'SD(SimLex)'],
            'stimulusID': data.loc[index, 'stimulusID'],
            'stim': data.loc[index, 'stimulus'],
            'lanc_motor_sim': distance.cosine(word1_lanc_motor, word2_lanc_motor).round(3),
            'lanc_sensory_sim': distance.cosine(word1_lanc_sensory, word2_lanc_sensory).round(3),
            'lanc_sensorymotor_sim': distance.cosine(word1_lanc_sensorymotor, word2_lanc_sensorymotor).round(3),
            'glove_sim': distance.cosine(glove[word1], glove[word2]).round(3),
            'lanc_visual_sim': abs(word1_lanc_visual - word2_lanc_visual)[0],
            'lanc_reduced_sim': distance.cosine(word1_lanc_reduced, word2_lanc_reduced).round(3),
            'attentionCheck': 0
        })
    random_indices = np.random.choice(experiment_indices, number_of_duplicate_pairs, replace=False)
    for index in random_indices:
        word = np.random.choice([data.loc[index, 'word1'], data.loc[index, 'word2']], 1)[0]
        random_stimulus_id = np.random.choice(range(1000, 2000), 1)[0]
        current_experiment.append({
            'word1': word,
            'word2': word,
            'POS': 'C',
            'SimLex999': data.loc[index, 'SimLex999'],
            'conc_word1': data.loc[index, 'conc(w1)'],
            'conc_word2': data.loc[index, 'conc(w2)'],
            'concQ': data.loc[index, 'concQ'],
            'assoc_usf': data.loc[index, 'Assoc(USF)'],
            'SimAssoc333': data.loc[index, 'SimAssoc333'],
            'sd_simLex': data.loc[index, 'SD(SimLex)'],
            'stimulusID': 1000 + random_stimulus_id,
            'stim': f'{word}/{word}',
            'lanc_motor_sim': distance.cosine(word1_lanc_motor, word2_lanc_motor).round(3),
            'lanc_sensory_sim': distance.cosine(word1_lanc_sensory, word2_lanc_sensory).round(3),
            'lanc_sensorymotor_sim': distance.cosine(word1_lanc_sensorymotor, word2_lanc_sensorymotor).round(3),
            'glove_sim': distance.cosine(glove[word1], glove[word2]).round(3),
            'lanc_visual_sim': abs(word1_lanc_visual - word2_lanc_visual)[0],
            'lanc_reduced_sim': distance.cosine(word1_lanc_reduced, word2_lanc_reduced).round(3),
            'attentionCheck': 1
        })
    random_indices = np.random.choice(experiment_indices, number_of_force_checks, replace=False)
    for index in random_indices:
        random_number = np.random.choice([1, 2, 3, 4, 5, 6], 1)[0]
        random_stimulus_id = np.random.choice(range(2001, 5000), 1)[0]
        current_experiment.append({
            'word1': 'force',
            'word2': 'check',
            'POS': 'C',
            'SimLex999': '1000',
            'conc_word1': '0',
            'conc_word2': '0',
            'concQ': '0',
            'assoc_usf': '0',
            'SimAssoc333': '0',
            'sd_simLex': '0',
            'stimulusID': 2000 + random_stimulus_id,
            'stim': f'Choose_{random_number}',
            'lanc_motor_sim': '0',
            'lanc_sensory_sim': '0',
            'lanc_sensorymotor_sim': '0',
            'glove_sim': '0',
            'attentionCheck': 2
        })
    experiment_word_pairs[f'List {i}'] = current_experiment
    print(i, len(current_experiment))
                
with open('C:\\Users\\HP\\Desktop\\SimLex_imagery\\datasets\\allTrials.js', 'w', encoding='utf-8') as f:
    f.write('var simLexData = ')
    f.write(str(experiment_word_pairs))
    f.write(';')
