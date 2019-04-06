### 구글 입사문제 중에서 ###
sum([str(i).count('8') for i in range(1,10001)])

### Primary Arithmetic ###
def carry_op(x,y):
    x = str(x)
    y = str(y)
    if len(x) > len(y): y = '0'*(len(x)-len(y))+y
    elif len(y) > len(x): x =  '0'*(len(y)-len(x))+x
    a= 0
    carry = 0
    for i in range(1,len(x)+1):
        if a + int(x[len(x)-i]) + int(y[len(y)-i]) >=10:
            a = 1
            carry += 1
        else: a = 0
    return print('{0} carry operations.'.format(carry))
carry_op(9999999,1)

### 리스트 회전 ###
def tornado(x):
    a = x[0]
    del x[0]
    if a>0:  return x[::-1][:a][::-1] + x[::-1][a:][::-1]
    elif a<0: return x[abs(a):] + x[:abs(a)]
    else: return x
tornado([-2,'a','b','c','d','e','f','g'])

### 파일 찾기 ###
import os
for root, dirs, files in os.walk('./'):
    for file in files:
        if '.txt' in file:
            with open(os.path.join(root,file),'r') as f:
                text = f.read()
                if "Life Is Too Short" in text: print(file)


### 다음 입사문제 중에서 ###

def min_distance(x):
    import itertools
    pairs_tuple = list(itertools.combinations(x,2))
    distance_list = []
    for i in pairs_tuple: distance_list.append(abs(i[0]-i[1]))
    return pairs_tuple[distance_list.index(min(distance_list))]
min_distance([1,3,4,8,13,17,20])
