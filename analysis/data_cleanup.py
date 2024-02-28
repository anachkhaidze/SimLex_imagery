import os
import json
import pandas as pd

path = 'D:\\kiyonaga\\SimLex_imagery\\data'
combine_data = []
for file in os.listdir(path):
    with open(os.path.join(path, file), 'r') as f:
        data = json.load(f)
        combine_data.extend(data['filedata'][:-1])
df = pd.DataFrame(combine_data)
df['attention_accuracy'] = pd.NA
df['stim'] = df['stim'].str.replace('Choose_', '')

df.loc[(df['attentioncheck'] == '1') & (df['value'] != '6'), 'attention_accuracy'] = 0
df.loc[(df['attentioncheck'] == '1') & (df['value'] == '6'), 'attention_accuracy'] = 1

df.loc[(df['attentioncheck'] == '2') & (df['value'] != df['stim']), 'attention_accuracy'] = 0
df.loc[(df['attentioncheck'] == '2') & (df['value'] == df['stim']), 'attention_accuracy'] = 1
df.fillna(-1, inplace=True)

df.to_csv('D:\\kiyonaga\\SimLex_imagery\\user_consolidated.csv', index=False)