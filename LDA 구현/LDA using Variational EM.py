#!/usr/bin/env python
# coding: utf-8

# In[164]:


import pandas as pd
import numpy as np
import timeit


# In[146]:


from math import exp
from scipy.special import gamma
from scipy.special import digamma
from math import log


# In[7]:


# define an empty list
noun_list = []

# open file and read the content in a list
with open('dat.txt', 'r') as filehandle:
    for line in filehandle:
        # remove linebreak which is the last character of the string
        currentPlace = line[:-1]

        # add item to the list
        noun_list.append(currentPlace)


# In[171]:


from sklearn.feature_extraction.text import CountVectorizer
cv = CountVectorizer(stop_words="english", max_features=1000)
transformed = cv.fit_transform(noun_list)


# # Latent Dirichlet Allocation in Python

# ## Variational EM
# E-Step: estimate gamma, phi in variational inference <br>
# M-Step: maximize log likelihood w.r.t. alpha and beta

# ### E-Step
# - initiate iteration with initial alpha, beta, gamma and phi
# - for fixed alpha and beta, iteratively update gamma and phi
# - phi corresponds to word probabilities matrix, beta
# - gamma corresponds to dirichlet parameter, alpha
# - E-step is taken by every document

# ### M-Step
# - Fixing the updated gamma and phi in E-Step, update alpha and beta
# - Do E-Step and M-Step until the lower bound converges
# - After finishing E-step for every document, M-step is invoked

# #### Clear the dimension of each parameter
# - K: number of topics (pre-determined before)
# - N: number of total words in 'one' document
# - V: number of unique words in 'one' document
# - alpha, gamma: 1 * K
# - phi: N * K 
# - beta: K * V ( topic index * unique words index )

# In[170]:


documents = [["Hadoop", "Big-Data", "HBase", "Java", "Spark", "Storm", "Cassandra"],
    ["NoSQL", "MongoDB", "Cassandra", "HBase", "Postgres"],
    ["Python", "scikit-learn", "scipy", "numpy", "statsmodels", "pandas"],
    ["R", "Python", "statistics", "regression", "probability"],
    ["machine learning", "regression", "decision trees", "libsvm"],
    ["Python", "R", "Java", "C++", "Haskell", "programming languages"],
    ["statistics", "probability", "mathematics", "theory"],
    ["machine learning", "scikit-learn", "Mahout", "neural networks"],
    ["neural networks", "deep-learning", "Big Data", "artificial-intelligence"],
    ["Hadoop", "Java", "MapReduce", "Big Data"],
    ["statistics", "R", "statsmodels"],
    ["C++", "deep-learning", "artificial-intelligence", "probability"],
    ["pandas", "R", "Python"],
    ["databases", "HBase", "Postgres", "MySQL", "MongoDB"],
    ["libsvm", "regression", "support-vector-machines"]]

noun_list = []

for i in range(len(documents)):
    noun_list.append(' '.join(documents[i]))


# In[147]:


# two lists
# 1) unique_words_for_all_docs: consists of all unique words (not index) of all docs from a corpus
# 2) seq_of_words_for_a_doc: consists of all unique words (not index) of nth doc

# the stopwords should be removed before making countvectorizer.
# input of LDA is countvectorizer object, which is  D * V matrix
# where D is the number of documents in a coupus and V is the total unique words.


'''
cv = CountVectorizer(stop_words="english", max_features=1000)
transformed = cv.fit_transform(noun_list)
cv.get_feature_names()
'''

