#!/usr/bin/env python
# coding: utf-8

# In[14]:


import os
import json


# ### LIST OF ABI REFERENCES -- REMOVE MIGRATIONS

# In[59]:


path = '/home/wickstjo/coding/ethereum/oracle-manager/build/contracts/'


# In[60]:


files = os.listdir(path)


# In[61]:


files.remove('Migrations.json')


# ### CREATE UNITED ABI FILE

# In[53]:


latest = {}


# In[54]:


def load_json(path):
    with open(path) as json_file:
        return json.load(json_file)


# In[55]:


for file in files:
    
    # CREATE NEW HEADER & EXTRACT JSON CONTENT
    header = file[0:-5].lower()
    content = load_json(path + file)
    
    # NETWORK LIST
    network_list = list(content['networks'].keys())
    
    # IF THE CONTRACT DOES NOT HAVE AN ADDRESS
    if len(network_list) == 0:
        address = 'undefined'
    
    # IF IT DOES, EXTRACT IT
    else:
        address = content['networks'][network_list[0]]['address']
    
    # PUSH TO CONTAINER
    latest[header] = {
        'address': address,
        'abi': content['abi'] 
    }


# ### DISTRIBUTE THE FILE TO OTHER REPOS

# In[56]:


def save_json(data, path):
    with open(path, 'w') as outfile:
        json.dump(data, outfile)


# In[57]:


repos = [
    '/home/wickstjo/coding/python/iot-manager/config/',
    '/home/wickstjo/coding/react/new-thesis/src/resources/'
]


# In[58]:


for repo in repos:
    save_json(latest, repo + 'latest.json')


# In[ ]:




