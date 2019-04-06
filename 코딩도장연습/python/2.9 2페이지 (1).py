### Printing OXs ###
def printing_ox(x):
    for i in range(x):
        a = 'O'*(x-i-1)
        b='X'*(i+1)
        print(a + b)
printing_ox(6)

### 버전비교###
def compare_version(x,y):
    a = 0
    x_split = x.split('.')
    y_split = y.split('.')
    if len(x_split) == 2: x_split.append('0')
    if len(y_split) == 2: y_split.append('0')
    for i in range(3):
        if int(x_split[i]) > int(y_split[i]):
            print(x + '>' + y)
            a = 1
            return
        elif int(x_split[i]) < int(y_split[i]):
            print(x + '<' + y)
            a = 1
            return
        else: continue
    if a == 0: print('둘의 버전은 같습니다.')

compare_version('1.0.10','1.0.3')

### 1~1000에서 각 숫자의 개수 구하기 ###
a = []
b = []
for i in range(1,1001):
    for j in str(i):
        a.append(j)
# 개수 print하기
for i in range(0,10):
    print('{0}의 개수는 {1}개 입니다'.format(i,a.count(str(i))))


### 10~1000까지 각 숫자 분해하여 곱하기의 전체 합 구하기 ###
prod_list = []
composition_num_list = []
for i in range(10,1001):
    for j in str(i):
        composition_num_list.append(j)
    prod_list.append(eval('*'.join(composition_num_list)))
    composition_num_list = []
sum = 0
for i in prod_list:
    sum += i
print(sum)

### Dash Insert ###
def dash_insert(x):
    result = ''
    for i in range(len(x)):
        if int(x[i]) % 2 == 1 and int(x[i+1]) % 2 == 1:
            result += x[i] + '-'
        elif int(x[i]) % 2 == 0 and int(x[i+1]) % 2 == 0:
            result += x[i] + '*'
        else: result += x[i]
        if i+2 == len(x): break
    return result + x[len(x)-1]

dash_insert('4546793')