def E_Step(K, alpha, beta, cv, transformed):
    
    # K: number of topics predetermined
    
    from scipy.special import digamma
    from scipy.special import polygamma
    from math import exp
    import numpy as np
    
    V = len(cv.get_feature_names())
    
    D = transformed.shape[0]
    
    # dictionary to put variational parameters in each document
    # the length of dictionary should be equal to D, the number of docs

    phi_corpus_dic = {}
    gamma_corpus_dic = {}
    
    for i in range(D):
        phi_corpus_dic[str(i)] = []
        
        gamma_corpus_dic[str(i)] = []
    
    
    # variational inference on each documnet
    # for each document, we will estimate variational patameters
    
    for d in range(D):
        
        # words list that appear in dth document
        seq_of_words_for_a_doc = [cv.get_feature_names()[i] for i in np.where(transformed.toarray()[d] != 0)[0].tolist()]
        # this returns which words consist of a document
        # for example, for first document, it returns
        # ['경기도', '이과인', '첼시', '콘테']
        # in paper, it corresponds to w_1, w_2, ... ,w_N before converting to unit vector
        
        N = len(seq_of_words_for_a_doc)
        # number of words in dth doc

        t = 0
        
        # initial value for each document
        phi_0 = np.full((N, K), 1/K)  # N * K dimension numpy array
        gamma_0 = alpha + N/K


        while True:
            t += 1
            phi_1 = np.copy(phi_0)
            gamma_1 = np.copy(gamma_0)

            for n in range(N):
                for i in range(K):
                    w_n = cv.get_feature_names().index(seq_of_words_for_a_doc[n])
                    # this returns the index of a word in the vocabulary
                    # for example, the word '경기도' in first document has index '46'
                    
                    # update phi for all n, i (dimension of phi is N * K)
                    phi_1[n,i] = beta[i, w_n] * exp(digamma(gamma_0[i]))
                    # this updates variational parameters phi

                # normalize phi to sum to 1
                phi_1[n,:] = phi_1[n,:] / sum(phi_1[n,:])

            # update gamma
            gamma_1 = alpha + np.sum(phi_1, axis=0)

            diff_phi = np.power(phi_1 - phi_0, np.full((N,K), 2))
            diff_gamma = np.power(gamma_1 - gamma_0, np.full(K, 2))

            if sum(sum(diff_phi)) < 1e-6 and sum(diff_gamma) < 1e-6: 
                break
            else:
                phi_0 = np.copy(phi_1)
                gamma_0 = np.copy(gamma_1)
                
        phi_corpus_dic[str(d)] = phi_1
        gamma_corpus_dic[str(d)] = gamma_1
            
    return phi_corpus_dic, gamma_corpus_dic


# In[148]:


def M_Step(phi_, gamma_, cv, transformed, K):
    
    '''
    The input phi_, gamma_ is dictionary whose lenghts are equal to number of documents in a corpus.
    To access a document in the corpus, phi_['1'] or gamma_['1'] is required because
    the keys of dictionary are consist of str(number)
    
    '''
    
    from scipy.special import digamma
    from scipy.special import polygamma
    from math import exp
    import numpy as np    
    
    
    M = transformed.shape[0]
    V = len(cv.get_feature_names())
    
    alpha_0 = np.full(K, 1/K)  # initial value with alpha
    beta_0  = np.full((K,V), 1/K)  # initial value with beta

    beta_1 = beta_0
    
    ####### beta estimation #######
    
        ####### beta estimation #######
    
    # object to restore value of beta in each iteration
    
    phi_ele = np.full(V,0)
    
    for i in range(K):
        for d in range(M):
            words_indx_per_doc = np.where(transformed.toarray()[d] != 0)[0].tolist()
            temp = beta_1[i,:]
            temp[words_indx_per_doc] = phi_[str(d)][:,i]
            beta_1[i,:] = beta_1[i,:] + temp
            
        # normalize beta to sum to 1
        # note that this normalization is done by summing by row
        # because the ith row of beta means that ith topic in total Kth topics
        beta_1[i,:] = beta_1[i,:] / sum(beta_1[i,:])        
            
    ####### alpha estimation through Newton Rapshon Method using Hessian matrix ####### 
    
    while True:
        
        h_vec = -M * polygamma(1, alpha_0) # K*1 Vector

        z = M * polygamma(1, sum(alpha_0))

        grad_vec = []
        
        # for grad_vec
        for i in range(K):
            # first term
            a = M * ( digamma(sum(alpha_0)) - digamma(alpha_0[i]) )

            # second term
            
            # the summation is over all docs, so for loop is initialized
            
            b = 0
            for d in range(M):
                b += digamma(gamma_[str(d)][i]) - digamma(sum(gamma_[str(d)]))

            grad_vec.append( a+b )

        grad_vec = np.asarray(grad_vec)

        c = sum(grad_vec / h_vec) / (1/z + sum(1/h_vec))

        update_vec = (grad_vec - c) / h_vec
        
        alpha_1 = alpha_0 - update_vec
        
        if sum(np.power(alpha_1 - alpha_0, np.full(K,2))) < 1e-6:
            break
        else:
            alpha_0 = alpha_1
            
    return beta_1, alpha_1


