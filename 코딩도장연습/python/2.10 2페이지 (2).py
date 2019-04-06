### 완전수 구하기 ###
def perfect_num(x):
    print('{0}이하의 완전수를 리스트로 출력합니다.'.format(x))
    num_per_list = []
    for j in range(1,x+1):
        num_list = [i for i in range(1, j) if j % i == 0]
        a = 0
        for i in num_list: a += i
        if a == j: num_per_list.append(j)
    return num_per_list
perfect_num(28)

### special pythagorean triplet ###
def pytha(x):
    result = ()
    num_list_tuple = [(a,b,c) for a in range(1,500)
                                for b in range(1,500)
                                for c in range(1,500)
                                if a < b < c and a+b+c==1000]
    for a, b, c in num_list_tuple:
        if a**2 + b**2 == c**2 and a+b+c == 1000:
            result = (a,b,c)
            break
    return result
pytha(1000)

### even fibonacci numbers ###
fibo_list = [1,2]
while True:
    a = fibo_list[-2] + fibo_list[-1]
    if a > 4000000: break
    fibo_list.append(a)
fibo_list = [i for i in fibo_list if i % 2 == 0]
result = 0
for i in fibo_list: result += i
print(result)

### 100까지의 자연수의 합의 제곱과 제곱의 합의 차이 ###
def sum(x):
    result = 0
    for i in x: result += i
    return result
sum([i for i in range(1,101)])**2 - sum([i**2 for i in range(1,101)])

### 시저 암호 풀기 ###
import string
str_list = list(string.ascii_uppercase)
def cissor(x,n):
    text = x.upper()
    result = ''
    for i in text:
        result += str_list[str_list.index(i) + n]
    return result
cissor('CAt',5)

