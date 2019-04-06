### 삼각형 구별하기 ###
def triangle(list):
    if len(list) != 3: return print('3개의 각을 입력하세요')
    if list[0] == 0 or list[1] == 0 or list[2] == 0: return print('0보다 큰 각을 입력하세요')
    sum = 0
    for i in list: sum+= i
    if sum != 180: return print('세 각의 합은 180도이어야 합니다.')
    list.sort()
    if list[0] <90 and list[1] <90 and list[2] <90: return print('예각삼각형')
    elif list[1] == 90: return print('직각삼각형')
    elif list[2] > 90: return print('둔각삼각형')
triangle([60,701,1,1,1])

### 각 자리수의 합을 구할 수 있나요? ###
def myfunc(x):
    a = '.'.join(str(x)).split('.')
    return sum([int(i) for i in a])

print(eval('+'.join(input())))

### MVP를 찾아라 ###
a = '''1/6/3
5/6/2
5/1/4
6/3/2
4/5/7
4/3/2
1/4/6
5/1/4
6/4/1
4/5/1'''
b = ['Q','P','Q','O','P','T','Q','D','Q','Q']
c = ['W','W','W','W','W','L','L','L','L','L']
def mvp(kda,kill,victory):
    player = ['a1','a2','a3','a4','a5','b1','b2','b3','b4','b5']
    kda_list = kda.split('\n')
    list = []
    for i in kda_list:
        list.append(i.split('/'))
    mvp_score = []
    for i in list: mvp_score.append((int(i[0])*2+int(i[2]))/int(i[1]))
    dict_kill = {'P': 5, 'Q': 4, 'T': 3, 'D': 2, 'O': 1}
    kill_score = [dict_kill[k] for k in kill]
    dict_gameresult = {'W' : 1, 'L' : 0}
    vict_score = [dict_gameresult[k] for k in victory]
    final_score = mvp_score + kill_score + vict_score
    return player[final_score.index(max(final_score))]
mvp(a,b,c)

### 넥슨 입사문제 중에서 ###
def d(n):
    return eval('+'.join(str(n))) + n
a = [d(i) for i in range(1,5001)]
b = [i for i in range(1,5001) if i not in a]
sum(b)