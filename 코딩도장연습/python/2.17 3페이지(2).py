### 자리수 출력하기 ###
def myfunc(x):
    return print('{0}자리수입니다'.format(len(str(x))))

### 공백을 제외한 글자수 세기 ###
def count_num(x):
    a = x.split()
    result = ''
    for i in a: result += i
    return len(result)
count_num('''공백을 제외한
글자수만을 세는 코드 테스트''')

### 자신을 제외한 곱셈 ###
def multi(list):
    result = []
    a = 1
    for i in list:
        temp = [j for j in list if j not in [i]]
        for k in temp: a *= k
        result.append(a)
        a = 1
    return result
multi([2,6,4,7])

### 농장 분할 ###
from math import gcd
def division_farm(n,m):
    print(n * m // gcd(m,n)**2)
division_farm(1980,640)

### 문자에 해당하는 아스키코드를 알아내는 코드 ###
def asci():
    a = input('아스키코드를 알고 싶은 알파벳을 입력하세요')
    print('{0}는 아스키코드로 {1}입니다'.format(a,ord(a)))
asci()
