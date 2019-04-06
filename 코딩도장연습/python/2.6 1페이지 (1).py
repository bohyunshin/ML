### multiples of 3 and 5 ###
result = 0
for i in range(1,1000):
    if i % 3 == 0 or i % 5 == 0:
        result += i
print(result)

### 탭을 공백 문자로 바꾸기 ###
#현재 디렉토리가 파일이 위치한 곳이라고 가정.
def tab_to_4_space(file_name):
    with open(file_name,"r") as f:
        lines = f.readlines()
    for i in range(len(lines)):
        lines[i] = lines[i].replace("\t"," "*4)
    with open(file_name,"w") as f:
        for i in range(len(lines)):
            f.write(lines[i])
#test
tab_to_4_space('text.txt')

### 게시판 페이징 ###
def totalpage(m,n):
    if n <=0:
        print("한페이지에 보여줄 게시물수는 1이상이어야 합니당")
        return
    if m % n == 0:
        return m//n
    if m % n !=0:
        return m//n + 1

### special sort ###
def special_sort(int_list):
    post_list = []
    neg_list = []
    zero_list = []
    for i in int_list:
        if i>0: post_list.append(i)
        elif i<0: neg_list.append(i)
        else: zero_list.append(i)
    return neg_list + zero_list + post_list
special_sort([-1,1,3,-2,2])


### the knights of the round table ###
#삼각형의 내접원 반지름 구하는 문제
#헤론의 공식을 써서 일반적인 삼각형의 넓이를 구한다.
import math
def get_radius(a,b,c):
    s = (a+b+c)/2 #삼각형의 반둘레
    area = math.sqrt(s*(s-a)*(s-b)*(s-c)) #헤론의 공식을 이용한 삼각형의 넓이
    radius = area * 2 / (a+b+c) #삼각형의 내접원의 반지름과 삼각형의 둘레의 길이의 관계를 이용하여 반지름 구함
    return round(radius,3)
get_radius(12,12,8)



