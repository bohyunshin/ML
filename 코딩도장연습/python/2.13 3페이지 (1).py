### 2진법으로 자연수 나타내기 ###
def to_2_digit(x):
    r = 0
    q = 0
    result = ''
    while True:
        r = x % 2
        q = x // 2
        if r == 1: result = '1' + result
        else: result = '0' + result
        if q == 1:
            result = '1' + result
            return result
            break
        x = q
to_2_digit(73)

a = int(input())
b = []
while a:
    b.append(a%2)
    a = int(a/2)
b.reverse()
b = [str(x) for x in b]
''.join(b)

### palindrome ###
num_list = [(a,b) for a in range(100,1000) for b in range(100,1000) if a<=b]
prod_list = [a*b for a,b in num_list]
palin_list = [i for i in prod_list if str(i) == str(i)[::-1]]
palin_list[palin_list.index(max(palin_list))]

### 이차방정식###
def equal(a,b,c):
    if b**2 - 4*a*c <0:
        print("해가 없습니다.")
        return
    import math
    x1 = round((-b+math.sqrt(b**2 - 4*a*c))/(2*a))
    x2 = round((-b-math.sqrt(b**2 - 4*a*c))/(2*a))
    if b**2 - 4*a*c == 0:
        print("해는 {0}으로 중근입니다.".format(x1))
    if b**2 - 4*a*c >0:
        print("해는 {0} 또는 {1} 입니다.".format(x1,x2))

### 1부터 20사이의 어떤 수로도 나누어 떨어지는 가장 작은 수 ###
from functools import reduce
def gcd(a, b):
    if a < b: a, b = b, a
    while b: a, b = b, a % b
    return a
def lcm_range(a, b): return reduce(lambda x, y: x*y/gcd(x, y), range(a, b+1))
print(lcm_range(1, 20))

### 어느 숫자가 중간값? ###
def median(a,b,c):
    list_num = [a,b,c]
    list_num.sort()
    return list_num[1]



