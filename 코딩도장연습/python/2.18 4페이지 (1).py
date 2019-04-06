### 문자열을 제거한 뒤 숫자만 반환 ###
def myfunc(x):
    a = [i for i in x if i.isnumeric()]
    return ''.join(a)
myfunc('1w627r00o00p00')

### 숫자를 입력 받으면 그에 맞는 자릿수 출력
a = input('숫자를 입력하세영')
print('{0}의 자리수'.format(10**(len(a)-1)))

### 평균 구하기 ###
def avg(list):
    a = 0
    for i in list: a += i
    return a/len(list)
avg([26,33,45,51,60])

### 중앙값 구하기 ###
def median(list):
    if len(list) % 2 == 1: return list[len(list) // 2]
    else: return (list[int(len(list)/2 -1)] + list[int(len(list)/2)])/2
median([24,31,35,49])

### 홀수와 짝수의 개수 구하기 ###
def odd_even(list):
    even = len([i for i in list if i%2 == 0])
    odd = len([i for i in list if i%2 == 1])
    print('홀수 {0}개, 짝수 {1}개'.format(odd,even))
odd_even([3,4,5,6,7])