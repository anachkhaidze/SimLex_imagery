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

simLex1 = pd.read_csv('D:\kiyonaga\SimLex_imagery\SimLex_dataset\simLex_list1.csv')
simLex2 = pd.read_csv('D:\kiyonaga\SimLex_imagery\SimLex_dataset\simLex_list2.csv')
lancaster_norms = pd.read_csv('D:\kiyonaga\SimLex_imagery\SimLex_dataset\lancaster_norms.csv')

data = pd.concat([simLex1, simLex2], axis=0)
data = data.reset_index(drop=True)

lancaster_norms['Word'] = lancaster_norms['Word'].str.lower()
sensory_columns = ['Word', 'Auditory.mean', 'Gustatory.mean', 'Haptic.mean','Interoceptive.mean', 'Olfactory.mean', 'Visual.mean']
motor_columns = ['Word', 'Foot_leg.mean', 'Hand_arm.mean', 'Head.mean', 'Mouth.mean', 'Torso.mean']
combined = list(set(sensory_columns + motor_columns))

lancaster_motor = lancaster_norms[motor_columns]
lancaster_sensory = lancaster_norms[sensory_columns]
lancaster_norms = lancaster_norms[combined]

nouns = data[data['POS'] == 'N'].index
adjs = data[data['POS'] == 'A'].index
verbs = data[data['POS'] == 'V'].index

np.random.seed(0)
nouns_indices = np.random.choice(nouns, 666, replace=False)
adjs_indices = np.random.choice(adjs, 111, replace=False)
verbs_indices = np.random.choice(verbs, 222, replace=False)

# ignoring total of 9 words (what do we do with them?)
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
for i in range(11):
    current_experiment = []
    for index in samples_sets[i]:
        word1 = data.loc[index, 'word1']
        word2 = data.loc[index, 'word2']
        word1_lanc_motor = np.array(lancaster_motor.loc[lancaster_motor['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_motor = np.array(lancaster_motor.loc[lancaster_motor['Word'] == word2].drop('Word', axis=1).values[0])
        word1_lanc_sensory = np.array(lancaster_sensory.loc[lancaster_sensory['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_sensory = np.array(lancaster_sensory.loc[lancaster_sensory['Word'] == word2].drop('Word', axis=1).values[0])
        word1_lanc_sensorymotor = np.array(lancaster_norms.loc[lancaster_norms['Word'] == word1].drop('Word', axis=1).values[0])
        word2_lanc_sensorymotor = np.array(lancaster_norms.loc[lancaster_norms['Word'] == word2].drop('Word', axis=1).values[0])
        
        current_experiment.append({
            'word1': word1,
            'word2': word2,
            'POS': data.loc[index, 'POS'],
            'SimLex999': data.loc[index, 'SimLex999'],
            'conc_word1': data.loc[index, 'conc_word1'],
            'conc_word2': data.loc[index, 'conc_word2'],
            'concQ': data.loc[index, 'concQ'],
            'assoc_usf': data.loc[index, 'assoc_usf'],
            'SimAssoc333': data.loc[index, 'SimAssoc333'],
            'sd_simLex': data.loc[index, 'sd_simLex'],
            'stimulusID': data.loc[index, 'stimulusID'],
            'stim': data.loc[index, 'stim'],
            'lanc_motor_sim': distance.cosine(word1_lanc_motor, word2_lanc_motor).round(3),
            'lanc_sensory_sim': distance.cosine(word1_lanc_sensory, word2_lanc_sensory).round(3),
            'lanc_sensorymotor_sim': distance.cosine(word1_lanc_sensorymotor, word2_lanc_sensorymotor).round(3),
            'glove_sim': distance.cosine(glove[word1], glove[word2]).round(3),
            'attentionCheck': 0
        })
    experiment_word_pairs[f'List {i}'] = current_experiment

for i in range(11):
    indices = samples_sets[i]
    random_indices = np.random.choice(indices, 10, replace=False)
    for index in random_indices:
        word = np.random.choice([data.loc[index, 'word1'], data.loc[index, 'word2']], 1)[0]
        experiment_word_pairs[f'List {i}'].append({
            'word1': word,
            'word2': word,
            'stimulusID': data.loc[index, 'stimulusID'],
            'attentionCheck': '1',
            'POS': '',
            'SimLex999': '',
            'conc_word1': '',
            'conc_word2': '',
            'concQ': '',
            'assoc_usf': '',
            'SimAssoc333': '',
            'sd_simLex': '',
            'stimulusID': '',
            'stim': '',
            'lanc_motor_sim': '',
            'lanc_sensory_sim': '',
            'lanc_sensorymotor_sim': '',
            'glove_sim': ''
        })

with open('D:\\kiyonaga\\SimLex_imagery\\SimLex_dataset\\allTrials.js', 'w', encoding='utf-8') as f:
    f.write('var simLexData = ')
    f.write(str(experiment_word_pairs))