# In[149]:


def ELBO(phi_, gamma_, alpha, beta, cv, transformed,K):
    
    from scipy.special import gamma
    from scipy.special import digamma
    from math import log
    
    ### phi and gamma are dicionary which contain estimation of variational parameters in ecah document
    M = transformed.shape[0]
    V = len(cv.get_feature_names())
    
    log_likelihood_0 = 0
    second = 0
    third = 0
    
    for d in range(M):
        # words list that appear in dth document
        seq_of_words_for_a_doc = [cv.get_feature_names()[i] for i in np.where(transformed.toarray()[d] != 0)[0].tolist()]
        N = len(seq_of_words_for_a_doc)
        
        # first term
        first = log(gamma(sum(alpha))) - sum(np.log(gamma(alpha))) + sum( (alpha-1) *         (digamma(gamma_[str(d)]) - digamma(sum(gamma_[str(d)]))) )

        # second term
        for n in range(N):
            second += sum( phi_[str(d)][n,] * (digamma(gamma_[str(d)]) - digamma(sum(gamma_[str(d)]))) )
            
        # third term
        for i in range(K):
            words_indx_per_doc = np.where(transformed.toarray()[d] != 0)[0].tolist()
            third += sum( phi_[str(d)][:,i] * np.log(beta[i,words_indx_per_doc]) )

        fourth = -log(gamma(sum(gamma_[str(d)]))) + sum(np.log(gamma(gamma_[str(d)]))) -                 sum( (gamma_[str(d)]-1) * (digamma(gamma_[str(d)]) - digamma(sum(gamma_[str(d)]))) )

        fifth = sum( sum(-phi_[str(d)] * np.log(phi_[str(d)])) )

        log_likelihood_0 = log_likelihood_0 + first + second + third + fourth + fifth
        
    return log_likelihood_0


# In[150]:


len(cv.get_feature_names())


# In[172]:


a = 0
while True:
    start = timeit.default_timer()
    a += 1
    if a % 50: print('{0}번째 iteration'.format(a))
    if a == 1: 
        E_result = E_Step(K=5, alpha = np.full(5,1/5), beta = np.full((5, 851), 1/5), cv=cv, transformed=transformed)
        M_result = M_Step(phi_=E_result[0], gamma_=E_result[1], cv=cv, transformed=transformed, K=5)
        log_L_0 = ELBO(phi_=E_result[0], gamma_=E_result[1], alpha=M_result[1], beta=M_result[0], cv=cv, transformed=transformed, K=5)
        continue
        
    else:
        E_result = E_Step(K=5, alpha = M_result[1], beta = M_result[0], cv=cv, transformed=transformed)
        M_result = M_Step(phi_=E_result[0], gamma_=E_result[1], cv=cv, transformed=transformed, K=5)
        log_L_1 = ELBO(phi_=E_result[0], gamma_=E_result[1], alpha=M_result[1], beta=M_result[0], cv=cv, transformed=transformed, K=5)
    
    if (log_L_1 - log_L_0)**2 < 1e-6: break
    else: 
        log_L_0 = log_L_1
        print(log_L_0)
        stop = timeit.default_timer()
        print('Time: ', stop - start)


# In[ ]:




