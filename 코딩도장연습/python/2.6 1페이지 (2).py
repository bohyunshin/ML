### 메모리공간을 동적으로 사용하여 데이터 관리하기 ###
number = int(input("정수의 개수를 입력해주세요"))
sum = 0
for i in range(number):
    sum += int(input("enter num %d" % (i+1)))

print("sum: {0}".format(sum))
print("avg: {0}".format(sum/number))

### 3이 나타나는 시간을 전부 합하면? ###
result = 0
for hour in range(24):
    for minute in range(60):
        if '3' in str(hour) or '3' in str(minute): result += 60
print(result)

### CamelCase를 Pothole_case로 바꾸기 ###
def to_pothole(x):
    result = ''
    for i in x:
        if i.isupper(): i = '_' + i.lower()
        elif i.isdigit(): i = '_' + i
        result += i
    return result
to_pothole('numGoat30')

### Duplicate Numbers ###
def is_duplicate(x):
    return all([x.count(i) == 1 for i in '0123456789'])
is_duplicate('0123456789')

### 가성비 최대화 ###

def gasungbi(org_price,org_ability,add_price,add_ability):
    import itertools as iter
    max_gasungbi = []
    max_gasungbi_tuple = []
    for i in range(1,len(add_ability)+1):
        result1 = []
        result2 = []
        a = -1
        tup_price = list(iter.combinations(add_ability,i))
        for j in tup_price:
            b = 0
            for k in j: b += k
            result1.append(b)
        for h in result1:
            a += 1
            result2.append((org_ability+h)/(org_price+add_price*i))
        max_gasungbi.append(max(result2))
        max_gasungbi_tuple.append(tup_price[result2.index(max(result2))])
    final_result = int(max(max_gasungbi))
    final_tuple = max_gasungbi_tuple[max_gasungbi.index(max(max_gasungbi))]
    print("최고 가성비는 {0}이고 이때의 부품 조합은 {1}입니다.".format(final_result,final_tuple))
gasungbi(10,150,3,[30,70,15,40,65])



