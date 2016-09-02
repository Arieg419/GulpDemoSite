import sys
from subprocess import Popen, PIPE
from datetime import datetime

def add_search(log):
    return 0

def num_of_searches():
    count=0
    with open("send.txt", 'r') as f:
        for line in f:
            if '***' in line:
                count=count+1
    return count

def get_searches():
    dict=[]
    count=1
    dict.append([])
    with open("send.txt",'r') as f:
        for line in f:
            if '***' in line:
                if count == num_of_searches():
                    break
                dict.append([])
                count=count+1
            else:
                dict[count-1].append(line)
    return dict

def showlog():
    count=0
    print count
    print '\n'
    count=count+1
    with open("send.txt",'r') as f:
        for line in f:
            if '***' in line:
                if count==num_of_searches()-1:
                    break
                print count
                print '\n'
                count = count + 1
            else:
                if "Link" in line:
                    continue
                print line
    return 0

def add_args():
    log=open("helpful-searches",'w')
    if sys.argv[2]=='all':
        nums=range(num_of_searches())
    else:
        nums=sys.argv[2:]
    searches=get_searches()
    for num in nums:
        log.write('************************\n')
        for line in searches[int(num)]:
            if "Link" in line:
                continue
            log.write(line)
    log.close()
    Popen('git add '+"helpful-searches",shell=True)

    return 0


def get_changes():
    changes=[]
    line_needed=False
    with open("efratCode.log", 'r') as f:
        for line in f:
            if line_needed:
                line_needed = False
                sides=line.split(";")
                dt=sides[1].split()
                date=dt[0].split("-")
                time=dt[1].split(":")
                changes.append([sides[0].split("+")[0].split("-")[0].split("\t")[0],sides[0].split("+")[-1].split("-")[-1].split("\t")[-1],datetime(int(date[-1]),int(date[-2]),int(date[-3]),int(time[0]),int(time[1]),int(time[2].split("<")[0]))])
            if "<hr>/*<br />" in line:
                line_needed=True
    return changes


def getDatasearch(searches):
    searches_data = []
    for search in searches:
        time=search[-2].split()[4].split(":")
        searches_data.append([search[:-3],datetime(2016,9,2,int(time[0]),int(time[1]),int(time[2]))])
    return searches_data

def get_order(changes,searches):
    print changes
    order=[]
    counter_changes=0
    s=[]

    for search in searches:
        if counter_changes== len(changes):
            break
        if search[1] > changes[counter_changes][2]:
            order.append({'line' :changes[counter_changes][0], 'searches':s })
            counter_changes = counter_changes + 1
            s=[]
        else:
            s.append(search)
    print order
    return order




def diff():
    changes=get_changes()
    searches = getDatasearch(get_searches())
    order= get_order(changes,searches)
    order=sorted(order, key= lambda k:k['line'])
    with open(sys.argv[2],'r') as f:
        lines=f.readlines()
        print lines
        for ord in reversed(order) :
            lines.insert(int(ord['line'])-1,ord['searches'])
        print lines
    for line in lines:
        f.write(line)
    print order
    return 0

def main():
    if sys.argv[1]=="status":
        showlog()

    if sys.argv[1]=="add":
        add_args()


if __name__ == "__main__":
    main()
